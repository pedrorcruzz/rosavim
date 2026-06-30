--- RosaAI cli - Open, manage and message the AI CLI terminals
--- Each tool owns one persistent terminal buffer + job; toggling only hides
--- or shows the window. The same shared window slot renders whichever tool
--- is currently active.
local M = {}

local api = vim.api
local fn = vim.fn
local tools = require 'rosavim.rosa_plugins.rosaai.tools'
local state = require 'rosavim.rosa_plugins.rosaai.state'
local layout = require 'rosavim.rosa_plugins.rosaai.layout'
local bar = require 'rosavim.rosa_plugins.rosaai.bar'
local themes = require 'rosavim.rosa_plugins.rosaai.themes'

local chip_win = nil
local chip_buf = nil

local function win_open()
  return state.win and api.nvim_win_is_valid(state.win)
end

local function chip_open()
  return chip_win and api.nvim_win_is_valid(chip_win)
end

local function close_chip()
  if chip_open() then
    pcall(api.nvim_win_close, chip_win, true)
  end
  chip_win = nil
end

--- Render or move the chip overlay on top of a floating CLI window
local function open_chip(parent_win, tool_name)
  if not parent_win or not api.nvim_win_is_valid(parent_win) then
    return
  end
  local cfg = api.nvim_win_get_config(parent_win)
  if not bar.chip_enabled() then
    close_chip()
    return
  end

  local theme = themes.current()
  local chip_border = layout.chip_border()
  local has_border = chip_border ~= 'none'
  local content_h = theme.layout == 'stem' and 2 or 1
  local rows_above = has_border and (content_h + 1) or content_h

  local width, col
  -- Petal renders as a borderless full-width banner (matches garland's
  -- horizontal layout, just without the box). Other inline themes (bloom)
  -- stay as compact centered chips.
  if theme.layout == 'banner' or theme.layout == 'stem' or theme.name == 'petal' then
    width = cfg.width
    col = cfg.col
  else
    width = vim.api.nvim_strwidth(bar.chip_plain(nil, tool_name))
    col = cfg.col + math.floor((cfg.width - width) / 2)
  end
  -- Engraved: bordered chip's bottom border lands on float's top border
  local row = math.max(0, cfg.row - rows_above)

  if not chip_buf or not api.nvim_buf_is_valid(chip_buf) then
    chip_buf = api.nvim_create_buf(false, true)
    vim.bo[chip_buf].bufhidden = 'hide'
  end
  bar.write_chip_buf(chip_buf, width, tool_name)

  if chip_open() then
    pcall(api.nvim_win_close, chip_win, true)
  end
  chip_win = api.nvim_open_win(chip_buf, false, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = content_h,
    style = 'minimal',
    border = chip_border,
    focusable = false,
    zindex = 60,
  })
  vim.wo[chip_win].winhl = 'Normal:Normal,FloatBorder:FloatBorder'
  vim.wo[chip_win].winbar = ''
end

--- Esc-hint winbar — renders inside the bordered window at the top.
--- The chip is always rendered as a separate overlay on top of the border,
--- so the winbar only carries the hint.
local function set_winbar(parent_win)
  if not parent_win or not api.nvim_win_is_valid(parent_win) then
    return
  end
  vim.wo[parent_win].winbar = bar.esc_hint()
end

--- Ensure a session exists for `name`; create buffer and start the CLI job
local function ensure_session(name)
  local tool = tools.get(name)
  if not tool then
    return nil, ('Unknown CLI tool: ' .. tostring(name))
  end
  if not tools.is_available(tool) then
    return nil, ('CLI binary not found in $PATH: ' .. tool.binary)
  end

  local s = state.get(name)
  if s and s.buf and api.nvim_buf_is_valid(s.buf) then
    return s
  end

  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].filetype = 'rosaai'
  vim.b[buf].rosaai_cli = name

  s = { tool = tool, buf = buf, job = nil, started = false }
  state.set(name, s)
  return s
end

local function start_job(s)
  if s.started then
    return
  end
  local cmd = s.tool.cmd
  api.nvim_buf_call(s.buf, function()
    s.job = fn.termopen(cmd, {
      on_exit = function()
        vim.schedule(function()
          state.remove(s.tool.name)
          if state.active == s.tool.name then
            M.hide()
          end
        end)
      end,
    })
  end)
  s.started = true
end

local function refresh_chip()
  if state.active and chip_open() then
    open_chip(state.win, state.active)
  end
end

--- Live-resize the active CLI float by a width/height delta and persist the
--- new size as a per-position override (so it survives hide/show/relayout).
--- Geometry is recomputed through layout so the float stays pinned to its
--- edge (or centered, for float) instead of drifting.
local function resize_active(d_w, d_h)
  if not win_open() then
    return false
  end
  local cfg = api.nvim_win_get_config(state.win)
  if not cfg.relative or cfg.relative == '' then
    return false
  end
  local cols = vim.o.columns
  local lines = vim.o.lines - vim.o.cmdheight - 1
  local new_w = math.max(20, math.min(cols - 2, cfg.width + d_w))
  local new_h = math.max(4, math.min(lines - 2, cfg.height + d_h))
  if new_w == cfg.width and new_h == cfg.height then
    return false
  end
  layout.set_override(layout.current_position(), new_w, new_h)
  local geom = layout.compute_geom()
  pcall(api.nvim_win_set_config, state.win, geom)
  refresh_chip()
  return true
end

--- Resize the active CLI float in an arrow direction, honoring the current
--- layout: vertical (right/left) → width, horizontal (bottom) → height,
--- float → both axes (kept centered). Returns true when it handled the
--- resize, so smart-splits can fall through to native splits otherwise.
function M.resize_arrow(dir)
  if not win_open() then
    return false
  end
  local pos = layout.current_position()
  if pos == 'right' then
    if dir == 'left' then
      return resize_active(1, 0)
    elseif dir == 'right' then
      return resize_active(-1, 0)
    end
  elseif pos == 'left' then
    if dir == 'right' then
      return resize_active(1, 0)
    elseif dir == 'left' then
      return resize_active(-1, 0)
    end
  elseif pos == 'bottom' then
    if dir == 'up' then
      return resize_active(0, 1)
    elseif dir == 'down' then
      return resize_active(0, -1)
    end
  elseif pos == 'float' then
    if dir == 'left' then
      return resize_active(-2, 0)
    elseif dir == 'right' then
      return resize_active(2, 0)
    elseif dir == 'up' then
      return resize_active(0, 1)
    elseif dir == 'down' then
      return resize_active(0, -1)
    end
  end
  return false
end

--- Show a CLI tool's terminal in the shared window. With no name,
--- re-shows the last active session (or the first available tool).
function M.show(name)
  if not name then
    name = state.active
  end
  if not name then
    local avail = tools.available()
    name = avail[1] and avail[1].name
  end
  if not name then
    vim.notify('RosaAI: no CLI tools installed', vim.log.levels.WARN)
    return
  end

  local s, err = ensure_session(name)
  if not s then
    vim.notify(err or 'RosaAI: failed to open session', vim.log.levels.ERROR)
    return
  end

  local prev = state.win
  local win, kind = layout.open(s.buf, prev)
  state.win = win
  state.active = name

  if not s.started then
    start_job(s)
  end

  set_winbar(win)
  open_chip(win, name)
  bar.attach(win, s.buf, refresh_chip)

  if bar.autoinsert_enabled() then
    vim.cmd 'startinsert'
  end
end

--- Hide the active CLI window without killing the job (state.active is
--- preserved so the next bare M.show() can restore the same session).
function M.hide()
  close_chip()
  if win_open() then
    bar.detach(state.win)
    pcall(api.nvim_win_close, state.win, true)
  end
  state.win = nil
end

--- Toggle the named CLI (or the most recent one if no name given)
function M.toggle(name)
  name = name or state.active
  if not name then
    -- Pick the first available tool when nothing has been opened yet
    local avail = tools.available()
    if #avail == 0 then
      vim.notify('RosaAI: no CLI tools installed', vim.log.levels.WARN)
      return
    end
    name = avail[1].name
  end

  if state.active == name and win_open() then
    M.hide()
    return
  end
  M.show(name)
end

--- Small popup that asks which layout to open the CLI in.
--- Pressing v/h/f resolves the position; <Esc>/q cancels.
local function show_layout_picker(on_pick)
  -- The picker is reachable from the ask prompt where the user was in
  -- insert mode — force normal mode so v/h/f land as commands.
  vim.cmd 'stopinsert'
  local text = ' [v] vertical  [h] horizontal  [f] float '
  local width = vim.api.nvim_strwidth(text)
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'

  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - 3) / 2) - 1,
    col = math.floor((vim.o.columns - width - 2) / 2),
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    title = '   RosaAI Layout ',
    title_pos = 'center',
  })

  local function close()
    if api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
  end

  local function pick(pos)
    close()
    on_pick(pos)
  end

  local kopts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set('n', 'v', function()
    -- vertical = whichever vertical position is currently configured (right/left)
    local cur = require('rosavim.rosa_plugins.rosaai.layout').current_position()
    pick(cur == 'left' and 'left' or 'right')
  end, kopts)
  vim.keymap.set('n', 'h', function()
    pick 'bottom'
  end, kopts)
  vim.keymap.set('n', 'f', function()
    pick 'float'
  end, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)
  vim.keymap.set('n', 'q', close, kopts)
end

--- Pick a CLI via vim.ui.select (matches the `<leader>as` flow).
--- `items` is an array of { name = string, tool = table }.
--- No `stopinsert` here — the picker's input field should open in insert
--- mode so the user can type to filter. The layout picker is different;
--- it needs normal mode for its single-letter keymaps (v/h/f).
local function pick_cli(items, on_pick)
  table.sort(items, function(a, b)
    return a.name < b.name
  end)
  vim.ui.select(items, {
    prompt = 'RosaAI · select CLI',
    format_item = function(it)
      return it.tool.icon .. ' ' .. it.tool.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    on_pick(choice.name)
  end)
end

--- Route a prepared ask message to the right CLI:
---  - 0 alive sessions → pick CLI (if multiple installed), pick layout, send
---  - 1 alive session  → send straight to it (no picker)
---  - 2+ alive         → pick CLI from alive ones, send
--- `opts.submit = false` defers the CR so the user can edit the message in
--- the CLI before submitting (used by the multiline preview prompt).
local function route_ask(msg, opts)
  opts = opts or {}
  local submit = opts.submit
  local alive = state.alive()
  local count, only_name = 0, nil
  for name, _ in pairs(alive) do
    count = count + 1
    only_name = name
  end

  local function send_to(name)
    M.send { msg = msg, focus = true, submit = submit, tool = name }
  end

  if count == 0 then
    local avail = tools.available()
    if #avail == 0 then
      vim.notify('RosaAI: no CLI tools installed', vim.log.levels.WARN)
      return
    end
    local function pick_layout(name)
      show_layout_picker(function(pos)
        if not pos then
          return
        end
        require('rosavim.config.toggles').set('rosaai_position', pos)
        send_to(name)
      end)
    end
    if #avail == 1 then
      pick_layout(avail[1].name)
    else
      local items = {}
      for _, t in ipairs(avail) do
        table.insert(items, { name = t.name, tool = t })
      end
      pick_cli(items, pick_layout)
    end
  elseif count == 1 then
    send_to(only_name)
  else
    local items = {}
    for name, s in pairs(alive) do
      table.insert(items, { name = name, tool = s.tool })
    end
    pick_cli(items, send_to)
  end
end

--- Smart toggle:
--- - open + matches + focused → hide
--- - open + matches + not focused → focus it (saves a leaderm trip)
--- - never opened any CLI before → show layout picker, then show
--- - otherwise → reuse the last saved position (no picker)
function M.toggle_with_picker(tool_name)
  if win_open() and (not tool_name or state.active == tool_name) then
    if api.nvim_get_current_win() == state.win then
      M.hide()
    else
      M.focus()
    end
    return
  end
  -- Skip the picker once any session has ever been created.
  if next(state.sessions) ~= nil then
    M.show(tool_name)
    return
  end
  show_layout_picker(function(pos)
    if not pos then
      return
    end
    require('rosavim.config.toggles').set('rosaai_position', pos)
    M.show(tool_name)
  end)
end

--- Open (or hide) the CLI in a specific layout. Pressing the same direct
--- key while the CLI is already in that layout hides it (toggle).
--- Pressing a different direct key while open switches to the new layout.
function M.show_in(position, tool_name)
  local toggles = require 'rosavim.config.toggles'
  local current = toggles.get 'rosaai_position'
  if win_open() and current == position and (not tool_name or state.active == tool_name) then
    M.hide()
    return
  end
  toggles.set('rosaai_position', position)
  M.show(tool_name)
end

--- Focus the active CLI window (re-show it if hidden)
function M.focus()
  if state.active and win_open() then
    api.nvim_set_current_win(state.win)
    if bar.autoinsert_enabled() then
      vim.cmd 'startinsert'
    end
    return
  end
  if state.active then
    M.show(state.active)
  else
    M.toggle()
  end
end

--- Hide the window and drop the active session
function M.close()
  local name = state.active
  M.hide()
  if name then
    state.remove(name)
  end
end

--- Picker: choose which CLI to open from the list of installed tools
function M.select(opts)
  opts = opts or {}
  local avail = tools.available()
  if #avail == 0 then
    vim.notify('RosaAI: no CLI tools installed', vim.log.levels.WARN)
    return
  end

  local items = {}
  for _, t in ipairs(avail) do
    table.insert(items, {
      text = t.icon .. ' ' .. t.label,
      tool = t,
    })
  end

  vim.ui.select(items, {
    prompt = 'RosaAI · select CLI',
    format_item = function(item)
      return item.text
    end,
  }, function(choice)
    if not choice then
      return
    end
    M.show(choice.tool.name)
  end)
end

--- Expand template tokens (this/file/selection) into actual references
local function expand(msg, ctx)
  local file = fn.fnamemodify(api.nvim_buf_get_name(ctx.buf), ':~:.')
  msg = msg:gsub('{file}', '@' .. file)
  msg = msg:gsub('{this}', '@' .. file .. ':' .. ctx.line)
  if msg:find '{selection}' then
    if ctx.sel_start and ctx.sel_end then
      msg = msg:gsub('{selection}', '@' .. file .. ':' .. ctx.sel_start .. '-' .. ctx.sel_end)
    else
      msg = msg:gsub('{selection}', '')
    end
  end
  return msg
end

--- Capture the source-buffer context BEFORE the CLI takes focus
local function capture_ctx()
  local buf = api.nvim_get_current_buf()
  local mode = api.nvim_get_mode().mode
  local ctx = { buf = buf, line = fn.line '.' }
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local s = fn.line 'v'
    local e = fn.line '.'
    if s > e then
      s, e = e, s
    end
    ctx.sel_start = s
    ctx.sel_end = e
    api.nvim_feedkeys(api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
  end
  return ctx
end

--- Send a message to the active CLI's terminal (opens it if not visible)
function M.send(opts)
  opts = opts or {}
  local ctx = capture_ctx()
  local msg = expand(opts.msg or '', ctx)

  local name = opts.tool or state.active or (function()
    local avail = tools.available()
    return avail[1] and avail[1].name or nil
  end)()
  if not name then
    vim.notify('RosaAI: no CLI tools installed', vim.log.levels.WARN)
    return
  end

  local prev = state.get(name)
  local fresh = not (prev and prev.started)
  M.show(name)
  -- A cold-started CLI hasn't enabled bracketed-paste mode yet; if we
  -- send immediately the bytes leak into its boot banner AND get re-read
  -- once the input handler attaches, so the message shows up twice. Wait
  -- long enough for the prompt to come up before sending.
  local delay = fresh and 1500 or 80
  vim.defer_fn(function()
    local s = state.get(name)
    if not s or not s.job then
      return
    end
    local submit = opts.submit ~= false
    local cr = submit and '\r' or ''
    if msg:find '\n' then
      -- Bracketed paste so CLIs treat embedded newlines as one input
      fn.chansend(s.job, '\27[200~' .. msg .. '\27[201~' .. cr)
    else
      fn.chansend(s.job, msg .. cr)
    end
    if opts.focus ~= false and win_open() then
      api.nvim_set_current_win(state.win)
      if bar.autoinsert_enabled() then
        vim.cmd 'startinsert'
      end
    end
  end, delay)
end

--- Built-in prompt templates the user can pick from
M.prompts = {
  { name = 'explain', icon = '󰋽 ', label = 'Explain', msg = 'Explain {this} in detail.' },
  { name = 'review', icon = '󰈈 ', label = 'Review', msg = 'Review {file} for bugs, smells and improvements.' },
  { name = 'refactor', icon = '󰠭 ', label = 'Refactor', msg = 'Refactor {selection} for clarity and simplicity.' },
  { name = 'tests', icon = '󰙨 ', label = 'Write tests', msg = 'Write tests for {selection}.' },
  { name = 'fix', icon = '󰁨 ', label = 'Fix', msg = 'Fix the issue in {selection}.' },
  { name = 'doc', icon = '󰈙 ', label = 'Document', msg = 'Document {selection}.' },
}

function M.prompt()
  vim.ui.select(M.prompts, {
    prompt = 'RosaAI · select prompt',
    format_item = function(p)
      return p.icon .. p.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    M.send { msg = choice.msg }
  end)
end

--- Open a small input prompt that prefixes the selection range and sends it
function M.ask_with_selection()
  local ctx = capture_ctx()
  local file = fn.fnamemodify(api.nvim_buf_get_name(ctx.buf), ':~:.')
  local input_fn = (_G.Snacks and Snacks.input) or vim.ui.input

  input_fn({ prompt = '  Ask AI' }, function(input)
    if not input or input == '' then
      return
    end
    local ref
    if ctx.sel_start and ctx.sel_end then
      ref = '@' .. file .. ':' .. ctx.sel_start .. '-' .. ctx.sel_end
    else
      ref = '@' .. file .. ':' .. ctx.line
    end
    route_ask(ref .. ' ' .. input)
  end)
end

--- Visual-mode ask: shows the selected snippet in a preview float and an
--- input box right below it. `<CR>` sends, `<Esc>` cancels.
--- Falls back to the simple prompt when no selection is captured.
function M.ask_with_preview()
  local ctx = capture_ctx()
  if not ctx.sel_start or not ctx.sel_end then
    return M.ask_with_selection()
  end

  local file = fn.fnamemodify(api.nvim_buf_get_name(ctx.buf), ':~:.')
  -- Title shows just the basename; the message still uses the relative path
  local file_name = fn.fnamemodify(api.nvim_buf_get_name(ctx.buf), ':t')
  local source_ft = vim.bo[ctx.buf].filetype
  local snippet = api.nvim_buf_get_lines(ctx.buf, ctx.sel_start - 1, ctx.sel_end, false)

  -- Snapshot the snippet into a scratch buffer so the source is untouchable
  local preview_buf = api.nvim_create_buf(false, true)
  vim.bo[preview_buf].bufhidden = 'wipe'
  vim.bo[preview_buf].filetype = source_ft
  api.nvim_buf_set_lines(preview_buf, 0, -1, false, snippet)
  vim.bo[preview_buf].modifiable = false

  local cols = vim.o.columns
  local lines = vim.o.lines - vim.o.cmdheight - 1
  local width = math.min(90, math.floor(cols * 0.62))
  -- Cap preview: max 25 rows OR 50% of the editor (whichever is smaller),
  -- so even a 200-line selection stays balanced with the input box below.
  local max_preview = math.min(25, math.floor(lines * 0.50))
  local preview_h = math.max(5, math.min(#snippet, max_preview))
  local input_h = 2
  local gap = 1
  local total_h = preview_h + 2 + gap + input_h + 2 -- +2 each for rounded borders
  local start_row = math.max(0, math.floor((lines - total_h) / 2))
  local start_col = math.max(0, math.floor((cols - width - 2) / 2))

  local preview_win = api.nvim_open_win(preview_buf, false, {
    relative = 'editor',
    row = start_row,
    col = start_col,
    width = width,
    height = preview_h,
    border = 'rounded',
    style = 'minimal',
    title = { { ' ' .. file_name .. ':' .. ctx.sel_start .. '-' .. ctx.sel_end .. ' ', 'Title' } },
    title_pos = 'center',
    zindex = 50,
  })
  vim.wo[preview_win].number = false
  vim.wo[preview_win].cursorline = false
  vim.wo[preview_win].wrap = false
  vim.wo[preview_win].signcolumn = 'no'
  vim.wo[preview_win].winhl = 'Normal:Normal,FloatBorder:FloatBorder,FloatTitle:Title'

  local input_buf = api.nvim_create_buf(false, true)
  vim.bo[input_buf].bufhidden = 'wipe'
  vim.bo[input_buf].filetype = 'rosaai_ask'
  -- Disable blink.cmp / nvim-cmp completion in the prompt buffer
  vim.b[input_buf].completion = false

  local input_win = api.nvim_open_win(input_buf, true, {
    relative = 'editor',
    row = start_row + preview_h + 2 + gap,
    col = start_col,
    width = width,
    height = input_h,
    border = 'rounded',
    style = 'minimal',
    title = { { '   Ask AI ', 'Title' } },
    title_pos = 'center',
    footer = ' Enter · send  │  Esc · normal  │  Esc Esc · cancel ',
    footer_pos = 'center',
    zindex = 51,
  })
  vim.wo[input_win].number = false
  vim.wo[input_win].signcolumn = 'no'
  vim.wo[input_win].winhl = 'Normal:Normal,FloatBorder:FloatBorder,FloatTitle:Title,FloatFooter:Comment'

  vim.cmd 'startinsert'

  local function close_all()
    pcall(api.nvim_win_close, input_win, true)
    pcall(api.nvim_win_close, preview_win, true)
  end

  local function submit()
    local lines_in = api.nvim_buf_get_lines(input_buf, 0, -1, false)
    local text = table.concat(lines_in, ' '):gsub('^%s+', ''):gsub('%s+$', '')
    close_all()
    if text == '' then
      return
    end
    local ref = '@' .. file .. ':' .. ctx.sel_start .. '-' .. ctx.sel_end
    local msg = ref .. '\n' .. text
    route_ask(msg, { submit = false })
  end

  local kopts = { buffer = input_buf, silent = true, nowait = true }
  vim.keymap.set({ 'i', 'n' }, '<CR>', submit, kopts)
  vim.keymap.set('n', 'q', close_all, kopts)

  -- Double-Esc behavior, mirrors the CLI terminal:
  -- - In insert mode: <Esc> exits to normal mode and opens a 300ms window.
  -- - In normal mode within 300ms: <Esc> cancels (close all).
  -- - In normal mode after 300ms: <Esc> does nothing — use q to cancel.
  local double_esc_ms = 300
  local esc_window_until = 0
  local now = (vim.uv and vim.uv.now) or vim.loop.now

  vim.keymap.set('i', '<Esc>', function()
    esc_window_until = now() + double_esc_ms
    api.nvim_feedkeys(api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  end, kopts)

  vim.keymap.set('n', '<Esc>', function()
    if now() < esc_window_until then
      esc_window_until = 0
      close_all()
    end
  end, kopts)

  -- Forward scroll keys to the preview window without leaving the input.
  -- Overrides <C-u>/<C-d> in insert mode (they normally delete text in nvim
  -- input) — for this prompt buffer scrolling the preview is more useful.
  local function scroll_preview(key)
    if not api.nvim_win_is_valid(preview_win) then
      return
    end
    api.nvim_win_call(preview_win, function()
      vim.cmd('normal! ' .. api.nvim_replace_termcodes(key, true, false, true))
    end)
  end
  for _, k in ipairs { '<C-d>', '<C-u>', '<C-f>', '<C-b>' } do
    vim.keymap.set({ 'i', 'n' }, k, function()
      scroll_preview(k)
    end, kopts)
  end

  -- Close preview if input goes away (e.g. window closed externally)
  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(input_win),
    once = true,
    callback = function()
      pcall(api.nvim_win_close, preview_win, true)
    end,
  })
end

--- Re-render the chip overlay on the active window (called by toggles)
function M.refresh_chips()
  if not win_open() then
    return
  end
  if not state.active then
    return
  end
  set_winbar(state.win)
  open_chip(state.win, state.active)
end

--- Re-open the active CLI in the new layout (called after position/size change)
--- Re-open the active CLI in the new layout. No-op when the window is
--- closed — switching theme/border/position should never open the CLI
--- on its own (user must trigger it explicitly via <leader>aa).
function M.relayout()
  if not win_open() or not state.active then
    return
  end
  local name = state.active
  M.hide()
  M.show(name)
end

--- Per-buffer Esc handler: single Esc → normal mode, double Esc within
--- 300ms → re-enter terminal and forward a literal ESC byte to the CLI.
--- Installed lazily on TermOpen so the keymaps land after the terminal
--- is fully attached (otherwise the t-mode mapping never fires).
local function install_esc_handler(buf)
  if vim.b[buf].rosaai_esc_installed then
    return
  end
  vim.b[buf].rosaai_esc_installed = true

  local opts = { buffer = buf, silent = true, nowait = true }
  local double_esc_window_ms = 300
  local esc_window_until = 0
  local now = (vim.uv and vim.uv.now) or vim.loop.now

  vim.keymap.set('t', '<Esc>', function()
    esc_window_until = now() + double_esc_window_ms
    api.nvim_feedkeys(api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), 'n', false)
  end, opts)

  vim.keymap.set('n', '<Esc>', function()
    if now() < esc_window_until then
      esc_window_until = 0
      local chan = vim.b[buf].terminal_job_id
      vim.cmd 'startinsert'
      if chan then
        fn.chansend(chan, '\27')
      end
    end
  end, opts)
end

--- Arrow-key resize, Normal mode only. Terminal mode keeps the arrows so
--- the CLI's own navigation/history still works — press <Esc> to drop to
--- Normal first, then the arrows resize the float (mirrors rosaterm).
local function install_resize_keymaps(buf)
  if vim.b[buf].rosaai_resize_installed then
    return
  end
  vim.b[buf].rosaai_resize_installed = true

  local opts = { buffer = buf, silent = true, nowait = true }
  local dirs = { ['<Up>'] = 'up', ['<Down>'] = 'down', ['<Left>'] = 'left', ['<Right>'] = 'right' }
  for key, dir in pairs(dirs) do
    vim.keymap.set('n', key, function()
      M.resize_arrow(dir)
    end, opts)
  end
end

api.nvim_create_autocmd('TermOpen', {
  group = api.nvim_create_augroup('RosaaiCliTerm', { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      if not api.nvim_buf_is_valid(ev.buf) then
        return
      end
      if not vim.b[ev.buf].rosaai_cli then
        return
      end
      install_esc_handler(ev.buf)
      install_resize_keymaps(ev.buf)
    end)
  end,
})

--- Whether the shared CLI window is on the current tabpage. Floats are
--- tabpage-local, so after switching away and back the float is re-shown
--- but its terminal cells are not repainted, leaving the overlapping/ghosted
--- look. We force a full repaint on TabEnter to clear it.
local function rosaai_visible_here()
  if not win_open() then
    return false
  end
  for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
    if w == state.win then
      return true
    end
  end
  return false
end

local function force_repaint()
  if not rosaai_visible_here() then
    return
  end
  vim.schedule(function()
    if not win_open() then
      return
    end
    -- Re-pin the chip (it can desync after a tab switch), then repaint the
    -- whole screen so stale terminal cells from the hidden tab are cleared.
    refresh_chip()
    pcall(vim.cmd, 'redraw!')
  end)
end

local redraw_group = api.nvim_create_augroup('RosaaiRedraw', { clear = true })
api.nvim_create_autocmd('TabEnter', {
  group = redraw_group,
  callback = force_repaint,
})
api.nvim_create_autocmd('WinEnter', {
  group = redraw_group,
  callback = function()
    if win_open() and api.nvim_get_current_win() == state.win then
      force_repaint()
    end
  end,
})
-- Reflow the float (and chip) when the editor itself is resized.
api.nvim_create_autocmd('VimResized', {
  group = redraw_group,
  callback = function()
    if not win_open() then
      return
    end
    vim.schedule(function()
      if not win_open() then
        return
      end
      local geom = layout.compute_geom()
      pcall(api.nvim_win_set_config, state.win, geom)
      refresh_chip()
    end)
  end,
})

api.nvim_create_autocmd('WinClosed', {
  group = api.nvim_create_augroup('RosaaiCliClose', { clear = true }),
  callback = function(args)
    local closed = tonumber(args.match)
    if closed and closed == state.win then
      bar.detach(state.win)
      close_chip()
      state.win = nil
    end
  end,
})

return M

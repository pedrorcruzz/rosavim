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

-- One chip overlay per layout slot: pos -> { win, buf }. Several CLIs can be
-- visible at once, so each visible slot carries its own title chip.
local chips = {}

local function win_open()
  return state.win and api.nvim_win_is_valid(state.win)
end

--- Position of the currently focused window if it is a RosaAI slot, else nil.
local function focused_pos()
  return state.pos_of_win(api.nvim_get_current_win())
end

local function chip_open(pos)
  local c = chips[pos]
  return c and c.win and api.nvim_win_is_valid(c.win)
end

local function close_chip(pos)
  local c = chips[pos]
  if c and c.win and api.nvim_win_is_valid(c.win) then
    pcall(api.nvim_win_close, c.win, true)
  end
  chips[pos] = nil
end

local function close_all_chips()
  for pos, _ in pairs(chips) do
    close_chip(pos)
  end
end

--- Tear down a slot's window + chip and forget it (session is left untouched;
--- callers that also want to kill the CLI call state.remove separately).
local function teardown_slot(pos)
  local sl = state.slots[pos]
  if sl and sl.win then
    bar.detach(sl.win)
    if api.nvim_win_is_valid(sl.win) then
      pcall(api.nvim_win_close, sl.win, true)
    end
    if state.win == sl.win then
      state.win = nil
    end
  end
  close_chip(pos)
  state.clear_slot(pos)
end

--- Focus a slot's window and mark it as the compat-active session.
local function focus_slot(pos)
  local sl = state.slot(pos)
  if not sl then
    return false
  end
  api.nvim_set_current_win(sl.win)
  state.win = sl.win
  state.active = sl.name
  if bar.autoinsert_enabled() then
    vim.cmd 'startinsert'
  end
  return true
end

--- Render or move the chip overlay on top of a slot's floating CLI window
local function open_chip(pos, parent_win, tool_name)
  if not parent_win or not api.nvim_win_is_valid(parent_win) then
    return
  end
  local cfg = api.nvim_win_get_config(parent_win)
  if not bar.chip_enabled() then
    close_chip(pos)
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

  local c = chips[pos] or {}
  if not c.buf or not api.nvim_buf_is_valid(c.buf) then
    c.buf = api.nvim_create_buf(false, true)
    vim.bo[c.buf].bufhidden = 'hide'
  end
  bar.write_chip_buf(c.buf, width, tool_name)

  if c.win and api.nvim_win_is_valid(c.win) then
    pcall(api.nvim_win_close, c.win, true)
  end
  c.win = api.nvim_open_win(c.buf, false, {
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
  vim.wo[c.win].winhl = 'Normal:Normal,FloatBorder:FloatBorder'
  vim.wo[c.win].winbar = ''
  chips[pos] = c
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

--- Whether the CLI panel is rendered on a dark background right now: dark
--- colorscheme, or a light one with the rosaai_dark_bg override on (which
--- forces the float bg to #000). We hand this to the child via COLORFGBG so
--- TUIs that auto-theme by the terminal background (Cursor Agent shades its
--- input box from it) pick dark instead of painting a light box.
local function panel_is_dark()
  if vim.o.background == 'dark' then
    return true
  end
  local ok, term_bg = pcall(require, 'rosavim.rosa_plugins.term_bg')
  return ok and term_bg.is_black('rosaai_dark_bg', true)
end

local function start_job(s)
  if s.started then
    return
  end
  local cmd = s.tool.cmd
  -- COLORFGBG '15;0' = light fg on dark bg (→ app uses a dark theme);
  -- '0;15' = the inverse for a genuinely light panel.
  local colorfgbg = panel_is_dark() and '15;0' or '0;15'
  api.nvim_buf_call(s.buf, function()
    s.job = fn.termopen(cmd, {
      env = { COLORFGBG = colorfgbg },
      on_exit = function()
        vim.schedule(function()
          local pos = state.pos_of(s.tool.name)
          if pos then
            teardown_slot(pos)
          end
          state.remove(s.tool.name)
        end)
      end,
    })
  end)
  s.started = true
end

--- Repaint the chip on a specific slot (or, with no arg, every visible slot).
local function refresh_chip(pos)
  if pos then
    local sl = state.slot(pos)
    if sl and chip_open(pos) then
      open_chip(pos, sl.win, sl.name)
    end
    return
  end
  state.each_slot(function(p, win, name)
    if chip_open(p) then
      open_chip(p, win, name)
    end
  end)
end

--- Live-resize the focused CLI float by a width/height delta and persist the
--- new size as a per-position override (so it survives hide/show/relayout).
--- Geometry is recomputed through layout so the float stays pinned to its
--- edge (or centered, for float) instead of drifting.
local function resize_active(d_w, d_h)
  local pos = focused_pos()
  if not pos then
    return false
  end
  local win = state.slot(pos).win
  local cfg = api.nvim_win_get_config(win)
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
  layout.set_override(pos, new_w, new_h)
  local geom = layout.compute_geom(pos)
  pcall(api.nvim_win_set_config, win, geom)
  refresh_chip(pos)
  return true
end

--- Resize the focused CLI float in an arrow direction, honoring its slot's
--- layout: vertical (right/left) → width, horizontal (bottom) → height,
--- float → both axes (kept centered). Returns true when it handled the
--- resize, so smart-splits can fall through to native splits otherwise.
function M.resize_arrow(dir)
  local pos = focused_pos()
  if not pos then
    return false
  end
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

--- Show a CLI tool's terminal in the given layout slot (defaults to the last
--- configured position). Other slots stay visible, so several CLIs can share
--- the screen. If the CLI is already visible in another slot it RELOCATES
--- here; if the target slot holds a different CLI it REPLACES it (the
--- replaced CLI's session stays alive and can be reopened later).
function M.show(name, pos)
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

  pos = pos or layout.current_position()

  -- Relocate: if this CLI is already shown elsewhere, drop that slot first.
  local prev_pos = state.pos_of(name)
  if prev_pos and prev_pos ~= pos then
    teardown_slot(prev_pos)
  end

  -- Replace: close the slot's current occupant window in place (its session
  -- lives on). bar/chip of the occupant are dropped before we reuse the slot.
  local occupant = state.slots[pos]
  local prev_win = occupant and occupant.win
  if occupant and occupant.win then
    bar.detach(occupant.win)
  end
  close_chip(pos)

  local win, kind = layout.open(s.buf, prev_win, pos)
  state.set_slot(pos, win, name)
  state.win = win
  state.active = name
  require('rosavim.config.toggles').set('rosaai_position', pos)

  if not s.started then
    start_job(s)
  end

  set_winbar(win)
  open_chip(pos, win, name)
  bar.attach(win, s.buf, function()
    refresh_chip(pos)
  end)

  if bar.autoinsert_enabled() then
    vim.cmd 'startinsert'
  end
end

--- Hide a slot without killing its job (defaults to the focused slot, else
--- the compat-active session, else any single visible slot). The session is
--- preserved so a later show restores it with history intact.
function M.hide(pos)
  pos = pos or focused_pos() or state.pos_of(state.active)
  if not pos then
    state.each_slot(function(p)
      pos = pos or p
    end)
  end
  if not pos then
    return
  end
  teardown_slot(pos)
end

--- Toggle the named CLI (or the most recent one if no name given): hide its
--- slot if visible, otherwise show it in its last/default position.
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

  local pos = state.pos_of(name)
  if pos then
    M.hide(pos)
  else
    M.show(name)
  end
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

--- Choose which CLI to act on, following the SAME rules as the ask flow
--- (route_ask), minus the layout picker:
---  - 0 alive sessions → pick from installed tools (or the only one)
---  - 1 alive session  → use it, no picker
---  - 2+ alive          → pick from the alive (open) ones
--- Calls on_pick(name) with the chosen CLI. Used by the layout-open keys so
--- they mirror <leader>aa instead of always defaulting to the first tool.
local function select_cli_then(on_pick)
  local alive = state.alive()
  local count, only_name = 0, nil
  for name, _ in pairs(alive) do
    count = count + 1
    only_name = name
  end
  if count == 0 then
    local avail = tools.available()
    if #avail == 0 then
      vim.notify('RosaAI: no CLI tools installed', vim.log.levels.WARN)
      return
    end
    if #avail == 1 then
      on_pick(avail[1].name)
    else
      local items = {}
      for _, t in ipairs(avail) do
        table.insert(items, { name = t.name, tool = t })
      end
      pick_cli(items, on_pick)
    end
  elseif count == 1 then
    on_pick(only_name)
  else
    local items = {}
    for name, s in pairs(alive) do
      table.insert(items, { name = name, tool = s.tool })
    end
    pick_cli(items, on_pick)
  end
end

--- Smart toggle for <leader>aa (bare) and the per-tool keys (<leader>ac …):
--- - CLI visible + focused    → hide its slot
--- - CLI visible + not focused → focus it
--- - CLI hidden but a session exists → reopen in its last position
--- - very first open ever      → ask the layout once, then show
--- Bare <leader>aa routes through select_cli_then, so with 2+ CLIs alive it
--- pops the selector to choose which one to toggle.
function M.toggle_with_picker(tool_name)
  local function proceed(name)
    local pos = state.pos_of(name)
    if pos then
      if focused_pos() == pos then
        M.hide(pos)
      else
        focus_slot(pos)
      end
      return
    end
    -- Not visible. On the very first open (no sessions at all) let the user
    -- pick the layout once; afterwards just reuse the last position.
    if next(state.sessions) == nil then
      show_layout_picker(function(p)
        if not p then
          return
        end
        M.show(name, p)
      end)
    else
      M.show(name)
    end
  end
  if tool_name then
    proceed(tool_name)
  else
    select_cli_then(proceed)
  end
end

--- Show a CLI in a specific layout slot. Pressing this while that exact slot
--- already shows this CLI (and is focused) toggles it off; otherwise it
--- shows/replaces the slot, keeping every OTHER slot visible.
function M.show_in(position, tool_name)
  local sl = state.slot(position)
  if sl and (not tool_name or sl.name == tool_name) and focused_pos() == position then
    M.hide(position)
    return
  end
  M.show(tool_name, position)
end

--- Open a CLI in a specific layout (vertical/horizontal/float), following the
--- SAME CLI-selection logic as <leader>aa: prompt for a CLI when none is
--- open, use the only one when just one is alive (migrate it here), or pick
--- among the open ones when several are. Pressing the same layout key while
--- that slot is showing toggles it off. Every other slot stays visible.
function M.open_in_layout(position)
  if state.slot(position) then
    M.hide(position)
    return
  end
  select_cli_then(function(name)
    M.show(name, position)
  end)
end

--- Focus a visible CLI window (re-show the compat-active one if hidden)
function M.focus()
  local pos = state.pos_of(state.active)
  if not pos then
    state.each_slot(function(p)
      pos = pos or p
    end)
  end
  if pos then
    focus_slot(pos)
    return
  end
  if state.active then
    M.show(state.active)
  else
    M.toggle()
  end
end

--- Hide the focused/active window and drop that one session (kills its job)
function M.close()
  local pos = focused_pos() or state.pos_of(state.active)
  local name = pos and state.slots[pos] and state.slots[pos].name or state.active
  if pos then
    teardown_slot(pos)
  end
  if name then
    state.remove(name)
  end
end

--- Kill a CLI for good: close its slot window and drop the session (buffer +
--- job), losing its history. Used by <leader>ad / <leader>aD.
function M.kill(name)
  local pos = state.pos_of(name)
  if pos then
    teardown_slot(pos)
  end
  state.remove(name)
end

--- <leader>ad — pick one of the ALIVE CLIs (visible or hidden) and kill it.
--- With a single alive CLI it kills straight away; with none it just warns.
function M.close_pick()
  local items = {}
  for name, s in pairs(state.alive()) do
    table.insert(items, { name = name, tool = s.tool })
  end
  if #items == 0 then
    vim.notify('RosaAI: no CLI running', vim.log.levels.INFO)
    return
  end
  if #items == 1 then
    M.kill(items[1].name)
    return
  end
  pick_cli(items, M.kill)
end

--- <leader>am — visual window picker (rosapick): the picked CLI slot is
--- hidden (session kept alive), like <leader>aa does for the focused one.
function M.minimize_pick()
  if not state.any_visible() then
    return
  end
  local rok, rosapick = pcall(require, 'rosavim.rosa_plugins.rosapick')
  if not rok then
    -- Fall back to hiding the focused/active slot if rosapick is unavailable.
    M.hide()
    return
  end
  local win = rosapick.select()
  if not win then
    return
  end
  local pos = state.pos_of_win(win)
  if pos then
    M.hide(pos)
  end
end

--- <leader>aD — kill every alive CLI (all slots close, all history dropped).
function M.close_all()
  local names = {}
  for name, _ in pairs(state.alive()) do
    table.insert(names, name)
  end
  if #names == 0 then
    vim.notify('RosaAI: no CLI running', vim.log.levels.INFO)
    return
  end
  for _, name in ipairs(names) do
    M.kill(name)
  end
end

--- Picker: choose a CLI, then choose a layout slot to open it in (replacing
--- whatever occupies that slot, even a different CLI). Wired to <leader>as.
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
    show_layout_picker(function(pos)
      if not pos then
        return
      end
      M.show(choice.tool.name, pos)
    end)
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

--- Re-render the chip overlay on every visible slot (called by toggles)
function M.refresh_chips()
  state.each_slot(function(pos, win, name)
    set_winbar(win)
    open_chip(pos, win, name)
  end)
end

--- Re-apply theme/size/border to every visible slot (called after a toggle
--- change). Re-opens each CLI in its OWN position, leaving the set of visible
--- slots unchanged. No-op when nothing is visible — toggles never open a CLI
--- on their own (the user must trigger it via <leader>aa/av/ah/af).
function M.relayout()
  local shown = {}
  state.each_slot(function(pos, _, name)
    table.insert(shown, { pos = pos, name = name })
  end)
  for _, sl in ipairs(shown) do
    M.show(sl.name, sl.pos)
  end
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

--- Whether the win belongs to RosaAI (a slot or one of the chip overlays).
local function is_our_win(w)
  for _, sl in pairs(state.slots) do
    if sl.win == w then
      return true
    end
  end
  for _, c in pairs(chips) do
    if c.win == w then
      return true
    end
  end
  return false
end

--- Whether any RosaAI slot is on the current tabpage. Floats are tabpage-local,
--- so after switching away and back they are re-shown but their terminal cells
--- are not repainted, leaving a ghosted look. We force a repaint on TabEnter.
local function rosaai_visible_here()
  if not state.any_visible() then
    return false
  end
  for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
    if state.pos_of_win(w) then
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
    if not state.any_visible() then
      return
    end
    -- Re-pin every chip (they can desync after a tab switch), then repaint the
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
    if focused_pos() then
      force_repaint()
    end
  end,
})
-- Reflow every visible slot (and its chip) to its layout. For the bottom
-- (horizontal) position, compute_geom tracks the editor main area, so this
-- also slides/shrinks the float when a side panel (Snacks Explorer, etc.)
-- opens or closes. `reflowing` guards the synchronous chip open/close events
-- our own refresh_chip emits, and the geometry diff skips redundant churn —
-- together these prevent the WinResized/WinNew feedback loop.
local reflow_timer = nil
local reflowing = false

local function apply_layout()
  if not state.any_visible() then
    return
  end
  reflowing = true
  state.each_slot(function(pos, win)
    local ok, cur = pcall(api.nvim_win_get_config, win)
    if not ok then
      return
    end
    local geom = layout.compute_geom(pos)
    if cur.width == geom.width and cur.height == geom.height and cur.col == geom.col and cur.row == geom.row then
      return
    end
    pcall(api.nvim_win_set_config, win, geom)
    refresh_chip(pos)
  end)
  reflowing = false
end

local function schedule_reflow()
  if reflow_timer then
    pcall(function()
      reflow_timer:stop()
      reflow_timer:close()
    end)
  end
  reflow_timer = vim.uv.new_timer()
  reflow_timer:start(
    16,
    0,
    vim.schedule_wrap(function()
      reflow_timer = nil
      apply_layout()
    end)
  )
end

-- Editor resize reflows every slot (existing behavior).
api.nvim_create_autocmd('VimResized', {
  group = redraw_group,
  callback = function()
    if state.any_visible() then
      schedule_reflow()
    end
  end,
})

-- Smart resize for the horizontal (bottom) slot: when another window is
-- resized or opened/closed, re-anchor it to the new main area. Events from our
-- own floats/chips are filtered to avoid a feedback loop.
api.nvim_create_autocmd('WinResized', {
  group = redraw_group,
  callback = function()
    if reflowing then
      return
    end
    if state.slot 'bottom' then
      schedule_reflow()
    end
  end,
})
api.nvim_create_autocmd({ 'WinNew', 'WinClosed' }, {
  group = redraw_group,
  callback = function(args)
    if reflowing then
      return
    end
    local w = tonumber(args.match) or args.win
    if w and is_our_win(w) then
      return
    end
    if state.slot 'bottom' then
      schedule_reflow()
    end
  end,
})

api.nvim_create_autocmd('WinClosed', {
  group = api.nvim_create_augroup('RosaaiCliClose', { clear = true }),
  callback = function(args)
    local closed = tonumber(args.match)
    if not closed then
      return
    end
    -- A slot window closed externally (e.g. :q): forget that slot cleanly.
    for pos, sl in pairs(state.slots) do
      if sl.win == closed then
        bar.detach(closed)
        close_chip(pos)
        state.clear_slot(pos)
        if state.win == closed then
          state.win = nil
        end
        break
      end
    end
  end,
})

-- Nvim answers OSC 10/11 (terminal fg/bg color queries) from a default
-- autocmd that keys off the 'background' option: a light colorscheme reports a
-- WHITE background. TUIs like Cursor Agent query this to auto-theme, so on a
-- light theme they paint a light input box even though our CLI float is forced
-- dark (rosaai_dark_bg / <leader>laad). winhl can't change the OSC answer, and
-- COLORFGBG is only a fallback the app uses when the query goes unanswered.
-- So we replace Nvim's stock responder with one that reports DARK for our
-- forced-dark CLI terminals, and preserves stock behavior for every other
-- terminal (fg=white/bg=black when 'background' is dark, inverse when light).
local function install_osc_color_override()
  local ok, existing = pcall(api.nvim_get_autocmds, { event = 'TermRequest' })
  if ok then
    for _, au in ipairs(existing) do
      if au.desc == 'Handles OSC foreground/background color requests' and au.id then
        pcall(api.nvim_del_autocmd, au.id)
      end
    end
  end
  api.nvim_create_autocmd('TermRequest', {
    group = api.nvim_create_augroup('RosaaiOscColor', { clear = true }),
    desc = 'RosaAI OSC fg/bg response (dark for forced-dark CLI panels)',
    callback = function(ev)
      local channel = vim.bo[ev.buf].channel
      if channel == 0 then
        return
      end
      local seq = ev.data and ev.data.sequence
      local fg_request = seq == '\027]10;?'
      local bg_request = seq == '\027]11;?'
      if not (fg_request or bg_request) then
        return
      end
      -- Our CLI panels report dark whenever they render dark; any other
      -- terminal keeps Nvim's stock 'background'-driven answer.
      local dark
      if vim.b[ev.buf].rosaai_cli then
        dark = panel_is_dark()
      else
        dark = vim.o.background == 'dark'
      end
      local red, green, blue = 0, 0, 0
      if (fg_request and dark) or (bg_request and not dark) then
        red, green, blue = 65535, 65535, 65535
      end
      local command = fg_request and 10 or 11
      local data = string.format('\027]%d;rgb:%04x/%04x/%04x%s', command, red, green, blue, ev.data.terminator)
      pcall(api.nvim_chan_send, channel, data)
    end,
  })
end

install_osc_color_override()

return M

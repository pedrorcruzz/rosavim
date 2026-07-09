--- Rosaterm float - Floating terminal window with multi-instance cycling
--- A separate rounded "chip" window is overlaid on the top border to display
--- the Rosaterm title + time, sitting on the border line.
local M = {}

local api = vim.api
local bar = require 'rosavim.rosa_plugins.rosaterm.bar'
local themes = require 'rosavim.rosa_plugins.rosaterm.themes'
local term_bg = require 'rosavim.rosa_plugins.term_bg'

local state = {
  terms = {},
  current = 1,
  win = nil,
  geom = nil,
  chip_win = nil,
  chip_buf = nil,
}

local function win_open()
  return state.win and api.nvim_win_is_valid(state.win)
end

local function chip_open()
  return state.chip_win and api.nvim_win_is_valid(state.chip_win)
end

local function calc_geom()
  local sizes = require 'rosavim.rosa_plugins.rosaterm.sizes'
  local pct = sizes.current().float
  local cols = vim.o.columns
  local lines = vim.o.lines - vim.o.cmdheight - 1
  local width = math.floor(cols * pct.wpct)
  local height = math.floor(lines * pct.hpct)
  return {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((lines - height) / 2),
    col = math.floor((cols - width) / 2),
    style = 'minimal',
    border = 'rounded',
  }
end

local function setup_buf_keymaps(buf)
  local opts = { buffer = buf, silent = true }
  vim.keymap.set({ 'n', 't' }, '<C-j>', function()
    M.cycle 'next'
  end, vim.tbl_extend('force', opts, { desc = 'Rosaterm: next' }))
  vim.keymap.set({ 'n', 't' }, '<C-k>', function()
    M.cycle 'prev'
  end, vim.tbl_extend('force', opts, { desc = 'Rosaterm: prev' }))
end

local function new_term_buf()
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].filetype = 'rosaterm'
  return buf
end

local function start_term(buf)
  local job
  api.nvim_buf_call(buf, function()
    job = vim.fn.termopen(vim.o.shell, {
      on_exit = function()
        M._on_term_exit(buf)
      end,
    })
  end)
  return job
end

local function ensure_term()
  if #state.terms == 0 then
    local buf = new_term_buf()
    table.insert(state.terms, { buf = buf, job = nil, started = false })
    state.current = 1
  end
  if state.current > #state.terms then
    state.current = #state.terms
  end
end

local function open_chip()
  if not state.geom then
    return
  end
  local theme = themes.current()
  local width, col, row
  if theme.layout == 'banner' then
    -- Banner: full width. Position so chip's bottom border lands on float's
    -- top border (so they merge into one frame) and chip text sits above.
    width = state.geom.width
    col = state.geom.col
    row = state.geom.row - 2
  elseif theme.layout == 'stem' then
    -- Stem: borderless 2-row chip. Row 0 = text (above float), row 1 = `─`
    -- separator on the float's top border row.
    width = state.geom.width
    col = state.geom.col
    row = state.geom.row - 1
  else
    -- Inline: small chip centered. Bordered uses 3 rows so subtract 1.
    width = vim.api.nvim_strwidth(bar.chip_plain())
    col = state.geom.col + math.floor((state.geom.width - width) / 2)
    row = state.geom.row - (theme.border == 'none' and 0 or 1)
  end

  if not state.chip_buf or not api.nvim_buf_is_valid(state.chip_buf) then
    state.chip_buf = api.nvim_create_buf(false, true)
    vim.bo[state.chip_buf].bufhidden = 'hide'
  end
  bar.write_chip_buf(state.chip_buf, width)

  if chip_open() then
    pcall(api.nvim_win_close, state.chip_win, true)
  end
  state.chip_win = api.nvim_open_win(state.chip_buf, false, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = theme.layout == 'stem' and 2 or 1,
    style = 'minimal',
    border = theme.border,
    focusable = false,
    zindex = 49,
  })
  vim.wo[state.chip_win].winhl = 'Normal:Normal,FloatBorder:FloatBorder'
  vim.wo[state.chip_win].winbar = ''
end

local function close_chip()
  if chip_open() then
    pcall(api.nvim_win_close, state.chip_win, true)
  end
  state.chip_win = nil
end

local function refresh_chip()
  if not chip_open() then
    return
  end
  local theme = themes.current()
  local width
  if theme.layout == 'banner' or theme.layout == 'stem' then
    width = state.geom and state.geom.width or 0
  else
    width = vim.api.nvim_strwidth(bar.chip_plain())
  end
  bar.write_chip_buf(state.chip_buf, width)
end

local function show_current()
  ensure_term()
  local term = state.terms[state.current]

  state.geom = calc_geom()
  if not win_open() then
    -- Sit below the RosaAI float (main 50 / chip 60) so the AI window
    -- always overlays rosaterm when both are open. zindex is create-only,
    -- so setting it here (not on state.geom) survives later resizes.
    state.win = api.nvim_open_win(term.buf, true, vim.tbl_extend('force', state.geom, { zindex = 45 }))
    vim.wo[state.win].winhl = term_bg.winhl('rosaterm_dark_bg', true, 'RosatermNormal', ',FloatBorder:FloatBorder')
    vim.wo[state.win].winbar = ''
  else
    api.nvim_win_set_buf(state.win, term.buf)
  end

  if not term.started then
    term.job = start_term(term.buf)
    term.started = true
    setup_buf_keymaps(term.buf)
  end

  if bar.chip_enabled() then
    open_chip()
  end
  bar.attach_float(state.win, term.buf, refresh_chip)
  api.nvim_set_current_win(state.win)
  if bar.autoinsert_enabled() then
    vim.cmd 'startinsert'
  end
end

--- Re-evaluate chip visibility (called when toggles change)
function M.refresh()
  if not win_open() then
    return
  end
  if bar.chip_enabled() then
    open_chip()
  else
    close_chip()
  end
end

--- Re-apply the terminal bg to the open float (used when rosaterm_dark_bg
--- toggles). Dark mode is unaffected; only light mode flips #000 ↔ theme.
function M.refresh_bg()
  if not win_open() then
    return
  end
  vim.wo[state.win].winhl = term_bg.winhl('rosaterm_dark_bg', true, 'RosatermNormal', ',FloatBorder:FloatBorder')
end

--- Re-apply geometry to the open float (used when the size preset changes).
function M.apply_geom()
  if not win_open() then
    return
  end
  state.geom = calc_geom()
  pcall(api.nvim_win_set_config, state.win, {
    relative = 'editor',
    row = state.geom.row,
    col = state.geom.col,
    width = state.geom.width,
    height = state.geom.height,
  })
  if bar.chip_enabled() then
    open_chip()
  end
end

function M.toggle()
  if win_open() then
    bar.detach(state.win)
    close_chip()
    api.nvim_win_close(state.win, true)
    state.win = nil
    return
  end
  show_current()
end

function M.cycle(direction)
  if #state.terms <= 1 then
    return
  end
  if direction == 'next' then
    state.current = state.current % #state.terms + 1
  else
    state.current = (state.current - 2) % #state.terms + 1
  end
  if win_open() then
    show_current()
  end
end

function M.new()
  local buf = new_term_buf()
  table.insert(state.terms, { buf = buf, job = nil, started = false })
  state.current = #state.terms
  if win_open() then
    show_current()
  end
end

--- Floats are tabpage-local: after switching tabs and back, the terminal
--- cells are re-shown but never repainted, leaving the ghosted/overlapping
--- look. Force a full repaint whenever a tab carrying any rosaterm window
--- (float or bordered split) is entered. Filetype is reliably 'rosaterm'.
local function rosaterm_visible_here()
  for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
    local b = api.nvim_win_get_buf(w)
    if api.nvim_buf_is_valid(b) and vim.bo[b].filetype == 'rosaterm' then
      return true
    end
  end
  return false
end

local redraw_group = api.nvim_create_augroup('RosatermRedraw', { clear = true })
api.nvim_create_autocmd('TabEnter', {
  group = redraw_group,
  callback = function()
    if not rosaterm_visible_here() then
      return
    end
    vim.schedule(function()
      pcall(vim.cmd, 'redraw!')
    end)
  end,
})
api.nvim_create_autocmd('WinEnter', {
  group = redraw_group,
  callback = function()
    local b = api.nvim_get_current_buf()
    if api.nvim_buf_is_valid(b) and vim.bo[b].filetype == 'rosaterm' then
      vim.schedule(function()
        pcall(vim.cmd, 'redraw!')
      end)
    end
  end,
})

--- Autocmd to clean up the chip if the main float window is closed externally
api.nvim_create_autocmd('WinClosed', {
  group = api.nvim_create_augroup('RosatermFloatClose', { clear = true }),
  callback = function(args)
    local closed = tonumber(args.match)
    if closed and closed == state.win then
      bar.detach(state.win)
      close_chip()
      state.win = nil
    end
  end,
})

function M._on_term_exit(buf)
  for i, t in ipairs(state.terms) do
    if t.buf == buf then
      table.remove(state.terms, i)
      break
    end
  end
  if state.current > #state.terms then
    state.current = math.max(1, #state.terms)
  end
  vim.schedule(function()
    if api.nvim_buf_is_valid(buf) then
      pcall(api.nvim_buf_delete, buf, { force = true })
    end
    if win_open() then
      if #state.terms == 0 then
        close_chip()
        api.nvim_win_close(state.win, true)
        state.win = nil
      else
        show_current()
      end
    end
  end)
end

return M

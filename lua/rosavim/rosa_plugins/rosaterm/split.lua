--- Rosaterm split - Horizontal/vertical terminal splits with toggle behavior
--- Each split gets a rounded "chip" overlay (same look as the float) anchored
--- to its top edge.
local M = {}

local api = vim.api
local bar = require 'rosavim.rosa_plugins.rosaterm.bar'
local themes = require 'rosavim.rosa_plugins.rosaterm.themes'

local terms = {}
local resize_au = nil

local function term_win_is_open(term)
  return term.win and api.nvim_win_is_valid(term.win)
end

local function chip_open(term)
  return term.chip_win and api.nvim_win_is_valid(term.chip_win)
end

local function close_chip(term)
  if chip_open(term) then
    pcall(api.nvim_win_close, term.chip_win, true)
  end
  term.chip_win = nil
end

local function open_chip(term)
  if not term_win_is_open(term) then
    return
  end
  local theme = themes.current()
  local pos = api.nvim_win_get_position(term.win) -- { row, col }
  local win_width = api.nvim_win_get_width(term.win)
  local cfg = api.nvim_win_get_config(term.win)
  -- Floats with border are 2 cells wider (and the position is the border
  -- top-left, not the content); native splits don't have those extras.
  local has_border = cfg.relative ~= '' and cfg.border and cfg.border ~= 'none'
  local outer_width = has_border and (win_width + 2) or win_width
  local outer_col = pos[2]

  local width, col, row
  if theme.layout == 'banner' then
    -- Banner: span the float's full outer width so chip and float align.
    width = outer_width
    col = outer_col
    row = pos[1] - 2
  elseif theme.layout == 'stem' then
    width = outer_width
    col = outer_col
    row = pos[1] - 2
  else
    -- Inline: small chip centered above the split.
    local text = bar.chip_plain()
    width = vim.api.nvim_strwidth(text)
    col = outer_col + math.floor((outer_width - width) / 2)
    row = pos[1] - (theme.border == 'none' and 1 or 2)
  end
  if row < 0 then
    row = 0
  end
  if col < 0 then
    col = 0
  end
  if not width or width < 1 then
    return
  end

  if not term.chip_buf or not api.nvim_buf_is_valid(term.chip_buf) then
    term.chip_buf = api.nvim_create_buf(false, true)
    vim.bo[term.chip_buf].bufhidden = 'hide'
  end
  bar.write_chip_buf(term.chip_buf, width)

  close_chip(term)
  term.chip_win = api.nvim_open_win(term.chip_buf, false, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = theme.layout == 'stem' and 2 or 1,
    style = 'minimal',
    border = theme.border,
    focusable = false,
    zindex = 60,
  })
  vim.wo[term.chip_win].winhl = 'Normal:Normal,FloatBorder:FloatBorder'
  vim.wo[term.chip_win].winbar = ''
end

local function refresh_chip(term)
  if not chip_open(term) then
    return
  end
  local theme = themes.current()
  local width
  if term.win and api.nvim_win_is_valid(term.win) then
    local cfg = api.nvim_win_get_config(term.win)
    local has_border = cfg.relative ~= '' and cfg.border and cfg.border ~= 'none'
    local outer = api.nvim_win_get_width(term.win) + (has_border and 2 or 0)
    if theme.layout == 'banner' or theme.layout == 'stem' then
      width = outer
    else
      width = vim.api.nvim_strwidth(bar.chip_plain())
    end
  else
    width = vim.api.nvim_strwidth(bar.chip_plain())
  end
  bar.write_chip_buf(term.chip_buf, width)
end

local function reposition_all_chips()
  for _, term in pairs(terms) do
    if term_win_is_open(term) and chip_open(term) then
      open_chip(term)
    end
  end
end

local function ensure_resize_au()
  if resize_au then
    return
  end
  resize_au = api.nvim_create_augroup('RosatermSplitChip', { clear = true })
  api.nvim_create_autocmd({ 'WinResized', 'VimResized' }, {
    group = resize_au,
    callback = function()
      vim.schedule(reposition_all_chips)
    end,
  })
  api.nvim_create_autocmd('WinClosed', {
    group = resize_au,
    callback = function(args)
      local closed = tonumber(args.match)
      if not closed then
        return
      end
      for _, term in pairs(terms) do
        if term.win == closed then
          bar.detach(term.win)
          close_chip(term)
          term.win = nil
          return
        end
      end
    end,
  })
end

local function border_for(direction)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return false
  end
  if direction == 'horizontal' then
    return toggles.get 'rosaterm_horizontal_border'
  end
  return toggles.get 'rosaterm_vertical_border'
end

local function open_split(term)
  local border_on = border_for(term.direction)

  if border_on then
    -- Pinned-float mode: render the "split" as a floating window glued to
    -- the editor edge, so it can have a rounded border. Chip overlay needs
    -- a couple of rows above for vertical orientation.
    local cols = vim.o.columns
    local lines = vim.o.lines - vim.o.cmdheight - 1
    local adj = 2 -- 1 row each for top/bottom border (or col for left/right)
    -- Match the chip overlay row offset (chip ends right on the float top
    -- border, no padding row above for vertical).
    local chip_room = term.direction == 'horizontal' and 0 or 2
    local geom
    if term.direction == 'horizontal' then
      local h = term.size
      geom = {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        width = cols - adj,
        height = h - adj,
        row = lines - h,
        col = 0,
      }
    else
      local w = term.size
      geom = {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        width = w - adj,
        height = lines - adj - chip_room,
        row = chip_room,
        col = cols - w,
      }
    end

    if not term.started then
      term.buf = api.nvim_create_buf(false, true)
      vim.bo[term.buf].bufhidden = 'hide'
      vim.bo[term.buf].filetype = 'rosaterm'
    end
    term.win = api.nvim_open_win(term.buf, true, geom)
  else
    -- Native split mode (no border possible — preserves the historical look)
    local in_terminal = vim.bo.filetype == 'rosaterm'
    local prefix = in_terminal and 'rightbelow ' or 'botright '
    local size = term.size
    if in_terminal then
      if term.direction == 'horizontal' then
        size = math.floor(api.nvim_win_get_height(0) / 2)
      else
        size = math.floor(api.nvim_win_get_width(0) / 2)
      end
    end
    local cmd
    if term.direction == 'horizontal' then
      cmd = prefix .. size .. 'split'
    else
      cmd = prefix .. size .. 'vsplit'
    end
    vim.cmd(cmd)
    term.win = api.nvim_get_current_win()
  end

  vim.wo[term.win].number = false
  vim.wo[term.win].relativenumber = false
  vim.wo[term.win].signcolumn = 'no'

  -- In float mode, the buffer is already attached via nvim_open_win.
  -- In native split mode we still need to create/attach it here.
  if not term.started then
    if not term.buf or not api.nvim_buf_is_valid(term.buf) then
      term.buf = api.nvim_create_buf(false, true)
      vim.bo[term.buf].bufhidden = 'hide'
      vim.bo[term.buf].filetype = 'rosaterm'
    end
    if api.nvim_win_get_buf(term.win) ~= term.buf then
      api.nvim_win_set_buf(term.win, term.buf)
    end
    api.nvim_buf_call(term.buf, function()
      term.job = vim.fn.termopen(vim.o.shell, {
        on_exit = function()
          M._on_exit(term.id)
        end,
      })
    end)
    term.started = true
  elseif api.nvim_win_get_buf(term.win) ~= term.buf then
    api.nvim_win_set_buf(term.win, term.buf)
  end

  if bar.chip_enabled() then
    open_chip(term)
  end
  bar.attach_split(term.win, term.buf, function()
    refresh_chip(term)
  end)
  ensure_resize_au()

  if bar.autoinsert_enabled() then
    vim.cmd 'startinsert'
  end
end

--- Re-evaluate chip visibility for all open splits (called when toggles change)
function M.refresh_all()
  for _, term in pairs(terms) do
    if term_win_is_open(term) then
      if bar.chip_enabled() then
        open_chip(term)
      else
        close_chip(term)
      end
    end
  end
end

--- Close + reopen every open split so they pick up a new border mode
--- (native split ↔ pinned float). Called when latb/latB toggle changes.
function M.reload_all(filter_direction)
  for _, term in pairs(terms) do
    if term_win_is_open(term) and (not filter_direction or term.direction == filter_direction) then
      bar.detach(term.win)
      close_chip(term)
      api.nvim_win_close(term.win, false)
      term.win = nil
      open_split(term)
    end
  end
end

function M.toggle(id, direction, size, name)
  local term = terms[id]
  if not term then
    term = {
      id = id,
      direction = direction,
      size = size,
      name = name or 'Terminal',
      buf = nil,
      job = nil,
      started = false,
      win = nil,
      chip_win = nil,
      chip_buf = nil,
    }
    terms[id] = term
  end

  if term_win_is_open(term) then
    bar.detach(term.win)
    close_chip(term)
    api.nvim_win_close(term.win, false)
    term.win = nil
    return
  end

  open_split(term)
end

function M._on_exit(id)
  local term = terms[id]
  if not term then
    return
  end
  vim.schedule(function()
    if term.win and api.nvim_win_is_valid(term.win) then
      bar.detach(term.win)
      pcall(api.nvim_win_close, term.win, true)
    end
    close_chip(term)
    if term.chip_buf and api.nvim_buf_is_valid(term.chip_buf) then
      pcall(api.nvim_buf_delete, term.chip_buf, { force = true })
    end
    if term.buf and api.nvim_buf_is_valid(term.buf) then
      pcall(api.nvim_buf_delete, term.buf, { force = true })
    end
    terms[id] = nil
  end)
end

return M

--- Rosaterm split - Horizontal/vertical terminal splits with toggle behavior
--- Each split gets a rounded "chip" overlay (same look as the float) anchored
--- to its top edge.
local M = {}

local api = vim.api
local bar = require 'rosavim.rosa_plugins.rosaterm.bar'
local themes = require 'rosavim.rosa_plugins.rosaterm.themes'

local terms = {}
local resize_au = nil

-- Forward declaration: referenced by the WinResized autocmd installed in
-- ensure_resize_au() before reposition_floats() is defined further down.
local reposition_floats

--- Pick the winhl for the terminal window. Dark mode follows the theme's
--- Normal bg (which is already dark). Light mode forces #000 — the shell
--- prompt assumes a dark terminal, and a light bg makes light-on-light
--- prompts unreadable.
local function term_winhl(border_on)
  local fb = border_on and ',FloatBorder:FloatBorder' or ''
  if vim.o.background == 'light' then
    api.nvim_set_hl(0, 'RosatermNormal', { bg = '#000000', fg = '#d4d0c8' })
    return 'Normal:RosatermNormal' .. fb
  end
  return 'Normal:Normal' .. fb
end

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
    -- Inline: small chip centered on the top border of the float. Sit
    -- one row above the float's top border so the chip's bottom border
    -- crosses the float's border (engraved tab look — chip body above,
    -- bottom corners crossing into the terminal).
    local text = bar.chip_plain()
    width = vim.api.nvim_strwidth(text)
    col = outer_col + math.floor((outer_width - width) / 2)
    row = pos[1] - 1
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
  api.nvim_create_autocmd({ 'WinResized' }, {
    group = resize_au,
    callback = function()
      vim.schedule(reposition_all_chips)
    end,
  })
  api.nvim_create_autocmd({ 'VimResized' }, {
    group = resize_au,
    callback = function()
      vim.schedule(function()
        reposition_floats()
        reposition_all_chips()
      end)
    end,
  })
  -- React to non-rosaterm window opens/closes (Snacks Explorer, Rosaai,
  -- etc) so the terminal float slides to respect the new layout. Events
  -- from the terminal's own chip overlays are filtered out to prevent
  -- the infinite WinNew → reposition → reopen-chip → WinNew loop.
  api.nvim_create_autocmd({ 'WinNew', 'WinClosed' }, {
    group = resize_au,
    callback = function(args)
      local w = tonumber(args.match) or args.win
      for _, t in pairs(terms) do
        if t.win == w or t.chip_win == w then
          return
        end
      end
      vim.schedule(function()
        reposition_floats()
        reposition_all_chips()
      end)
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
          vim.schedule(function()
            reposition_floats()
            reposition_all_chips()
          end)
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

--- Compute the editor "main area" rect, excluding left/right sidebars
--- (regular splits anchored to an edge) and other focusable floats
--- (Rosaai CLI, etc). Skips rosaterm windows so they don't constrain
--- themselves recursively.
local function compute_main_area(skip_terms)
  local cols = vim.o.columns
  local lines = vim.o.lines - vim.o.cmdheight - 1
  local left = 0
  local right = 0
  local skip = {}
  if skip_terms then
    for _, t in ipairs(skip_terms) do
      if t.win then
        skip[t.win] = true
      end
    end
  end
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if not skip[win] then
      local cfg = api.nvim_win_get_config(win)
      local buf = api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local is_rosaterm = ft == 'rosaterm'
      if not is_rosaterm and cfg.focusable ~= false then
        local pos = api.nvim_win_get_position(win)
        local w = api.nvim_win_get_width(win)
        local is_float = cfg.relative ~= ''
        local outer_w = w
        if is_float and cfg.border and cfg.border ~= 'none' then
          outer_w = w + 2
        end
        local outer_col = pos[2]
        local right_edge = outer_col + outer_w
        -- Anchored sidebars: a narrow window touching (or near) the
        -- left/right edge counts as a side panel. Snacks Picker /
        -- Explorer floats sit a cell or two inside the edge, so we
        -- give a 2-col tolerance.
        if outer_w < cols * 0.5 then
          if outer_col <= 2 then
            left = math.max(left, right_edge)
          elseif right_edge >= cols - 2 then
            right = math.max(right, cols - outer_col)
          end
        end
      end
    end
  end
  return { col = left, row = 0, width = cols - left - right, height = lines }
end

--- Find an existing open rosaterm with the perpendicular orientation, so
--- a new split can dock into the same band (horizontal + vertical
--- coexisting side-by-side at the bottom).
local function find_sibling(direction)
  local other = direction == 'horizontal' and 'vertical' or 'horizontal'
  for _, t in pairs(terms) do
    if term_win_is_open(t) and t.direction == other then
      local cfg = api.nvim_win_get_config(t.win)
      if cfg.relative and cfg.relative ~= '' then
        return t
      end
    end
  end
  return nil
end

--- Build the floating geometry for a terminal. When a perpendicular
--- sibling rosaterm is already open and we're being launched from inside
--- it, dock into the sibling's band (and shrink the sibling) instead of
--- spanning the whole main area.
local function compute_geom(term)
  local adj = 2
  local chip_room = term.direction == 'horizontal' and 0 or 2

  local in_term = vim.bo.filetype == 'rosaterm'
  local sibling = in_term and find_sibling(term.direction) or nil

  if sibling then
    local s_cfg = api.nvim_win_get_config(sibling.win)
    local has_border = s_cfg.border and s_cfg.border ~= 'none'
    local b_pad = has_border and 2 or 0
    local s_w = s_cfg.width
    local s_h = s_cfg.height
    local s_row = s_cfg.row
    local s_col = s_cfg.col
    local s_outer_w = s_w + b_pad
    local s_outer_h = s_h + b_pad

    if term.direction == 'vertical' and sibling.direction == 'horizontal' then
      local v_w = math.min(term.size, math.floor(s_outer_w / 2))
      if v_w < 10 or s_outer_w - v_w < 10 then
        return nil
      end
      api.nvim_win_set_config(sibling.win, {
        relative = 'editor',
        row = s_row,
        col = s_col,
        width = (s_outer_w - v_w) - b_pad,
        height = s_h,
        border = s_cfg.border,
      })
      return {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        col = s_col + (s_outer_w - v_w),
        row = s_row,
        width = v_w - adj,
        height = s_h,
      }
    elseif term.direction == 'horizontal' and sibling.direction == 'vertical' then
      local h_h = math.min(term.size, math.floor(s_outer_h / 2))
      if h_h < 4 or s_outer_h - h_h < 4 then
        return nil
      end
      api.nvim_win_set_config(sibling.win, {
        relative = 'editor',
        row = s_row,
        col = s_col,
        width = s_w,
        height = (s_outer_h - h_h) - b_pad,
        border = s_cfg.border,
      })
      return {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        col = s_col,
        row = s_row + (s_outer_h - h_h),
        width = s_w,
        height = h_h - adj,
      }
    end
  end

  local area = compute_main_area()
  if term.direction == 'horizontal' then
    local h = term.size
    return {
      relative = 'editor',
      style = 'minimal',
      border = 'rounded',
      width = area.width - adj,
      height = h - adj,
      row = area.height - h,
      col = area.col,
    }
  end
  local w = term.size
  return {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    width = w - adj,
    height = area.height - adj - chip_room,
    row = chip_room,
    col = area.col + area.width - w,
  }
end

--- Re-anchor every open rosaterm float to the current main area. Called
--- when a sidebar (Snacks Explorer) or perpendicular float toggles, so
--- the terminal slides over to make room. When both a horizontal and a
--- vertical rosaterm are open, preserve their docked side-by-side layout
--- at the bottom band.
reposition_floats = function()
  local open, horizontal, vertical = {}, nil, nil
  for _, t in pairs(terms) do
    if term_win_is_open(t) then
      local cfg = api.nvim_win_get_config(t.win)
      if cfg.relative and cfg.relative ~= '' then
        table.insert(open, t)
        if t.direction == 'horizontal' then
          horizontal = t
        end
        if t.direction == 'vertical' then
          vertical = t
        end
      end
    end
  end
  if #open == 0 then
    return
  end
  local area = compute_main_area(open)
  local adj = 2

  if horizontal and vertical then
    local h_cfg = api.nvim_win_get_config(horizontal.win)
    local v_cfg = api.nvim_win_get_config(vertical.win)
    local h_outer_h = h_cfg.height + adj
    local v_outer_w = math.min(v_cfg.width + adj, math.floor(area.width / 2))
    if v_outer_w < 10 then
      v_outer_w = math.floor(area.width / 2)
    end
    local new_h_outer_w = area.width - v_outer_w
    local row = area.height - h_outer_h
    pcall(api.nvim_win_set_config, horizontal.win, {
      relative = 'editor',
      width = new_h_outer_w - adj,
      height = h_outer_h - adj,
      row = row,
      col = area.col,
      border = h_cfg.border,
    })
    pcall(api.nvim_win_set_config, vertical.win, {
      relative = 'editor',
      width = v_outer_w - adj,
      height = h_outer_h - adj,
      row = row,
      col = area.col + new_h_outer_w,
      border = v_cfg.border,
    })
    return
  end

  for _, t in ipairs(open) do
    local cfg = api.nvim_win_get_config(t.win)
    local chip_room = t.direction == 'horizontal' and 0 or 2
    local geom
    if t.direction == 'horizontal' then
      geom = {
        relative = 'editor',
        width = area.width - adj,
        height = cfg.height,
        row = area.height - (cfg.height + adj),
        col = area.col,
        border = cfg.border,
      }
    else
      geom = {
        relative = 'editor',
        width = cfg.width,
        height = area.height - adj - chip_room,
        row = chip_room,
        col = area.col + area.width - (cfg.width + adj),
        border = cfg.border,
      }
    end
    pcall(api.nvim_win_set_config, t.win, geom)
  end
end

--- Apply a delta resize to a rosaterm float. dh = rows to add to height
--- (positive grows up from bottom); dw = cols to add to width (positive
--- grows left from right edge).
local function resize_term(term, dh, dw)
  if not term_win_is_open(term) then
    return false
  end
  local cfg = api.nvim_win_get_config(term.win)
  if not cfg.relative or cfg.relative == '' then
    return false
  end
  local new_w = cfg.width + dw
  local new_h = cfg.height + dh
  if new_w < 10 or new_h < 3 then
    return false
  end
  if term.direction == 'horizontal' and dh ~= 0 then
    cfg.row = cfg.row - dh
  end
  if term.direction == 'vertical' and dw ~= 0 then
    cfg.col = cfg.col - dw
  end
  cfg.width = new_w
  cfg.height = new_h
  pcall(api.nvim_win_set_config, term.win, cfg)
  term.size = (term.direction == 'horizontal' and new_h or new_w) + 2
  vim.schedule(reposition_all_chips)
  return true
end

--- Find an open rosaterm float matching the given direction.
local function find_term_by_direction(direction)
  for _, t in pairs(terms) do
    if term_win_is_open(t) and t.direction == direction then
      local cfg = api.nvim_win_get_config(t.win)
      if cfg.relative and cfg.relative ~= '' then
        return t
      end
    end
  end
  return nil
end

--- Public: resize the rosaterm float matching an arrow direction. Called
--- from smart-splits' fallback when no native split changed. dir = one of
--- 'up', 'down', 'left', 'right'. Returns true if a terminal was resized.
function M.resize_arrow(dir)
  if dir == 'up' or dir == 'down' then
    local t = find_term_by_direction 'horizontal'
    if not t then
      return false
    end
    return resize_term(t, dir == 'up' and 1 or -1, 0)
  end
  if dir == 'left' or dir == 'right' then
    local t = find_term_by_direction 'vertical'
    if not t then
      return false
    end
    return resize_term(t, 0, dir == 'left' and 1 or -1)
  end
  return false
end

--- Buffer-local arrow-key resize for rosaterm floats. smart-splits doesn't
--- handle floats; the arrows would otherwise be no-ops inside the terminal.
local function setup_resize_keymaps(buf, term)
  local opts = { buffer = buf, silent = true, nowait = true }
  for _, mode in ipairs { 'n', 't' } do
    if term.direction == 'horizontal' then
      vim.keymap.set(mode, '<Up>', function()
        resize_term(term, 1, 0)
      end, opts)
      vim.keymap.set(mode, '<Down>', function()
        resize_term(term, -1, 0)
      end, opts)
    else
      vim.keymap.set(mode, '<Left>', function()
        resize_term(term, 0, 1)
      end, opts)
      vim.keymap.set(mode, '<Right>', function()
        resize_term(term, 0, -1)
      end, opts)
    end
  end
end

local function open_split(term)
  local border_on = border_for(term.direction)

  if border_on then
    if not term.started then
      term.buf = api.nvim_create_buf(false, true)
      vim.bo[term.buf].bufhidden = 'hide'
      vim.bo[term.buf].filetype = 'rosaterm'
    end
    local geom = compute_geom(term)
    if not geom then
      return
    end
    term.win = api.nvim_open_win(term.buf, true, geom)
    vim.wo[term.win].winhl = term_winhl(true)
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
  if not border_on then
    vim.wo[term.win].winhl = term_winhl(false)
  end

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
  setup_resize_keymaps(term.buf, term)
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

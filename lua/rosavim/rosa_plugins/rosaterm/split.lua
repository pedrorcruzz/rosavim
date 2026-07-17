--- Rosaterm split - Horizontal/vertical terminal splits with toggle behavior
--- Each split gets a rounded "chip" overlay (same look as the float) anchored
--- to its top edge.
local M = {}

local api = vim.api
local bar = require 'rosavim.rosa_plugins.rosaterm.bar'
local themes = require 'rosavim.rosa_plugins.rosaterm.themes'
local term_bg = require 'rosavim.rosa_plugins.term_bg'
local reserve = require 'rosavim.rosa_plugins.panel_reserve'

local terms = {}
local resize_au = nil

-- Forward declaration: referenced by the WinResized autocmd installed in
-- ensure_resize_au() before reposition_floats() is defined further down.
local reposition_floats

local function term_win_is_open(term)
  return term.win and api.nvim_win_is_valid(term.win)
end

-- Re-derive the cursor-parking reservation for every terminal from its live
-- window geometry. A pinned horizontal float reserves rows (scrolloff), a
-- pinned vertical float reserves columns (sidescrolloff + nowrap); native
-- splits and closed terminals reserve nothing (real space / gone). Batched so
-- swapping a slot never flickers the editor's wrap. Mirrors rosaai.
local function update_reservations()
  reserve.batch(function()
    for _, t in pairs(terms) do
      local win = term_win_is_open(t) and t.win or nil
      reserve.track('rosaterm:' .. t.id, win, t.direction)
    end
  end)
end

--- Pick the winhl for the terminal window. Dark mode follows the theme's
--- Normal bg (which is already dark). Light mode forces #000 by default —
--- the shell prompt assumes a dark terminal, and a light bg makes
--- light-on-light prompts unreadable. The rosaterm_dark_bg toggle
--- (<leader>latd) lets the user opt back into the theme's light bg.
local function term_winhl(border_on)
  local fb = border_on and ',FloatBorder:FloatBorder' or ''
  return term_bg.winhl('rosaterm_dark_bg', true, 'RosatermNormal', fb)
end

local function chip_open(term)
  return term.chip_win and api.nvim_win_is_valid(term.chip_win)
end

local function close_chip(term)
  if chip_open(term) then
    pcall(api.nvim_win_close, term.chip_win, true)
  end
  term.chip_win = nil
  -- Also clear any winbar fallback the terminal window might have set.
  if term.win and api.nvim_win_is_valid(term.win) then
    pcall(function()
      vim.wo[term.win].winbar = ''
    end)
  end
  term._chip_mode = nil
end

local function open_chip(term)
  if not term_win_is_open(term) then
    return
  end
  local theme = themes.current()
  local pos = api.nvim_win_get_position(term.win) -- { row, col }
  local win_width = api.nvim_win_get_width(term.win)
  local cfg = api.nvim_win_get_config(term.win)
  local has_border = cfg.relative ~= '' and cfg.border and cfg.border ~= 'none'
  -- Chip content spans the window's INNER width; the chip's own rounded
  -- border then lands exactly on the window's border (engraved look),
  -- matching rosaai. The previous (win_width + 2) double-counted the chip
  -- border, leaving the banner 2 cells too wide and misaligned on the right.
  local outer_width = win_width
  local outer_col = pos[2]

  -- Fallback: when the terminal is a NATIVE split AND the chip overlay
  -- would clamp off-screen (pos[1] too low for a 3-row chip above), use
  -- the window's winbar to render the chip text inline. No rounded box,
  -- but perfect alignment with no gap and no content coverage. This is
  -- what fixes the vertical vsplit case where pos[1] = 0.
  if not has_border and pos[1] < 3 then
    pcall(api.nvim_win_close, term.chip_win or -1, true)
    term.chip_win = nil
    pcall(function()
      vim.wo[term.win].winbar = bar.winbar_text(win_width)
    end)
    term._chip_mode = 'winbar'
    return
  end
  -- Switching back to overlay mode? Clear any leftover winbar.
  if term._chip_mode == 'winbar' then
    pcall(function()
      vim.wo[term.win].winbar = ''
    end)
    term._chip_mode = nil
  end

  local width, col, row
  -- Position the chip so its bottom border lands exactly on the float's
  -- top border row (engraved look, zero gap). nvim_win_get_position
  -- returns the float's FRAME top (= top border row), so chip outer
  -- bottom must equal pos[1] → chip outer top = pos[1] - (outer_h - 1).
  --   banner: bordered, 1 content row → outer_h = 3 → row = pos[1] - 2
  --   inline: mirrors the float exactly so the chip sits ON the border
  --     line (not above it). Bloom (rounded) borders 3 rows → -1; Petal
  --     (borderless) is a single engraved row → -0.
  if theme.layout == 'banner' then
    width = outer_width
    col = outer_col
    row = pos[1] - 2
  else
    local text = bar.chip_plain()
    width = vim.api.nvim_strwidth(text)
    col = outer_col + math.floor((outer_width - width) / 2)
    row = pos[1] - (theme.border == 'none' and 0 or 1)
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
    height = 1,
    style = 'minimal',
    border = theme.border,
    focusable = false,
    zindex = 49,
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
    -- Inner window width — chip border supplies the +2 (see open_chip).
    local outer = api.nvim_win_get_width(term.win)
    if theme.layout == 'banner' then
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

-- Debounce reposition: layout events (WinResized, WinNew, WinClosed) can
-- fire many times in quick succession (interactive resizes, picker label
-- floats opening, diff view spawning multiple windows). Coalesce into one
-- reposition pass per ~16ms tick.
local reposition_timer = nil
local function schedule_reposition()
  if reposition_timer then
    pcall(function()
      reposition_timer:stop()
      reposition_timer:close()
    end)
  end
  reposition_timer = vim.uv.new_timer()
  reposition_timer:start(
    16,
    0,
    vim.schedule_wrap(function()
      reposition_timer = nil
      reposition_floats()
      reposition_all_chips()
      update_reservations()
    end)
  )
end

local function ensure_resize_au()
  if resize_au then
    return
  end
  resize_au = api.nvim_create_augroup('RosatermSplitChip', { clear = true })
  api.nvim_create_autocmd({ 'WinResized' }, {
    group = resize_au,
    callback = schedule_reposition,
  })
  api.nvim_create_autocmd({ 'VimResized' }, {
    group = resize_au,
    callback = schedule_reposition,
  })
  -- React to non-rosaterm window opens/closes (Snacks Explorer, RosaAI,
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
      schedule_reposition()
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
          update_reservations()
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

--- Sidebar filetypes that should ALWAYS count as side panels regardless
--- of size (Snacks Explorer, Neotree, NvimTree, oil, etc.). Editor diff
--- panes / vsplit halves are explicitly NOT sidebars even at 50% width.
local SIDEBAR_FILETYPES = {
  ['snacks_explorer'] = true,
  ['snacks_picker_list'] = true,
  ['snacks_picker_input'] = true,
  ['snacks_layout_box'] = true,
  ['neo-tree'] = true,
  ['NvimTree'] = true,
  ['oil'] = true,
  ['Outline'] = true,
  ['aerial'] = true,
  ['dbui'] = true,
  ['dbout'] = true,
  ['Trouble'] = true,
  ['trouble'] = true,
  ['undotree'] = true,
  ['diff'] = false, -- diff is part of the editing area, not a sidebar
}

--- Transient popup floats (completion menu/docs, signature, hover) must never
--- be mistaken for a side panel: they anchor to the cursor and are focusable,
--- so a narrow completion menu near the left edge would otherwise shrink and
--- slide the horizontal rosaterm every keystroke. Skip anything cursor-anchored
--- or carrying a known completion-popup filetype.
local POPUP_FILETYPES = {
  ['blink-cmp-menu'] = true,
  ['blink-cmp-documentation'] = true,
  ['blink-cmp-signature'] = true,
}

local function is_transient_popup(cfg, ft)
  return cfg.relative == 'cursor' or POPUP_FILETYPES[ft] == true
end

--- Compute the editor "main area" rect, excluding left/right sidebars
--- (regular splits anchored to an edge with a known sidebar filetype OR
--- a window that's both narrow AND edge-anchored). Diff/vsplit editor
--- panes are kept as part of the main area so a horizontal rosaterm
--- spans across them. Skips rosaterm windows so they don't constrain
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
      if not is_rosaterm and cfg.focusable ~= false and not is_transient_popup(cfg, ft) then
        local pos = api.nvim_win_get_position(win)
        local w = api.nvim_win_get_width(win)
        local is_float = cfg.relative ~= ''
        local outer_w = w
        if is_float and cfg.border and cfg.border ~= 'none' then
          outer_w = w + 2
        end
        local outer_col = pos[2]
        local right_edge = outer_col + outer_w
        local touches_left = outer_col <= 2
        local touches_right = right_edge >= cols - 2
        -- Two ways to count as a sidebar:
        --   1. Known sidebar filetype (Snacks Explorer, etc.) anchored to an edge
        --   2. Narrow window (< 35% of total cols) anchored to an edge
        -- Editor panes from :vsplit / diff view are ~50% each and must
        -- NOT trigger #2, which is why the threshold is tight.
        local is_known_sidebar = SIDEBAR_FILETYPES[ft] == true
        local is_narrow_edge = outer_w < cols * 0.35
        if (is_known_sidebar or is_narrow_edge) and (touches_left or touches_right) then
          if touches_left then
            left = math.max(left, right_edge)
          else
            right = math.max(right, cols - outer_col)
          end
        end
      end
    end
  end
  -- Safety: never let sidebars eat more than 70% of the screen.
  if left + right > cols * 0.7 then
    left, right = 0, 0
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
      -- Exactly half the sibling band — no term.size cap, which on wide
      -- screens left the new pane narrower than its sibling.
      local v_w = math.floor(s_outer_w / 2)
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
      local h_h = math.floor(s_outer_h / 2)
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
  update_reservations()
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
    -- Below the RosaAI float (main 50 / chip 60) so the AI window overlays
    -- this pinned terminal float when both are open. zindex is create-only,
    -- so set it on the open geom without mutating the cached geometry.
    term.win = api.nvim_open_win(term.buf, true, vim.tbl_extend('force', geom, { zindex = 45 }))
    vim.wo[term.win].winhl = term_winhl(true)
    -- (winbar workaround removed — chip now lands its bottom border on
    -- the float's top border row, so it never covers content row 0.)
    -- A pinned float covers editor cells nvim doesn't know about, so the
    -- cursor could fall behind it. update_reservations() (end of this fn)
    -- reserves the panel's rows (horizontal) or columns (vertical) so the
    -- cursor parks before it — the buffer still scrolls to reach any cell.
  else
    -- Native split mode (no border possible — preserves the historical look)
    local in_terminal = vim.bo.filetype == 'rosaterm'
    if in_terminal then
      -- Split the focused terminal and force EXACTLY equal halves. nvim's
      -- size-arg / default split can leave one side a column (or more) bigger;
      -- we set the new window to floor(total/2) so both panels match.
      local prev = api.nvim_get_current_win()
      vim.cmd('rightbelow ' .. (term.direction == 'horizontal' and 'split' or 'vsplit'))
      term.win = api.nvim_get_current_win()
      if term.direction == 'vertical' then
        local total = api.nvim_win_get_width(prev) + api.nvim_win_get_width(term.win)
        pcall(api.nvim_win_set_width, term.win, math.floor(total / 2))
      else
        local total = api.nvim_win_get_height(prev) + api.nvim_win_get_height(term.win)
        pcall(api.nvim_win_set_height, term.win, math.floor(total / 2))
      end
    else
      -- Opening from a normal buffer: pin to the bottom/right at preset size.
      local cmd = 'botright ' .. term.size .. (term.direction == 'horizontal' and 'split' or 'vsplit')
      vim.cmd(cmd)
      term.win = api.nvim_get_current_win()
    end
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

  -- Float mode parks the cursor before the panel; native split reserves real
  -- space (track() clears the claim). Covers both branches above.
  update_reservations()

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

--- Re-apply the current size preset to every rosaterm split. Open splits are
--- reloaded so they pick up the new geometry; closed ones just update their
--- stored size for the next open. Mirrors RosaAI's size picker.
function M.apply_size()
  local sizes = require 'rosavim.rosa_plugins.rosaterm.sizes'
  for _, term in pairs(terms) do
    term.size = sizes.for_direction(term.direction)
  end
  M.reload_all()
end

function M.toggle(id, direction, size, name)
  local term = terms[id]
  if not term then
    -- Size is governed by the global size preset (<leader>latz). The legacy
    -- `size` arg from callers is kept only for signature compatibility.
    local sizes = require 'rosavim.rosa_plugins.rosaterm.sizes'
    term = {
      id = id,
      direction = direction,
      size = sizes.for_direction(direction),
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

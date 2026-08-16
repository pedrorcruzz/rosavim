--- Rosaterm split - Horizontal/vertical terminal splits with toggle behavior
--- Each split gets a rounded "chip" overlay (same look as the float) anchored
--- to its top edge.
local M = {}

local api = vim.api
local bar = require 'rosavim.rosa_plugins.rosaterm.bar'
local themes = require 'rosavim.rosa_plugins.rosaterm.themes'
local term_bg = require 'rosavim.helpers.term_bg'
local reserve = require 'rosavim.helpers.panel_reserve'

local terms = {}
local resize_au = nil

-- Forward declaration: referenced by the WinResized autocmd installed in
-- ensure_resize_au() before reposition_floats() is defined further down.
local reposition_floats

local function vertical_side()
  return require('rosavim.helpers.panel_side').vertical()
end

local function term_win_is_open(term)
  return term.win and api.nvim_win_is_valid(term.win)
end

-- Re-derive the cursor-parking reservation for every terminal from its live
-- window geometry. A pinned horizontal float reserves rows (scrolloff), a
-- pinned vertical float reserves columns (sidescrolloff + nowrap); native
-- splits and closed terminals reserve nothing (real space / gone). Batched so
-- swapping a slot never flickers the editor's wrap. Mirrors rosaai.
local function update_reservations()
  -- Top row of the horizontal terminal's band, when one is open as a float.
  local band_top = nil
  for _, t in pairs(terms) do
    if t.direction == 'horizontal' and term_win_is_open(t) then
      local cfg = api.nvim_win_get_config(t.win)
      if cfg.relative and cfg.relative ~= '' then
        band_top = cfg.row
      end
    end
  end
  reserve.batch(function()
    for _, t in pairs(terms) do
      local win = term_win_is_open(t) and t.win or nil
      -- A docked vertical panel lives inside rows the horizontal one already
      -- reserves; claiming its columns too would carve a full-height spacer
      -- and squeeze the editor into the left half.
      if win and band_top and t.direction == 'vertical' then
        local cfg = api.nvim_win_get_config(win)
        if cfg.relative and cfg.relative ~= '' and cfg.row >= band_top then
          win = nil
        end
      end
      reserve.track('rosaterm:' .. t.id, win, t.direction)
    end
  end)
end

--- Pick the winhl for the terminal window. Dark mode follows the theme's
--- Normal bg (which is already dark). Light mode forces #000 by default —
--- the shell prompt assumes a dark terminal, and a light bg makes
--- light-on-light prompts unreadable. The rosaterm_dark_bg toggle
--- (<leader>lqrd) lets the user opt back into the theme's light bg.
local function term_winhl(border_on)
  local fb = border_on and (',FloatBorder:' .. term_bg.border_hl 'rosaterm') or ''
  return term_bg.winhl('rosaterm', fb)
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
    zindex = 46,
  })
  vim.wo[term.chip_win].winhl = require('rosavim.helpers.term_bg').chip_winhl 'rosaterm'
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

--- Whether any rosaterm window is currently open (float or native split).
local function any_term_open()
  for _, t in pairs(terms) do
    if term_win_is_open(t) then
      return true
    end
  end
  return false
end

-- A foreign floating window (notify toast, picker, cmdline popup) drawn over a
-- pinned terminal float leaves ghosted terminal cells when it closes — Nvim
-- does not repaint the cells it covered, so the panel shows a stale black block
-- until it is focused. Repaint proactively when such a float closes while a
-- terminal is open. Debounced so a burst of closes coalesces into one redraw.
local repaint_timer = nil
local function schedule_repaint()
  if not any_term_open() then
    return
  end
  if repaint_timer then
    pcall(function()
      repaint_timer:stop()
      repaint_timer:close()
    end)
  end
  repaint_timer = vim.uv.new_timer()
  repaint_timer:start(
    30,
    0,
    vim.schedule_wrap(function()
      repaint_timer = nil
      if any_term_open() then
        pcall(vim.cmd, 'redraw!')
      end
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
      -- A foreign float closing over a pinned terminal leaves ghosted cells;
      -- repaint so the panel never stays half-blank until it is focused.
      if args.event == 'WinClosed' then
        schedule_repaint()
      end
      -- Floating windows (notify toasts, pickers, chips) don't change the
      -- split-based editor area, so they must not trigger a reposition (which
      -- re-runs the reservation and can crush the panel / raise E36).
      if w and api.nvim_win_is_valid(w) then
        local ok, cfg = pcall(api.nvim_win_get_config, w)
        if ok and cfg.relative and cfg.relative ~= '' then
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

--- Extra cells a float's border adds around its inner size (0 when borderless).
local function border_pad(cfg)
  return (cfg.border and cfg.border ~= 'none') and 2 or 0
end

--- True when the focused window is a rosaterm float. `:vsplit` from a float
--- carves the new pane out of the layout BEHIND it, never beside it.
local function in_rosaterm_float()
  if vim.bo.filetype ~= 'rosaterm' then
    return false
  end
  local cfg = api.nvim_win_get_config(api.nvim_get_current_win())
  return cfg.relative ~= nil and cfg.relative ~= ''
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
      -- panel_reserve spacers are invisible layout-only reservations pinned
      -- under a float; never let one masquerade as a side panel.
      local is_spacer = ft == 'rosa_spacer'
      if not is_rosaterm and not is_spacer and cfg.focusable ~= false and not is_transient_popup(cfg, ft) then
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
        --   2. Narrow non-file window (< 35% of total cols) anchored to an edge
        -- Editor panes from :vsplit / diff view are never sidebars, even when a
        -- third split drops them under the threshold.
        local is_known_sidebar = SIDEBAR_FILETYPES[ft] == true
        local is_narrow_edge = vim.bo[buf].buftype ~= '' and outer_w < cols * 0.35
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
  -- Padding follows the border: a forced-float terminal keeps its own
  -- border preference.
  local border = border_for(term.direction) and 'rounded' or 'none'
  local adj = border == 'none' and 0 or 2
  local chip_room = term.direction == 'horizontal' and 0 or 2

  local in_term = vim.bo.filetype == 'rosaterm'
  local sibling = in_term and find_sibling(term.direction) or nil

  if sibling then
    local s_cfg = api.nvim_win_get_config(sibling.win)
    local b_pad = border_pad(s_cfg)
    -- Dock wearing the SIBLING's border: a frame costs 2 cells, so mismatched
    -- frames draw visibly different boxes at the same outer size. The border
    -- preference still rules when the panel stands alone.
    border, adj = s_cfg.border, b_pad
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
        border = border,
        col = s_col + (s_outer_w - v_w),
        row = s_row,
        width = v_w - adj,
        height = s_outer_h - adj,
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
        border = border,
        col = s_col,
        row = s_row + (s_outer_h - h_h),
        width = s_outer_w - adj,
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
      border = border,
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
    border = border,
    width = w - adj,
    height = area.height - adj - chip_room,
    row = chip_room,
    col = vertical_side() == 'left' and area.col or (area.col + area.width - w),
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

  if horizontal and vertical then
    local h_cfg = api.nvim_win_get_config(horizontal.win)
    local v_cfg = api.nvim_win_get_config(vertical.win)
    local h_pad = border_pad(h_cfg)
    local v_pad = border_pad(v_cfg)
    local h_outer_h = h_cfg.height + h_pad
    -- Place the divider from the STORED fraction (even halves until an arrow
    -- moves it). Re-deriving it from the rounded widths every reflow loses a
    -- column per pass, so the pair walks sideways as the explorer toggles.
    local v_outer_w = math.floor(area.width * (vertical.band_frac or 0.5) + 0.5)
    if v_outer_w < 10 or v_outer_w > area.width - 10 then
      v_outer_w = math.floor(area.width / 2)
    end
    local new_h_outer_w = area.width - v_outer_w
    local row = area.height - h_outer_h
    local v_left = vertical_side() == 'left'
    pcall(api.nvim_win_set_config, horizontal.win, {
      relative = 'editor',
      width = new_h_outer_w - h_pad,
      height = h_outer_h - h_pad,
      row = row,
      col = v_left and (area.col + v_outer_w) or area.col,
      border = h_cfg.border,
    })
    pcall(api.nvim_win_set_config, vertical.win, {
      relative = 'editor',
      width = v_outer_w - v_pad,
      height = h_outer_h - v_pad,
      row = row,
      col = v_left and area.col or (area.col + new_h_outer_w),
      border = v_cfg.border,
    })
    return
  end

  for _, t in ipairs(open) do
    local cfg = api.nvim_win_get_config(t.win)
    local pad = border_pad(cfg)
    local chip_room = t.direction == 'horizontal' and 0 or 2
    local geom
    if t.direction == 'horizontal' then
      geom = {
        relative = 'editor',
        width = area.width - pad,
        height = cfg.height,
        row = area.height - (cfg.height + pad),
        col = area.col,
        border = cfg.border,
      }
    else
      geom = {
        relative = 'editor',
        width = cfg.width,
        height = area.height - pad - chip_room,
        row = chip_room,
        col = vertical_side() == 'left' and area.col or (area.col + area.width - (cfg.width + pad)),
        border = cfg.border,
      }
    end
    pcall(api.nvim_win_set_config, t.win, geom)
  end
end

--- The perpendicular float sharing this one's band. The pair always gets the
--- same border, so equal row + height identifies it.
local function docked_partner(term, cfg)
  for _, t in pairs(terms) do
    if t ~= term and t.direction ~= term.direction and term_win_is_open(t) then
      local o = api.nvim_win_get_config(t.win)
      if o.relative and o.relative ~= '' and o.row == cfg.row and o.height == cfg.height then
        return t, o
      end
    end
  end
  return nil
end

--- Resize a docked pair as one band: left/right moves the shared divider,
--- up/down moves the band's top edge. Resizing only the focused pane would
--- slide it over its partner instead of pushing it.
local function resize_band(term, cfg, partner, p_cfg, dh, dw)
  if dh ~= 0 then
    local new_h = cfg.height + dh
    if new_h < 3 then
      return false
    end
    for _, pair in ipairs { { term, cfg }, { partner, p_cfg } } do
      local t, c = pair[1], pair[2]
      c.height = new_h
      c.row = c.row - dh
      pcall(api.nvim_win_set_config, t.win, c)
      if t.direction == 'horizontal' then
        t.size = new_h + 2
      end
    end
  else
    local vert, v_cfg, horz, h_cfg = term, cfg, partner, p_cfg
    if term.direction == 'horizontal' then
      vert, v_cfg, horz, h_cfg = partner, p_cfg, term, cfg
    end
    -- The arrow moves the divider that way, so which pane grows depends on
    -- the side the vertical panel is docked to.
    local grow = v_cfg.col > h_cfg.col and dw or -dw
    local v_new, h_new = v_cfg.width + grow, h_cfg.width - grow
    if v_new < 10 or h_new < 10 then
      return false
    end
    if v_cfg.col > h_cfg.col then
      v_cfg.col = v_cfg.col - grow
    else
      h_cfg.col = h_cfg.col + grow
    end
    v_cfg.width, h_cfg.width = v_new, h_new
    pcall(api.nvim_win_set_config, vert.win, v_cfg)
    pcall(api.nvim_win_set_config, horz.win, h_cfg)
    vert.size = v_new + 2
    local v_outer = v_new + border_pad(v_cfg)
    vert.band_frac = v_outer / (v_outer + h_new + border_pad(h_cfg))
  end
  update_reservations()
  vim.schedule(reposition_all_chips)
  return true
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
  local partner, p_cfg = docked_partner(term, cfg)
  if partner then
    return resize_band(term, cfg, partner, p_cfg, dh, dw)
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

--- The rosaterm float that currently has focus, if any.
local function focused_term()
  local cur = api.nvim_get_current_win()
  for _, t in pairs(terms) do
    if term_win_is_open(t) and t.win == cur then
      local cfg = api.nvim_win_get_config(t.win)
      if cfg.relative and cfg.relative ~= '' then
        return t
      end
    end
  end
  return nil
end

--- Resize `term` from an arrow key. A standalone panel answers only its own
--- axis; a docked pair is one band, so both panes answer all four arrows.
local function arrow_resize(term, dir)
  if not term_win_is_open(term) then
    return false
  end
  local cfg = api.nvim_win_get_config(term.win)
  if not cfg.relative or cfg.relative == '' then
    return false
  end
  local vertical_axis = dir == 'up' or dir == 'down'
  local own_axis = (term.direction == 'horizontal') == vertical_axis
  if not own_axis and not docked_partner(term, cfg) then
    return false
  end
  if vertical_axis then
    return resize_term(term, dir == 'up' and 1 or -1, 0)
  end
  return resize_term(term, 0, dir == 'left' and 1 or -1)
end

--- Resize the FOCUSED rosaterm float. Only the focused one answers, so an open
--- but unfocused panel never swallows a globally mapped arrow.
function M.resize_arrow(dir)
  local t = focused_term()
  return t ~= nil and arrow_resize(t, dir)
end

--- Buffer-local arrow resize: smart-splits can't see floats, so the arrows
--- would be no-ops inside the terminal. A direction the panel can't use falls
--- back to smart-splits, keeping the key's usual meaning.
local function setup_resize_keymaps(buf, term)
  local opts = { buffer = buf, silent = true, nowait = true }
  for _, mode in ipairs { 'n', 't' } do
    for _, dir in ipairs { 'up', 'down', 'left', 'right' } do
      vim.keymap.set(mode, '<' .. dir .. '>', function()
        if arrow_resize(term, dir) then
          return
        end
        local ok, ss = pcall(require, 'smart-splits')
        if ok and type(ss['resize_' .. dir]) == 'function' then
          pcall(ss['resize_' .. dir])
        end
      end, opts)
    end
  end
end

local function open_split(term)
  local border_on = border_for(term.direction)
  -- Borderless means "native split", but a native split can't dock next to a
  -- pinned float — it lands underneath. Launching from a float forces float
  -- mode; the border preference itself is untouched.
  local float_mode = border_on or in_rosaterm_float()

  if float_mode then
    if not term.started then
      term.buf = api.nvim_create_buf(false, true)
      vim.bo[term.buf].bufhidden = 'hide'
      vim.bo[term.buf].filetype = 'rosaterm'
    end
    local geom = compute_geom(term)
    if not geom then
      return
    end
    -- compute_geom always docks at even halves; forget any stored split so a
    -- reflow doesn't immediately snap the fresh pane elsewhere.
    term.band_frac = nil
    -- Edge-pinned tier (45): a centered float (rosaterm/rosaai float, 55) always
    -- overlays this pinned terminal, and yazi/lazygit (70) stay on top of all.
    -- zindex is create-only, so set it on the open geom without mutating cache.
    term.win = api.nvim_open_win(term.buf, true, vim.tbl_extend('force', geom, { zindex = 45 }))
    -- Follow the border the window ACTUALLY got, not the toggle: a docked pane
    -- inherits its sibling's frame, and without the matching FloatBorder
    -- highlight it renders visible instead of blending into the terminal bg.
    vim.wo[term.win].winhl = term_winhl(geom.border and geom.border ~= 'none')
    -- (winbar workaround removed — chip now lands its bottom border on
    -- the float's top border row, so it never covers content row 0.)
    -- A pinned float covers editor cells nvim doesn't know about, so the
    -- cursor could fall behind it. update_reservations() (end of this fn)
    -- reserves the panel's rows (horizontal) or columns (vertical) so the
    -- cursor parks before it — the buffer still scrolls to reach any cell.
  else
    -- Native split mode (no border possible — preserves the historical look).
    -- Only reachable from a native rosaterm split; floats went the branch above.
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
      local modifier = 'botright'
      if term.direction == 'vertical' and vertical_side() == 'left' then
        modifier = 'topleft'
      end
      local cmd = modifier .. ' ' .. term.size .. (term.direction == 'horizontal' and 'split' or 'vsplit')
      vim.cmd(cmd)
      term.win = api.nvim_get_current_win()
    end
  end

  vim.wo[term.win].number = false
  vim.wo[term.win].relativenumber = false
  vim.wo[term.win].signcolumn = 'no'
  if not float_mode then
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
--- (native split ↔ pinned float). Called when lqrb/lqrB toggle changes.
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

--- Put every open panel back to its preset size and an even 50/50 band,
--- dropping any arrow resizing.
function M.reset_sizes()
  local sizes = require 'rosavim.rosa_plugins.rosaterm.sizes'
  local open = {}
  for _, t in pairs(terms) do
    t.size = sizes.for_direction(t.direction)
    t.band_frac = nil
    if term_win_is_open(t) then
      local cfg = api.nvim_win_get_config(t.win)
      if cfg.relative and cfg.relative ~= '' then
        open[#open + 1] = t
      end
    end
  end
  if #open == 0 then
    return
  end
  for _, t in ipairs(open) do
    local cfg = api.nvim_win_get_config(t.win)
    local pad = border_pad(cfg)
    if t.direction == 'horizontal' then
      cfg.height = t.size - pad
    else
      cfg.width = t.size - pad
    end
    pcall(api.nvim_win_set_config, t.win, cfg)
  end
  reposition_floats()
  update_reservations()
  vim.schedule(reposition_all_chips)
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
    -- Size is governed by the global size preset (<leader>lqrz). The legacy
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

--- Every split terminal with a live session, in a stable order.
function M.list()
  local out = {}
  for _, t in pairs(terms) do
    out[#out + 1] = { id = t.id, name = t.name, direction = t.direction, open = term_win_is_open(t) }
  end
  table.sort(out, function(a, b)
    return a.id < b.id
  end)
  return out
end

--- End a split terminal for good: window, chip, job and buffers. Toggling only
--- hides the window; this is what the shell exiting would do.
function M.close(id)
  local term = terms[id]
  if not term then
    return false
  end
  if term_win_is_open(term) then
    bar.detach(term.win)
    pcall(api.nvim_win_close, term.win, false)
  end
  close_chip(term)
  term.win = nil
  terms[id] = nil
  if term.job then
    pcall(vim.fn.jobstop, term.job)
  end
  for _, buf in ipairs { term.chip_buf, term.buf } do
    if buf and api.nvim_buf_is_valid(buf) then
      pcall(api.nvim_buf_delete, buf, { force = true })
    end
  end
  update_reservations()
  vim.schedule(function()
    reposition_floats()
    reposition_all_chips()
  end)
  return true
end

--- End the split terminal living in `win`, if any.
function M.close_win(win)
  for _, t in pairs(terms) do
    if t.win == win then
      return M.close(t.id)
    end
  end
  return false
end

--- Close every split terminal.
function M.close_all()
  local ids = {}
  for id in pairs(terms) do
    ids[#ids + 1] = id
  end
  for _, id in ipairs(ids) do
    M.close(id)
  end
  return #ids
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

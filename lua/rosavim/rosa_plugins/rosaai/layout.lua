--- RosaAI layout - Window positioning, sizing and theme border
--- Every position is a floating window pinned to an edge (or centered for
--- `float`). Splits would have no border, so right/left/bottom are floats
--- pinned to the corresponding edge — the active theme's `window` border
--- then applies in every position.
local M = {}

local api = vim.api
local term_bg = require 'rosavim.rosa_plugins.term_bg'

M.positions = {
  { name = 'right', label = 'Right', icon = '󰕴 ', desc = 'Pinned to the right edge' },
  { name = 'left', label = 'Left', icon = '󰕶 ', desc = 'Pinned to the left edge' },
  { name = 'bottom', label = 'Bottom', icon = '󰜨 ', desc = 'Pinned to the bottom edge' },
  { name = 'float', label = 'Float', icon = '󰕯 ', desc = 'Centered floating window' },
}

M.sizes = {
  { name = 'compact', label = 'Compact', icon = '󰍝 ', width = 56, height = 14, float = { wpct = 0.74, hpct = 0.70 } },
  { name = 'default', label = 'Default', icon = '󰍡 ', width = 70, height = 20, float = { wpct = 0.85, hpct = 0.85 } },
  { name = 'wide', label = 'Wide', icon = '󰍟 ', width = 90, height = 26, float = { wpct = 0.95, hpct = 0.92 } },
}

--- Runtime per-position size overrides set by interactive arrow resize.
--- Each entry is { width, height } (inner cells). compute_geom only honors
--- the axis the position actually resizes, so the other axis stays
--- responsive to VimResized. Cleared when a named size preset is picked.
M.overrides = {}

function M.set_override(pos, width, height)
  M.overrides[pos] = { width = width, height = height }
end

function M.clear_overrides()
  M.overrides = {}
end

local function tog_get(key, default)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return default
  end
  local v = toggles.get(key)
  if v == nil then
    return default
  end
  return v
end

function M.current_position()
  return tog_get('rosaai_position', 'right')
end

function M.current_size()
  return tog_get('rosaai_size', 'default')
end

--- Float window border. Per-orientation toggles:
--- - vertical (right/left/float) → rosaai_vertical_border (<leader>laab)
--- - horizontal (bottom)         → rosaai_horizontal_border (<leader>laaB)
--- When the relevant toggle is off, force 'none' regardless of theme.
function M.current_border(pos)
  pos = pos or M.current_position()
  local key = pos == 'bottom' and 'rosaai_horizontal_border' or 'rosaai_vertical_border'
  if not tog_get(key, true) then
    return 'none'
  end
  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  if ok then
    return themes.current().window or 'rounded'
  end
  return 'rounded'
end

--- Chip overlay border (always follows the active theme — the window
--- toggle does not affect the chip).
function M.chip_border()
  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  if ok then
    return themes.current().border or 'rounded'
  end
  return 'rounded'
end

--- Rows the chip overlay needs ABOVE the float. For bordered chips, the
--- chip's bottom border merges with the float's top border (engraved
--- look), so we reserve one fewer row.
function M.chip_overlay_height()
  if not tog_get('rosaai_title', true) then
    return 0
  end
  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  if not ok then
    return 0
  end
  local t = themes.current()
  local has_border = M.chip_border() ~= 'none'
  local content = t.layout == 'stem' and 2 or 1
  local total = content + (has_border and 2 or 0)
  return has_border and (total - 1) or total
end

local function size_spec()
  local name = M.current_size()
  for _, s in ipairs(M.sizes) do
    if s.name == name then
      return s
    end
  end
  return M.sizes[2]
end

--- A border adds 2 cells per axis (one for each side)
local function border_adj(border)
  if border == 'none' or border == '' or border == nil then
    return 0
  end
  return 2
end

--- Sidebar filetypes that always count as side panels regardless of width
--- (Snacks Explorer, Neotree, oil, Trouble, ...). Editor vsplit/diff panes
--- are explicitly NOT sidebars even at ~50% width. Mirrors rosaterm.
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
}

--- Compute the editor "main area" (col + width) for the current tabpage,
--- excluding left/right side panels — a known sidebar filetype OR a narrow
--- window anchored to an edge. The rosaai float and any non-focusable
--- overlays (chips) are skipped so it never constrains itself. Used only by
--- the bottom (horizontal) position so it slides/shrinks when a sidebar opens.
function M.compute_main_area()
  local cols = vim.o.columns
  local left, right = 0, 0
  -- RosaAI vertical slots (right/left) are floats, so they don't reserve
  -- editor columns on their own. Treat them as side panels here so the bottom
  -- (horizontal) slot shrinks to sit BESIDE them instead of sliding under.
  local rosaai_side = {}
  local ok_state, state = pcall(require, 'rosavim.rosa_plugins.rosaai.state')
  if ok_state then
    for _, p in ipairs { 'right', 'left' } do
      local sl = state.slot(p)
      if sl then
        rosaai_side[sl.win] = true
      end
    end
  end
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local ok, cfg = pcall(api.nvim_win_get_config, win)
    if ok and cfg.focusable ~= false then
      local buf = api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      -- Skip our OWN horizontal/float slots, but keep vertical slots in play.
      if ft ~= 'rosaai' or rosaai_side[win] then
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
        -- Our vertical slots always count as side panels regardless of width.
        local is_known_sidebar = SIDEBAR_FILETYPES[ft] == true or rosaai_side[win] == true
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
  return { col = left, width = cols - left - right }
end

--- Compute the floating window options for a position+size+theme. When `pos`
--- is omitted, uses the currently configured position (compat).
function M.compute_geom(pos)
  pos = pos or M.current_position()
  local size = size_spec()
  local border = M.current_border(pos)
  local cols = vim.o.columns
  local lines = vim.o.lines - vim.o.cmdheight - 1
  local adj = border_adj(border)
  local ov = M.overrides[pos]

  local base = {
    relative = 'editor',
    style = 'minimal',
    border = border,
  }

  if pos == 'float' then
    -- Float resizes on both axes, so honor both override dimensions.
    local width = ov and ov.width or (math.floor(cols * size.float.wpct) - adj)
    local height = ov and ov.height or (math.floor(lines * size.float.hpct) - adj)
    base.width = math.min(width, cols - adj)
    base.height = math.min(height, lines - adj)
    base.row = math.floor((lines - (base.height + adj)) / 2)
    base.col = math.floor((cols - (base.width + adj)) / 2)
    return base, 'float'
  end

  -- Reserve rows at the top for the chip overlay so it sits fully above
  -- the float when pinned to row 0. Height of the chip depends on theme.
  local chip_room = M.chip_overlay_height()

  if pos == 'right' then
    -- Vertical: only width is user-resizable; height tracks the editor.
    base.width = ov and ov.width or (size.width - adj)
    base.height = lines - adj - chip_room
    base.row = chip_room
    base.col = cols - (base.width + adj)
    return base, 'right'
  end

  if pos == 'left' then
    base.width = ov and ov.width or (size.width - adj)
    base.height = lines - adj - chip_room
    base.row = chip_room
    base.col = 0
    return base, 'left'
  end

  -- bottom — horizontal: only height is user-resizable; width spans the
  -- editor MAIN AREA (excluding side panels like Snacks Explorer), so the
  -- float shrinks and slides over when a sidebar opens/closes. Mirrors
  -- rosaterm's horizontal pinned float.
  local area = M.compute_main_area()
  -- A left side panel is a native split, so there is a 1-col window
  -- separator between it and the editor. nvim draws a float's LEFT border at
  -- `col - 1`, so a bordered float placed at area.col would land its border
  -- (and the chip's) one column INSIDE the panel. Nudge right by 1 so the
  -- border sits on the separator and the content lines up with the editor.
  -- No nudge when flush to the screen edge (area.col == 0).
  local nudge = (adj > 0 and area.col > 0) and 1 or 0
  base.width = area.width - adj
  base.height = ov and ov.height or (size.height - adj)
  base.row = lines - (base.height + adj)
  base.col = area.col + nudge
  return base, 'bottom'
end

--- Open a floating window for the given buffer at `pos`. When `prev_win` is
--- valid it is closed first (used to replace a slot's occupant in place).
function M.open(buf, prev_win, pos)
  local geom, kind = M.compute_geom(pos)
  if prev_win and api.nvim_win_is_valid(prev_win) then
    pcall(api.nvim_win_close, prev_win, true)
  end
  local win = api.nvim_open_win(buf, true, geom)

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  -- Light mode: force #000 when rosaai_dark_bg is on (<leader>laad). Defaults
  -- off, so the CLI follows the theme's light bg until the user opts in.
  vim.wo[win].winhl = term_bg.winhl('rosaai_dark_bg', false, 'RosaaiNormal', ',FloatBorder:FloatBorder,WinBar:Normal,WinBarNC:Normal')
  vim.wo[win].winbar = ''
  return win, kind
end

return M

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
  { name = 'compact', label = 'Compact', icon = '󰍝 ', width = 50, height = 14, float = { wpct = 0.70, hpct = 0.70 } },
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
function M.current_border()
  local pos = M.current_position()
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

--- Compute the floating window options for the current position+size+theme
function M.compute_geom()
  local pos = M.current_position()
  local size = size_spec()
  local border = M.current_border()
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

  -- bottom — horizontal: only height is user-resizable; width spans editor.
  base.width = cols - adj
  base.height = ov and ov.height or (size.height - adj)
  base.row = lines - (base.height + adj)
  base.col = 0
  return base, 'bottom'
end

--- Open (or reuse) the shared floating window for the given buffer
function M.open(buf, prev_win)
  local geom, kind = M.compute_geom()
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

--- Rosaterm sizes - Named size presets (compact / default / wide) shared by
--- vertical splits (width), horizontal splits (height) and the float (pct).
--- Values mirror RosaAI's presets so both plugins feel identical.
local M = {}

M.list = {
  { name = 'compact', label = 'Compact', icon = '󰍝 ', vertical = 56, horizontal = 14, float = { wpct = 0.74, hpct = 0.70 } },
  { name = 'default', label = 'Default', icon = '󰍡 ', vertical = 70, horizontal = 20, float = { wpct = 0.85, hpct = 0.85 } },
  { name = 'wide', label = 'Wide', icon = '󰍟 ', vertical = 90, horizontal = 26, float = { wpct = 0.95, hpct = 0.92 } },
}

--- The currently selected preset (falls back to 'default')
function M.current()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  local name = ok and toggles.get 'rosaterm_size' or 'default'
  for _, s in ipairs(M.list) do
    if s.name == name then
      return s
    end
  end
  return M.list[2]
end

--- Outer size (cells, including the 2-cell border) for a split direction:
--- vertical → width, horizontal → height.
function M.for_direction(direction)
  local s = M.current()
  return direction == 'horizontal' and s.horizontal or s.vertical
end

return M

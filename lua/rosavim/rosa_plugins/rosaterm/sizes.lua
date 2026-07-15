--- Rosaterm sizes - Named size presets (compact / default / wide) applied
--- INDEPENDENTLY per display mode: float (pct), vertical split (width) and
--- horizontal split (height). So the user can run e.g. a Compact vertical
--- split while the float stays Wide. Values mirror RosaAI's presets.
local M = {}

M.list = {
  { name = 'compact', label = 'Compact', icon = '󰍝 ', vertical = 56, horizontal = 14, float = { wpct = 0.74, hpct = 0.70 } },
  { name = 'default', label = 'Default', icon = '󰍡 ', vertical = 70, horizontal = 20, float = { wpct = 0.85, hpct = 0.85 } },
  { name = 'wide', label = 'Wide', icon = '󰍟 ', vertical = 90, horizontal = 26, float = { wpct = 0.95, hpct = 0.92 } },
}

local MODES = { 'float', 'vertical', 'horizontal' }

local function toggles()
  local ok, t = pcall(require, 'rosavim.config.toggles')
  return ok and t or nil
end

local function key(mode)
  return 'rosaterm_size_' .. mode
end

--- Seed the per-mode toggles once from the legacy single `rosaterm_size`
--- value (so an existing preference carries over). Idempotent: after the
--- first run the per-mode keys are set, so this becomes a no-op.
local migrated = false
local function migrate()
  if migrated then
    return
  end
  migrated = true
  local t = toggles()
  if not t then
    return
  end
  local legacy = t.get 'rosaterm_size' or 'default'
  for _, mode in ipairs(MODES) do
    if t.get(key(mode)) == nil then
      t.set(key(mode), legacy)
    end
  end
end

--- Look up a preset by name (falls back to 'default').
function M.by_name(name)
  for _, s in ipairs(M.list) do
    if s.name == name then
      return s
    end
  end
  return M.list[2]
end

--- Current preset name for a mode ('float'|'vertical'|'horizontal').
function M.name(mode)
  migrate()
  local t = toggles()
  return (t and t.get(key(mode))) or 'default'
end

--- Current preset (full spec) for a mode.
function M.get(mode)
  return M.by_name(M.name(mode))
end

--- Persist a mode's preset.
function M.set(mode, name)
  migrate()
  local t = toggles()
  if t then
    t.set(key(mode), name)
  end
end

--- Outer size (cells, including the 2-cell border) for a split direction:
--- vertical → width, horizontal → height. Each direction reads its own preset.
function M.for_direction(direction)
  local s = M.get(direction)
  return direction == 'horizontal' and s.horizontal or s.vertical
end

return M

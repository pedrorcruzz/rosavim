--- RosaAI themes - Visual styles for the CLI window + chip
--- `border` controls the chip overlay border; `window` controls the
--- border of the float window itself (no effect on splits).
local M = {}

M.list = {
  {
    name = 'bloom',
    label = 'Bloom',
    icon = '󰧮',
    desc = 'Rounded chip and rounded window',
    border = 'rounded',
    layout = 'inline',
    window = 'rounded',
  },
  {
    name = 'petal',
    label = 'Petal',
    icon = '󰓎',
    desc = 'No borders — minimal text-only look',
    border = 'none',
    layout = 'inline',
    window = 'none',
  },
  {
    name = 'garland',
    label = 'Garland',
    icon = '󱁂',
    desc = 'Full-width banner chip + rounded window',
    border = 'rounded',
    layout = 'banner',
    window = 'rounded',
  },
  {
    name = 'stem',
    label = 'Stem',
    icon = '󱦬',
    desc = 'Full-width stem chip — no boxes',
    border = 'none',
    layout = 'stem',
    window = 'none',
  },
}

--- Get the currently selected theme (falls back to first one)
function M.current()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  local name = ok and toggles.get 'rosaai_theme' or M.list[1].name
  for _, t in ipairs(M.list) do
    if t.name == name then
      return t
    end
  end
  return M.list[1]
end

--- Set the active theme by name and refresh open chips
function M.set(name)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return
  end
  toggles.set('rosaai_theme', name)
  local rok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
  if rok then
    rosaai.refresh_chips()
    rosaai.relayout()
  end
end

return M

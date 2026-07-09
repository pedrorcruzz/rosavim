--- Rosaterm themes - Visual styles for the title chip
local M = {}

M.list = {
  {
    name = 'bloom',
    label = 'Bloom',
    icon = '󰧮',
    desc = 'Rounded border around the chip',
    border = 'rounded',
    layout = 'inline',
  },
  {
    name = 'petal',
    label = 'Petal',
    icon = '󰓎',
    desc = 'No border — text engraved on the line',
    border = 'none',
    layout = 'inline',
  },
  {
    name = 'garland',
    label = 'Garland',
    icon = '󱁂',
    desc = 'Full-width banner across the top',
    border = 'rounded',
    layout = 'banner',
  },
}

--- Get the currently selected theme (falls back to first one)
function M.current()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  local name = ok and toggles.get 'rosaterm_theme' or M.list[1].name
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
  toggles.set('rosaterm_theme', name)
  local rok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
  if rok then
    rosaterm.refresh_chips()
  end
end

return M

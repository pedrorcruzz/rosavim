--- Rosa Palette - Shared color palette that adapts to light/dark themes
local M = {}

local dark = {
  title = '#cba6f7',
  border = '#6c7086',
  key = '#89b4fa',
  green = '#a6e3a1',
  yellow = '#f9e2af',
  pink = '#f5c2e7',
  teal = '#89dceb',
  red = '#f38ba8',
  text = '#cdd6f4',
  subtext = '#a6adc8',
  dim = '#6c7086',
}

local light = {
  title = '#7c3aed',
  border = '#94a3b8',
  key = '#1d4ed8',
  green = '#16a34a',
  yellow = '#b45309',
  pink = '#be185d',
  teal = '#0e7490',
  red = '#dc2626',
  text = '#1e293b',
  subtext = '#64748b',
  dim = '#94a3b8',
}

--- Get the current palette based on background
--- @return table
function M.get()
  if vim.o.background == 'light' then
    return light
  end
  return dark
end

return M

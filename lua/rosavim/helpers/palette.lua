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

--- Define `<prefix><Suffix>` highlight groups from the current palette.
---
--- `spec` maps suffix -> highlight attrs, where attrs is a static table or a
--- function(palette) -> attrs. The whole spec may also be a single
--- function(palette) returning that map, which keeps call sites compact:
---   palette.define('Rosafile', function(p)
---     return { Title = { fg = p.title, bold = true }, Dim = { fg = p.dim } }
---   end)
--- Setting groups is idempotent and cheap, so plugins keep calling this on
--- every popup open to stay in sync with light/dark switches.
--- @param prefix string
--- @param spec table|fun(palette: table): table
function M.define(prefix, spec)
  local p = M.get()
  if type(spec) == 'function' then
    spec = spec(p)
  end
  for suffix, attrs in pairs(spec) do
    if type(attrs) == 'function' then
      attrs = attrs(p)
    end
    vim.api.nvim_set_hl(0, prefix .. suffix, attrs)
  end
end

return M

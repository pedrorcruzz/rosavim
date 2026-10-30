-- Clear module caches to ensure fresh evaluation
package.loaded['rosagawa'] = nil
package.loaded['rosagawa.colors'] = nil

local ok, appearance = pcall(require, 'rosavim.config.appearance')
local transparent = ok and appearance.get_transparent() or false
local mode = (vim.o.background == 'light' and not transparent) and 'light' or 'dark'
-- kanagawa-dragon (dark) / kanagawa-lotus (light) — the only two variants
-- this port ships.
local theme = mode == 'light' and 'lotus' or 'dragon'

local overrides_ok, overrides = pcall(require, 'rosavim.plugins.ui.colorschemes.rosagawa.overrides')
local override_table = (overrides_ok and overrides.get(mode, transparent)) or {}

local rosagawa = require 'rosagawa'
rosagawa.setup {
  transparent = transparent,
  overrides = function()
    return override_table
  end,
}
rosagawa.load(theme)

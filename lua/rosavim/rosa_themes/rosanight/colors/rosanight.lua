-- Clear module caches to ensure fresh evaluation
package.loaded['rosanight'] = nil
package.loaded['rosanight.colors'] = nil
package.loaded['rosanight.config'] = nil

local ok, appearance = pcall(require, 'rosavim.config.appearance')
if ok then
  local overrides = require('rosavim.plugins.ui.colorschemes.rosanight.overrides')
  local mode = appearance.get_mode()
  local transparent = appearance.get_transparent()
  local rosanight = require 'rosanight'
  rosanight.setup {
    transparent = transparent,
    overrides = overrides.get(mode, transparent),
  }
  rosanight.colorscheme()
else
  require('rosanight').colorscheme()
end

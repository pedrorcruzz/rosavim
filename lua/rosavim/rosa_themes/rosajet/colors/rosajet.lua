-- Clear module caches to ensure fresh evaluation
package.loaded['rosajet'] = nil
package.loaded['rosajet.colors'] = nil
package.loaded['rosajet.config'] = nil

local ok, appearance = pcall(require, 'rosavim.config.appearance')
if ok then
  local overrides = require 'rosavim.plugins.ui.colorschemes.rosajet.overrides'
  local mode = appearance.get_mode()
  local transparent = appearance.get_transparent()
  local rosajet = require 'rosajet'
  rosajet.setup {
    transparent = transparent,
    overrides = overrides.get(mode, transparent),
  }
  rosajet.colorscheme()
else
  require('rosajet').colorscheme()
end

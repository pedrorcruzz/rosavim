-- Clear module caches to ensure fresh evaluation
package.loaded['rosavintage'] = nil
package.loaded['rosavintage.colors'] = nil
package.loaded['rosavintage.config'] = nil

local ok, appearance = pcall(require, 'rosavim.config.appearance')
if ok then
  local overrides = require('rosavim.plugins.ui.colorschemes.rosavintage.overrides')
  local mode = appearance.get_mode()
  local transparent = appearance.get_transparent()
  local rosavintage = require 'rosavintage'
  rosavintage.setup {
    transparent = transparent,
    overrides = overrides.get(mode, transparent),
  }
  rosavintage.colorscheme()
else
  require('rosavintage').colorscheme()
end

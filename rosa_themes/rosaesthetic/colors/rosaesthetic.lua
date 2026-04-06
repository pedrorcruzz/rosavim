-- Clear module caches to ensure fresh evaluation
package.loaded['rosaesthetic'] = nil
package.loaded['rosaesthetic.colors'] = nil
package.loaded['rosaesthetic.config'] = nil

local ok, appearance = pcall(require, 'rosavim.config.appearance')
if ok then
  local overrides = require('rosavim.plugins.ui.colorschemes.rosaesthetic.overrides')
  local mode = appearance.get_mode()
  local transparent = appearance.get_transparent()
  local rosaesthetic = require 'rosaesthetic'
  rosaesthetic.setup {
    transparent = transparent,
    overrides = overrides.get(mode, transparent),
  }
  rosaesthetic.colorscheme()
else
  require('rosaesthetic').colorscheme()
end

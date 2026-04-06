-- Clear module caches to ensure fresh evaluation
package.loaded['rosaesthetic'] = nil
package.loaded['rosaesthetic.colors'] = nil
package.loaded['rosaesthetic.config'] = nil

local ok, appearance = pcall(require, 'rosavim.config.appearance')
if ok then
  local rosaesthetic = require 'rosaesthetic'
  rosaesthetic.setup {
    transparent = appearance.get_transparent(),
  }
  rosaesthetic.colorscheme()
else
  require('rosaesthetic').colorscheme()
end

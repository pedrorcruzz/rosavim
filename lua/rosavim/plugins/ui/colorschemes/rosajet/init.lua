local overrides = require 'rosavim.plugins.ui.colorschemes.rosajet.overrides'
local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local mode = appearance.get_mode()
  local transparent_background = appearance.get_transparent()
  require('rosajet').setup {
    transparent = transparent_background,
    overrides = overrides.get(mode, transparent_background),
  }
end

return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_themes/rosajet',
  name = 'rosajet',
  lazy = false,
  priority = 1000,
  config = function()
    setup_theme()
    appearance.register_reloader('rosajet', function()
      setup_theme()
      vim.cmd 'colorscheme rosajet'
    end)
  end,
}

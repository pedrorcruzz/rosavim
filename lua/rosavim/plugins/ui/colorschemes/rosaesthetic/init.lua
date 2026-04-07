local overrides = require 'rosavim.plugins.ui.colorschemes.rosaesthetic.overrides'
local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local mode = appearance.get_mode()
  local transparent_background = appearance.get_transparent()
  require('rosaesthetic').setup {
    transparent = transparent_background,
    overrides = overrides.get(mode, transparent_background),
  }
end

return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_themes/rosaesthetic',
  name = 'rosaesthetic',
  lazy = false,
  priority = 1000,
  config = function()
    setup_theme()
    appearance.register_reloader('rosaesthetic', function()
      setup_theme()
      vim.cmd 'colorscheme rosaesthetic'
    end)
  end,
}

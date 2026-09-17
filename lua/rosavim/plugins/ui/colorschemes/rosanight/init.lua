local appearance = require 'rosavim.config.appearance'

-- Only the active (cached) theme loads at startup; the other themes are
-- lazy and load through lazy.nvim's colorscheme handler on switch.
local active = (appearance.get_colorscheme() or 'rosamin') == 'rosanight'

local function setup_theme()
  local overrides = require 'rosavim.plugins.ui.colorschemes.rosanight.overrides'
  local mode = appearance.get_mode()
  local transparent_background = appearance.get_transparent()
  require('rosanight').setup {
    transparent = transparent_background,
    overrides = overrides.get(mode, transparent_background),
  }
end

return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_themes/rosanight',
  name = 'rosanight',
  lazy = not active,
  priority = 1000,
  config = function()
    setup_theme()
    appearance.register_reloader('rosanight', function()
      setup_theme()
      vim.cmd 'colorscheme rosanight'
    end)
  end,
}

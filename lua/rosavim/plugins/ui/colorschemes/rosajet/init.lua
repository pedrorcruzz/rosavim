local appearance = require 'rosavim.config.appearance'

-- Only the active (cached) theme loads at startup; the other themes are
-- lazy and load through lazy.nvim's colorscheme handler on switch.
local active = (appearance.get_colorscheme() or 'rosamin') == 'rosajet'

local function setup_theme()
  local overrides = require 'rosavim.plugins.ui.colorschemes.rosajet.overrides'
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
  lazy = not active,
  priority = 1000,
  config = function()
    setup_theme()
    appearance.register_reloader('rosajet', function()
      setup_theme()
      vim.cmd 'colorscheme rosajet'
    end)
  end,
}

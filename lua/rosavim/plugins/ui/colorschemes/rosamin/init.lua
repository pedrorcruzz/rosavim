local overrides = require 'rosavim.plugins.ui.colorschemes.rosamin.overrides'
local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local mode = appearance.get_mode()
  local transparent_background = appearance.get_transparent()
  require('rosamin').setup {
    transparent = transparent_background,
    bold = true,
    strikethrough = true,
    italics = {
      comments = true,
      keywords = true,
      functions = true,
      strings = true,
      variables = true,
    },
    overrides = overrides.get(mode, transparent_background),
  }
end

return {
  {
    dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_themes/rosamin',
    name = 'rosamin',
    lazy = false,
    priority = 1000,
    config = function()
      setup_theme()
      appearance.register_reloader('rosamin', function()
        setup_theme()
        vim.cmd 'colorscheme rosamin'
      end)
    end,
  },
}

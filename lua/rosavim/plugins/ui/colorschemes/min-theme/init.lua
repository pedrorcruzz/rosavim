local overrides = require 'rosavim.plugins.ui.colorschemes.min-theme.overrides'
local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local mode = appearance.get_mode()
  local transparent_background = appearance.get_transparent()
  require('min-theme').setup {
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
    'datsfilipe/min-theme.nvim',
    lazy = true,
    config = function()
      setup_theme()
      appearance.register_reloader(function()
        setup_theme()
        vim.cmd 'colorscheme min-theme'
      end)
    end,
  },
}

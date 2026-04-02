local overrides = require 'rosavim.plugins.ui.colorschemes.vesper.overrides'
local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local mode = appearance.get_mode()
  local transparent_background = appearance.get_transparent()
  require('vesper').setup {
    transparent = transparent_background,
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
    'datsfilipe/vesper.nvim',
    lazy = true,
    config = function()
      setup_theme()
      appearance.register_reloader(function()
        setup_theme()
        vim.cmd 'colorscheme vesper'
      end)
    end,
  },
}

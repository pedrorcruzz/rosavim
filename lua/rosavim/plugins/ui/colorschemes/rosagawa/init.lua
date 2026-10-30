local appearance = require 'rosavim.config.appearance'

-- Only the active (cached) theme loads at startup; the other themes are
-- lazy and load through lazy.nvim's colorscheme handler on switch.
local active = appearance.get_colorscheme() == 'rosagawa'

-- kanagawa-dragon is the dark variant, kanagawa-lotus the light one — the
-- only two of kanagawa's three palettes this port ships.
local function setup_theme()
  local overrides = require 'rosavim.plugins.ui.colorschemes.rosagawa.overrides'
  local mode = appearance.get_mode()
  local transparent_background = appearance.get_transparent()
  local effective_mode = transparent_background and 'dark' or mode
  local theme = effective_mode == 'light' and 'lotus' or 'dragon'
  local rosagawa = require 'rosagawa'
  rosagawa.setup {
    transparent = transparent_background,
    overrides = function()
      return overrides.get(effective_mode, transparent_background)
    end,
  }
  rosagawa.load(theme)
end

return {
  {
    dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_themes/rosagawa',
    name = 'rosagawa',
    lazy = not active,
    priority = 1000,
    config = function()
      setup_theme()
      appearance.register_reloader('rosagawa', function()
        setup_theme()
        vim.cmd 'colorscheme rosagawa'
      end)
    end,
  },
}

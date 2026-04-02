local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local transparent_background = appearance.get_transparent()

  require('rose-pine').setup {
      variant = 'auto',
      dark_variant = 'main',
      dim_inactive_windows = false,
      extend_background_behind_borders = true,

      enable = {
        terminal = true,
        legacy_highlights = true,
        migrations = true,
      },

      styles = {
        bold = true,
        italic = true,
        transparency = transparent_background,
      },

      groups = {
        border = 'muted',
        link = 'iris',
        panel = 'surface',

        error = 'love',
        hint = 'iris',
        info = 'foam',
        note = 'pine',
        todo = 'rose',
        warn = 'gold',

        git_add = 'foam',
        git_change = 'rose',
        git_delete = 'love',
        git_dirty = 'rose',
        git_ignore = 'muted',
        git_merge = 'iris',
        git_rename = 'pine',
        git_stage = 'iris',
        git_text = 'rose',
        git_untracked = 'subtle',

        h1 = 'iris',
        h2 = 'foam',
        h3 = 'rose',
        h4 = 'gold',
        h5 = 'pine',
        h6 = 'foam',
      },

      palette = {
        -- Override the builtin palette per variant
        -- moon = {
        --     base = '#18191a',
        --     overlay = '#363738',
        -- },
      },

      highlight_groups = vim.o.background == 'dark' and {
        WinBarNC = { bg = transparent_background and 'NONE' or '#1F1D2F' },
        WinBar = { bg = transparent_background and 'NONE' or '#1F1D2F' },
        WinSeparator = { fg = transparent_background and '#6e6a86' or '#1a1a1a' },
        BufferLineFill = { bg = transparent_background and 'NONE' or '#101010' },
      } or {},

      before_highlight = function(group, highlight, palette)
        -- if highlight.undercurl then
        --   highlight.undercurl = false
        -- end
      end,
    }
end

return {
  'rose-pine/neovim',
  name = 'rose-pine',
  lazy = true,
  config = function()
    setup_theme()
    appearance.register_reloader(function()
      setup_theme()
      vim.cmd 'colorscheme rose-pine'
    end)
  end,
}

local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local transparent_background = appearance.get_transparent()
  require('catppuccin').setup {
    flavour = 'auto',
    background = { light = 'latte', dark = 'mocha' },
    transparent_background = transparent_background,
    term_colors = true,
    integrations = {
      notify = true,
      mini = true,
    },
    styles = {
      comments = { 'italic' },
      functions = { 'bold' },
      keywords = { 'italic' },
    },
    custom_highlights = function(colors)
      if vim.o.background == 'light' then
        return {}
      end
      return {
            WinBarNC = { bg = transparent_background and 'NONE' or '#1E1E2F' },
            NormalFloat = { bg = transparent_background and 'NONE' or '#1E1E2F' },
            WinBar = { bg = transparent_background and 'NONE' or '#1E1E2F' },
            WinSeparator = { fg = '#181826' },
            BufferLineFill = { bg = transparent_background and 'NONE' or '#181826' },
            BufferLineTabSelected = { fg = '#181827' },
            BufferLineIndicatorSelected = { fg = '#181827' },

            FloatBorder = { fg = '#6BB8FF' },
            Border = { fg = '#4c4c4c' },
            FloatShadow = { fg = '#4c4c4c' },
            VertSplit = { fg = '#4c4c4c' },
            CursorLine = { bg = '#45475C' },
            Underlined = { bg = '#45475C' },

            SnacksPicker = { bg = transparent_background and 'NONE' or '#181826' },
            SnacksPickerBorder = { fg = '#7DB6FF', bg = transparent_background and 'NONE' or '#181826' },
            SnacksPickerInputTitle = { fg = '#6390CA', bg = transparent_background and 'NONE' or '#181826' }, --explorer 202020 or 1A1A1A
            SnacksPickerToggle = { fg = '#6390CA', bg = transparent_background and 'NONE' or '#181826' }, --explorer 202020 or 1A1A1A

            TreesitterContext = { bg = transparent_background and 'NONE' or '#181826', fg = '#45475C' },
            TreesitterContextLineNumber = { bg = transparent_background and 'NONE' or '#181826', fg = '#45475C' },
            TreesitterContextBottom = { sp = '#45475c', underline = true },

            debugBreakpoint = { fg = '#B2BEFF' },
            DapUiBreakpointsDisabledLine = { fg = '#B2BEFF' },

            ['@punctuation.special'] = { fg = '#abb2bf' }, --#45475c
            ['@punctuation.special.tsx'] = { fg = '#FFC0EA' },
            ['@punctuation.special.jsx'] = { fg = '#FFC0EA' },
            ['@punctuation.special.htmldjango'] = { fg = '#FFC0EA' },
            ['@punctuation.special.javascript'] = { fg = '#FFC0EA' },
            ['@punctuation.special.typescript'] = { fg = '#FFC0EA' },

            GitSignsCurrentLineBlame = { fg = '#abb2bf' },
          }
        end,
      }
end

return {
  {
    'catppuccin/nvim',
    lazy = true,
    config = function()
      setup_theme()
      appearance.register_reloader(function()
        setup_theme()
        vim.cmd 'colorscheme catppuccin'
      end)
    end,
  },
}

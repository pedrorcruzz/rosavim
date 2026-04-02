local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local transparent_background = appearance.get_transparent()
  local dark_overrides = {
          Normal = { bg = transparent_background and 'none' or '#282828' }, --#202020 #000000 #1F1F1F
          Underlined = { bg = nil },
          Directory = { fg = '#83A598' }, --#A1BCC5
          NonText = { fg = '#7C6F64' }, --#A1BCC5
          EndOfBuffer = { fg = '#120B0A', bg = 'none' }, --#282828
          FloatBorder = { fg = '#4c4c4c' },
          TelescopePromptBorder = { fg = '#4c4c4c' },
          TelescopePreviewBorder = { fg = '#4c4c4c' },
          TelescopeResultsBorder = { fg = '#4c4c4c' },
          VertSplit = { fg = transparent_background and '#1F1F1F' or '#665C54' },
          TabLineFill = { bg = transparent_background and 'none' or '#3C3836' },
          TabLineSel = { bg = transparent_background and 'none' or '#3C3836' },
          WinSeparator = { fg = transparent_background and '#1F1F1F' or '#665C54' },
          Pmenu = { bg = transparent_background and 'NONE' or '#504944' },
          WinBar = { bg = transparent_background and 'NONE' or '#504944' },
          WinBarNC = { bg = transparent_background and 'NONE' or '#504944' },
          PmenuSel = { bg = '#83A598' },
          GitSignsCurrentLineBlame = { fg = '#717171' },
          -- Search = { bg = '#FABD2E', fg = '#000000' },
          -- IncSearch = { bg = '#FABD2E', fg = '#FE8018' },

          StatusLineNC = { bg = transparent_background and 'NONE' or '#1c1c1c' },
          StatusLine = { bg = transparent_background and 'NONE' or '#1c1c1c' },

          TreesitterContext = { bg = transparent_background and 'NONE' or '#1C1C1C', fg = '#7C6F64' },
          TreesitterContextLineNumber = { bg = transparent_background and 'NONE' or '#1C1C1C', fg = '#7C6F64' },
          TreesitterContextBottom = { sp = '#45475c', underline = true },

          ['@punctuation.special'] = { fg = '#59514B' },
          ['@punctuation.special.tsx'] = { fg = '#FFC0EA' },
          ['@punctuation.special.jsx'] = { fg = '#FFC0EA' },
          ['@punctuation.special.htmldjango'] = { fg = '#FFC0EA' },
          ['@punctuation.special.javascript'] = { fg = '#FFC0EA' },
          ['@punctuation.special.typescript'] = { fg = '#FFC0EA' },

          SnacksPicker = { bg = transparent_background and 'NONE' or '#443F3E' }, --333333 443f3e
          SnacksPickerBorder = { fg = '#665C54', bg = transparent_background and 'NONE' or '#443f3e' },
          SnacksInputIcon = { fg = '#fb4a34' },
          DiagnosticVirtualTextInfo = { bg = transparent_background and 'NONE' or '#443F3E', fg = '#FB4A34' },
          SnacksInputTitle = { fg = '#EBDBB2' },
          SnacksInputBorder = { fg = '#3c3836' }, --3c3836
          -- SnacksIndent = { fg = '#4c4c4c' },
          -- SnacksIndentScope = { fg = '#abb2bf' },

          NoiceConfirmBorder = { fg = '#3C3836' },
          NoiceCmdlinePrompt = { fg = '#3c3836' },
          NoiceCmdlinePopupBorder = { fg = '#3c3836' },
          NoiceCmdlinePopupTitleCmdline = { fg = '#EBDBB2' },
          NoiceCmdlinePopupTitle = { fg = '#EBDBB2' },
          NoiceCmdlineTitle = { fg = '#EBDBB2' },
          NoiceCmdlineIcon = { fg = '#FB4A34' }, --#ffffff
          NoiceCmdlineIconSearch = { fg = '#FB4A34' }, --#ffffff
  }

  require('gruvbox').setup {
    transparent_mode = transparent_background,
    overrides = vim.o.background == 'dark' and dark_overrides or {},
  }
end

return {
  {
    'ellisonleao/gruvbox.nvim',
    lazy = true,
    config = function()
      setup_theme()
      appearance.register_reloader(function()
        setup_theme()
        vim.cmd 'colorscheme gruvbox'
      end)
    end,
  },
}

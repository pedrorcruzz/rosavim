local appearance = require 'rosavim.config.appearance'

local function setup_theme()
  local transparent_background = appearance.get_transparent()

  require('kanagawa').setup {
      compile = false,
      undercurl = false,
      commentStyle = { italic = true },
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      transparent = transparent_background,
      dimInactive = false,
      terminalColors = true,

      colors = {
        theme = {
          all = {
            ui = {
              -- bg_gutter = 'none',
            },
            -- syn = {
            --   keyword = '#C099FF',
            --   string = '#A1C181',
            -- },
            diag = {
              error = '#FF5F87',
              warn = '#FFAF00',
              info = '#6BB8FF',
              hint = '#A1C181',
            },
          },
        },
      },

      overrides = function(colors)
        if vim.o.background == 'light' then
          return {}
        end
        local theme = colors.theme
        return {
          Directory = { fg = '#DAE7EC' }, --#A1BCC5
          EndOfBuffer = { fg = '#282727' },
          Visual = { bg = '#4c4c4c' }, --606060
          SnacksInputTitle = { fg = '#ffffff' },
          SnacksInputBorder = { fg = '#4c4c4c' },
          -- SnacksPicker = { bg = transparent_background and 'none' or '#1a1a1a' },
          SnacksPickerBorder = { fg = '#606060', bg = transparent_background and 'NONE' or '#1a1a1a' },
          SnacksPickerInputTitle = { fg = '#4c4c4c', bg = transparent_background and 'NONE' or '#1a1a1a' }, --explorer
          SnacksPickerToggle = { fg = '#4c4c4c', bg = transparent_background and 'NONE' or '#1a1a1a' }, --explorer
          StatusLineNC = { bg = transparent_background and 'NONE' or '#1c1c1c', fg = '#606060' },
          StatusLine = { bg = transparent_background and 'NONE' or '#1c1c1c', fg = '#606060' },
          VertSplit = { fg = transparent_background and '#1F1F1F' or '#665C54' },
          WinSeparator = { fg = transparent_background and '#1F1F1F' or '#665C54' },
          Pmenu = { bg = transparent_background and 'NONE' or '#504944' },
          PmenuSel = { bg = '#282727' },
          TreesitterContext = { bg = transparent_background and 'NONE' or '#282727', fg = '#282727' },
          TreesitterContextLineNumber = { bg = '#282727', fg = '#665c54' },
          TreesitterContextBottom = { sp = '#4c4c4c', underline = true },
          WinBarNC = { fg = '#9c9ea4', bg = transparent_background and 'NONE' or '#1c1c1c' },
          WinBar = { fg = '#9c9ea4', bg = transparent_background and 'NONE' or '#1c1c1c' },
        }
      end,

      theme = 'dragon',
      background = {
        dark = 'dragon',
        light = 'lotus',
      },
    }
end

return {
  'rebelot/kanagawa.nvim',
  lazy = true,
  config = function()
    setup_theme()
    appearance.register_reloader(function()
      setup_theme()
      require('kanagawa').load()
    end)
  end,
}

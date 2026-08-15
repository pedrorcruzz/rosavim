local M = {}

--- The editor background for `mode`. The Invert Backgrounds toggle swaps it
--- with the chrome shade afterwards (rosavim.config.invert_bg), so these stay
--- at their plain values.
local function editor_bg(mode)
  return mode == 'light' and '#fafafa' or '#272729'
end

function M.get(mode, transparent_background)
  local lualine_on = require('rosavim.config.toggles').get 'lualine'
  local editor = editor_bg(mode)
  if mode == 'light' then
    return {
      EndOfBuffer = { bg = 'none' },
      SnacksPickerPreview = { link = 'Normal' },

      Cursor = { fg = '#1A1A1A', bg = '#D3E5F1' },
      lCursor = { link = 'Cursor' },
      TermCursor = { link = 'Cursor' },
      Visual = { bg = '#D6E4F0' },
      WinBar = { fg = '#6c707d', bg = transparent_background and 'NONE' or '#F5F5F5' },
      WinBarNC = { fg = '#6c707d', bg = transparent_background and 'NONE' or '#F5F5F5' },
      Search = { bg = '#FFDF80', fg = '#383A42' },
      IncSearch = { bg = '#FFDF80', fg = '#E45649' },
      MatchParen = { fg = '#383A42', bg = '#D6E4F0' },

      -- blink.cmp: the IDE's completion popup is plain white with a thin grey
      -- border, so pin the menu/doc bg to the editor bg instead of a shade.
      BlinkCmpMenu = { bg = transparent_background and 'NONE' or editor },
      BlinkCmpDoc = { bg = transparent_background and 'NONE' or editor },
      BlinkCmpDocSeparator = { fg = '#ebecf0', bg = transparent_background and 'NONE' or editor },
      BlinkCmpMenuBorder = { fg = '#d4d4d4', bg = transparent_background and 'NONE' or editor },
      BlinkCmpDocBorder = { fg = '#d4d4d4', bg = transparent_background and 'NONE' or editor },
      BlinkCmpKind = { fg = '#6c707d', bg = transparent_background and 'NONE' or editor },

      -- mason: follow the editor bg like the other IDE dialogs. MasonHighlight
      -- drives the installed-check icons — the IDE's accent blue.
      MasonNormal = { fg = '#080808', bg = transparent_background and 'NONE' or editor },
      MasonHighlight = { fg = '#4573e8' },
      MasonHighlightSecondary = { fg = '#4573e8' },

      -- flash.nvim
      FlashMatch = { fg = '#1c1c1e', bg = '#c4c3bd' },
      FlashCurrent = { fg = '#1c1c1e', bg = '#c4c3bd' },
      FlashLabel = { fg = '#d3d2ce', bg = '#38383c', bold = true },
      FlashBackdrop = { fg = '#a8a7a1' },

      -- lazygit (Snacks reads the RosaLg* groups — see helpers/lazygit_theme).
      -- Values mirror the IntelliJ Light chrome so lazygit matches the theme,
      -- except the active border and selected line, which keep rosamin's tones.
      RosaLg241 = { fg = '#8c8c8c' },
      RosaLgActive = { fg = '#383A42', bold = true },
      RosaLgCherryBg = { fg = '#6c707d' },
      RosaLgCherryFg = { fg = '#871094' },
      RosaLgDefault = { fg = '#080808' },
      RosaLgInactive = { fg = '#d4d4d4' },
      RosaLgOptions = { fg = '#00627a' },
      RosaLgSelected = { bg = '#D6E4F0' },
      RosaLgUnstaged = { fg = '#ff0000' },

      -- mini.icons (kept as coloured file-type icons — chrome, not code syntax)
      MiniIconsAzure = { fg = '#3877e8', bg = 'none' },
      MiniIconsBlue = { fg = '#4573e8', bg = 'none' },
      MiniIconsCyan = { fg = '#007a80', bg = 'none' },
      MiniIconsPurple = { fg = '#7a58e8', bg = 'none' },
      MiniIconsRed = { fg = '#d04b50', bg = 'none' },
      MiniIconsGreen = { fg = '#3c8745', bg = 'none' },
      MiniIconsOrange = { fg = '#dd7430', bg = 'none' },
      MiniIconsYellow = { fg = '#9e880d', bg = 'none' },
      MiniIconsGrey = { fg = '#6c707d', bg = 'none' },

      -- statusline: with lualine off the native statusline shows, so its bar
      -- follows the IDE status-bar shade instead of lualine's fallback
      StatusLine = { bg = transparent_background and 'NONE' or '#f0f0f0', fg = '#7f828d' },
      StatusLineNC = { bg = transparent_background and 'NONE' or '#f0f0f0', fg = '#aeb3c2' },
      StatusLineTerm = { link = 'StatusLine' },
      StatusLineTermNC = { link = 'StatusLineNC' },
    }
  end
  return {
    EndOfBuffer = { bg = 'none' },
    SnacksPickerPreview = { link = 'Normal' },

    -- The IDE's dark caret is a near-white block.
    Cursor = { fg = editor, bg = '#ced0d6' },
    lCursor = { link = 'Cursor' },
    TermCursor = { link = 'Cursor' },

    -- blink.cmp: the popup follows the editor bg (the IDE puts it a shade under,
    -- at #27282B) with the IDE's #43454A border.
    BlinkCmpMenu = { bg = transparent_background and 'NONE' or editor },
    BlinkCmpDoc = { bg = transparent_background and 'NONE' or editor },
    BlinkCmpDocSeparator = { fg = '#393b40', bg = transparent_background and 'NONE' or editor },
    BlinkCmpMenuBorder = { fg = '#43454a', bg = transparent_background and 'NONE' or editor },
    BlinkCmpDocBorder = { fg = '#43454a', bg = transparent_background and 'NONE' or editor },
    BlinkCmpKind = { fg = '#ced0d6', bg = transparent_background and 'NONE' or editor },

    -- mason
    MasonNormal = { fg = '#bcbec4', bg = transparent_background and 'NONE' or '#2b2d30' },
    MasonHighlight = { fg = '#6089ef' },
    MasonHighlightSecondary = { fg = '#6089ef' },

    -- flash.nvim
    FlashMatch = { fg = '#000000', bg = '#c6c6ce' },
    FlashCurrent = { fg = '#000000', bg = '#c6c6ce' },
    FlashLabel = { fg = '#FFFFFF', bg = '#606060', bold = true },
    FlashBackdrop = { fg = '#505050' },

    -- lazygit (see the light-mode note; values mirror the IDE's dark chrome,
    -- except the active border and selected line, which keep rosamin's tones)
    RosaLg241 = { fg = '#7a7e85' },
    RosaLgActive = { fg = '#abb2bf', bold = true },
    RosaLgCherryBg = { fg = '#6f737a' },
    RosaLgCherryFg = { fg = '#c77dbb' },
    RosaLgDefault = { fg = '#bcbec4' },
    RosaLgInactive = { fg = '#43454a' },
    RosaLgOptions = { fg = '#56a8f5' },
    RosaLgSelected = { bg = '#4c4c4c' },
    RosaLgUnstaged = { fg = '#fa6675' },

    -- mini.icons (kept as coloured file-type icons — chrome, not code syntax)
    MiniIconsAzure = { fg = '#578cf0', bg = 'none' },
    MiniIconsBlue = { fg = '#6089ef', bg = 'none' },
    MiniIconsCyan = { fg = '#2aacb8', bg = 'none' },
    MiniIconsPurple = { fg = '#af8ee6', bg = 'none' },
    MiniIconsRed = { fg = '#d1655f', bg = 'none' },
    MiniIconsGreen = { fg = '#6aab73', bg = 'none' },
    MiniIconsOrange = { fg = '#cf8e6d', bg = 'none' },
    MiniIconsYellow = { fg = '#b3ae60', bg = 'none' },
    MiniIconsGrey = { fg = '#9fa0a2', bg = 'none' },

    -- statusline: with lualine off the native statusline shows, so its bar
    -- follows the IDE status-bar shade instead of lualine's fallback
    StatusLine = { bg = transparent_background and 'NONE' or '#2b2d30', fg = lualine_on and '#6f737a' or '#9a9ca4' },
    StatusLineNC = { bg = transparent_background and 'NONE' or '#2b2d30', fg = '#6f737a' },
    StatusLineTerm = { link = 'StatusLine' },
    StatusLineTermNC = { link = 'StatusLineNC' },
  }
end

return M

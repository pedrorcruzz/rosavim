local M = {}

function M.get(mode, transparent_background)
  if mode == 'light' then
    return {
      -- Cursor: explicit fg/bg instead of the default reverse cursor, which
      -- takes the bg color and is nearly invisible on this light palette. The
      -- bg also drives the terminal cursor color via OSC 12 (colorscheme.lua),
      -- a standard escape sequence most terminals honor.
      Cursor = { fg = '#1c1c1e', bg = '#FFFFFF' },
      lCursor = { link = 'Cursor' },
      TermCursor = { link = 'Cursor' },

      -- blink.cmp: menu + doc bg follow the editor bg (#D3D2CE) so the popups
      -- blend with the background instead of the lighter bgFloat/#c9c8c3.
      BlinkCmpMenu = { bg = '#D3D2CE' },
      BlinkCmpDoc = { bg = '#D3D2CE' },
      BlinkCmpDocSeparator = { bg = '#D3D2CE' },
      BlinkCmpMenuBorder = { bg = '#D3D2CE', fg = '#8a8a84' },
      BlinkCmpDocBorder = { bg = '#D3D2CE', fg = '#8a8a84' },
      -- Kind-icon column: without this it links to PmenuKind -> Pmenu (bg #c3c0ba),
      -- rendering the icons on a different shade. Pin bg to #D3D2CE (fg = colors.fg)
      -- so the icon cells match the menu bg. All BlinkCmpKind<Kind> link here.
      BlinkCmpKind = { fg = '#1c1c1e', bg = '#D3D2CE' },

      -- flash.nvim (monochrome)
      FlashMatch = { fg = '#1c1c1e', bg = '#c4c3bd' },
      FlashCurrent = { fg = '#1c1c1e', bg = '#c4c3bd' },
      FlashLabel = { fg = '#000000', bg = '#c4c3bd', bold = true },
      FlashBackdrop = { fg = '#a8a7a1' },

      -- gitsigns blame
      GitSignsCurrentLineBlame = { fg = '#a4a39c' },

      -- mini.icons (kept as coloured file-type icons, identical across light/dark)
      MiniIconsAzure = { fg = '#79b8ff', bg = 'none' },
      MiniIconsBlue = { fg = '#64BAFF', bg = 'none' },
      MiniIconsCyan = { fg = '#7DD3FC', bg = 'none' },
      MiniIconsPurple = { fg = '#b392f0', bg = 'none' },
      MiniIconsRed = { fg = '#F67582', bg = 'none' },
      MiniIconsGreen = { fg = '#A0D6A0', bg = 'none' },
      MiniIconsOrange = { fg = '#FFA868', bg = 'none' },
      MiniIconsYellow = { fg = '#FFD580', bg = 'none' },
      MiniIconsGrey = { fg = '#9C9EA4', bg = 'none' },

      -- snacks explorer/picker selected row (matches the Visual highlight)
      SnacksPickerListCursorLine = { bg = '#bcbbb5' },

      -- Hidden files/dirs (and everything under a hidden dir, e.g. .config)
      -- default to NonText (grey). Use normal fg so nested names stay readable.
      SnacksPickerPathHidden = { fg = '#1c1c1e' },

      -- statusline
      StatusLine = { fg = '#1c1c1e' },
      StatusLineNC = { fg = '#1c1c1e' },
    }
  end
  return {
    Cursor = { fg = '#000000', bg = '#FFFFFF' },
    lCursor = { link = 'Cursor' },
    TermCursor = { link = 'Cursor' },

    -- lazygit borders (Snacks reads FloatBorder fg for inactive, MatchParen fg for active)
    FloatBorder = { fg = '#4c4c4c' },
    MatchParen = { fg = '#c6c6ce', bg = '#555555' },

    -- blink.cmp completion menu
    -- Selected item: solid #303030 so it stands out on the near-black menu.
    -- BlinkCmpMenuSelection -> PmenuSel.
    PmenuSel = { bg = '#303030' },
    -- Documentation/preview window: follow the editor bg (#000000) instead of the
    -- grey bgFloat, and go transparent when transparent mode is on.
    -- BlinkCmpDoc / DocBorder / DocSeparator all link to NormalFloat by default.
    BlinkCmpDoc = { bg = transparent_background and 'none' or '#000000' },
    BlinkCmpDocSeparator = { bg = transparent_background and 'none' or '#000000' },
    -- Borders were rendering near-white (they inherit Pmenu/NormalFloat fg).
    -- Darken both the menu and doc borders to #303030 (matches FloatBorder).
    BlinkCmpDocBorder = { bg = transparent_background and 'none' or '#000000', fg = '#303030' },
    BlinkCmpMenuBorder = { bg = transparent_background and 'none' or '#0a0a0a', fg = '#303030' },

    -- flash.nvim (monochrome)
    FlashMatch = { fg = '#FFFFFF', bg = '#606060' },
    FlashCurrent = { fg = '#FFFFFF', bg = '#606060' },
    FlashLabel = { fg = '#FFFFFF', bg = '#606060', bold = true },
    FlashBackdrop = { fg = '#505050' },

    -- gitsigns blame
    GitSignsCurrentLineBlame = { fg = '#565656' },

    -- mini.icons (kept as coloured file-type icons — chrome, not code syntax)
    MiniIconsAzure = { fg = '#79b8ff', bg = 'none' },
    MiniIconsBlue = { fg = '#64BAFF', bg = 'none' },
    MiniIconsCyan = { fg = '#7DD3FC', bg = 'none' },
    MiniIconsPurple = { fg = '#b392f0', bg = 'none' },
    MiniIconsRed = { fg = '#F67582', bg = 'none' },
    MiniIconsGreen = { fg = '#A0D6A0', bg = 'none' },
    MiniIconsOrange = { fg = '#FFA868', bg = 'none' },
    MiniIconsYellow = { fg = '#FFD580', bg = 'none' },
    MiniIconsGrey = { fg = '#9C9EA4', bg = 'none' },

    -- snacks explorer/picker selected row (matches the Visual highlight)
    SnacksPickerListCursorLine = { bg = '#262631' },

    -- Hidden files/dirs (and everything under a hidden dir, e.g. .config)
    -- default to NonText (grey). Use normal fg so nested names stay readable.
    SnacksPickerPathHidden = { fg = '#c6c6ce' },

    -- statusline
    StatusLine = { bg = transparent_background and 'NONE' or '#1a1a1a', fg = '#606060' },
    StatusLineNC = { bg = transparent_background and 'NONE' or '#1a1a1a', fg = '#606060' },
  }
end

return M

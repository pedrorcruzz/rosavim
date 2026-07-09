local M = {}

function M.get(mode, transparent_background)
  if mode == 'light' then
    return {
      -- blink.cmp: menu + doc bg follow the editor bg (#D3D2CE) so the popups
      -- blend with the background instead of the lighter bgFloat/#C4C0B9.
      BlinkCmpMenu = { bg = '#D3D2CE' },
      BlinkCmpDoc = { bg = '#D3D2CE' },
      BlinkCmpDocSeparator = { bg = '#D3D2CE' },
      BlinkCmpMenuBorder = { bg = '#D3D2CE', fg = '#989387' },
      BlinkCmpDocBorder = { bg = '#D3D2CE', fg = '#989387' },
      -- Kind-icon column: without this it links to PmenuKind -> Pmenu (bg #c3c0ba),
      -- rendering the icons on a different shade. Pin bg to #D3D2CE (fg = colors.fg)
      -- so the icon cells match the menu bg. All BlinkCmpKind<Kind> link here.
      BlinkCmpKind = { fg = '#444136', bg = '#D3D2CE' },

      -- flash.nvim
      FlashMatch = { fg = '#383A42', bg = '#D6E4F0' },
      FlashCurrent = { fg = '#383A42', bg = '#D6E4F0' },
      FlashLabel = { fg = '#E45649', bg = '#D6E4F0', bold = true },
      FlashBackdrop = { fg = '#B0B0B0' },

      -- gitsigns blame
      GitSignsCurrentLineBlame = { fg = '#9e9a8f' },

      -- mini.icons (match the dark variant so icon colors are identical across light/dark)
      MiniIconsAzure = { fg = '#79b8ff', bg = 'none' },
      MiniIconsBlue = { fg = '#64BAFF', bg = 'none' },
      MiniIconsCyan = { fg = '#7DD3FC', bg = 'none' },
      MiniIconsPurple = { fg = '#b392f0', bg = 'none' },
      MiniIconsRed = { fg = '#F67582', bg = 'none' },
      MiniIconsGreen = { fg = '#A0D6A0', bg = 'none' },
      MiniIconsOrange = { fg = '#FFA868', bg = 'none' },
      MiniIconsYellow = { fg = '#FFD580', bg = 'none' },
      MiniIconsGrey = { fg = '#9C9EA4', bg = 'none' },

      -- Hidden files/dirs (and everything under a hidden dir, e.g. .config)
      -- default to NonText (grey). Use normal fg so nested names stay readable.
      SnacksPickerPathHidden = { fg = '#444136' },

      -- statusline
      StatusLine = { fg = '#454135' },
      StatusLineNC = { fg = '#454135' },
    }
  end
  return {
    -- lazygit borders (Snacks reads FloatBorder fg for inactive, MatchParen fg for active)
    FloatBorder = { fg = '#4c4c4c' },
    MatchParen = { fg = '#A9B2C0', bg = '#555555' },

    -- blink.cmp completion menu
    -- Selected item: solid #303030 so it stands out on the near-black menu
    -- (the theme default rendered nearly white). BlinkCmpMenuSelection -> PmenuSel.
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

    -- flash.nvim
    FlashMatch = { fg = '#abb2bf', bg = '#606060' },
    FlashCurrent = { fg = '#abb2bf', bg = '#606060' },
    FlashLabel = { fg = '#F67582', bg = '#606060', bold = true },
    FlashBackdrop = { fg = '#505050' },

    -- gitsigns blame
    GitSignsCurrentLineBlame = { fg = '#727272' },

    -- mini.icons (override links to Function/Diagnostic* which would otherwise turn icons purple/yellow)
    MiniIconsAzure = { fg = '#79b8ff', bg = 'none' },
    MiniIconsBlue = { fg = '#64BAFF', bg = 'none' },
    MiniIconsCyan = { fg = '#7DD3FC', bg = 'none' },
    MiniIconsPurple = { fg = '#b392f0', bg = 'none' },
    MiniIconsRed = { fg = '#F67582', bg = 'none' },
    MiniIconsGreen = { fg = '#A0D6A0', bg = 'none' },
    MiniIconsOrange = { fg = '#FFA868', bg = 'none' },
    MiniIconsYellow = { fg = '#FFD580', bg = 'none' },
    MiniIconsGrey = { fg = '#9C9EA4', bg = 'none' },

    -- Hidden files/dirs (and everything under a hidden dir, e.g. .config)
    -- default to NonText (grey). Use normal fg so nested names stay readable.
    SnacksPickerPathHidden = { fg = '#d4d0c8' },

    -- statusline
    StatusLine = { bg = transparent_background and 'NONE' or '#1a1a1a', fg = '#606060' },
    StatusLineNC = { bg = transparent_background and 'NONE' or '#1a1a1a', fg = '#606060' },
  }
end

return M

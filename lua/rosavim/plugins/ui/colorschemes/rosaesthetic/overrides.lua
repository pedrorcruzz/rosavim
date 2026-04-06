local M = {}

function M.get(mode, transparent_background)
  if mode == 'light' then
    return {
      -- flash.nvim
      FlashMatch = { fg = '#383A42', bg = '#D6E4F0' },
      FlashCurrent = { fg = '#383A42', bg = '#D6E4F0' },
      FlashLabel = { fg = '#E45649', bg = '#D6E4F0', bold = true },
      FlashBackdrop = { fg = '#B0B0B0' },
    }
  end
  return {
    -- lazygit borders (Snacks reads FloatBorder fg for inactive, MatchParen fg for active)
    FloatBorder = { fg = '#4c4c4c' },
    MatchParen = { fg = '#A9B2C0', bg = '#555555' },

    -- flash.nvim
    FlashMatch = { fg = '#abb2bf', bg = '#606060' },
    FlashCurrent = { fg = '#abb2bf', bg = '#606060' },
    FlashLabel = { fg = '#F67582', bg = '#606060', bold = true },
    FlashBackdrop = { fg = '#505050' },
  }
end

return M

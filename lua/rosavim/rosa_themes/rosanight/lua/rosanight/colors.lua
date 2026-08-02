local config = require 'rosanight.config'

local colors = {}

-- rosanight is a strictly monochrome theme: everything floats between black,
-- grey and white — no saturated hues. The colour "roles" below (red/green/...)
-- keep the shared theme structure, but each is mapped to a point on a single
-- grey ramp:
--   white   #FFFFFF  Normal text, keywords (max contrast)
--   #C6C6CE          functions/identifiers (bright)
--   #B4B4BE          types/structures
--   #9A9AA6          imports/preproc
--   #8C8C9A          strings/numbers/constants (desaturated grey-lavender)
--   #6E6E78          punctuation/special (recessive)
--   #565656          comments (dim)
if vim.o.background == 'light' and not config.transparent then
  colors.bg = '#d3d2ce'
  colors.bgDark = '#c3c0ba'
  colors.bgDarker = '#c3c0ba'
  colors.bgFloat = '#c9c8c3'
  colors.bgOption = '#c3c0ba'
  colors.bgSidebar = '#cfcec9'
  colors.fg = '#1c1c1e'
  colors.fgAlt = '#000000'
  colors.fgInactive = '#8a8a84'
  colors.fgLineNr = '#6a6a64'
  colors.border = '#8a8a84'
  colors.comment = '#97968f'
  colors.red = '#38383c'
  colors.green = '#000000'
  colors.gold = '#7a7a76'
  colors.blue = '#63636b'
  colors.magenta = '#47474e'
  colors.cyan = '#55555c'
  colors.search = '#38383c'
  colors.searchFg = '#d3d2ce'
  colors.spellRed = '#38383c'
  colors.spellBlue = '#63636b'
  colors.spellCyan = '#55555c'
  colors.spellMagenta = '#47474e'
else
  colors.bg = config.transparent and 'NONE' or '#000000'
  colors.bgDark = '#0a0a0a'
  colors.bgDarker = '#111111'
  colors.bgFloat = '#1a1a1a'
  colors.bgOption = '#1a1a1a'
  colors.bgSidebar = '#000000'
  colors.fg = '#FFFFFF'
  colors.fgAlt = '#FFFFFF'
  colors.fgInactive = '#565656'
  colors.fgLineNr = '#3a3a3a'
  colors.border = '#6e6e6e'
  colors.comment = '#565656'
  colors.red = '#c6c6ce'
  colors.green = '#FFFFFF'
  colors.gold = '#6e6e78'
  colors.blue = '#8c8c9a'
  colors.magenta = '#b4b4be'
  colors.cyan = '#9a9aa6'
  colors.search = '#c6c6ce'
  colors.searchFg = '#000000'
  colors.spellRed = '#c6c6ce'
  colors.spellBlue = '#8c8c9a'
  colors.spellCyan = '#9a9aa6'
  colors.spellMagenta = '#b4b4be'
end

return colors

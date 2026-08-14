local config = require 'rosajet.config'

local colors = {}

-- rosajet reproduces the JetBrains IDE palette (IntelliJ IDEA New UI). Every
-- value below was read out of the IDE colour scheme itself — dark mode is the
-- "Dark" scheme, light mode is "IntelliJ Light". The role names follow the
-- JetBrains editor settings rather than the usual red/green/blue slots, because
-- that is how the scheme is actually organised:
--
--   keyword    Keyword, Boolean, Type, Tag        (orange dark / blue light)
--   builtin    escape sequences, builtin ctors    (a shade off `keyword`)
--   string     String literals                    (green)
--   number     Number literals                    (cyan dark / blue light)
--   func       Function/method declarations       (blue dark / teal light)
--   constant   constants, properties, enum members(magenta / purple)
--   metadata   annotations, decorators, attributes(olive)
--
-- Classes, interfaces, namespaces and plain identifiers stay at `fg` — that is
-- the JetBrains look and not an omission.
--
-- Transparent mode keeps the palette of the *current* background and only drops
-- the solid editor bg, so a transparent light setup stays legible on a light
-- terminal instead of falling back to the dark scheme.
--
-- The editor and the explorer/tab chrome sit on two shades; the Invert
-- Backgrounds toggle (<leader>lqij) swaps them as a post-pass over the finished
-- groups — see rosavim.config.invert_bg. `bgSolid` is the editor shade even in
-- transparent mode, for the few groups that need something opaque to sit on.
if vim.o.background == 'light' then
  -- Editor
  local editor, chrome = '#ffffff', '#fcfcfc'
  colors.bgSolid = editor
  colors.bg = config.transparent and 'NONE' or editor
  colors.bgDark = '#f7f8fa' -- tool windows, status bar, tab strip
  colors.bgDarker = '#f5f8fe' -- caret row
  colors.bgFloat = editor -- completion popup, follows the editor bg
  colors.bgOption = '#d7e1fc' -- selected completion item
  colors.bgSidebar = chrome -- explorer / picker / tab strip chrome
  colors.fg = '#080808'
  colors.fgAlt = '#000000'
  colors.fgInactive = '#6c707d'
  colors.fgLineNr = '#aeb3c2'
  colors.border = '#d4d4d4'
  colors.separator = '#ebecf0'
  colors.comment = '#8c8c8c'

  -- Syntax
  colors.keyword = '#0033b3'
  colors.builtin = '#0037a6'
  colors.string = '#067d17'
  colors.number = '#1750eb'
  colors.func = '#00627a'
  colors.constant = '#871094'
  colors.metadata = '#9e880d'

  -- Editor decorations. The IDE selects in a saturated blue (#A6D2FF); the
  -- neutral rosamin selection is used instead so long selections stay readable
  -- over syntax colours.
  colors.visual = '#d6e4f0'
  colors.search = '#fcd47e'
  colors.searchFg = '#000000'
  -- Drives the yank flash (vim.highlight.on_yank falls back to IncSearch);
  -- rosamin's neutral value, matching `visual`, instead of the IDE's blue.
  colors.incsearch = '#ffdf80'
  colors.matchParen = '#93d9d9'
  colors.rowSelected = '#d6e4f0' -- picker/quickfix selected row, matches `visual`
  colors.guide = '#dae6fd'
  colors.todo = '#008dde'
  colors.link = '#808080'

  -- Diagnostics. JetBrains' literal Info/Hint values (#cccccc / #808080) are
  -- unreadable on white, so those two take the IDE's *gutter icon* colours,
  -- which are the same signal at usable contrast.
  colors.error = '#ff0000'
  colors.warn = '#a66f00'
  colors.info = '#517deb'
  colors.hint = '#808080'
  colors.ok = '#007f00'

  -- VCS
  colors.gitAdd = '#7fc784'
  colors.gitChange = '#88adf7'
  colors.gitDelete = '#767a8a'
  colors.diffAdd = '#bee6be'
  colors.diffChange = '#c2d8f2'
  colors.diffDelete = '#d6d6d6'

  -- Spelling
  colors.spellBad = '#b0d1ab'
  colors.spellCap = '#f2c55c'
  colors.spellLocal = '#808080'
  colors.spellRare = '#808080'
else
  -- Editor
  local editor, chrome = '#272729', '#191a1c'
  colors.bgSolid = editor
  colors.bg = config.transparent and 'NONE' or editor
  colors.bgDark = '#2b2d30' -- tool windows, status bar, tab strip
  colors.bgDarker = '#2e3033' -- caret row (invert_bg re-pins this when swapped)
  -- Completion popup. The IDE puts it a shade under the editor (#27282B); here
  -- it follows the editor bg so the menu reads as part of the buffer.
  colors.bgFloat = editor
  colors.bgOption = '#32426b' -- selected completion item
  colors.bgSidebar = chrome -- explorer / picker / tab strip chrome
  colors.fg = '#bcbec4'
  colors.fgAlt = '#ced0d5'
  colors.fgInactive = '#6f737a'
  colors.fgLineNr = '#4b5059'
  colors.border = '#43454a'
  colors.separator = '#323438'
  colors.comment = '#7a7e85'

  -- Syntax
  colors.keyword = '#cf8e6d'
  colors.builtin = '#cf8e6d'
  colors.string = '#6aab73'
  colors.number = '#2aacb8'
  colors.func = '#56a8f5'
  colors.constant = '#c77dbb'
  colors.metadata = '#b3ae60'

  -- Editor decorations (see the light-mode note on `visual`)
  colors.visual = '#4c4c4c'
  colors.search = '#114957'
  colors.searchFg = '#bcbec4'
  colors.incsearch = '#606060' -- yank flash / incsearch, see the light-mode note
  colors.matchParen = '#43454a'
  colors.rowSelected = '#4c4c4c' -- picker/quickfix selected row, matches `visual`
  colors.guide = '#2b2d30'
  colors.todo = '#8bb33d'
  colors.link = '#6b6c73'

  -- Diagnostics (see the light-mode note; dark's literal Info is an olive
  -- #857042 that reads as a dim comment, so it uses the gutter blue too).
  colors.error = '#fa6675'
  colors.warn = '#f2c55c'
  colors.info = '#5d85eb'
  colors.hint = '#6f737a'
  colors.ok = '#6aab73'

  -- VCS
  colors.gitAdd = '#549159'
  colors.gitChange = '#375fad'
  colors.gitDelete = '#868a91'
  colors.diffAdd = '#294436'
  colors.diffChange = '#385570'
  colors.diffDelete = '#484a4a'

  -- Spelling
  colors.spellBad = '#7ec482'
  colors.spellCap = '#f2c55c'
  colors.spellLocal = '#6f737a'
  colors.spellRare = '#6f737a'
end

return colors

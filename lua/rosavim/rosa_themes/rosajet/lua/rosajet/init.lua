local config = require 'rosajet.config'
local M = {}

local function set_terminal_colors()
  local colors = require 'rosajet.colors'
  -- ANSI ramp taken from the JetBrains terminal palette (the same values the
  -- upstream Kitty/Ghostty/Alacritty exports ship).
  if vim.o.background == 'light' then
    vim.g.terminal_color_0 = '#000000'
    vim.g.terminal_color_1 = '#c93645'
    vim.g.terminal_color_2 = '#357d1f'
    vim.g.terminal_color_3 = '#b2a400'
    vim.g.terminal_color_4 = '#225cd6'
    vim.g.terminal_color_5 = '#6e32e5'
    vim.g.terminal_color_6 = '#007a80'
    vim.g.terminal_color_7 = '#bec0c5'
    vim.g.terminal_color_8 = '#6c707e'
    vim.g.terminal_color_9 = '#ff5462'
    vim.g.terminal_color_10 = '#3dcc3d'
    vim.g.terminal_color_11 = '#d4bb00'
    vim.g.terminal_color_12 = '#009dff'
    vim.g.terminal_color_13 = '#d659ff'
    vim.g.terminal_color_14 = '#31c4b3'
    vim.g.terminal_color_15 = '#d2d4d9'
  else
    vim.g.terminal_color_0 = '#000000'
    vim.g.terminal_color_1 = '#f27481'
    vim.g.terminal_color_2 = '#6bcc62'
    vim.g.terminal_color_3 = '#e0ce70'
    vim.g.terminal_color_4 = '#5594fa'
    vim.g.terminal_color_5 = '#c092fa'
    vim.g.terminal_color_6 = '#47ccbd'
    vim.g.terminal_color_7 = '#ced0d6'
    vim.g.terminal_color_8 = '#4e5157'
    vim.g.terminal_color_9 = '#ff6b7a'
    vim.g.terminal_color_10 = '#67ff59'
    vim.g.terminal_color_11 = '#ffec1a'
    vim.g.terminal_color_12 = '#3399ff'
    vim.g.terminal_color_13 = '#d970ff'
    vim.g.terminal_color_14 = '#40ffe9'
    vim.g.terminal_color_15 = '#ffffff'
  end
  vim.g.terminal_color_background = colors.bg
  vim.g.terminal_color_foreground = colors.fg
end

local function set_groups()
  local colors = require 'rosajet.colors'
  local light = vim.o.background == 'light'
  local bg = config.transparent and 'NONE' or colors.bg
  local sidebar = config.transparent and 'NONE' or colors.bgSidebar
  local float = config.transparent and 'NONE' or colors.bgFloat
  -- Tab strip: bufferline + native tabline.
  local bl_bg = config.transparent and 'NONE' or colors.bgTabline
  -- Separators and the active-tab indicator are hidden by painting them the bar
  -- colour. In transparent mode that colour is 'NONE', which makes the glyphs
  -- fall back to the DEFAULT foreground and draw a white bar — so they take the
  -- dim separator grey there instead.
  local bl_hidden = config.transparent and colors.separator or bl_bg
  -- Comments and constants are italic in the IDE's light scheme only.
  local italic_comment = light

  local groups = {
    -- base
    Normal = { fg = colors.fg, bg = bg },
    NormalNC = { link = 'Normal' },
    Bold = { bold = true },
    Conceal = { fg = colors.fgLineNr },
    Directory = { fg = colors.fgAlt },
    EndOfBuffer = { fg = colors.fgLineNr, bg = bg },
    Ignore = {},
    Italic = { italic = true },
    ModeMsg = { fg = colors.fg },
    MsgArea = { fg = colors.fg },
    MoreMsg = { fg = colors.fgAlt },
    Question = { fg = colors.info },
    NonText = { fg = colors.fgLineNr },
    Whitespace = { fg = colors.fgInactive },
    Terminal = { link = 'Normal' },
    Title = { fg = colors.constant, bold = true },
    Underlined = { underline = true, sp = colors.link },

    Comment = { fg = colors.comment, italic = italic_comment },
    CursorLineNr = { fg = colors.fgInactive, bg = config.transparent and 'NONE' or colors.bgDarker },
    LineNr = { fg = colors.fgLineNr },
    FoldColumn = { fg = colors.fgInactive },
    SignColumn = { fg = colors.fg },
    Folded = { fg = colors.fgInactive, bg = config.transparent and 'NONE' or colors.bgDarker },

    -- Caret row / columns / guides
    CursorLine = { bg = config.transparent and 'NONE' or colors.bgDarker },
    CursorColumn = { link = 'CursorLine' },
    ColorColumn = { bg = colors.guide },
    QuickFixLine = { bg = colors.rowSelected },

    -- Selection & search
    Visual = { bg = colors.visual },
    VisualNOS = { link = 'Visual' },
    Search = { fg = colors.searchFg, bg = colors.search },
    IncSearch = { bg = colors.incsearch },
    CurSearch = { fg = colors.fg, bg = colors.visual, underline = true, sp = colors.fg },
    Substitute = { link = 'IncSearch' },
    MatchParen = { bg = colors.matchParen, bold = true },

    -- Cursor. JetBrains uses a solid block in the fg colour; drive it via
    -- explicit fg/bg so colorscheme.lua can push it to the terminal (OSC 12).
    Cursor = { fg = colors.bgSolid, bg = colors.fgAlt },
    lCursor = { link = 'Cursor' },
    CursorIM = { link = 'Cursor' },
    TermCursor = { link = 'Cursor' },
    TermCursorNC = { link = 'Cursor' },

    -- Popups / floats / tool windows
    Pmenu = { fg = colors.fg, bg = float },
    PmenuSel = { bg = colors.bgOption },
    PmenuSbar = { bg = float },
    PmenuThumb = { bg = colors.border },
    PmenuKind = { fg = colors.fgAlt, bg = float },
    PmenuExtra = { fg = colors.fgInactive, bg = float },
    NormalFloat = { fg = colors.fg, bg = config.transparent and 'NONE' or colors.bgDark },
    FloatBorder = { fg = colors.border },
    FloatTitle = { fg = colors.fgAlt, bold = true },
    WildMenu = { link = 'PmenuSel' },

    -- Splits & tabs
    VertSplit = { fg = colors.separator, bg = bg },
    WinSeparator = { fg = colors.separator, bg = bg },
    TabLine = { fg = colors.fgInactive, bg = bl_bg },
    TabLineSel = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    TabLineFill = { bg = bl_bg },
    ToolbarButton = { fg = colors.fg, bg = colors.bgDark, bold = true },
    ToolbarLine = { bg = colors.bgDark },

    -- Status bar
    StatusLine = { fg = colors.fgInactive, bg = config.transparent and 'NONE' or colors.bgDark },
    StatusLineNC = { fg = colors.fgInactive, bg = config.transparent and 'NONE' or colors.bgDark },
    StatusLineTerm = { link = 'StatusLine' },
    StatusLineTermNC = { link = 'StatusLineNC' },
    MsgSeparator = { link = 'StatusLine' },

    -- Messages
    ErrorMsg = { fg = colors.error },
    WarningMsg = { fg = colors.warn },
    Error = { undercurl = true, sp = colors.error },
    Todo = { fg = colors.todo, italic = true },

    SpellBad = { undercurl = true, sp = colors.spellBad },
    SpellCap = { undercurl = true, sp = colors.spellCap },
    SpellLocal = { undercurl = true, sp = colors.spellLocal },
    SpellRare = { undercurl = true, sp = colors.spellRare },

    -- Diff
    DiffAdd = { bg = colors.diffAdd },
    DiffChange = { bg = colors.diffChange },
    DiffDelete = { bg = colors.diffDelete },
    DiffText = { bg = colors.diffChange, bold = true },

    -- syntax. In JetBrains, keywords/types/tags share one colour, plain
    -- identifiers and classes stay at the default text colour.
    Keyword = { fg = colors.keyword },
    Statement = { fg = colors.keyword },
    Conditional = { fg = colors.keyword },
    Repeat = { fg = colors.keyword },
    Label = { fg = colors.keyword },
    Exception = { fg = colors.keyword },
    Include = { fg = colors.keyword },
    Boolean = { fg = colors.keyword },
    Type = { fg = colors.keyword },
    StorageClass = { fg = colors.keyword },
    Structure = { fg = colors.keyword },
    Typedef = { fg = colors.keyword },
    Tag = { fg = colors.keyword },
    SpecialComment = { fg = colors.keyword },
    Debug = { fg = colors.keyword },

    Special = { fg = colors.builtin },
    SpecialChar = { fg = colors.builtin },
    SpecialKey = { fg = colors.fgInactive },

    PreProc = { fg = colors.metadata },
    Define = { fg = colors.metadata },
    Macro = { fg = colors.metadata },
    PreCondit = { fg = colors.metadata },

    String = { fg = colors.string },
    Character = { fg = colors.string },
    Number = { fg = colors.number },
    Float = { fg = colors.number },
    Constant = { fg = colors.constant, italic = true },

    Function = { fg = colors.func },
    Identifier = { fg = colors.fg },
    Operator = { fg = colors.fg },
    Delimiter = { fg = colors.fg },

    -- treesitter
    ['@variable'] = { fg = colors.fg },
    ['@variable.builtin'] = { fg = colors.keyword },
    ['@variable.member'] = { fg = colors.constant },
    ['@variable.parameter'] = { fg = colors.fg },
    ['@text'] = { fg = colors.fg },
    ['@property'] = { fg = colors.constant },
    ['@field'] = { fg = colors.constant },
    ['@parameter'] = { fg = colors.fg },

    ['@comment'] = { link = 'Comment' },
    ['@comment.todo'] = { link = 'Todo' },
    ['@comment.note'] = { link = 'Todo' },
    ['@comment.warning'] = { fg = colors.warn, italic = true },
    ['@comment.error'] = { fg = colors.error, italic = true },

    ['@function'] = { fg = colors.func },
    ['@function.call'] = { fg = colors.func },
    ['@function.method'] = { fg = colors.func },
    ['@function.method.call'] = { fg = colors.func },
    ['@method'] = { fg = colors.func },
    ['@function.builtin'] = { fg = colors.builtin },
    ['@constructor'] = { fg = colors.builtin },

    ['@keyword'] = { fg = colors.keyword },
    ['@keyword.function'] = { fg = colors.keyword },
    ['@keyword.operator'] = { fg = colors.keyword },
    ['@keyword.import'] = { fg = colors.keyword },
    ['@keyword.repeat'] = { fg = colors.keyword },
    ['@keyword.return'] = { fg = colors.keyword },
    ['@keyword.conditional'] = { fg = colors.keyword },
    ['@keyword.exception'] = { fg = colors.keyword },
    ['@operator'] = { fg = colors.fg },
    ['@exception'] = { fg = colors.keyword },
    ['@label'] = { fg = colors.keyword },

    ['@string'] = { fg = colors.string },
    ['@string.escape'] = { fg = colors.builtin },
    ['@string.special'] = { fg = colors.builtin },
    ['@string.regexp'] = { fg = colors.builtin },
    ['@character'] = { fg = colors.string },
    ['@number'] = { fg = colors.number },
    ['@number.float'] = { fg = colors.number },
    ['@boolean'] = { fg = colors.keyword },
    ['@constant'] = { fg = colors.constant, italic = true },
    ['@constant.builtin'] = { fg = colors.builtin },

    -- Classes/interfaces/namespaces are plain text in JetBrains.
    ['@type'] = { fg = colors.fg },
    ['@type.definition'] = { fg = colors.fg },
    ['@type.builtin'] = { fg = colors.keyword },
    ['@type.qualifier'] = { fg = colors.keyword },
    ['@namespace'] = { fg = colors.fg },
    ['@module'] = { fg = colors.fg },
    ['@attribute'] = { fg = colors.metadata },

    ['@punctuation'] = { fg = colors.fg },
    ['@punctuation.bracket'] = { fg = colors.fg },
    ['@punctuation.delimiter'] = { fg = colors.fg },
    ['@punctuation.special'] = { fg = colors.builtin },

    ['@tag'] = { fg = colors.keyword },
    ['@tag.builtin'] = { fg = colors.keyword },
    ['@tag.delimiter'] = { fg = colors.fg },
    ['@tag.attribute'] = { fg = colors.metadata },
    ['@symbol'] = { fg = colors.constant },

    ['@markup.heading'] = { fg = colors.fg, bold = true },
    ['@markup.strong'] = { bold = true },
    ['@markup.italic'] = { italic = true },
    ['@markup.link'] = { fg = colors.func, underline = true, sp = colors.link },
    ['@markup.link.url'] = { fg = colors.func, underline = true, sp = colors.link },
    ['@markup.raw'] = { fg = colors.string },
    ['@markup.list'] = { fg = colors.keyword },

    ['@diff.plus'] = { fg = colors.gitAdd },
    ['@diff.minus'] = { fg = colors.gitDelete },
    ['@diff.delta'] = { fg = colors.gitChange },

    -- lsp semantic
    ['@lsp.type.namespace'] = { fg = colors.fg },
    ['@lsp.type.type'] = { fg = colors.fg },
    ['@lsp.type.class'] = { fg = colors.fg },
    ['@lsp.type.enum'] = { fg = colors.fg },
    ['@lsp.type.enumMember'] = { fg = colors.constant, italic = true },
    ['@lsp.type.interface'] = { fg = colors.fg },
    ['@lsp.type.struct'] = { fg = colors.fg },
    ['@lsp.type.parameter'] = { fg = colors.fg },
    ['@lsp.type.property'] = { fg = colors.constant },
    ['@lsp.type.variable'] = { fg = colors.fg },
    ['@lsp.type.function'] = { fg = colors.func },
    ['@lsp.type.method'] = { fg = colors.func },
    ['@lsp.type.macro'] = { fg = colors.metadata },
    ['@lsp.type.decorator'] = { fg = colors.metadata },
    ['@lsp.type.keyword'] = { fg = colors.keyword },
    ['@lsp.type.string'] = { fg = colors.string },
    ['@lsp.type.number'] = { fg = colors.number },
    ['@lsp.mod.readonly'] = {},
    ['@lsp.mod.deprecated'] = { strikethrough = true },

    LspReferenceText = { bg = colors.matchParen },
    LspReferenceRead = { bg = colors.matchParen },
    LspReferenceWrite = { bg = colors.matchParen },
    LspInlayHint = { fg = colors.fgInactive, bg = config.transparent and 'NONE' or colors.bgDarker },
    LspSignatureActiveParameter = { fg = colors.fgAlt, bold = true },

    -- diagnostics
    DiagnosticError = { fg = colors.error },
    DiagnosticWarn = { fg = colors.warn },
    DiagnosticInfo = { fg = colors.info },
    DiagnosticHint = { fg = colors.hint },
    DiagnosticOk = { fg = colors.ok },
    DiagnosticVirtualTextError = { fg = colors.error },
    DiagnosticVirtualTextWarn = { fg = colors.warn },
    DiagnosticVirtualTextInfo = { fg = colors.info },
    DiagnosticVirtualTextHint = { fg = colors.hint },
    DiagnosticVirtualTextOk = { fg = colors.ok },
    DiagnosticUnderlineError = { undercurl = true, sp = colors.error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = colors.warn },
    DiagnosticUnderlineInfo = { undercurl = true, sp = colors.info },
    DiagnosticUnderlineHint = { undercurl = true, sp = colors.hint },
    DiagnosticUnderlineOk = { underline = true, sp = colors.ok },
    DiagnosticUnnecessary = { fg = colors.fgInactive },
    DiagnosticDeprecated = { strikethrough = true, sp = colors.fg },

    -- gitsigns
    GitSignsAdd = { fg = colors.gitAdd },
    GitSignsChange = { fg = colors.gitChange },
    GitSignsDelete = { fg = colors.gitDelete },
    GitSignsTopdelete = { fg = colors.gitDelete },
    GitSignsChangedelete = { fg = colors.gitChange },
    GitSignsUntracked = { fg = colors.gitAdd },
    GitSignsAddInline = { bg = colors.diffAdd },
    GitSignsChangeInline = { bg = colors.diffChange },
    GitSignsDeleteInline = { bg = colors.diffDelete },
    GitSignsCurrentLineBlame = { fg = colors.fgInactive, italic = true },
    Added = { fg = colors.gitAdd },
    Changed = { fg = colors.gitChange },
    Removed = { fg = colors.gitDelete },

    -- buffer inactive
    BufferInactive = { bg = colors.bgDark },
    BufferInactiveSign = { bg = colors.bgDark },
    BufferInactiveIndex = { bg = colors.bgDark },

    -- snacks explorer / sidebar (JetBrains tool windows sit a shade off the
    -- editor background — that separation is the whole point of the New UI)
    SnacksExplorerNormal = { fg = colors.fg, bg = sidebar },
    SnacksExplorerWinBar = { fg = colors.fgAlt, bg = sidebar },
    SnacksExplorerTitle = { fg = colors.fgAlt, bg = sidebar },

    -- snacks picker
    SnacksPicker = { fg = colors.fg, bg = sidebar },
    -- Visible border in the IDE's separator grey. The Borderless toggle
    -- (<leader>lqn) repaints it the same colour as the bg to blend in.
    SnacksPickerBorder = { fg = colors.border, bg = sidebar },
    SnacksPickerTitle = { fg = colors.fgAlt, bg = sidebar, bold = true },
    SnacksPickerInputTitle = { fg = colors.fgAlt, bg = sidebar, bold = true },
    SnacksPickerInput = { bg = sidebar },
    -- Upstream jb paints the input border the same colour as its bg for a
    -- seamless look; keep the rounded box visible instead, like the rosa themes.
    SnacksPickerInputBorder = { fg = colors.border, bg = sidebar },
    SnacksPickerList = { fg = colors.fgAlt, bg = sidebar },
    SnacksPickerPreview = { bg = sidebar },
    SnacksPickerPreviewTitle = { fg = colors.fgAlt, bg = sidebar, bold = true },
    SnacksPickerToggle = { fg = '#ffffff', bg = colors.info, bold = true },
    SnacksPickerListCursorLine = { bg = colors.rowSelected },
    SnacksPickerCursorLine = { bg = colors.rowSelected },
    SnacksPickerDir = { fg = colors.fgAlt },
    SnacksPickerFile = { fg = colors.fgAlt },
    SnacksPickerPathHidden = { fg = colors.fgAlt },
    SnacksPickerPathIgnored = { fg = colors.fgInactive },
    SnacksPickerMatch = { fg = colors.info, bold = true },
    -- The `>` prompt glyph. Snacks links it to Special, which is the orange
    -- escape-sequence colour here; use the muted UI grey instead — readable
    -- without pulling attention like an accent would.
    SnacksPickerPrompt = { fg = colors.fgInactive },
    SnacksPickerTree = { fg = colors.separator },

    -- rosapick (window picker) label border, same separator grey as the picker.
    RosapickBorder = { fg = colors.border, bg = colors.bgSolid },

    -- snacks input
    SnacksInputIcon = { fg = colors.info },
    SnacksInputTitle = { fg = colors.fgAlt, bold = true },
    SnacksInputBorder = { fg = colors.border },

    -- snacks indent
    SnacksIndent = { fg = colors.separator },
    SnacksIndentScope = { fg = colors.fgInactive },
    SnacksIndentUnderline_SnacksIndentScope = { fg = colors.fgInactive },
    IblIndent = { fg = colors.separator },
    IblScope = { fg = colors.fgInactive },

    -- snacks dashboard
    SnacksDashboardDesc = { fg = colors.fg },
    SnacksDashboardDir = { fg = colors.fgInactive },
    SnacksDashboardHeader = { fg = colors.func },
    SnacksDashboardFooter = { fg = colors.fgInactive },
    SnacksDashboardIcon = { fg = colors.keyword },
    SnacksDashboardFile = { fg = colors.fg },
    SnacksDashboardKey = { fg = colors.constant },
    SnacksDashboardTitle = { fg = colors.fgAlt, bold = true },

    -- snacks notifier
    SnacksNotifierBorderInfo = { fg = colors.border },
    SnacksNotifierBorderWarn = { fg = colors.border },
    SnacksNotifierBorderError = { fg = colors.border },
    SnacksNotifierIconInfo = { fg = colors.info },
    SnacksNotifierIconWarn = { fg = colors.warn },
    SnacksNotifierIconError = { fg = colors.error },
    SnacksNotifierTitleInfo = { fg = colors.fgAlt, bold = true },
    SnacksNotifierTitleWarn = { fg = colors.fgAlt, bold = true },
    SnacksNotifierTitleError = { fg = colors.fgAlt, bold = true },

    -- noice
    NoiceConfirmBorder = { fg = colors.border },
    NoiceCmdlinePrompt = { fg = colors.fgInactive },
    NoiceCmdlinePopupBorder = { fg = colors.border },
    NoiceCmdlinePopupTitleCmdline = { fg = colors.fgAlt },
    NoiceCmdlinePopupTitle = { fg = colors.fgAlt },
    NoiceCmdlineTitle = { fg = colors.fgAlt },
    NoiceCmdlineIcon = { fg = colors.info },
    NoiceCmdlineIconSearch = { fg = colors.warn },

    -- blink.cmp
    BlinkCmpMenu = { fg = colors.fg, bg = float },
    BlinkCmpMenuBorder = { fg = colors.border, bg = float },
    BlinkCmpMenuSelection = { bg = colors.bgOption },
    BlinkCmpLabel = { fg = colors.fg },
    BlinkCmpLabelMatch = { fg = colors.info, bold = true },
    BlinkCmpLabelDeprecated = { fg = colors.fgInactive, strikethrough = true },
    BlinkCmpLabelDescription = { fg = colors.fgInactive },
    BlinkCmpKind = { fg = colors.fgAlt, bg = float },
    BlinkCmpDoc = { fg = colors.fg, bg = float },
    BlinkCmpDocBorder = { fg = colors.border, bg = float },
    BlinkCmpDocSeparator = { fg = colors.separator, bg = float },
    BlinkCmpSignatureHelpBorder = { fg = colors.border, bg = float },

    -- bufferline
    BufferLineBackground = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineBufferSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineBufferVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineFill = { bg = bl_bg },
    BufferLineSeparator = { fg = bl_hidden, bg = bl_bg },
    BufferLineSeparatorSelected = { fg = bl_hidden, bg = bl_bg },
    BufferLineSeparatorVisible = { fg = bl_hidden, bg = bl_bg },
    BufferLineModified = { fg = colors.metadata, bg = bl_bg },
    BufferLineModifiedSelected = { fg = colors.metadata, bg = bl_bg },
    BufferLineModifiedVisible = { fg = colors.metadata, bg = bl_bg },
    -- No accent stripe on the active tab: paint the indicator the bar colour.
    BufferLineIndicatorSelected = { fg = bl_hidden, bg = bl_bg },
    BufferLineIndicatorVisible = { fg = bl_hidden, bg = bl_bg },
    BufferLineCloseButton = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineCloseButtonSelected = { fg = colors.fgAlt, bg = bl_bg },
    BufferLineCloseButtonVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineTab = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineTabSelected = { fg = colors.fgAlt, bg = bl_bg },
    BufferLineTabSeparator = { fg = bl_hidden, bg = bl_bg },
    BufferLineTabSeparatorSelected = { fg = bl_hidden, bg = bl_bg },
    BufferLineTabClose = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineDuplicate = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineDuplicateSelected = { fg = colors.fgAlt, bg = bl_bg },
    BufferLineDuplicateVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineTruncMarker = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineOffset = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineOffsetSeparator = { fg = bl_hidden, bg = bl_bg },
    BufferLinePick = { fg = colors.pick, bg = bl_bg, bold = true },
    BufferLinePickSelected = { fg = colors.pick, bg = bl_bg, bold = true },
    BufferLinePickVisible = { fg = colors.pick, bg = bl_bg, bold = true },
    BufferLineNumbers = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineNumbersSelected = { fg = colors.fgAlt, bg = bl_bg },
    BufferLineNumbersVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineDiagnostic = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineDiagnosticSelected = { fg = colors.fgAlt, bg = bl_bg },
    BufferLineDiagnosticVisible = { fg = colors.fgInactive, bg = bl_bg },

    -- Buffers carrying diagnostics. Left undefined, bufferline builds these
    -- from Diagnostic<Severity> for the fg and the editor Normal bg for the bg,
    -- which paints the active file name red on the wrong shade. Pin them to the
    -- plain buffer look instead — severity still shows in the diagnostics
    -- indicator counts, which carry their own Diagnostic* highlights.
    BufferLineError = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineErrorVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineErrorSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineErrorDiagnostic = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineErrorDiagnosticVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineErrorDiagnosticSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineWarning = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineWarningVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineWarningSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineWarningDiagnostic = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineWarningDiagnosticVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineWarningDiagnosticSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineInfo = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineInfoVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineInfoSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineInfoDiagnostic = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineInfoDiagnosticVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineInfoDiagnosticSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineHint = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineHintVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineHintSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },
    BufferLineHintDiagnostic = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineHintDiagnosticVisible = { fg = colors.fgInactive, bg = bl_bg },
    BufferLineHintDiagnosticSelected = { fg = colors.fgAlt, bg = bl_bg, bold = true },

    -- which-key
    WhichKey = { fg = colors.keyword, bg = sidebar },
    WhichKeyNormal = { fg = colors.fg, bg = sidebar },
    -- Visible border in the IDE separator grey; the Borderless toggle
    -- (<leader>lqn) repaints it bg-coloured to blend in.
    WhichKeyBorder = { fg = colors.border, bg = sidebar },
    WhichKeyTitle = { fg = colors.fgAlt, bg = sidebar, bold = true },
    WhichKeyGroup = { fg = '#7e838d' },
    WhichKeyDesc = { fg = colors.fg },
    WhichKeyValue = { fg = colors.fgInactive },
    WhichKeySeparator = { fg = colors.fgInactive },

    -- incline / dropbar. The breadcrumb bar follows the EDITOR background (and
    -- goes bg-less in transparent mode) rather than the tool-window shade, so it
    -- reads as part of the buffer instead of a second toolbar.
    InclineNormal = { fg = colors.fgAlt, bg = bg },
    InclineNormalNC = { fg = colors.fgInactive, bg = bg },
    WinBar = { fg = colors.fgInactive, bg = bg },
    WinBarNC = { fg = colors.fgInactive, bg = bg },
  }

  -- overrides
  groups =
    vim.tbl_extend('force', groups, type(config.overrides) == 'function' and config.overrides() or config.overrides)

  for group, parameters in pairs(groups) do
    vim.api.nvim_set_hl(0, group, parameters)
  end

  -- Borderless-mode repaint must run on EVERY set_groups path: lualine's
  -- 'auto' theme re-sources this file without firing ColorScheme.
  pcall(function()
    require('rosavim.config.borderless').apply()
  end)
  -- Invert Backgrounds (<leader>lqi<theme>): swap the editor surface with the
  -- explorer/tab chrome. Runs here as well as from the ColorScheme autocmd
  -- because lualine's 'auto' theme re-sources this file without firing it.
  pcall(function()
    require('rosavim.config.invert_bg').apply()
  end)
end

function M.setup(values)
  local merged = vim.tbl_extend('force', config.defaults, values)
  for k, v in pairs(merged) do
    config[k] = v
  end
end

function M.colorscheme()
  -- Sync transparent state from appearance module
  local ok, appearance = pcall(require, 'rosavim.config.appearance')
  if ok then
    config.transparent = appearance.get_transparent()
  end

  vim.api.nvim_command 'hi clear'
  if vim.fn.exists 'syntax_on' then
    vim.api.nvim_command 'syntax reset'
  end

  vim.g.VM_theme_set_by_colorscheme = true
  vim.o.termguicolors = true
  vim.g.colors_name = 'rosajet'

  -- Clear cached color module so it re-evaluates vim.o.background
  package.loaded['rosajet.colors'] = nil

  set_terminal_colors()
  set_groups()
end

return M

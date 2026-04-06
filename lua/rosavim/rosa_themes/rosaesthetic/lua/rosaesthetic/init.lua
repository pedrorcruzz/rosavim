local config = require 'rosaesthetic.config'
local M = {}

local function set_terminal_colors()
  local colors = require 'rosaesthetic.colors'
  if vim.o.background == 'light' then
    vim.g.terminal_color_0 = '#d3d2ce'
    vim.g.terminal_color_1 = '#834742'
    vim.g.terminal_color_2 = '#2c633f'
    vim.g.terminal_color_3 = '#645826'
    vim.g.terminal_color_4 = '#3c5a89'
    vim.g.terminal_color_5 = '#784872'
    vim.g.terminal_color_6 = '#006470'
    vim.g.terminal_color_7 = '#444136'
    vim.g.terminal_color_8 = '#c3c0ba'
    vim.g.terminal_color_9 = '#834742'
    vim.g.terminal_color_10 = '#2c633f'
    vim.g.terminal_color_11 = '#645826'
    vim.g.terminal_color_12 = '#3c5a89'
    vim.g.terminal_color_13 = '#784872'
    vim.g.terminal_color_14 = '#006470'
    vim.g.terminal_color_15 = '#312d23'
  else
    vim.g.terminal_color_0 = '#000000'
    vim.g.terminal_color_1 = '#e07a6e'
    vim.g.terminal_color_2 = '#7cbd8a'
    vim.g.terminal_color_3 = '#d4b462'
    vim.g.terminal_color_4 = '#82b0d4'
    vim.g.terminal_color_5 = '#c49aba'
    vim.g.terminal_color_6 = '#5cb8c4'
    vim.g.terminal_color_7 = '#d4d0c8'
    vim.g.terminal_color_8 = '#555555'
    vim.g.terminal_color_9 = '#e07a6e'
    vim.g.terminal_color_10 = '#7cbd8a'
    vim.g.terminal_color_11 = '#d4b462'
    vim.g.terminal_color_12 = '#82b0d4'
    vim.g.terminal_color_13 = '#c49aba'
    vim.g.terminal_color_14 = '#5cb8c4'
    vim.g.terminal_color_15 = '#eeece6'
  end
  vim.g.terminal_color_background = colors.bg
  vim.g.terminal_color_foreground = colors.fg
end

local function set_groups()
  local colors = require 'rosaesthetic.colors'
  local utils = require 'rosaesthetic.utils'
  local bg = config.transparent and 'NONE' or colors.bg
  local sidebar = config.transparent and 'NONE' or colors.bgSidebar
  local real_bg = vim.o.background == 'light' and '#d3d2ce' or '#000000'
  local diff_add = utils.shade(colors.green, 0.5, real_bg)
  local diff_delete = utils.shade(colors.red, 0.5, real_bg)
  local diff_change = utils.shade(colors.blue, 0.5, real_bg)
  local diff_text = utils.shade(colors.gold, 0.5, real_bg)

  local groups = {
    -- base
    Normal = { fg = colors.fg, bg = bg },
    Bold = { bold = true },
    Conceal = {},
    Directory = { fg = colors.fg, bold = true },
    EndOfBuffer = { fg = colors.bg, bg = bg },
    Ignore = {},
    Italic = { italic = true },
    ModeMsg = {},
    MoreMsg = {},
    Question = {},
    NonText = {},
    Terminal = {},
    Title = { bold = true },
    Underlined = { underline = true },

    Comment = { fg = colors.comment },
    CursorLineNr = { fg = colors.comment },
    LineNr = { fg = colors.fgLineNr },
    FoldColumn = { fg = colors.fg },
    SignColumn = { fg = colors.fg },

    PmenuSel = { fg = colors.fg, bg = colors.bg, reverse = true },
    StatusLine = { fg = colors.border, bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#525252' or bg), bold = true },
    StatusLineNC = { fg = colors.border, bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#414141' or bg), bold = true },
    StatusLineTerm = { fg = colors.border, bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#525252' or bg), bold = true },
    StatusLineTermNC = { fg = colors.border, bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#414141' or bg), bold = true },
    TabLineSel = { fg = colors.fg, bg = colors.bg, reverse = true },
    VisualNOS = { fg = colors.comment, bg = colors.bg, reverse = true },

    Cursor = { fg = colors.fgAlt, bg = colors.bg, reverse = true },
    lCursor = { link = 'Cursor' },
    CursorIM = { link = 'Cursor' },
    IncSearch = { fg = colors.fgAlt, bg = colors.bg, reverse = true },

    ColorColumn = { bg = colors.bgDark },
    CursorColumn = { bg = colors.bgDark },
    DiffChange = { bg = bg, fg = diff_change },
    Folded = { bg = colors.bgDark },
    QuickFixLine = { bg = colors.bgDark },

    MatchParen = { fg = colors.fgAlt, bg = colors.fgInactive },
    Pmenu = { fg = colors.fg, bg = colors.bgDark },
    NormalFloat = { bg = config.transparent and 'NONE' or colors.bgFloat },
    TabLine = { fg = colors.fg, bg = colors.bgDark },
    ToolbarButton = { fg = colors.fg, bg = colors.bgDark, bold = true },
    WildMenu = { fg = colors.fg, bg = colors.bgDark },
    PmenuSbar = { fg = colors.fgInactive, bg = colors.fgInactive },
    PmenuThumb = { fg = colors.fg, bg = colors.fg },
    TabLineFill = { fg = colors.bgDark, bg = colors.bgDark },
    ToolbarLine = { fg = colors.bgDark, bg = colors.bgDark },
    VertSplit = { fg = vim.o.background == 'dark' and '#121212' or colors.border, bg = bg },
    Winseparator = { fg = vim.o.background == 'dark' and '#121212' or colors.border, bg = bg },
    WinSeparator = { fg = vim.o.background == 'dark' and '#121212' or colors.border, bg = bg },

    SpellBad = { undercurl = true, sp = colors.spellRed },
    SpellCap = { undercurl = true, sp = colors.spellBlue },
    SpellLocal = { undercurl = true, sp = colors.spellCyan },
    SpellRare = { undercurl = true, sp = colors.spellMagenta },

    -- syntax
    StorageClass = { fg = colors.magenta },
    Structure = { fg = colors.magenta },
    Type = { fg = colors.magenta },
    Typedef = { fg = colors.magenta },
    WarningMsg = { fg = colors.magenta, bg = colors.bg, reverse = true },

    Function = { fg = colors.red },
    Identifier = { fg = colors.red },
    DiffDelete = { bg = bg, fg = diff_delete },
    Error = { fg = colors.red, bg = colors.bg, reverse = true },
    ErrorMsg = { fg = colors.red },

    Debug = { fg = colors.gold },
    Delimiter = { fg = colors.gold },
    Special = { fg = colors.gold },
    SpecialChar = { fg = colors.gold },
    SpecialComment = { fg = colors.gold },
    SpecialKey = { fg = colors.gold },
    Tag = { fg = colors.gold },
    DiffText = { bg = bg, fg = diff_text },
    Search = { fg = colors.search, bg = colors.searchFg, reverse = true },

    Conditional = { fg = colors.green },
    Exception = { fg = colors.green },
    Keyword = { fg = colors.green },
    Label = { fg = colors.green },
    Operator = { fg = colors.green },
    Repeat = { fg = colors.green },
    Statement = { fg = colors.green },
    DiffAdd = { bg = bg, fg = diff_add },

    Define = { fg = colors.cyan },
    Include = { fg = colors.cyan },
    Macro = { fg = colors.cyan },
    PreCondit = { fg = colors.cyan },
    PreProc = { fg = colors.cyan },
    Todo = { fg = colors.cyan, bg = colors.bg, reverse = true },

    Boolean = { fg = colors.blue },
    Character = { fg = colors.blue },
    Constant = { fg = colors.blue },
    Float = { fg = colors.blue },
    Number = { fg = colors.blue },
    String = { fg = colors.blue },
    Visual = { bg = config.transparent and '#4C4C4C' or (vim.o.background == 'dark' and '#525252' or '#B8CAD8') },
    VisualNOS = { bg = config.transparent and '#4C4C4C' or (vim.o.background == 'dark' and '#525252' or '#B8CAD8') },
    CursorLine = { bg = (config.transparent or vim.o.background == 'dark') and '#323232' or colors.bgDarker },

    -- treesitter (mapped to match rusticated base groups exactly)
    ['@variable'] = { fg = colors.fg },
    ['@variable.builtin'] = { fg = colors.fg },
    ['@variable.member'] = { fg = colors.fg },
    ['@variable.parameter'] = { fg = colors.fg },
    ['@text'] = { fg = colors.fg },
    ['@property'] = { fg = colors.fg },
    ['@field'] = { fg = colors.fg },
    ['@parameter'] = { fg = colors.fg },

    ['@comment'] = { link = 'Comment' },

    ['@function'] = { fg = colors.red },
    ['@function.call'] = { fg = colors.red },
    ['@function.builtin'] = { fg = colors.red },
    ['@function.method'] = { fg = colors.red },
    ['@function.method.call'] = { fg = colors.red },
    ['@method'] = { fg = colors.red },
    ['@constructor'] = { fg = colors.red },

    ['@keyword'] = { fg = colors.green },
    ['@keyword.function'] = { fg = colors.green },
    ['@keyword.operator'] = { fg = colors.green },
    ['@keyword.import'] = { fg = colors.cyan },
    ['@keyword.repeat'] = { fg = colors.green },
    ['@keyword.return'] = { fg = colors.green },
    ['@keyword.conditional'] = { fg = colors.green },
    ['@keyword.exception'] = { fg = colors.green },
    ['@operator'] = { fg = colors.green },
    ['@exception'] = { fg = colors.green },
    ['@label'] = { fg = colors.green },

    ['@string'] = { fg = colors.blue },
    ['@string.escape'] = { fg = colors.blue },
    ['@string.special'] = { fg = colors.blue },
    ['@number'] = { fg = colors.blue },
    ['@number.float'] = { fg = colors.blue },
    ['@boolean'] = { fg = colors.blue },
    ['@constant'] = { fg = colors.blue },
    ['@constant.builtin'] = { fg = colors.blue },

    ['@type'] = { fg = colors.magenta },
    ['@type.builtin'] = { fg = colors.magenta },
    ['@type.definition'] = { fg = colors.magenta },
    ['@type.qualifier'] = { fg = colors.magenta },
    ['@namespace'] = { fg = colors.magenta },
    ['@module'] = { fg = colors.magenta },
    ['@attribute'] = { fg = colors.magenta },

    ['@punctuation'] = { fg = colors.gold },
    ['@punctuation.bracket'] = { fg = colors.gold },
    ['@punctuation.delimiter'] = { fg = colors.gold },
    ['@punctuation.special'] = { fg = colors.gold },

    ['@tag'] = { fg = colors.gold },
    ['@tag.builtin'] = { fg = colors.gold },
    ['@tag.delimiter'] = { fg = colors.gold },
    ['@tag.attribute'] = { fg = colors.magenta },
    ['@symbol'] = { fg = colors.gold },
    ['@markup.heading'] = { bold = true },

    -- lsp semantic (mapped to rusticated colors)
    ['@lsp.type.namespace'] = { fg = colors.magenta },
    ['@lsp.type.type'] = { fg = colors.magenta },
    ['@lsp.type.class'] = { fg = colors.magenta },
    ['@lsp.type.enum'] = { fg = colors.magenta },
    ['@lsp.type.enumMember'] = { fg = colors.blue },
    ['@lsp.type.interface'] = { fg = colors.magenta },
    ['@lsp.type.struct'] = { fg = colors.magenta },
    ['@lsp.type.parameter'] = { fg = colors.fg },
    ['@lsp.type.property'] = { fg = colors.fg },
    ['@lsp.type.variable'] = { fg = colors.fg },
    ['@lsp.type.function'] = { fg = colors.red },
    ['@lsp.type.method'] = { fg = colors.red },
    ['@lsp.type.macro'] = { fg = colors.cyan },
    ['@lsp.type.decorator'] = { fg = colors.green },

    -- diagnostics
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.magenta },
    DiagnosticInfo = { fg = colors.blue },
    DiagnosticHint = { fg = colors.cyan },
    DiagnosticVirtualTextError = { fg = colors.red },
    DiagnosticVirtualTextWarn = { fg = colors.magenta },
    DiagnosticVirtualTextInfo = { fg = colors.blue },
    DiagnosticVirtualTextHint = { fg = colors.cyan },
    DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = colors.magenta },
    DiagnosticUnderlineInfo = { undercurl = true, sp = colors.blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = colors.cyan },

    -- buffer inactive (matching original rusticated)
    BufferInactive = { bg = colors.bgDark },
    BufferInactiveSign = { bg = colors.bgDark },
    BufferInactiveIndex = { bg = colors.bgDark },

    -- snacks explorer / sidebar
    SnacksExplorerNormal = { fg = colors.fg, bg = sidebar },
    SnacksExplorerWinBar = { fg = colors.fg, bg = sidebar },
    SnacksExplorerTitle = { fg = colors.fg, bg = sidebar },

    -- snacks picker
    SnacksPicker = { bg = sidebar },
    SnacksPickerBorder = { fg = config.transparent and colors.border or (vim.o.background == 'dark' and '#303030' or '#C0C5D0'), bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#767676' or '#DEE2EC') },
    SnacksPickerTitle = { fg = colors.fg, bg = sidebar },
    SnacksPickerInputTitle = { fg = colors.fg, bg = sidebar },
    SnacksPickerInput = { bg = sidebar },
    SnacksPickerList = { bg = sidebar },
    SnacksPickerPreview = { bg = sidebar },
    SnacksPickerToggle = { fg = colors.fg, bg = sidebar },

    -- float border
    FloatBorder = { fg = vim.o.background == 'dark' and '#303030' or colors.border },

    -- snacks input
    SnacksInputIcon = { fg = colors.fg },
    SnacksInputTitle = { fg = colors.fgAlt },
    SnacksInputBorder = { fg = colors.border },

    -- snacks indent
    SnacksIndent = { fg = (config.transparent or vim.o.background == 'dark') and '#4c4c4c' or colors.bgDark },
    SnacksIndentScope = { fg = (config.transparent or vim.o.background == 'dark') and '#abb2bf' or colors.fgInactive },
    SnacksIndentUnderline_SnacksIndentScope = { fg = (config.transparent or vim.o.background == 'dark') and '#abb2bf' or colors.fgInactive },

    -- snacks dashboard
    SnacksDashboardDesc = { fg = colors.fg },
    SnacksDashboardDir = { fg = colors.fgInactive },
    SnacksDashboardHeader = { fg = colors.magenta },
    SnacksDashboardFooter = { fg = colors.magenta },
    SnacksDashboardIcon = { fg = colors.fg },
    SnacksDashboardFile = { fg = colors.fg },
    SnacksDashboardTitle = { fg = colors.fgAlt },

    -- snacks notifier
    SnacksNotifierBorderInfo = { fg = colors.border },
    SnacksNotifierBorderWarn = { fg = colors.magenta },
    SnacksNotifierBorderError = { fg = colors.red },
    SnacksNotifierTitleInfo = { fg = colors.fgAlt },

    -- noice
    NoiceConfirmBorder = { fg = colors.border },
    NoiceCmdlinePrompt = { fg = colors.fgInactive },
    NoiceCmdlinePopupBorder = { fg = colors.border },
    NoiceCmdlinePopupTitleCmdline = { fg = colors.fgAlt },
    NoiceCmdlinePopupTitle = { fg = colors.fgAlt },
    NoiceCmdlineTitle = { fg = colors.fgAlt },
    NoiceCmdlineIcon = { fg = colors.fg },
    NoiceCmdlineIconSearch = { fg = colors.magenta },

    -- bufferline
    BufferLineBackground = { fg = colors.fgInactive, bg = colors.bgDark },
    BufferLineBufferSelected = { fg = colors.fg, bg = colors.bg },
    BufferLineSeparator = { fg = colors.bg, bg = colors.bgDark },
    BufferLineSeparatorSelected = { fg = colors.bg, bg = colors.bg },
    BufferLineFill = { bg = colors.bgDark },
    BufferLineModified = { fg = colors.gold, bg = colors.bgDark },
    BufferLineModifiedSelected = { fg = colors.gold, bg = colors.bg },
    BufferLineIndicatorSelected = { fg = colors.blue, bg = colors.bg },

    -- which-key
    WhichKey = { fg = colors.fg, bg = sidebar },
    WhichKeyNormal = { fg = colors.fg, bg = sidebar },
    WhichKeyBorder = { fg = config.transparent and colors.border or (vim.o.background == 'dark' and '#303030' or '#C0C5D0'), bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#767676' or '#DEE2EC') },
    WhichKeyTitle = { fg = colors.fgAlt, bg = sidebar },
    WhichKeyGroup = { fg = colors.green },
    WhichKeyDesc = { fg = colors.fg },
    WhichKeyValue = { fg = colors.fgInactive },
    WhichKeySeparator = { fg = colors.fgInactive },

    -- incline
    InclineNormal = { fg = (config.transparent or vim.o.background == 'dark') and '#D5D0C7' or '#454135', bg = bg },
    InclineNormalNC = { fg = (config.transparent or vim.o.background == 'dark') and '#D5D0C7' or '#454135', bg = bg },

    -- dropbar
    WinBar = { fg = (config.transparent or vim.o.background == 'dark') and '#D5D0C7' or '#43423B', bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#303030' or colors.bgSidebar) },
    WinBarNC = { fg = (config.transparent or vim.o.background == 'dark') and '#D5D0C7' or '#43423B', bg = config.transparent and 'NONE' or (vim.o.background == 'dark' and '#303030' or colors.bgSidebar) },
  }

  -- overrides
  groups =
    vim.tbl_extend('force', groups, type(config.overrides) == 'function' and config.overrides() or config.overrides)

  for group, parameters in pairs(groups) do
    vim.api.nvim_set_hl(0, group, parameters)
  end
end

function M.setup(values)
  local merged = vim.tbl_extend('force', config.defaults, values)
  for k, v in pairs(merged) do
    config[k] = v
  end
end

function M.colorscheme()
  if vim.version().minor < 8 then
    vim.notify('Neovim 0.8+ is required for rosaesthetic colorscheme', vim.log.levels.ERROR, { title = 'Rosaesthetic' })
    return
  end

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
  vim.g.colors_name = 'rosaesthetic'

  -- Clear cached color module so it re-evaluates vim.o.background
  package.loaded['rosaesthetic.colors'] = nil

  set_terminal_colors()
  set_groups()
end

return M

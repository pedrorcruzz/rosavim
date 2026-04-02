local M = {}

function M.get(mode, transparent_background)
  if mode == 'light' then
    return {}
  end
  return {
    Directory = { fg = '#DAE7EC' }, --#A1BCC5

    Normal = { fg = '#abb2bf', bg = transparent_background and 'none' or '#000000' }, --#202020 #000000 #0D0D0D #101010
    EndOfBuffer = { fg = '#000000', bg = 'none' },
    NormalFloat = { bg = transparent_background and 'none' or '#000000' }, --#101010
    VertSplit = { fg = transparent_background and '#121212' or '#121212' },
    WinBarNC = { bg = transparent_background and 'NONE' or '#000000' },
    WinBar = { bg = transparent_background and 'NONE' or '#000000' },

    Visual = { bg = transparent_background and '#4c4c4c' or '#525252' }, --#606060
    CursorLine = { bg = '#323232' },
    CursorLineNr = { fg = '#C6C6C6' },
    SignColumn = { bg = '#323232' },
    LineNr = { fg = '#727272' }, --#4b5263 #727272
    FloatBorder = { fg = '#323232' },
    Border = { fg = '#101010' },
    FloatShadow = { fg = '#101010' },
    Search = { bg = '#606060', fg = '#abb2bf' },
    IncSearch = { bg = '#606060', fg = '#FFCDA2' },
    Underlined = { bg = nil },
    MatchParen = { fg = '#abb2bf' },
    NonText = { fg = '#727272' },
    Title = { fg = '#FFFFFF' },
    Comment = { fg = '#585858' },
    Question = { fg = '#FFFFFF' },

    StatusLineNC = { bg = transparent_background and 'NONE' or '#1c1c1c' },
    StatusLine = { bg = transparent_background and 'NONE' or '#1c1c1c' },

    --underline cmp preview
    ['@markup.heading.1.markdown'] = { fg = '#323232' },

    -- ['@punctuation.bracket'] = { fg = '#323232' },

    TreesitterContext = { fg = '#505050', bg = transparent_background and 'none' or '#111111' },
    TreesitterContextLineNumber = { fg = '#727272', bg = transparent_background and 'none' or '#111111' },
    TreesitterContextBottom = { sp = '#323232', underline = true },

    --Buferlines
    BufferLineFill = { bg = transparent_background and 'none' or '#1C1C1C' },
    BufferLinePick = { fg = '#00E0C0' },
    BufferLinePickVisible = { fg = '#00E0C0' },
    BufferLinePickSelected = { fg = '#00E0C0' },
    BufferLineModifiedVisible = { fg = '#A9A9A9', bg = '#161616' },
    BufferLineModifiedSelected = { fg = '#A9A9A9', bg = '#161616' },
    BufferLineBufferSelected = { fg = '#A9A9A9', bg = '#1616161' },
    BufferLineBackground = { fg = '#606060', bg = '#161616' },
    BufferLineBufferVisible = { fg = '#606060', bg = '#161616' },
    BufferLineBufferSelected = { fg = '#a9a9a9', bg = '#161616' },
    BufferLineSeparator = { fg = '#323232', bg = '#161616' },
    BufferLineIndicatorSelected = { fg = '#1c1c1c', bg = '#161616' },
    BufferLineCloseButton = { fg = '#606060', bg = '#161616' },
    BufferLineCloseButtonVisible = { fg = '#606060', bg = '#161616' },
    BufferLineCloseButtonSelected = { fg = '#606060', bg = '#161616' },

    -- Avante
    AvanteInlineHint = { fg = '#606060' }, --#abb2bf
    -- Keyword = { fg = '#606060' }, --#abb2bf

    --Punctuation Special
    ['@punctuation.special'] = { fg = transparent_background and '#323232' or '#323232' },
    ['@punctuation.special.bash'] = { fg = '#62747F' },
    ['@punctuation.special.python'] = { fg = '#62747F' },
    ['@punctuation.special.htmldjango'] = { fg = '#FED600' },
    ['@punctuation.special.javascript'] = { fg = '#62747F' },
    ['@punctuation.special.typescript'] = { fg = '#62747F' },
    ['@punctuation.special.go'] = { fg = '#62747F' },
    ['@punctuation.special.elixir'] = { fg = '#62747F' },
    ['@punctuation.special.c'] = { fg = '#62747F' },
    ['@punctuation.special.lua'] = { fg = '#62747F' },
    ['@punctuation.special.php'] = { fg = '#62747F' },
    ['@punctuation.special.json'] = { fg = '#62747F' },

    --number
    Number = { fg = '#FFCDA2' },

    --punctuation
    ['@punctuation'] = { fg = '#ffffff' },

    --variable
    -- ['@variable'] = { fg = '#BCBBBB' },
    -- ['@variable.builtin'] = { fg = '#BCBBBB' },

    --constant
    -- ['@constant'] = { fg = '#B3B2B3' },

    --bash
    -- ['@string.bash'] = { fg = '#BAB9BA' },
    -- ['@number.bash'] = { fg = '#BAB9BA' },
    -- ['@variable.bash'] = { fg = '#BAB9BA' },
    -- ['@constant.bash'] = { fg = '#F67582' },

    --module
    -- ['@module'] = { fg = '#B6B5B6' },

    --constructor
    -- ['@constructor'] = { fg = '#c18efe' },

    --Documentation
    ['@string.documentation'] = { fg = '#585858' },

    --html
    -- ['@none.html'] = { fg = '#B0AFB0' },
    -- ['@markup.heading.1.html'] = { fg = '#AAA9AA' },
    -- ['@markup.heading.2.html'] = { fg = '#AAA9AA' },
    -- ['@markup.heading.3.html'] = { fg = '#AAA9AA' },
    -- ['@markup.heading.4.html'] = { fg = '#AAA9AA' },
    -- ['@markup.heading.5.html'] = { fg = '#AAA9AA' },
    -- ['@markup.heading.6.html'] = { fg = '#AAA9AA' },

    --htmldjango
    -- ['@punctuation.special.htmldjango'] = { fg = '#FED600' },
    -- ['@variable.htmldjango'] = { fg = '#92A4B6' },
    -- ['@function.htmldjango'] = { fg = '#F67582' },
    -- ['@keyword.repeat.htmldjango'] = { fg = '#F67582' },
    -- ['@keyword.operator.htmldjango'] = { fg = '#F67582' },

    --Telescope
    TelescopeBorder = { fg = '#ffffff' },
    TelescopePreviewBorder = { fg = '#4c4c4c' },
    TelescopePromptBorder = { fg = '#4c4c4c' },
    TelescopeResultsBorder = { fg = '#4c4c4c' },

    --todo
    TodoBgTODO = { bg = '#64baff', fg = '#111111', bold = true },
    TodoBgNOTE = { bg = '#60DCC1', fg = '#111111', bold = true },
    TodoBgWARN = { bg = '#ffa868', fg = '#111111', bold = true },
    TodoBgFIX = { bg = '#F67582', fg = '#111111', bold = true },
    TodoFgTODO = { fg = '#64baff' },
    TodoFgNOTE = { fg = '#60DCC1' },
    TodoFgWARN = { fg = '#ffa868' },
    TodoFgFIX = { fg = '#F67582' },
    -- todobghack = { bg = '#c18efe', fg = '#111111', bold = true },
    -- todofghack = { fg = '#c18efe' },

    --diagnostic
    -- diagnosticerror = { fg = '#be5046' },
    DiagnosticWarn = { fg = '#ffa868' },
    DiagnosticInfo = { fg = '#64baff' },
    DiagnosticHint = { fg = '#60DCC1' },

    -- snacks notifier
    SnacksNotifierBorderInfo = { fg = '#4c4c4c' },
    SnacksNotifierBorderWarn = { fg = '#ffa868' },
    SnacksNotifierBorderError = { fg = '#F67582' },
    SnacksNotifierTitleInfo = { fg = '#ffffff' },

    SnacksPickerTitle = { fg = '#abb2bf', bg = '#000000' }, --#1a1a1a
    SnacksPickerInputTitle = { fg = '#abb2bf', bg = transparent_background and 'none' or '#000000' }, --explorer
    SnacksPickerBorder = { fg = transparent_background and '#101010' or '#101010', bg = transparent_background and 'none' or '#101010' }, --#323232
    SnacksPickerToggle = { fg = '#abb2bf', bg = '#1A1A1A' },

    SnacksPicker = { bg = transparent_background and 'none' or '#303030' }, --#101010
    -- SnacksPicker = { bg = '#303030' }, --#1a1a1a
    SnacksPickerBorder = { fg = '#303030', bg = transparent_background and 'NONE' or '#767676' }, --#1a1a1a

    SnacksInputIcon = { fg = '#abb2bf' }, --#ff657e
    SnacksInputTitle = { fg = '#ffffff' },
    SnacksInputBorder = { fg = '#4c4c4c' },

    SnacksIndent = { fg = '#4c4c4c' },
    SnacksIndentScope = { fg = '#abb2bf' },
    SnacksIndentUnderline_SnacksIndentScope = { fg = '#abb2bf' },

    SnacksDashboardDesc = { fg = '#ffffff' },
    SnacksDashboardDir = { fg = '#4c4c4c' },
    SnacksDashboardHeader = { fg = '#60DCC1' },
    SnacksDashboardFooter = { fg = '#60DCC1' },
    SnacksDashboardIcon = { fg = '#60DCC1' },
    SnacksDashboardFile = { fg = '#ffffff' },
    SnacksDashboardTitle = { fg = '#ffffff' },
    snacksdashboardspecial = { fg = '#ff657e' },
    -- SnacksDashboardNormal = { fg = '#4c4c4c' }, --4b4f6b

    -- noice
    NoiceConfirmBorder = { fg = '#4c4c4c' },
    NoiceCmdlinePrompt = { fg = '#4c4c4c' },
    NoiceCmdlinePopupBorder = { fg = '#4c4c4c' },
    NoiceCmdlinePopupTitleCmdline = { fg = '#ffffff' },
    NoiceCmdlinePopupTitle = { fg = '#ffffff' },
    NoiceCmdlineTitle = { fg = '#ffffff' },
    NoiceCmdlineIcon = { fg = '#62747F' }, --#ffffff
    NoiceCmdlineIconSearch = { fg = '#FFCDA2' }, --#ffffff

    -- whichkey
    WhichkeyTitle = { fg = '#abb2bf' },
    WhichkeyGroup = { fg = '#abb2bf' },

    -- fzf
    FzfLuaBorder = { fg = '#4c4c4c' },
    FzfLuaHeaderText = { fg = '#abb2bf' },
    FzfLuaDirIcon = { fg = '#abb2bf' },
    FzfLuaHeaderBind = { fg = '#ffffff' },
    FzfLuaTabTitle = { fg = '#ffffff' },
    FzfLuaSearch = { fg = '#ffffff' },

    -- nvim tree
    nvimtreenormal = { bg = transparent_background and 'none' or '#1a1a1a' },
    nvimtreeendofbuffer = { fg = '#1a1a1a', bg = nil }, -- fundo para o final do buffer no nvimtree
    nvimtreeemptyfoldername = { fg = '#666666' }, -- nome de pastas vazias no nvimtree
    nvimtreeopenedfoldername = { fg = '#579fdc' }, -- nome de pastas abertas no nvimtree
    nvimtreefoldername = { fg = '#aaaaaa' }, -- nome de pastas no nvimtree

    bufferlinefill = { bg = '#1a1a1a' }, -- cor de fundo do bufferline
  }
end

return M

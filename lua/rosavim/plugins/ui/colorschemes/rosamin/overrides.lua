local M = {}

function M.get(mode, transparent_background)
  if mode == 'light' then
    return {
      Directory = { fg = '#3B6E8F' },
      MiniPickIconDirectory = { fg = '#3B6E8F' },
      Normal = { fg = '#383A42', bg = '#FAFAFA' },
      EndOfBuffer = { fg = '#FAFAFA', bg = 'none' },
      NormalFloat = { bg = '#F0F0F0' },
      VertSplit = { fg = '#D0D0D0' },
      WinSeparator = { fg = '#D0D0D0' },
      Visual = { bg = '#D6E4F0' },
      CursorLine = { bg = '#EAEAEA' },
      CursorLineNr = { fg = '#383A42' },
      SignColumn = { bg = 'none' },
      LineNr = { fg = '#B0B0B0' },
      FloatBorder = { fg = '#C0C0C0' },
      Border = { fg = '#C0C0C0' },
      FloatShadow = { fg = '#C0C0C0' },
      Search = { bg = '#FFDF80', fg = '#383A42' },
      IncSearch = { bg = '#FFDF80', fg = '#E45649' },
      AvanteInlineHint = { fg = '#A0A0A0', bg = 'none' },
      Folded = { fg = '#7C3AED', bg = '#F0EDFF' },

      Underlined = { bg = nil },
      StatusLineNC = { bg = '#EAEAEA', fg = '#909090' },
      StatusLine = { bg = '#EAEAEA', fg = '#909090' },

      WinBarNC = { fg = '#707070', bg = '#F5F5F5' },
      WinBar = { fg = '#707070', bg = '#F5F5F5' },
      MatchParen = { fg = '#383A42', bg = '#D6E4F0' },
      NonText = { fg = '#C0C0C0' },
      Title = { fg = '#1A1A1A' },
      Question = { fg = '#1A1A1A' },

      TreesitterContext = { fg = '#909090', bg = '#F0F0F0' },
      TreesitterContextLineNumber = { fg = '#909090', bg = '#F0F0F0' },
      TreesitterContextBottom = { sp = '#D0D0D0', underline = true },

      -- Markdown: hierarchy of headings + inline elements
      ['@markup.heading.1.markdown'] = { fg = '#7C3AED', bold = true },
      ['@markup.heading.2.markdown'] = { fg = '#0184BC', bold = true },
      ['@markup.heading.3.markdown'] = { fg = '#0A9396', bold = true },
      ['@markup.heading.4.markdown'] = { fg = '#50A14F', bold = true },
      ['@markup.heading.5.markdown'] = { fg = '#C18401', bold = true },
      ['@markup.heading.6.markdown'] = { fg = '#E45649', bold = true },
      ['@markup.heading.1.marker.markdown'] = { fg = '#B79CF5' },
      ['@markup.heading.2.marker.markdown'] = { fg = '#7AB6D4' },
      ['@markup.heading.3.marker.markdown'] = { fg = '#7CC0BD' },
      ['@markup.heading.4.marker.markdown'] = { fg = '#9BC79B' },
      ['@markup.heading.5.marker.markdown'] = { fg = '#DCB76C' },
      ['@markup.heading.6.marker.markdown'] = { fg = '#EE8E84' },
      ['@markup.strong.markdown_inline'] = { fg = '#1A1A1A', bold = true },
      ['@markup.italic.markdown_inline'] = { fg = '#7C3AED', italic = true },
      ['@markup.strikethrough.markdown_inline'] = { fg = '#909090', strikethrough = true },
      ['@markup.raw.markdown_inline'] = { fg = '#E45649', bg = '#F0EDFF' },
      ['@markup.raw.block.markdown'] = { bg = '#F2F2F2' },
      ['@markup.raw.delimiter.markdown'] = { fg = '#909090' },
      ['@markup.link.markdown_inline'] = { fg = '#0184BC' },
      ['@markup.link.label.markdown_inline'] = { fg = '#7C3AED', underline = true },
      ['@markup.link.url.markdown_inline'] = { fg = '#909090', italic = true, underline = true },
      ['@markup.list.markdown'] = { fg = '#7C3AED', bold = true },
      ['@markup.list.checked.markdown'] = { fg = '#50A14F' },
      ['@markup.list.unchecked.markdown'] = { fg = '#B0B0B0' },
      ['@markup.quote.markdown'] = { fg = '#707070', italic = true },
      ['@punctuation.special.markdown'] = { fg = '#7C3AED' },
      -- Legacy @text.* fallbacks (older treesitter parsers)
      ['@text.title.1.markdown'] = { fg = '#7C3AED', bold = true },
      ['@text.title.2.markdown'] = { fg = '#0184BC', bold = true },
      ['@text.title.3.markdown'] = { fg = '#0A9396', bold = true },
      ['@text.title.4.markdown'] = { fg = '#50A14F', bold = true },
      ['@text.title.5.markdown'] = { fg = '#C18401', bold = true },
      ['@text.title.6.markdown'] = { fg = '#E45649', bold = true },
      ['@text.literal.markdown_inline'] = { fg = '#E45649', bg = '#F0EDFF' },
      ['@text.strong.markdown_inline'] = { fg = '#1A1A1A', bold = true },
      ['@text.emphasis.markdown_inline'] = { fg = '#7C3AED', italic = true },
      ['@text.uri.markdown_inline'] = { fg = '#0184BC', underline = true },

      ['@punctuation.bracket'] = { fg = '#383A42' },

      BufferLineModified = { fg = '#707070', bg = '#dddddd' },
      BufferLineModifiedVisible = { fg = '#707070', bg = '#dddddd' },
      BufferLineModifiedSelected = { fg = '#707070', bg = '#dddddd' },
      BufferLineBufferSelected = { fg = '#383A42', bg = '#dddddd' },
      BufferLineBackground = { fg = '#909090', bg = '#dddddd' },
      BufferLineSeparator = { fg = '#D0D0D0', bg = '#dddddd' },
      BufferLineIndicatorSelected = { fg = '#FAFAFA', bg = '#dddddd' },

      ['@punctuation.special'] = { fg = '#C0C0C0' },
      ['@punctuation.special.bash'] = { fg = '#A626A4' },
      ['@punctuation.special.python'] = { fg = '#A626A4' },
      ['@punctuation.special.javascript'] = { fg = '#A626A4' },
      ['@punctuation.special.typescript'] = { fg = '#A626A4' },
      ['@punctuation.special.jsx'] = { fg = '#A626A4' },
      ['@punctuation.special.tsx'] = { fg = '#A626A4' },
      ['@punctuation.special.go'] = { fg = '#A626A4' },
      ['@punctuation.special.elixir'] = { fg = '#A626A4' },
      ['@punctuation.special.c'] = { fg = '#A626A4' },
      ['@punctuation.special.lua'] = { fg = '#A626A4' },
      ['@punctuation.special.php'] = { fg = '#A626A4' },
      ['@punctuation.special.json'] = { fg = '#A626A4' },

      ['@variable'] = { fg = '#4A4A4A' },
      ['@variable.builtin'] = { fg = '#4A4A4A' },
      ['@constant'] = { fg = '#505050' },

      ['@string.bash'] = { fg = '#50A14F' },
      ['@number.bash'] = { fg = '#986801' },
      ['@variable.bash'] = { fg = '#4A4A4A' },
      ['@constant.bash'] = { fg = '#E45649' },

      ['@module'] = { fg = '#505050' },
      ['@constructor'] = { fg = '#7C3AED' },
      ['@string.documentation'] = { fg = '#A0A5B0' },

      ['@none.html'] = { fg = '#505050' },
      ['@markup.heading.1.html'] = { fg = '#383A42' },
      ['@markup.heading.2.html'] = { fg = '#383A42' },
      ['@markup.heading.3.html'] = { fg = '#383A42' },
      ['@markup.heading.4.html'] = { fg = '#383A42' },
      ['@markup.heading.5.html'] = { fg = '#383A42' },
      ['@markup.heading.6.html'] = { fg = '#383A42' },

      ['@punctuation.special.htmldjango'] = { fg = '#C18401' },
      ['@variable.htmldjango'] = { fg = '#3B6E8F' },
      ['@function.htmldjango'] = { fg = '#E45649' },
      ['@keyword.repeat.htmldjango'] = { fg = '#E45649' },
      ['@keyword.operator.htmldjango'] = { fg = '#E45649' },

      -- yaml / yml
      ['@property.yaml'] = { fg = '#0184BC' },
      ['@string.yaml'] = { fg = '#50A14F' },
      ['@number.yaml'] = { fg = '#C18401' },
      ['@boolean.yaml'] = { fg = '#7C3AED', bold = true },
      ['@constant.builtin.yaml'] = { fg = '#E45649', italic = true },
      ['@type.yaml'] = { fg = '#A626A4' },
      ['@operator.yaml'] = { fg = '#E45649' },
      ['@punctuation.delimiter.yaml'] = { fg = '#909090' },
      ['@punctuation.special.yaml'] = { fg = '#7C3AED' },
      ['@punctuation.bracket.yaml'] = { fg = '#383A42' },
      ['@comment.yaml'] = { fg = '#A0A5B0', italic = true },
      ['@label.yaml'] = { fg = '#0184BC' },

      TelescopeBorder = { fg = '#C0C0C0' },
      TelescopePreviewBorder = { fg = '#C0C0C0' },
      TelescopePromptBorder = { fg = '#C0C0C0' },
      TelescopeResultsBorder = { fg = '#C0C0C0' },

      TodoBgTODO = { bg = '#0184BC', fg = '#FFFFFF', bold = true },
      TodoBgNOTE = { bg = '#7C3AED', fg = '#FFFFFF', bold = true },
      TodoBgWARN = { bg = '#C18401', fg = '#FFFFFF', bold = true },
      TodoBgFIX = { bg = '#E45649', fg = '#FFFFFF', bold = true },
      TodoFgTODO = { fg = '#0184BC' },
      TodoFgNOTE = { fg = '#7C3AED' },
      TodoFgWARN = { fg = '#C18401' },
      TodoFgFIX = { fg = '#E45649' },

      DiagnosticWarn = { fg = '#C18401' },
      DiagnosticInfo = { fg = '#0184BC' },
      DiagnosticHint = { fg = '#7C3AED' },

      SnacksNotifierBorderInfo = { fg = '#C0C0C0' },
      SnacksNotifierBorderWarn = { fg = '#C18401' },
      SnacksNotifierBorderError = { fg = '#E45649' },
      SnacksNotifierTitleInfo = { fg = '#1A1A1A' },

      SnacksPickerTitle = { fg = '#1A1A1A', bg = '#E0E0E0' },
      SnacksPickerInputTitle = { fg = '#383A42', bg = '#F0F0F0' },
      SnacksPickerToggle = { fg = '#383A42', bg = '#F0F0F0' },
      SnacksPicker = { bg = '#F5F5F5' },
      SnacksPickerBorder = { fg = '#D0D0D0', bg = '#F5F5F5' },

      SnacksInputIcon = { fg = '#383A42' },
      SnacksInputTitle = { fg = '#1A1A1A' },
      SnacksInputBorder = { fg = '#C0C0C0' },

      SnacksIndent = { fg = '#E0E0E0' },
      SnacksIndentScope = { fg = '#909090' },
      SnacksIndentUnderline_SnacksIndentScope = { fg = '#909090' },

      SnacksDashboardDesc = { fg = '#383A42' },
      SnacksDashboardDir = { fg = '#909090' },
      SnacksDashboardHeader = { fg = '#7C3AED' },
      SnacksDashboardFooter = { fg = '#7C3AED' },
      SnacksDashboardIcon = { fg = '#383A42' },
      SnacksDashboardFile = { fg = '#383A42' },
      SnacksDashboardTitle = { fg = '#1A1A1A' },

      NoiceConfirmBorder = { fg = '#C0C0C0' },
      NoiceCmdlinePrompt = { fg = '#909090' },
      NoiceCmdlinePopupBorder = { fg = '#C0C0C0' },
      NoiceCmdlinePopupTitleCmdline = { fg = '#1A1A1A' },
      NoiceCmdlinePopupTitle = { fg = '#1A1A1A' },
      NoiceCmdlineTitle = { fg = '#1A1A1A' },
      NoiceCmdlineIcon = { fg = '#383A42' },
      NoiceCmdlineIconSearch = { fg = '#7C3AED' },

      WhichkeyTitle = { fg = '#383A42' },
      WhichkeyGroup = { fg = '#383A42' },

      FzfLuaBorder = { fg = '#C0C0C0' },
      FzfLuaHeaderText = { fg = '#383A42' },
      FzfLuaDirIcon = { fg = '#383A42' },
      FzfLuaHeaderBind = { fg = '#1A1A1A' },
      FzfLuaTabTitle = { fg = '#1A1A1A' },
      FzfLuaSearch = { fg = '#1A1A1A' },

      bufferlinefill = { bg = '#EAEAEA' },

      -- flash.nvim
      FlashMatch = { fg = '#383A42', bg = '#D6E4F0' },
      FlashCurrent = { fg = '#383A42', bg = '#D6E4F0' },
      FlashLabel = { fg = '#E45649', bg = '#D6E4F0', bold = true },
      FlashBackdrop = { fg = '#B0B0B0' },

      -- gitsigns blame
      GitSignsCurrentLineBlame = { fg = '#B0B0B0' },
    }
  end
  return {
    Directory = { fg = '#DAE7EC' }, --#A1BCC5
    MiniPickIconDirectory = { fg = '#DAE7EC' }, --#A1BCC5
    Normal = { fg = '#abb2bf', bg = transparent_background and 'none' or '#1F1F1F' }, --#202020 #000000 #1F1F1F
    EndOfBuffer = { fg = '#1F1F1F', bg = 'none' },
    NormalFloat = { bg = transparent_background and 'none' or '#1F1F1F' },
    -- VertSplit = { fg = '#4c4c4c' },
    VertSplit = { fg = transparent_background and '#1F1F1F' or '#1A1A1A' }, -- #1a1a1a
    WinSeparator = { fg = '#1A1A1A' },
    Visual = { bg = transparent_background and '#4c4c4c' or '#4c4c4c' }, --606060
    CursorLine = { bg = '#323232' },
    CursorLineNr = { fg = '#C6C6C6' },
    SignColumn = { bg = transparent_background and 'none' or '#323232' },
    LineNr = { fg = '#505050' }, --#4b5263 #727272
    FloatBorder = { fg = '#4c4c4c' }, --#4c4c4c
    Border = { fg = '#4c4c4c' },
    FloatShadow = { fg = '#4c4c4c' },
    Search = { bg = transparent_background and 'none' or '#606060', fg = '#abb2bf' },
    IncSearch = { bg = transparent_background and 'none' or '#606060', fg = '#F67582' },
    AvanteInlineHint = { fg = '#606060', bg = 'none' }, --#abb2bf
    -- Keyword = { fg = '#606060' }, --#abb2bf
    Folded = { fg = '#B990F6', bg = '#1a1a1a' },

    Underlined = { bg = nil },
    StatusLineNC = { bg = transparent_background and 'NONE' or '#1a1a1a', fg = '#606060' },
    StatusLine = { bg = transparent_background and 'NONE' or '#1a1a1a', fg = '#606060' },
    -- StatusLineNC = { fg = '#A9B2C0', bg = transparent_background and 'NONE' or '#1a1a1a' },
    -- StatusLine = { fg = '#A9B2C0', bg = transparent_background and 'NONE' or '#1a1a1a' },

    WinBarNC = { fg = '#9C9EA4', bg = transparent_background and 'NONE' or '#202020' }, -- barra de janelas não ativa
    WinBar = { fg = '#9C9EA4', bg = transparent_background and 'NONE' or '#202020' }, -- barra de janelas não ativa
    -- TabLine = { bg = transparent_background and 'NONE' or '#202020' },
    -- TabLineFill = { bg = transparent_background and 'NONE' or '#202020' },
    MatchParen = { fg = '#abb2bf' }, --quando coloca o cursor em cima de um parênteses / tag
    NonText = { fg = '#727272' },
    Title = { fg = '#FFFFFF' },
    Question = { fg = '#FFFFFF' },

    TreesitterContext = { fg = '#505050', bg = transparent_background and 'none' or '#1c1c1c' },
    TreesitterContextLineNumber = { fg = '#505050', bg = transparent_background and 'none' or '#1c1c1c' },
    TreesitterContextBottom = { sp = '#505050', underline = true },

    -- Markdown: hierarchy of headings + inline elements
    ['@markup.heading.1.markdown'] = { fg = '#C18EFE', bold = true },
    ['@markup.heading.2.markdown'] = { fg = '#64BAFF', bold = true },
    ['@markup.heading.3.markdown'] = { fg = '#7DD3FC', bold = true },
    ['@markup.heading.4.markdown'] = { fg = '#A0D6A0', bold = true },
    ['@markup.heading.5.markdown'] = { fg = '#FFD580', bold = true },
    ['@markup.heading.6.markdown'] = { fg = '#FFA868', bold = true },
    ['@markup.heading.1.marker.markdown'] = { fg = '#8E6FB8' },
    ['@markup.heading.2.marker.markdown'] = { fg = '#4A89BF' },
    ['@markup.heading.3.marker.markdown'] = { fg = '#5B9DBE' },
    ['@markup.heading.4.marker.markdown'] = { fg = '#7AA37A' },
    ['@markup.heading.5.marker.markdown'] = { fg = '#BFA060' },
    ['@markup.heading.6.marker.markdown'] = { fg = '#BF7E4F' },
    ['@markup.strong.markdown_inline'] = { fg = '#FFFFFF', bold = true },
    ['@markup.italic.markdown_inline'] = { fg = '#DAB8FF', italic = true },
    ['@markup.strikethrough.markdown_inline'] = { fg = '#727272', strikethrough = true },
    ['@markup.raw.markdown_inline'] = { fg = '#FFB86C', bg = '#2A2A2A' },
    ['@markup.raw.block.markdown'] = { bg = '#2F2F2F' },
    ['@markup.raw.block'] = { bg = '#2F2F2F' },
    ['@markup.raw.delimiter.markdown'] = { fg = '#606060' },
    ['@markup.link.markdown_inline'] = { fg = '#64BAFF' },
    ['@markup.link.label.markdown_inline'] = { fg = '#C18EFE', underline = true },
    ['@markup.link.url.markdown_inline'] = { fg = '#6B737C', italic = true, underline = true },
    ['@markup.list.markdown'] = { fg = '#C18EFE', bold = true },
    ['@markup.list.checked.markdown'] = { fg = '#A0D6A0' },
    ['@markup.list.unchecked.markdown'] = { fg = '#606060' },
    ['@markup.quote.markdown'] = { fg = '#9B9B9B', italic = true },
    ['@punctuation.special.markdown'] = { fg = '#C18EFE' },
    -- Legacy @text.* fallbacks (older treesitter parsers)
    ['@text.title.1.markdown'] = { fg = '#C18EFE', bold = true },
    ['@text.title.2.markdown'] = { fg = '#64BAFF', bold = true },
    ['@text.title.3.markdown'] = { fg = '#7DD3FC', bold = true },
    ['@text.title.4.markdown'] = { fg = '#A0D6A0', bold = true },
    ['@text.title.5.markdown'] = { fg = '#FFD580', bold = true },
    ['@text.title.6.markdown'] = { fg = '#FFA868', bold = true },
    ['@text.literal.markdown_inline'] = { fg = '#FFB86C', bg = '#2A2A2A' },
    ['@text.strong.markdown_inline'] = { fg = '#FFFFFF', bold = true },
    ['@text.emphasis.markdown_inline'] = { fg = '#DAB8FF', italic = true },
    ['@text.uri.markdown_inline'] = { fg = '#64BAFF', underline = true },

    ['@punctuation.bracket'] = { fg = '#abb2bf' },

    --Buferlines
    -- BufferLinePick = { fg = '#CA8BFF' },
    -- BufferLinePickVisible = { fg = '#CA8BFF' },
    -- BufferLinePickSelected = { fg = '#A9A9A9' },
    BufferLineModified = { fg = '#A9A9A9' },
    -- BufferLineFill = { bg = '#da70d6' },
    BufferLineModifiedVisible = { fg = '#A9A9A9' },
    BufferLineModifiedSelected = { fg = '#A9A9A9' },
    BufferLineBufferSelected = { fg = '#A9A9A9' },
    BufferLineBackground = { fg = '#606060' },
    -- BufferLineBufferVisible = { bg = '#606060' },
    BufferLineSeparator = { fg = '#323232' },
    BufferLineIndicatorSelected = { fg = '#1a1a1a' },

    --Punctuation Special
    ['@punctuation.special'] = { fg = '#323232' },
    ['@punctuation.special.bash'] = { fg = '#DA70D6' },
    ['@punctuation.special.python'] = { fg = '#DA70D6' },
    ['@punctuation.special.javascript'] = { fg = '#DA70D6' },
    ['@punctuation.special.typescript'] = { fg = '#DA70D6' },
    ['@punctuation.special.jsx'] = { fg = '#DA70D6' },
    ['@punctuation.special.tsx'] = { fg = '#DA70D6' },
    ['@punctuation.special.go'] = { fg = '#DA70D6' },
    ['@punctuation.special.elixir'] = { fg = '#DA70D6' },
    ['@punctuation.special.c'] = { fg = '#DA70D6' },
    ['@punctuation.special.lua'] = { fg = '#DA70D6' },
    ['@punctuation.special.php'] = { fg = '#DA70D6' },
    ['@punctuation.special.json'] = { fg = '#DA70D6' },

    --variable
    ['@variable'] = { fg = '#BCBBBB' },
    ['@variable.builtin'] = { fg = '#BCBBBB' },

    --constant
    ['@constant'] = { fg = '#B3B2B3' },

    --bash
    ['@string.bash'] = { fg = '#BAB9BA' },
    ['@number.bash'] = { fg = '#BAB9BA' },
    ['@variable.bash'] = { fg = '#BAB9BA' },
    ['@constant.bash'] = { fg = '#F67582' },

    --module
    ['@module'] = { fg = '#B6B5B6' },

    --constructor
    ['@constructor'] = { fg = '#c18efe' },

    --Documentation
    ['@string.documentation'] = { fg = '#646B73' },

    --html
    ['@none.html'] = { fg = '#B0AFB0' },
    ['@markup.heading.1.html'] = { fg = '#AAA9AA' },
    ['@markup.heading.2.html'] = { fg = '#AAA9AA' },
    ['@markup.heading.3.html'] = { fg = '#AAA9AA' },
    ['@markup.heading.4.html'] = { fg = '#AAA9AA' },
    ['@markup.heading.5.html'] = { fg = '#AAA9AA' },
    ['@markup.heading.6.html'] = { fg = '#AAA9AA' },

    --JSX and TSX
    -- ['@tag.jsx.element'] = { fg = '#B0AFB0' },

    --htmldjango
    ['@punctuation.special.htmldjango'] = { fg = '#FED600' },
    ['@variable.htmldjango'] = { fg = '#92A4B6' },
    ['@function.htmldjango'] = { fg = '#F67582' },
    ['@keyword.repeat.htmldjango'] = { fg = '#F67582' },
    ['@keyword.operator.htmldjango'] = { fg = '#F67582' },

    --yaml / yml
    ['@property.yaml'] = { fg = '#64BAFF' },
    ['@string.yaml'] = { fg = '#A0D6A0' },
    ['@number.yaml'] = { fg = '#FFD580' },
    ['@boolean.yaml'] = { fg = '#C18EFE', bold = true },
    ['@constant.builtin.yaml'] = { fg = '#F67582', italic = true },
    ['@type.yaml'] = { fg = '#DA70D6' },
    ['@operator.yaml'] = { fg = '#F67582' },
    ['@punctuation.delimiter.yaml'] = { fg = '#606060' },
    ['@punctuation.special.yaml'] = { fg = '#C18EFE' },
    ['@punctuation.bracket.yaml'] = { fg = '#abb2bf' },
    ['@comment.yaml'] = { fg = '#646B73', italic = true },
    ['@label.yaml'] = { fg = '#64BAFF' },

    --Telescope
    TelescopeBorder = { fg = '#ffffff' },
    TelescopePreviewBorder = { fg = '#4c4c4c' },
    TelescopePromptBorder = { fg = '#4c4c4c' },
    TelescopeResultsBorder = { fg = '#4c4c4c' },

    --todo
    TodoBgTODO = { bg = '#64baff', fg = '#111111', bold = true },
    TodoBgNOTE = { bg = '#c18efe', fg = '#111111', bold = true },
    TodoBgWARN = { bg = '#ffa868', fg = '#111111', bold = true },
    TodoBgFIX = { bg = '#F67582', fg = '#111111', bold = true },
    TodoFgTODO = { fg = '#64baff' },
    TodoFgNOTE = { fg = '#c18efe' },
    TodoFgWARN = { fg = '#ffa868' },
    TodoFgFIX = { fg = '#F67582' },
    -- todobghack = { bg = '#c18efe', fg = '#111111', bold = true },
    -- todofghack = { fg = '#c18efe' },

    --diagnostic
    -- diagnosticerror = { fg = '#be5046' },
    DiagnosticWarn = { fg = '#ffa868' },
    DiagnosticInfo = { fg = '#64baff' },
    DiagnosticHint = { fg = '#c18efe' },

    -- snacks notifier
    SnacksNotifierBorderInfo = { fg = '#4c4c4c' },
    SnacksNotifierBorderWarn = { fg = '#ffa868' },
    SnacksNotifierBorderError = { fg = '#F67582' },
    SnacksNotifierTitleInfo = { fg = '#ffffff' },

    SnacksPickerTitle = { fg = '#ffffff', bg = '#323232' },
    SnacksPickerInputTitle = { fg = '#abb2bf', bg = '#1A1A1A' }, --explorer 202020 or 1A1A1A
    SnacksPickerToggle = { fg = '#abb2bf', bg = '#1A1A1A' },

    -- SnacksPicker = { bg = '#1A1A1A' },
    SnacksPicker = { bg = transparent_background and 'none' or '#1A1A1A' },
    SnacksPickerBorder = { fg = '#323232', bg = transparent_background and 'none' or '#1A1A1A' },

    SnacksInputIcon = { fg = '#abb2bf' }, --#ff657e
    SnacksInputTitle = { fg = '#ffffff' },
    SnacksInputBorder = { fg = '#4c4c4c' },

    SnacksIndent = { fg = '#4c4c4c' },
    SnacksIndentScope = { fg = '#abb2bf' },
    SnacksIndentUnderline_SnacksIndentScope = { fg = '#abb2bf' },

    SnacksDashboardDesc = { fg = '#ffffff' },
    SnacksDashboardDir = { fg = '#4c4c4c' },
    SnacksDashboardHeader = { fg = '#c18efe' },
    SnacksDashboardFooter = { fg = '#c18efe' },
    SnacksDashboardIcon = { fg = '#ffffff' },
    SnacksDashboardFile = { fg = '#ffffff' },
    SnacksDashboardTitle = { fg = '#ffffff' },
    -- snacksdashboardspecial = { fg = '#ff657e' },
    -- SnacksDashboardNormal = { fg = '#4c4c4c' }, --4b4f6b

    -- noice
    NoiceConfirmBorder = { fg = '#4c4c4c' },
    NoiceCmdlinePrompt = { fg = '#4c4c4c' },
    NoiceCmdlinePopupBorder = { fg = '#4c4c4c' },
    NoiceCmdlinePopupTitleCmdline = { fg = '#ffffff' },
    NoiceCmdlinePopupTitle = { fg = '#ffffff' },
    NoiceCmdlineTitle = { fg = '#ffffff' },
    NoiceCmdlineIcon = { fg = '#abb2bf' }, --#ffffff
    NoiceCmdlineIconSearch = { fg = '#c18efe' }, --#ffffff

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

    -- flash.nvim
    FlashMatch = { fg = '#abb2bf', bg = '#606060' },
    FlashCurrent = { fg = '#abb2bf', bg = '#606060' },
    FlashLabel = { fg = '#F67582', bg = '#606060', bold = true },
    FlashBackdrop = { fg = '#505050' },

    -- gitsigns blame
    GitSignsCurrentLineBlame = { fg = '#727272' },
  }
end

return M

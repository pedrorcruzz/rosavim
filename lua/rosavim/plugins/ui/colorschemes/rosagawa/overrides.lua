local toggles = require 'rosavim.config.toggles'

local M = {}

-- Gutter BG toggle (<leader>lqu) — rosagawa's own LineNr/CursorLineNr/
-- SignColumn/FoldColumn paint theme.ui.bg_gutter (dragon #282727 / lotus
-- #dddddd), a shade distinct from the editor's own Normal bg on purpose —
-- that grey strip down the left edge is part of rosagawa's look. When flat,
-- the gutter is repainted to match the editor bg instead: theme.ui.bg per
-- mode, or NONE under transparency (same rule Normal itself follows).
local EDITOR_BG = {
  dark = '#181616',
  light = '#ffffff',
}

-- kanagawa's own float border colour (dragon #54546D / lotus #716e61) reads
-- too blue/saturated next to the other rosa themes' neutral grey borders
-- (which-key, Snacks pickers, blink.cmp...). Match rosamin's border grey
-- instead, in every mode.
local BORDER_FG = {
  dark = '#4c4c4c',
  light = '#C0C0C0',
}

-- rosamin's Cursor — kanagawa's own (fg=ui.bg, bg=ui.fg) renders as a flat
-- grey block against the new neutral light bg; rosamin's own Cursor override
-- is a soft accent instead (pale blue light / light grey dark).
local CURSOR_FG = {
  dark = '#212121',
  light = '#1A1A1A',
}
local CURSOR_BG = {
  dark = '#C1C1C1',
  light = '#9CC3E8', -- darker than rosamin's own #D3E5F1: too pale to see otherwise
}

-- Snacks explorer/picker background. rosagawa never set this explicitly, so
-- it fell back to NormalFloat/float.bg — a different shade from the gutter
-- and from the title/input boxes, so the panel read as several mismatched
-- greys. light matches the one grey the rest of light mode now uses
-- (bg_gutter/bg_m1/bg_p1/bg_p2, see themes.lua's lotus()); dark keeps its
-- existing float-bg look explicitly instead of relying on the fallback.
-- Both drop to NONE under transparency (see M.get below) so the picker
-- actually goes see-through instead of keeping this solid colour.
local SNACKS_EXPLORER_BG = {
  dark = '#0D0C0C',
  light = '#E0E0E0',
}

-- The explorer's selected-row highlight defaults (via Snacks' `default =
-- true` registration) to `Visual`'s bg, which is a much bluer tone than the
-- editor's own CursorLine. Pin it to the real CursorLine bg (dragon bg_p2
-- #393836 / lotus bg_p2 #e4d794) so the explorer's "cursor on a row" look
-- matches a normal buffer's cursorline instead of a visual selection.
-- light was kanagawa-lotus's own bg_p2 (#e4d794, yellow — same warm family
-- as the old gutter bg) until this fix; now the new neutral bg_p2 (#dddddd,
-- see themes.lua's lotus()).
local EXPLORER_CURSORLINE_BG = {
  dark = '#393836',
  light = '#dddddd',
}

-- rosamin's folder colour — kanagawa's own Directory (theme.syn.fun) reads
-- too blue/teal next to rosamin's softer tone. Covers Directory itself plus
-- MiniPickIconDirectory and SnacksPickerDirectory, which both link to it.
local DIRECTORY_FG = {
  dark = '#DAE7EC',
  light = '#3B6E8F',
}

-- rosamin's split divider — kanagawa's own WinSeparator/VertSplit (bg_m3,
-- dragon #0D0C0C / lotus bg_m3) is nearly invisible against the float bg,
-- which also uses bg_m3. rosamin's greys stay visible without standing out.
local SEPARATOR_FG = {
  dark = '#1A1A1A',
  light = '#D0D0D0',
}

-- Same value as theme.ui.float.bg (dragon/lotus). Snacks never defines
-- `SnacksPickerPrompt`/`SnacksPickerTotals` itself (no kanagawa or Snacks
-- default at all), so when the ">" prompt icon and the "n/n" match counter
-- are drawn through 'statuscolumn' (prompt icon) and virtual text (counter)
-- their bg falls back to the terminal's own background instead of the
-- float's — a visibly different near-black. Pin it explicitly.
-- light matches theme.ui.float.bg in themes.lua's lotus() (rosamin's bgFloat).
local FLOAT_BG = {
  dark = '#0D0C0C',
  light = '#E0E0E0',
}

-- theme.syn.special1 — Snacks' own default for SnacksPickerPrompt links to
-- `Special` (kanagawa: fg = syn.special1), so set it explicitly here too:
-- a `default = true` registration never overrides a group we've already set
-- explicitly (even partially), so merging only `bg` in would silently drop
-- this fg the moment Snacks tries to apply its own default.
local PROMPT_FG = {
  dark = '#949fb5',
  light = '#6693bf',
}

-- rosamin's diagnostic severity colours.
local DIAGNOSTIC = {
  dark = { error = '#FF7A84', warn = '#ffa868', info = '#64baff', hint = '#6b737c' },
  light = { error = '#d6656a', warn = '#C18401', info = '#0184BC', hint = '#848484' },
}

-- rosamin's Visual selection — kanagawa's own (bg_visual, dragon waveBlue1
-- #223249 / lotus lotusViolet3) is a saturated blue; rosamin's dark Visual
-- is a neutral grey instead (same tone as the border), light stays a soft
-- blue-grey.
local VISUAL_BG = {
  dark = '#4c4c4c',
  light = '#D6E4F0',
}

-- rosamin's completion menu — kanagawa's own popup menu colours (pmenu.bg/
-- bg_sel: dragon waveBlue1/waveBlue2, lotus lotusBlue1/lotusBlue3) are
-- saturated blues. rosamin keeps the menu at the float bg and only nudges
-- the selected row a shade darker (lighter in light mode) instead of tinting
-- it blue. blink.cmp's BlinkCmpMenu/BlinkCmpMenuSelection link straight to
-- Pmenu/PmenuSel, so this covers it too.
local PMENU_BG = {
  dark = '#181616',
  light = '#E0E0E0',
}
local PMENU_SEL_BG = {
  dark = '#393836',
  light = '#EDEDED',
}

-- rosamin's snacks notifier. Info/Warn reuse rosamin's own border/diagnostic
-- greys (border_fg, diag.warn below); Error and the Info title get their own
-- rosamin-specific colours, distinct from DiagnosticError/the default title.
local NOTIFIER_ERROR_FG = {
  dark = '#F67582',
  light = '#E45649',
}
local NOTIFIER_TITLE_FG = {
  dark = '#ffffff',
  light = '#1A1A1A',
}

-- rosamin's Snacks input (the "Add a new file or directory" prompt, rename,
-- etc.): snacks/input.lua registers SnacksInputBorder/Title as `default =
-- true` links to DiagnosticInfo, and SnacksInputIcon to DiagnosticHint.
-- rosagawa overrides DiagnosticInfo to a bright blue (diag.info above), so
-- without an explicit override here the whole prompt box — border and title
-- text — rendered in that same blue. Pin it to rosamin's neutral look
-- instead: icon at the normal buffer fg, title at the bright title colour,
-- border at the shared border grey.
local SNACKS_INPUT_ICON_FG = {
  dark = '#c5c9c5',
  light = '#616161',
}

-- rosamin's bufferline (tab bar). rosagawa never defined a single BufferLine*
-- group, so bufferline.nvim fell back to its own defaults derived from
-- Normal: under transparency that left the bar looking broken/see-through
-- instead of rosamin's solid dark strip, and the auto-derived file-icon
-- square landed on a shade different from the rest of the tab (the
-- race-condition fix in plugins/ui/bufferline.lua forces the icon bg to
-- match BufferLineFill, but that only helps once BufferLineFill itself is
-- actually set). rosamin draws selected vs. inactive purely through
-- fg/bold, never a different bg, so every group below shares one flat bg
-- per mode: rosamin's own #1A1A1A dark / #dddddd light, exactly.
local BUFFERLINE_BG = {
  dark = '#1A1A1A',
  light = '#dddddd',
}
local BUFFERLINE_FG = {
  dark = '#c1c1c1',
  light = '#616161',
}
local BUFFERLINE_FG_INACTIVE = {
  dark = '#484848',
  light = '#9E9E9E',
}
-- rosamin's bufferline "modified" dot/fg — exact match, dark and light.
-- rosamin never varies this by transparency, so the dark value covers both.
local BUFFERLINE_MODIFIED = {
  dark = '#A9A9A9',
  light = '#707070',
}

-- rosamin's LineNr fg, exact match — kanagawa's own (theme.ui.nontext) reads
-- too muted/green against rosagawa's palette. Flat across dark and
-- transparent (only the gutter bg itself drops under transparency, via the
-- rosagawa_gutter_flat toggle below).
local LINENR_FG = {
  dark = '#505050', -- brighter alternative tried: #6A6A6A
  light = '#B0B0B0', -- brighter alternative tried: #909090
}

-- rosamin's CursorLineNr fg — kanagawa's own (theme.diag.warning, bold) paints
-- the cursor line's number bright orange; rosamin never varies this by
-- transparency, so match it flat here too, dark and light.
local CURSOR_LINE_NR_FG = {
  dark = '#C6C6C6',
  light = '#383A42',
}

function M.get(mode, transparent_background)
  local border_fg = BORDER_FG[mode] or BORDER_FG.dark
  local cursor_fg = CURSOR_FG[mode] or CURSOR_FG.dark
  local cursor_bg = CURSOR_BG[mode] or CURSOR_BG.dark
  local snacks_explorer_bg = transparent_background and 'none'
    or (SNACKS_EXPLORER_BG[mode] or SNACKS_EXPLORER_BG.dark)
  local cursorline_bg = EXPLORER_CURSORLINE_BG[mode] or EXPLORER_CURSORLINE_BG.dark
  local directory_fg = DIRECTORY_FG[mode] or DIRECTORY_FG.dark
  local separator_fg = SEPARATOR_FG[mode] or SEPARATOR_FG.dark
  local float_bg = transparent_background and 'none' or (FLOAT_BG[mode] or FLOAT_BG.dark)
  local prompt_fg = PROMPT_FG[mode] or PROMPT_FG.dark
  local diag = DIAGNOSTIC[mode] or DIAGNOSTIC.dark
  local visual_bg = VISUAL_BG[mode] or VISUAL_BG.dark
  -- Unlike the rest of this file's flat per-mode colours, the completion
  -- menu bg has to drop out under transparency (same as Normal/NormalFloat
  -- already do via the base plugin): otherwise blink.cmp's menu — which
  -- links straight to Pmenu — keeps this solid colour behind it even with
  -- `transparent_background` on, showing a visible box instead of blending
  -- with the terminal. The selected row keeps its solid bg either way so the
  -- highlighted item stays legible against a see-through menu.
  local pmenu_bg = transparent_background and 'none' or (PMENU_BG[mode] or PMENU_BG.dark)
  local pmenu_sel_bg = PMENU_SEL_BG[mode] or PMENU_SEL_BG.dark
  local notifier_error_fg = NOTIFIER_ERROR_FG[mode] or NOTIFIER_ERROR_FG.dark
  local notifier_title_fg = NOTIFIER_TITLE_FG[mode] or NOTIFIER_TITLE_FG.dark
  local snacks_input_icon_fg = SNACKS_INPUT_ICON_FG[mode] or SNACKS_INPUT_ICON_FG.dark
  -- Drop to NONE under transparency instead of a solid colour, so the
  -- bufferline bar is actually see-through (matches rosajet's bl_bg).
  -- bl_hidden keeps the separator/indicator glyphs a real (if faint) colour
  -- instead of leaking to the default fg once bg is NONE.
  local bl_bg = transparent_background and 'NONE' or (BUFFERLINE_BG[mode] or BUFFERLINE_BG.dark)
  local bl_hidden = transparent_background and separator_fg or bl_bg
  local bl_fg = BUFFERLINE_FG[mode] or BUFFERLINE_FG.dark
  local bl_fg_inactive = BUFFERLINE_FG_INACTIVE[mode] or BUFFERLINE_FG_INACTIVE.dark
  local bl_modified = BUFFERLINE_MODIFIED[mode] or BUFFERLINE_MODIFIED.dark
  local linenr_fg = LINENR_FG[mode] or LINENR_FG.dark
  local cursorlinenr_fg = CURSOR_LINE_NR_FG[mode] or CURSOR_LINE_NR_FG.dark
  -- rosamin keeps VertSplit at the editor bg shade under transparency so it
  -- doesn't draw a solid line over a see-through buffer.
  local vertsplit_fg = (mode ~= 'light' and transparent_background) and '#1F1F1F' or separator_fg

  local result = {
    -- Snacks defaults the explorer tree's indent markers to `link =
    -- "LineNr"`, and kanagawa's LineNr carries its own gutter bg
    -- (dragon #282727 / lotus bg_gutter) — a shade meant to contrast the
    -- editor's own Normal bg. Inside the explorer float that shows up as a
    -- stray rectangle behind the icons/dashes instead of matching the
    -- float's bg. NonText has the same fg with no bg, so link there instead
    -- (every other rosa theme does the same for SnacksPickerTree).
    SnacksPickerTree = { link = 'NonText' },

    LineNr = { fg = linenr_fg },
    CursorLineNr = { fg = cursorlinenr_fg },

    -- Float borders (which-key, Snacks pickers/explorer, Mini* floats, ...)
    -- all cascade from FloatBorder/Border via `default = true` links, so
    -- pinning these three covers every float in one place.
    FloatBorder = { fg = border_fg },
    Border = { fg = border_fg },
    FloatShadow = { fg = border_fg },

    -- rosamin's Cursor instead of kanagawa's flat grey block. lCursor/
    -- CursorIM/TermCursor/TermCursorNC already link to Cursor (set in
    -- highlights/editor.lua), so they follow this override for free.
    Cursor = { fg = cursor_fg, bg = cursor_bg },

    SnacksPicker = { bg = snacks_explorer_bg },
    -- Title/input/toggle boxes (the "Explorer" header, the search input
    -- title) had no explicit override, so they fell back to float.bg
    -- (#E0E0E0) — a different shade from the SnacksPicker body above it.
    -- Pin them to the same colour so the whole panel reads as one surface.
    SnacksPickerTitle = { bg = snacks_explorer_bg },
    SnacksPickerInputTitle = { bg = snacks_explorer_bg },
    SnacksPickerToggle = { bg = snacks_explorer_bg },
    -- blink.cmp's menu border isn't linked to FloatBorder in kanagawa (it
    -- has its own bg-search-derived colour, dragon waveBlue2/lotus
    -- lotusBlue2, on BOTH fg and bg) — the doc/signature borders already
    -- link to FloatBorder and pick up the border_fg change for free, but
    -- this one needs its bg pulled off the blue pmenu shade too, or the
    -- border still reads as a solid blue frame around the menu.
    BlinkCmpMenuBorder = { fg = border_fg, bg = pmenu_bg },

    SnacksPickerListCursorLine = { bg = cursorline_bg },
    SnacksPickerCursorLine = { bg = cursorline_bg },
    SnacksPickerBoxCursorLine = { bg = cursorline_bg },

    Directory = { fg = directory_fg },

    -- rosamin's Visual selection instead of kanagawa's saturated blue.
    -- VisualNOS already links to Visual (set in highlights/editor.lua), so it
    -- follows this override for free.
    Visual = { bg = visual_bg },

    -- rosamin's completion menu instead of kanagawa's blue popup menu.
    -- BlinkCmpMenu/BlinkCmpMenuSelection link to Pmenu/PmenuSel, so they
    -- follow these overrides for free; WildMenu links to Pmenu too.
    Pmenu = { bg = pmenu_bg },
    PmenuSel = { bg = pmenu_sel_bg },
    PmenuKind = { bg = pmenu_bg },
    PmenuKindSel = { bg = pmenu_sel_bg },
    PmenuExtra = { bg = pmenu_bg },
    PmenuExtraSel = { bg = pmenu_sel_bg },

    -- rosamin's snacks notifier instead of kanagawa's defaults.
    SnacksNotifierBorderInfo = { fg = border_fg },
    SnacksNotifierBorderWarn = { fg = diag.warn },
    SnacksNotifierBorderError = { fg = notifier_error_fg },
    SnacksNotifierTitleInfo = { fg = notifier_title_fg },

    -- rosamin's Snacks input prompt instead of kanagawa's DiagnosticInfo blue
    -- (see SNACKS_INPUT_ICON_FG above for why this was needed at all).
    SnacksInputIcon = { fg = snacks_input_icon_fg },
    SnacksInputTitle = { fg = notifier_title_fg },
    SnacksInputBorder = { fg = border_fg },

    WinSeparator = { fg = separator_fg },
    VertSplit = { fg = vertsplit_fg },

    -- The explorer's "> " prompt icon (drawn via 'statuscolumn') and its
    -- "n/n" match counter (right-aligned virtual text) have no theme default
    -- at all, so they fall back to the terminal's own bg instead of the
    -- float's.
    SnacksPickerPrompt = { fg = prompt_fg, bg = float_bg },
    SnacksPickerTotals = { fg = prompt_fg, bg = float_bg },

    -- rosamin's diagnostic palette: flat fg (no gutter pill behind signs,
    -- no theme-side bg on floats — both link straight to the base severity
    -- colour, same as rosamin's own un-overridden Sign/Floating defaults).
    DiagnosticError = { fg = diag.error },
    DiagnosticWarn = { fg = diag.warn },
    DiagnosticInfo = { fg = diag.info },
    DiagnosticHint = { fg = diag.hint },
    DiagnosticUnderlineError = { undercurl = true, sp = diag.error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = diag.warn },
    DiagnosticUnderlineInfo = { undercurl = true, sp = diag.info },
    DiagnosticUnderlineHint = { undercurl = true, sp = diag.hint },
    DiagnosticSignError = { link = 'DiagnosticError' },
    DiagnosticSignWarn = { link = 'DiagnosticWarn' },
    DiagnosticSignInfo = { link = 'DiagnosticInfo' },
    DiagnosticSignHint = { link = 'DiagnosticHint' },
    DiagnosticFloatingError = { link = 'DiagnosticError' },
    DiagnosticFloatingWarn = { link = 'DiagnosticWarn' },
    DiagnosticFloatingInfo = { link = 'DiagnosticInfo' },
    DiagnosticFloatingHint = { link = 'DiagnosticHint' },

    -- mini.icons: match rosamin's fixed palette instead of kanagawa's own
    -- (which linked these groups to Function/Diagnostic* and turned file
    -- icons purple/yellow). Same values in light and dark, like rosamin.
    MiniIconsAzure = { fg = '#79b8ff', bg = 'none' },
    MiniIconsBlue = { fg = '#64BAFF', bg = 'none' },
    MiniIconsCyan = { fg = '#7DD3FC', bg = 'none' },
    MiniIconsPurple = { fg = '#b392f0', bg = 'none' },
    MiniIconsRed = { fg = '#F67582', bg = 'none' },
    MiniIconsGreen = { fg = '#A0D6A0', bg = 'none' },
    MiniIconsOrange = { fg = '#FFA868', bg = 'none' },
    MiniIconsYellow = { fg = '#FFD580', bg = 'none' },
    MiniIconsGrey = { fg = '#9C9EA4', bg = 'none' },

    -- rosamin's bufferline (see BUFFERLINE_BG above): one flat bg per mode,
    -- selected vs. inactive drawn through fg/bold only.
    BufferLineBackground = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineBufferSelected = { fg = bl_fg, bg = bl_bg, bold = true },
    BufferLineBufferVisible = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineFill = { bg = bl_bg },
    BufferLineSeparator = { fg = bl_hidden, bg = bl_bg },
    BufferLineSeparatorSelected = { fg = bl_hidden, bg = bl_bg },
    BufferLineSeparatorVisible = { fg = bl_hidden, bg = bl_bg },
    BufferLineModified = { fg = bl_modified, bg = bl_bg },
    BufferLineModifiedSelected = { fg = bl_modified, bg = bl_bg },
    BufferLineModifiedVisible = { fg = bl_modified, bg = bl_bg },
    -- Invisible (fg == bg), not rosamin's blue accent bar — asked to drop it.
    BufferLineIndicatorSelected = { fg = bl_hidden, bg = bl_bg },
    BufferLineIndicatorVisible = { fg = bl_hidden, bg = bl_bg },
    BufferLineCloseButton = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineCloseButtonSelected = { fg = bl_fg, bg = bl_bg },
    BufferLineCloseButtonVisible = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineTab = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineTabSelected = { fg = bl_fg, bg = bl_bg },
    BufferLineTabSeparator = { fg = bl_hidden, bg = bl_bg },
    BufferLineTabSeparatorSelected = { fg = bl_hidden, bg = bl_bg },
    BufferLineTabClose = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineDuplicate = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineDuplicateSelected = { fg = bl_fg, bg = bl_bg },
    BufferLineDuplicateVisible = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineTruncMarker = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineOffset = { fg = bl_fg, bg = bl_bg, bold = true },
    BufferLineOffsetSeparator = { fg = bl_hidden, bg = bl_bg },
    BufferLinePick = { fg = diag.error, bg = bl_bg, bold = true },
    BufferLinePickSelected = { fg = diag.error, bg = bl_bg, bold = true },
    BufferLinePickVisible = { fg = diag.error, bg = bl_bg, bold = true },
    BufferLineNumbers = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineNumbersSelected = { fg = bl_fg, bg = bl_bg },
    BufferLineNumbersVisible = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineDiagnostic = { fg = bl_fg_inactive, bg = bl_bg },
    BufferLineDiagnosticSelected = { fg = bl_fg, bg = bl_bg },
    BufferLineDiagnosticVisible = { fg = bl_fg_inactive, bg = bl_bg },
  }

  if toggles.get_or('rosagawa_gutter_flat', false) then
    local gutter_bg = transparent_background and 'none' or (EDITOR_BG[mode] or EDITOR_BG.dark)
    result.LineNr = { fg = linenr_fg, bg = gutter_bg }
    result.CursorLineNr = { fg = cursorlinenr_fg, bg = gutter_bg }
    result.SignColumn = { bg = gutter_bg }
    result.FoldColumn = { bg = gutter_bg }
  end

  return result
end

return M

local c = require("rosagawa.lib.color")

--TODO:
--PreProc needs its own color
--parameter and field should be different
---@class SyntaxElements
---@field string ColorSpec
---@field variable ColorSpec
---@field number ColorSpec
---@field constant ColorSpec
---@field identifier ColorSpec
---@field parameter ColorSpec
---@field fun ColorSpec
---@field statement ColorSpec
---@field keyword ColorSpec
---@field operator ColorSpec
---@field preproc ColorSpec
---@field type ColorSpec
---@field regex ColorSpec
---@field deprecated ColorSpec
---@field comment ColorSpec
---@field punct ColorSpec
---@field special1 ColorSpec
---@field special2 ColorSpec
---@field special3 ColorSpec

---@class DiagnosticsElements
---@field error ColorSpec
---@field ok ColorSpec
---@field warning ColorSpec
---@field info ColorSpec
---@field hint ColorSpec
--
---@class DiffElements
---@field add ColorSpec
---@field delete ColorSpec
---@field change ColorSpec
---@field text ColorSpec

---@class VCSElements
---@field added ColorSpec
---@field removed ColorSpec
---@field changed ColorSpec

---@class UiElements
---@field fg ColorSpec Default foreground
---@field fg_dim ColorSpec Dimmed foreground
---@field fg_reverse ColorSpec
---@field bg_dim ColorSpec Dimmed background
---@field bg_m3 ColorSpec
---@field bg_m2 ColorSpec
---@field bg_m1 ColorSpec
---@field bg ColorSpec Default background
---@field bg_p1 ColorSpec Lighter background ColorColumn, Folded, Gutter
---@field bg_p2 ColorSpec Lighter background Cursor{Line,Column}, TabLineSel (Selected Items)
---@field bg_gutter ColorSpec {Sign,Fold}Column, LineNr
---@field special ColorSpec SpecialKey
---@field nontext ColorSpec LineNr, NonText
---@field whitespace ColorSpec Whitespace
---@field bg_search ColorSpec
---@field bg_visual ColorSpec
---@field pmenu MenuElements
---@field float FloatElements

---@class FloatElements
---@field fg ColorSpec
---@field bg ColorSpec
---@field fg_border ColorSpec
---@field bg_border ColorSpec

---@class MenuElements
---@field bg ColorSpec
---@field fg ColorSpec
---@field fg_sel ColorSpec
---@field bg_sel ColorSpec
---@field bg_sbar ColorSpec
---@field bg_thumb ColorSpec

---@class ThemeColors
---@field syn SyntaxElements
---@field diag DiagnosticsElements
---@field vcs VCSElements
---@field diff DiffElements
---@field ui UiElements
---@field term ColorSpec[]

return {
    ---@param palette PaletteColors
    ---@return ThemeColors
    dragon = function(palette)
        return {
            ui = {
                fg         = palette.dragonWhite,
                fg_dim     = palette.oldWhite,
                fg_reverse = palette.waveBlue1,

                bg_dim     = palette.dragonBlack1,
                bg_gutter  = palette.dragonBlack4,

                bg_m3      = palette.dragonBlack0,
                bg_m2      = palette.dragonBlack1,
                bg_m1      = palette.dragonBlack2,
                bg         = palette.dragonBlack3,
                bg_p1      = palette.dragonBlack4,
                bg_p2      = palette.dragonBlack5,

                special    = palette.dragonGray3,
                whitespace = palette.dragonBlack6,
                nontext    = palette.dragonBlack6,

                bg_visual  = palette.waveBlue1,
                bg_search  = palette.waveBlue2,

                pmenu      = {
                    fg       = palette.fujiWhite,
                    fg_sel   = "none",
                    bg       = palette.waveBlue1,
                    bg_sel   = palette.waveBlue2,
                    bg_thumb = palette.waveBlue2,
                    bg_sbar  = palette.waveBlue1,
                },

                float      = {
                    fg        = palette.oldWhite,
                    bg        = palette.dragonBlack0,
                    fg_border = palette.sumiInk6,
                    bg_border = palette.dragonBlack0,
                },
            },
            syn = {
                string     = palette.dragonGreen2,
                variable   = "none",
                number     = palette.dragonPink,
                constant   = palette.dragonOrange,
                identifier = palette.dragonYellow,
                parameter  = palette.dragonGray,
                fun        = palette.dragonBlue2,
                statement  = palette.dragonViolet,
                keyword    = palette.dragonViolet,
                operator   = palette.dragonRed,
                preproc    = palette.dragonRed,
                type       = palette.dragonAqua,
                regex      = palette.dragonRed,
                deprecated = palette.katanaGray,
                punct      = palette.dragonGray2,
                comment    = palette.dragonAsh,
                special1   = palette.dragonTeal,
                special2   = palette.dragonRed,
                special3   = palette.dragonRed,
            },
            diag = {
                error   = palette.samuraiRed,
                ok      = palette.springGreen,
                warning = palette.roninYellow,
                info    = palette.dragonBlue,
                hint    = palette.waveAqua1,
            },
            diff = {
                add    = palette.winterGreen,
                delete = palette.winterRed,
                change = palette.winterBlue,
                text   = palette.winterYellow,
            },
            vcs = {
                added   = palette.autumnGreen,
                removed = palette.autumnRed,
                changed = palette.autumnYellow,
            },
            term = {
                palette.dragonBlack0, -- black
                palette.dragonRed, -- red
                palette.dragonGreen2, -- green
                palette.dragonYellow, -- yellow
                palette.dragonBlue2, -- blue
                palette.dragonPink, -- magenta
                palette.dragonAqua, -- cyan
                palette.oldWhite, -- white
                palette.dragonGray, -- bright black
                palette.waveRed, -- bright red
                palette.dragonGreen, -- bright green
                palette.carpYellow, -- bright yellow
                palette.springBlue, -- bright blue
                palette.springViolet1, -- bright magenta
                palette.waveAqua2, -- bright cyan
                palette.dragonWhite, -- bright white
                palette.dragonOrange, -- extended color 1
                palette.dragonOrange2, -- extended color 2
            },
        }
    end,
    ---@param palette PaletteColors
    ---@return ThemeColors
    -- ui.* below is rosamin-light's neutral palette instead of kanagawa-
    -- lotus's own cream/yellow one (bg, bg_m1-3, bg_p1-2, bg_gutter were all
    -- shades of the same warm lotusWhite family — the "yellow gutter/lualine"
    -- look). syn/vcs/diff/diag/term stay untouched kanagawa-lotus: those drive
    -- actual syntax highlighting and filetype icon colours (Lua blue, etc.),
    -- which is its own look, not something this reskin touches.
    lotus = function(palette)
        return {
            ui = {
                fg         = "#616161",
                fg_dim     = "#848484",
                fg_reverse = "#ffffff",

                -- One consistent grey for every "not-quite-bg" surface (gutter,
                -- statusline/tabline, ColorColumn/Folded/CursorLine, Snacks
                -- picker/explorer...) instead of two close-but-different
                -- shades (#EDEDED vs #dddddd), which read as a mismatch
                -- between e.g. the picker preview's own LineNr gutter and the
                -- picker/explorer chrome around it.
                bg_dim     = "#dddddd",
                bg_gutter  = "#dddddd",

                bg_m3      = "#dddddd",
                bg_m2      = "#dddddd",
                bg_m1      = "#dddddd",
                bg         = "#ffffff",
                bg_p1      = "#dddddd",
                bg_p2      = "#dddddd",

                nontext    = "#a1a1a1",
                whitespace = "#a1a1a1",
                special    = "#a1a1a1",

                bg_visual  = "#D6E4F0",
                bg_search  = "#D6E4F0",

                pmenu      = {
                    fg       = "#616161",
                    fg_sel   = "none", -- This is important to make highlights pass-through
                    bg       = "#E0E0E0",
                    bg_sel   = "#EDEDED",
                    bg_sbar  = "#E0E0E0",
                    bg_thumb = "#dddddd",
                },
                float      = {
                    fg        = "#616161",
                    bg        = "#E0E0E0",
                    fg_border = "#c2c3c5",
                    bg_border = "#E0E0E0",
                },
            },
            syn = {
                string     = palette.lotusGreen,
                variable   = "none",
                number     = palette.lotusPink,
                constant   = palette.lotusOrange,
                identifier = palette.lotusYellow,
                parameter  = palette.lotusBlue5,
                fun        = palette.lotusBlue4,
                statement  = palette.lotusViolet4,
                keyword    = palette.lotusViolet4,
                operator   = palette.lotusYellow2,
                preproc    = palette.lotusRed,
                type       = palette.lotusAqua,
                regex      = palette.lotusYellow2,
                deprecated = palette.lotusGray3,
                comment    = palette.lotusGray3,
                punct      = palette.lotusTeal1,
                special1   = palette.lotusTeal2,
                special2   = palette.lotusRed,
                special3   = palette.lotusRed,
            },
            vcs = {
                added   = palette.lotusGreen2,
                removed = palette.lotusRed2,
                changed = palette.lotusYellow3,
            },
            diff = {
                add    = palette.lotusGreen3,
                delete = palette.lotusRed4,
                change = palette.lotusCyan,
                text   = palette.lotusYellow4,
            },
            diag = {
                error   = palette.lotusRed3,
                ok      = palette.lotusGreen,
                warning = palette.lotusOrange2,
                info    = palette.lotusTeal3,
                hint    = palette.lotusAqua2,
            },
            term = {
                palette.sumiInk3, -- black
                palette.lotusRed, -- red
                palette.lotusGreen, -- green
                palette.lotusYellow, -- yellow
                palette.lotusBlue4, -- blue
                palette.lotusPink, -- magenta
                palette.lotusAqua, -- cyan
                palette.lotusInk1, -- white
                palette.lotusGray3 , -- bright black
                palette.lotusRed2, -- bright red
                palette.lotusGreen2, -- bright green
                palette.lotusYellow2, -- bright yellow
                palette.lotusTeal2, -- bright blue
                palette.lotusViolet4, -- bright magenta
                palette.lotusAqua2, -- bright cyan
                palette.lotusInk2, -- bright white
                palette.lotusOrange2, -- extended color 1
                palette.lotusRed3, -- extended color 2
            },
        }
    end,
}

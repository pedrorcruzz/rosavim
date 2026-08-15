--- Invert Backgrounds (<leader>lqi<theme>) — swap a theme's editor surface with
--- its sidebar/tab chrome surface, so the explorer becomes the darker (or
--- lighter) plane and the buffer takes the chrome shade.
---
--- Each rosa theme paints two surfaces:
---   editor   Normal, dropbar, splits, the completion popup
---   chrome   snacks explorer/picker, which-key, the tab strip
--- Inverting means exchanging those two hexes wherever they appear.
---
--- The swap runs as a post-pass over the finished highlight groups rather than
--- inside each theme's palette, so a theme only has to declare its two shades
--- here — no per-theme plumbing, and the themes stay readable at their real
--- values. It is applied over an explicit surface list because the shades are
--- NOT unique: rosavintage's dark editor bg is #000000, which its DiffAdd,
--- Search, Todo and WarningMsg groups also sit on. Matching by colour alone
--- would drag those along.
local M = {}

--- The two shades per theme and background. `fix` re-pins groups that only look
--- right at one of the two shades — rosajet's caret row is a trench under the
--- default editor bg but has to be a highlight over the inverted (darker) one.
--- Every group painted in the theme's `bgDarker` belongs here, not just
--- CursorLine: CursorLineNr paints the same row in the number column, so
--- leaving it out splits the caret row into two shades.
M.themes = {
  rosajet = {
    dark = {
      editor = '#272729',
      chrome = '#191a1c',
      fix = {
        CursorLine = { bg = '#1f2024' },
        CursorLineNr = { bg = '#1f2024' },
        Folded = { bg = '#1f2024' },
        LspInlayHint = { bg = '#1f2024' },
      },
    },
    light = { editor = '#fafafa', chrome = '#f5f5f5' },
  },
  rosamin = {
    dark = { editor = '#1f1f1f', chrome = '#1a1a1a' },
    light = { editor = '#fafafa', chrome = '#f5f5f5' },
  },
  rosavintage = {
    -- Its caret row (#323232) is tuned against the OLED-black editor; over the
    -- inverted #303030 chrome it disappears, so lift it a step.
    dark = { editor = '#000000', chrome = '#303030', fix = { CursorLine = { bg = '#404040' } } },
    light = { editor = '#d3d2ce', chrome = '#edf1fa' },
  },
}

--- Highlight groups making up the two surfaces. Exact names first, then name
--- prefixes for the plugin families that paint whole panels.
---
--- Deliberately absent: `Folded`, which rosamin paints in the chrome shade as
--- an editor decoration — swapping it would land the fold on the (now chrome)
--- editor bg and make it vanish.
local SURFACES = {
  'Normal',
  'NormalNC',
  'NormalFloat',
  'EndOfBuffer',
  'VertSplit',
  'WinSeparator',
  'Winseparator',
  'WinBar',
  'WinBarNC',
  'InclineNormal',
  'InclineNormalNC',
  'TabLine',
  'TabLineSel',
  'TabLineFill',
  'StatusLine',
  'StatusLineNC',
  'StatusLineTerm',
  'StatusLineTermNC',
  'RosapickBorder',
  'RosatermFloatBorder',
  'RosaaiFloatBorder',
  'RosaChipNormal',
  'Pmenu',
  'PmenuKind',
  'PmenuExtra',
  'PmenuSbar',
}

local SURFACE_PREFIXES = {
  'BufferLine',
  'bufferline',
  'SnacksPicker',
  'SnacksExplorer',
  'WhichKey',
  'Whichkey',
  'BlinkCmp',
  'nvimtree',
}

local exact = {}
for _, name in ipairs(SURFACES) do
  exact[name] = true
end

local function is_surface(name)
  if exact[name] then
    return true
  end
  for _, prefix in ipairs(SURFACE_PREFIXES) do
    if name:sub(1, #prefix) == prefix then
      return true
    end
  end
  return false
end

--- Whether `theme` (default: the active colorscheme) is currently inverted.
function M.enabled(theme)
  theme = theme or vim.g.colors_name
  if not (theme and M.themes[theme]) then
    return false
  end
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  return ok and toggles.get(theme .. '_invert') or false
end

--- Resolved editor and chrome shades for `theme`, already swapped when the
--- theme is inverted. Consumers that cannot go through the highlight post-pass
--- (the lualine themes build their own tables) read them from here.
---@return string|nil editor, string|nil chrome
function M.shades(theme, background)
  local spec = M.themes[theme]
  if not spec then
    return nil, nil
  end
  local pair = spec[(background or vim.o.background) == 'light' and 'light' or 'dark']
  if M.enabled(theme) then
    return pair.chrome, pair.editor
  end
  return pair.editor, pair.chrome
end

local function hex(n)
  return type(n) == 'number' and string.format('#%06x', n) or nil
end

--- Marker group proving the swap already ran for the current `:colorscheme`.
--- apply() is called twice per application — once from the theme's set_groups
--- and once from the ColorScheme autocmd — and swapping twice restores the
--- original, so the second call has to be a no-op. `hi clear` (which every rosa
--- theme runs before set_groups) wipes this group, so it resets on its own for
--- the next application and never needs manual clearing.
local APPLIED = 'RosaInvertBgApplied'

--- Swap the two surfaces on the active theme, if it is inverted. Called from
--- the ColorScheme autocmd AND from each theme's set_groups — lualine's 'auto'
--- theme re-sources a theme without firing ColorScheme, so the themes must
--- re-apply this themselves or a rebuild would lose the inversion.
function M.apply()
  local theme = vim.g.colors_name
  if not M.enabled(theme) then
    return
  end
  if not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = APPLIED })) then
    return
  end
  vim.api.nvim_set_hl(0, APPLIED, { fg = '#000000' })

  local pair = M.themes[theme][vim.o.background == 'light' and 'light' or 'dark']
  local a, b = pair.editor:lower(), pair.chrome:lower()

  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if is_surface(name) and not hl.link then
      local fg, bg = hex(hl.fg), hex(hl.bg)
      local new_fg = (fg == a and b) or (fg == b and a) or nil
      local new_bg = (bg == a and b) or (bg == b and a) or nil
      if new_fg or new_bg then
        hl.fg = new_fg or hl.fg
        hl.bg = new_bg or hl.bg
        -- nvim_get_hl can hand back keys nvim_set_hl rejects on some builds;
        -- a single odd group must not abort the whole pass.
        pcall(vim.api.nvim_set_hl, 0, name, hl)
      end
    end
  end

  -- Transparent mode drops these bgs on purpose, so re-pinning them there would
  -- paint the caret row back over a see-through buffer.
  local transparent = require('rosavim.config.appearance').get_transparent()
  for name, attrs in pairs((not transparent and pair.fix) or {}) do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', hl, attrs))
  end
end

return M

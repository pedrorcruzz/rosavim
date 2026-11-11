--- Min Icons — two independent persisted toggles, split because some people
--- want plain folders but minimalist files (or vice versa):
---
---   <leader>lqh  min_icons_files — flattens mini.icons' per-category
---                MiniIcons* palette (Azure/Blue/Cyan/Purple/Red/Green/
---                Orange/Yellow/Grey) to a single neutral grey, for an all
---                black/white file-type icon set.
---   <leader>lqj  min_icons_dir   — swaps the explorer's closed/open folder
---                glyphs for the minimalist pair in M.folder_glyphs.mono.
---
--- The colour part (M.apply) is applied from inside each theme's own
--- overrides.lua (called right before that function returns its table)
--- instead of being centralized in a ColorScheme autocmd: mini.icons' lazy
--- load races a centralized override the same way the per-theme MiniIcons*
--- colours themselves do (see the note in
--- rosavim.plugins.ui.colorschemes.colorscheme) — folding the grey values
--- into the table overrides.get() already builds synchronously sidesteps
--- that race the same way the theme colours do. Highlight colours are looked
--- up by name on every redraw, so this toggle takes effect live with just
--- appearance.reload() — no further cache to invalidate.
---
--- The folder glyphs are different: their TEXT is baked into the picker's
--- rendered buffer lines and only recomputed when a row is marked dirty, so
--- flipping them live also needs M.refresh_open_pickers() to force that.
local M = {}

local GROUPS = { 'Azure', 'Blue', 'Cyan', 'Purple', 'Red', 'Green', 'Orange', 'Yellow', 'Grey' }

local function toggles()
  local ok, mod = pcall(require, 'rosavim.config.toggles')
  return ok and mod or nil
end

function M.files_enabled()
  local t = toggles()
  return t ~= nil and t.get_or('min_icons_files', false)
end

function M.dir_enabled()
  local t = toggles()
  return t ~= nil and t.get_or('min_icons_dir', false)
end

--- @param mode 'light'|'dark'
function M.palette(mode)
  local fg = mode == 'light' and '#5C5C5C' or '#B0B0B0'
  local palette = {}
  for _, name in ipairs(GROUPS) do
    palette['MiniIcons' .. name] = { fg = fg, bg = 'none' }
  end
  return palette
end

--- Call right before a theme's overrides.get() returns its table: merges the
--- grey palette on top when min_icons_files is on, a no-op otherwise.
function M.apply(result, mode)
  if not M.files_enabled() then
    return result
  end
  return vim.tbl_extend('force', result, M.palette(mode))
end

-- Folder glyphs for the Snacks picker/explorer (rosavim.plugins.ui.snacks.
-- picker) and for mini.icons' own 'directory' category (rosavim.plugins.ui.
-- mini-icons, which has no open/closed concept — only the closed glyph goes
-- through there). 'normal' is the current nerd-font pair; 'mono' is left
-- blank on purpose — paste your minimalist closed/open folder glyphs here.
-- INFO: DIR ICONS
M.folder_glyphs = {
  normal = { dir = ' ', dir_open = ' ' },
  mono = { dir = ' ', dir_open = ' ' },
}

function M.dir_icons()
  local set = M.dir_enabled() and M.folder_glyphs.mono or M.folder_glyphs.normal
  return set.dir, set.dir_open
end

--- The closed-folder glyph, bare (no trailing space): mini.icons' own
--- convention (see rosavim.plugins.ui.mini-icons' file/extension glyphs)
--- has no trailing space, unlike M.folder_glyphs' Snacks-picker-flavoured
--- strings, so trim it here rather than changing the stored values.
function M.dir_icon_glyph()
  local set = M.dir_enabled() and M.folder_glyphs.mono or M.folder_glyphs.normal
  return (set.dir:gsub('%s+$', ''))
end

--- Mutates the already-running Snacks picker config in place so any picker
--- opened from now on picks up the new glyphs, AND patches every already-open
--- picker's own opts too: `picker.opts.icons.files` is a deep copy taken when
--- the picker was created, not a live reference to Snacks.config.picker, so
--- mutating only the global config is invisible to a picker that's already
--- open (confirmed empirically — see M.refresh_open_pickers for the other
--- half of making that picker redraw with it).
function M.apply_picker()
  if not Snacks or not Snacks.picker then
    return
  end
  local dir, dir_open = M.dir_icons()
  if Snacks.config and Snacks.config.picker then
    Snacks.config.picker.icons.files.dir = dir
    Snacks.config.picker.icons.files.dir_open = dir_open
  end
  if Snacks.picker.get then
    for _, picker in ipairs(Snacks.picker.get { tab = false }) do
      if picker.opts and picker.opts.icons and picker.opts.icons.files then
        picker.opts.icons.files.dir = dir
        picker.opts.icons.files.dir_open = dir_open
      end
    end
  end
end

--- Forces every already-open picker/explorer (any tab) to reformat its
--- visible rows right now. Snacks.picker.core.list only recomputes a row's
--- text when `dirty`, so just mutating the config above is invisible to a
--- picker that's already drawn its rows — this is what makes the folder
--- glyph toggle take effect without closing and reopening the explorer.
function M.refresh_open_pickers()
  if not Snacks or not Snacks.picker or not Snacks.picker.get then
    return
  end
  for _, picker in ipairs(Snacks.picker.get { tab = false }) do
    if picker.list and picker.list.update then
      pcall(picker.list.update, picker.list, { force = true })
    end
  end
end

return M

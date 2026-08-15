-- Bespoke lualine theme for rosajet. The mode corner (section a) uses the
-- IdeaVim mode colours straight out of the IDE — olive for NORMAL, amber for
-- INSERT, steel blue for VISUAL, red for REPLACE — so the bar reads like the
-- IdeaVim status widget. The branch section (b) sits on the IDE status-bar
-- shade, and the centre (c) follows the editor background.
--
-- The IDE pairs those four chips with white text, which is fine on the dark red
-- REPLACE chip but unreadable on the amber INSERT one; the three light chips
-- take black text instead.
local config = require 'rosajet.config'

local transparent = config.transparent
local light = vim.o.background == 'light'

local mode_normal = { bg = '#94a863', fg = '#000000', gui = 'bold' }
local mode_insert = { bg = '#ecc180', fg = '#000000', gui = 'bold' }
local mode_visual = { bg = '#769eb3', fg = '#000000', gui = 'bold' }
local mode_replace = { bg = '#a44a45', fg = '#ffffff', gui = 'bold' }

-- Centre bar: the <leader>lqy toggle (default ON) keeps the y/centre bar
-- transparent — it blends with the editor bg (NONE in transparent mode). When
-- off, it restores the IDE status-bar shade.
local status_bar = light and '#f0f0f0' or '#2b2d30'
-- The centre bar follows the editor surface, so it has to go through the same
-- swap the highlight post-pass does — lualine builds its own colour table and
-- never sees those groups.
local editor_bg = require('rosavim.config.invert_bg').shades 'rosajet' or require('rosajet.colors').bgSolid
local ok_t, toggles = pcall(require, 'rosavim.config.toggles')
local center
if not ok_t or toggles.get 'lualine_bar_y_transparent' then
  center = transparent and 'NONE' or editor_bg
else
  center = transparent and 'NONE' or status_bar
end

local fg = light and '#080808' or '#bcbec4'
local muted_fg = light and '#7f828d' or '#9a9ca4'
local inactive_fg = light and '#aeb3c2' or '#4b5059'
-- Branch section (b) is uniform across ALL modes.
local branch_b = { bg = transparent and 'NONE' or status_bar, fg = muted_fg }

local function section(a)
  return { a = a, b = branch_b, c = { bg = center, fg = fg } }
end

return {
  normal = section(mode_normal),
  visual = section(mode_visual),
  insert = section(mode_insert),
  replace = section(mode_replace),
  command = section(mode_normal),
  terminal = section(mode_insert),
  inactive = {
    a = { bg = center, fg = inactive_fg },
    b = { bg = center, fg = inactive_fg },
    c = { bg = center, fg = inactive_fg },
  },
}

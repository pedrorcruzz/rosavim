-- Bespoke lualine theme for rosanight. Strictly monochrome. Only the mode
-- CORNER (section a — and the location, which shares it) keeps the dark look in
-- every background; the intermediate (b) and centre (c) follow the editor
-- background (light palette in light mode). Two corner looks:
--   * "v-line"  -> NORMAL and VISUAL (cinza-lavanda corner)
--   * "insert"  -> everything else: INSERT, REPLACE, COMMAND, TERMINAL
--                  (and the RosaAI CLI, which runs in a terminal)
local config = require 'rosanight.config'

local transparent = config.transparent
local light = vim.o.background == 'light' and not transparent

-- Mode corner (a) is ALWAYS the dark look, in every background.
local vline_a = { bg = '#8C8C9A', fg = '#000000', gui = 'bold' }
local insert_a = { bg = '#FFFFFF', fg = '#000000', gui = 'bold' }

-- Centre bar: the <leader>lqy toggle (default ON) keeps the y/centre bar
-- transparent — it blends with the editor bg (NONE in transparent mode). When
-- off, it restores the original solid #1a1a1a bar.
local ok_t, toggles = pcall(require, 'rosavim.config.toggles')
local center
if not ok_t or toggles.get 'lualine_bar_y_transparent' then
  center = transparent and 'NONE' or (light and '#D3D2CE' or '#000000')
else
  center = transparent and 'NONE' or '#1a1a1a'
end
local fg = light and '#2A2A2A' or '#FFFFFF'
local muted_fg = light and '#7a7a76' or '#8C8C9A'
-- Branch section (b) is uniform across ALL modes = the insert look.
local branch_b = { bg = light and '#BBBAB6' or '#262626', fg = fg }
local inactive_fg = light and '#A0A0A0' or '#404040'

local vline = {
  a = vline_a,
  b = branch_b,
  c = { bg = center, fg = muted_fg },
}
local insert = {
  a = insert_a,
  b = branch_b,
  c = { bg = center, fg = fg },
}

return {
  normal = vline,
  visual = vline,
  insert = insert,
  replace = insert,
  command = insert,
  terminal = insert,
  inactive = {
    a = { bg = center, fg = inactive_fg },
    b = { bg = center, fg = inactive_fg },
    c = { bg = center, fg = inactive_fg },
  },
}

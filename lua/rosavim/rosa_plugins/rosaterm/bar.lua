--- Rosaterm bar - Title chip on the float's top border + matching winbar for splits
local M = {}

local api = vim.api
local chip_bar = require 'rosavim.helpers.chip_bar'
local chip = chip_bar.new { ns = 'rosaterm_chip' }
local hex = chip_bar.hex
local get_time = chip_bar.get_time

local ICON_ROSA = '󰧱'
-- nf-md-console (U+F018D). Built via nr2char so the 4-byte glyph survives
-- saves intact — a raw paste was being stripped to an empty string before.
local ICON_TERMINAL = ' '
local ICONS = { rosa = ICON_ROSA, terminal = ICON_TERMINAL }

local function icon_visible()
  return chip_bar.toggle('rosaterm_icon_visible', true)
end

local function icon_glyph()
  return ICONS[chip_bar.toggle 'rosaterm_icon_style'] or ICON_ROSA
end

M.icon_visible = icon_visible
M.icon_glyph = icon_glyph

function M.setup_hl()
  local normal = api.nvim_get_hl(0, { name = 'Normal' })
  local fb = api.nvim_get_hl(0, { name = 'FloatBorder' })

  local nfg = hex(normal.fg) or '#cdd6f4'
  local border_fg = hex(fb and fb.fg) or nfg

  api.nvim_set_hl(0, 'RosatermBarIcon', { fg = '#A9B2C0', bold = true })
  api.nvim_set_hl(0, 'RosatermBarName', { fg = nfg, bold = true })
  api.nvim_set_hl(0, 'RosatermBarTime', { fg = '#7B8394' })
  api.nvim_set_hl(0, 'RosatermBarBracket', { fg = border_fg })
end

-- Re-apply highlights when colorscheme changes
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('RosatermBarHl', { clear = true }),
  callback = function()
    M.setup_hl()
  end,
})

--- Whether the chip should be shown at all (rosaterm_title toggle)
function M.chip_enabled()
  return chip_bar.toggle('rosaterm_title', true)
end

--- Whether the time should be shown inside the chip (rosaterm_time toggle)
function M.time_enabled()
  return chip_bar.toggle('rosaterm_time', true)
end

--- Whether to auto-start in insert mode when opening a terminal
function M.autoinsert_enabled()
  return chip_bar.toggle('rosaterm_autoinsert', true)
end

--- Display name in the chip: 'Rosaterm' when full toggle on, 'Terminal' when off
function M.name_text()
  if chip_bar.toggle('rosaterm_name_full', true) == false then
    return 'Terminal'
  end
  return 'Rosaterm'
end

local CLOCK = chip_bar.CLOCK

--- Inline segments: small chip with `󰧱 Rosaterm hh:mm`
local function inline_segments()
  local segs = { { ' ', 'RosatermBarBracket' } }
  if icon_visible() then
    table.insert(segs, { icon_glyph() .. ' ', 'RosatermBarIcon' })
  end
  table.insert(segs, { M.name_text(), 'RosatermBarName' })
  if M.time_enabled() then
    table.insert(segs, { ' ', 'RosatermBarBracket' })
    table.insert(segs, { get_time(), 'RosatermBarTime' })
  end
  table.insert(segs, { ' ', 'RosatermBarBracket' })
  return segs
end

--- Banner segments: full-width bar with name on left and time on right
local GLYPH_EXTRA = 1

local function banner_segments(width)
  local name = M.name_text()
  local show_icon = icon_visible()
  local icon = icon_glyph()
  local left_text = show_icon and (' ' .. icon .. ' ' .. name) or (' ' .. name)
  local left_w = vim.api.nvim_strwidth(left_text) + (show_icon and GLYPH_EXTRA or 0)

  local segs = { { ' ', 'RosatermBarBracket' } }
  if show_icon then
    table.insert(segs, { icon, 'RosatermBarIcon' })
    table.insert(segs, { ' ', 'RosatermBarBracket' })
  end
  table.insert(segs, { name, 'RosatermBarName' })

  if M.time_enabled() then
    local right_text = ' ' .. CLOCK .. ' ' .. get_time() .. ' '
    local right_w = vim.api.nvim_strwidth(right_text) + GLYPH_EXTRA
    local pad = width - left_w - right_w
    if pad < 1 then
      pad = 1
    end
    table.insert(segs, { string.rep(' ', pad), 'RosatermBarBracket' })
    table.insert(segs, { ' ' .. CLOCK .. ' ', 'RosatermBarIcon' })
    table.insert(segs, { get_time(), 'RosatermBarTime' })
    table.insert(segs, { ' ', 'RosatermBarBracket' })
  else
    local pad = width - left_w
    if pad < 1 then
      pad = 1
    end
    table.insert(segs, { string.rep(' ', pad), 'RosatermBarBracket' })
  end

  return segs
end

--- Colored text segments for the title chip (dispatches by theme layout)
function M.chip_segments(width)
  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaterm.themes')
  if ok and themes.current().layout == 'banner' then
    return banner_segments(width or 0)
  end
  return inline_segments()
end

--- Plain text version (for width measurement / buffer content)
function M.chip_plain(width)
  return chip_bar.segs_text(M.chip_segments(width))
end

--- Winbar-format text (`%#HlGroup#text...`) so the chip can be rendered
--- inline as the window's winbar instead of an overlay float — used for
--- native splits where the overlay would clamp off-screen and misalign.
function M.winbar_text(width)
  local parts = {}
  for _, seg in ipairs(M.chip_segments(width)) do
    -- Escape % in segment text so it isn't interpreted as a statusline item
    local safe = seg[1]:gsub('%%', '%%%%')
    table.insert(parts, '%#' .. seg[2] .. '#' .. safe)
  end
  return table.concat(parts) .. '%*'
end

--- Write the chip text + colored extmarks to the given buffer.
function M.write_chip_buf(buf, width)
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end
  chip.clear(buf)
  chip.write_line(buf, M.chip_segments(width))
end

function M._stop_timer()
  chip.stop_timer()
end

function M.attach_float(win, buf, refresh_fn)
  M.setup_hl()
  chip.track(win, { kind = 'float', buf = buf, refresh = refresh_fn })
end

function M.attach_split(win, buf, refresh_fn)
  M.setup_hl()
  chip.track(win, { kind = 'split', buf = buf, refresh = refresh_fn })
end

function M.detach(win)
  chip.untrack(win)
end

return M

--- Rosaterm bar - Title chip on the float's top border + matching winbar for splits
local M = {}

local api = vim.api
local tracked = {} -- win -> { kind = 'float'|'split', buf = N }
local timer = nil

local function hex(n)
  if not n then
    return nil
  end
  return string.format('#%06x', n)
end

local ICON_ROSA = '󰧱'
-- nf-md-console (U+F018D). Built via nr2char so the 4-byte glyph survives
-- saves intact — a raw paste was being stripped to an empty string before.
local ICON_TERMINAL = ' '
local ICONS = { rosa = ICON_ROSA, terminal = ICON_TERMINAL }

local function icon_visible()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return true
  end
  local v = toggles.get 'rosaterm_icon_visible'
  if v == nil then
    return true
  end
  return v
end

local function icon_glyph()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return ICON_ROSA
  end
  return ICONS[toggles.get 'rosaterm_icon_style'] or ICON_ROSA
end

M.icon_visible = icon_visible
M.icon_glyph = icon_glyph

function M.setup_hl()
  local normal = api.nvim_get_hl(0, { name = 'Normal' })
  local err = api.nvim_get_hl(0, { name = 'DiagnosticError' })
  local fb = api.nvim_get_hl(0, { name = 'FloatBorder' })

  local nfg = hex(normal.fg) or '#cdd6f4'
  local red = hex(err and err.fg) or '#f38ba8'
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

local function get_time()
  return os.date '%H:%M'
end

--- Whether the chip should be shown at all (toggle via <leader>latt)
function M.chip_enabled()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return true
  end
  local v = toggles.get 'rosaterm_title'
  if v == nil then
    return true
  end
  return v
end

--- Whether the time should be shown inside the chip (toggle via <leader>lath)
function M.time_enabled()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return true
  end
  local v = toggles.get 'rosaterm_time'
  if v == nil then
    return true
  end
  return v
end

--- Whether to auto-start in insert mode when opening a terminal
function M.autoinsert_enabled()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return true
  end
  local v = toggles.get 'rosaterm_autoinsert'
  if v == nil then
    return true
  end
  return v
end

--- Display name in the chip: 'Rosaterm' when full toggle on, 'Terminal' when off
function M.name_text()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return 'Rosaterm'
  end
  local v = toggles.get 'rosaterm_name_full'
  if v == false then
    return 'Terminal'
  end
  return 'Rosaterm'
end

local CLOCK = '󰥔'

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
local function banner_segments(width)
  local name = M.name_text()
  local show_icon = icon_visible()
  local icon = icon_glyph()
  local left_text = show_icon and (' ' .. icon .. ' ' .. name) or (' ' .. name)
  local left_w = vim.api.nvim_strwidth(left_text)

  local segs = { { ' ', 'RosatermBarBracket' } }
  if show_icon then
    table.insert(segs, { icon, 'RosatermBarIcon' })
    table.insert(segs, { ' ', 'RosatermBarBracket' })
  end
  table.insert(segs, { name, 'RosatermBarName' })

  if M.time_enabled() then
    local right_text = ' ' .. CLOCK .. ' ' .. get_time() .. ' '
    local right_w = vim.api.nvim_strwidth(right_text)
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
  local s = ''
  for _, seg in ipairs(M.chip_segments(width)) do
    s = s .. seg[1]
  end
  return s
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

local CHIP_NS = api.nvim_create_namespace 'rosaterm_chip'

local function apply_segs(buf, row, segs)
  local col = 0
  for _, seg in ipairs(segs) do
    local end_col = col + #seg[1]
    api.nvim_buf_set_extmark(buf, CHIP_NS, row, col, {
      end_row = row,
      end_col = end_col,
      hl_group = seg[2],
    })
    col = end_col
  end
end

--- Write the chip text + colored extmarks to the given buffer.
--- For stem layout, writes a second row with a `─` separator line.
function M.write_chip_buf(buf, width)
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end
  api.nvim_buf_clear_namespace(buf, CHIP_NS, 0, -1)

  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaterm.themes')
  local theme = ok and themes.current() or nil

  if theme and theme.layout == 'stem' then
    local segs = banner_segments(width or 0)
    local text = ''
    for _, seg in ipairs(segs) do
      text = text .. seg[1]
    end
    local sep = string.rep('─', width or 0)
    api.nvim_buf_set_lines(buf, 0, -1, false, { text, sep })
    apply_segs(buf, 0, segs)
    api.nvim_buf_set_extmark(buf, CHIP_NS, 1, 0, {
      end_row = 1,
      end_col = #sep,
      hl_group = 'RosatermBarBracket',
    })
  else
    local segs = M.chip_segments(width)
    local text = M.chip_plain(width)
    api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    apply_segs(buf, 0, segs)
  end
end

local function ensure_timer()
  if timer then
    return
  end
  timer = vim.uv.new_timer()
  timer:start(
    0,
    30000,
    vim.schedule_wrap(function()
      local any = false
      for win, info in pairs(tracked) do
        if api.nvim_win_is_valid(win) then
          any = true
          if info.refresh then
            info.refresh()
          end
        else
          tracked[win] = nil
        end
      end
      if not any then
        M._stop_timer()
      end
    end)
  )
end

function M._stop_timer()
  if timer then
    pcall(function()
      timer:stop()
      timer:close()
    end)
    timer = nil
  end
end

function M.attach_float(win, buf, refresh_fn)
  M.setup_hl()
  tracked[win] = { kind = 'float', buf = buf, refresh = refresh_fn }
  ensure_timer()
end

function M.attach_split(win, buf, refresh_fn)
  M.setup_hl()
  tracked[win] = { kind = 'split', buf = buf, refresh = refresh_fn }
  ensure_timer()
end

function M.detach(win)
  tracked[win] = nil
end

return M

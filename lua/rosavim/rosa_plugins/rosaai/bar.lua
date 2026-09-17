--- RosaAI bar - Title chip rendered on the top border of the CLI window
local M = {}

local api = vim.api
local chip_bar = require 'rosavim.helpers.chip_bar'
local chip = chip_bar.new { ns = 'rosaai_chip' }
local hex = chip_bar.hex
local get_time = chip_bar.get_time

local ICON = ''
local CLOCK = chip_bar.CLOCK

function M.setup_hl()
  local normal = api.nvim_get_hl(0, { name = 'Normal' })
  local fb = api.nvim_get_hl(0, { name = 'FloatBorder' })

  local nfg = hex(normal.fg) or '#cdd6f4'
  local border_fg = hex(fb and fb.fg) or nfg

  api.nvim_set_hl(0, 'RosaaiBarIcon', { fg = '#A9B2C0', bold = true })
  api.nvim_set_hl(0, 'RosaaiBarName', { fg = nfg, bold = true })
  api.nvim_set_hl(0, 'RosaaiBarTool', { fg = '#7B8394', italic = true })
  api.nvim_set_hl(0, 'RosaaiBarTime', { fg = '#7B8394' })
  api.nvim_set_hl(0, 'RosaaiBarBracket', { fg = border_fg })

  local review_fg = '#f9e2af'
  local okp, palette = pcall(require, 'rosavim.helpers.palette')
  if okp then
    local p = palette.get()
    review_fg = p.yellow or p.pink or review_fg
  end
  api.nvim_set_hl(0, 'RosaaiBarReview', { fg = review_fg, bold = true })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('RosaaiBarHl', { clear = true }),
  callback = function()
    M.setup_hl()
  end,
})

function M.chip_enabled()
  return chip_bar.toggle('rosaai_title', true)
end

function M.time_enabled()
  return chip_bar.toggle('rosaai_time', true)
end

function M.autoinsert_enabled()
  return chip_bar.toggle('rosaai_autoinsert', true)
end

--- Master Review toggle (default true). Gates the pending-review badge.
function M.review_enabled()
  return chip_bar.toggle('rosaai_review', true)
end

--- Whether the pending-review count badge is shown (default true).
function M.badge_enabled()
  return chip_bar.toggle('rosaai_review_badge', true)
end

local REVIEW_ICON = '󰈈'

--- The pending-review badge text (icon + count), or nil when it should not
--- show: feature off, badge hidden, a review already open, or nothing pending.
--- Reads the cached count from review.lua synchronously.
local function pending_badge()
  if not M.review_enabled() or not M.badge_enabled() then
    return nil
  end
  local ok, review = pcall(require, 'rosavim.rosa_plugins.rosaai.review')
  if not ok then
    return nil
  end
  if review.is_open and review.is_open() then
    return nil
  end
  local n = review.pending_count and review.pending_count() or 0
  if not n or n <= 0 then
    return nil
  end
  return REVIEW_ICON .. ' ' .. n
end

local function tool_label(tool_name)
  if not tool_name then
    return 'RosaAI'
  end
  local ok, tools = pcall(require, 'rosavim.rosa_plugins.rosaai.tools')
  if ok then
    local t = tools.get(tool_name)
    if t then
      return 'RosaAI · ' .. t.label
    end
  end
  return 'RosaAI'
end

local function inline_segments(tool_name)
  local segs = {
    { ' ', 'RosaaiBarBracket' },
    { ICON .. '  ', 'RosaaiBarIcon' },
    { tool_label(tool_name), 'RosaaiBarName' },
  }
  if M.time_enabled() then
    table.insert(segs, { ' ', 'RosaaiBarBracket' })
    table.insert(segs, { get_time(), 'RosaaiBarTime' })
  end
  local badge = pending_badge()
  if badge then
    table.insert(segs, { '  ', 'RosaaiBarBracket' })
    table.insert(segs, { badge, 'RosaaiBarReview' })
  end
  table.insert(segs, { ' ', 'RosaaiBarBracket' })
  return segs
end

local function banner_segments(width, tool_name)
  local label = tool_label(tool_name)
  local badge = pending_badge()
  local left_text = ' ' .. ICON .. '  ' .. label
  if badge then
    left_text = left_text .. '  ' .. badge
  end
  local left_w = vim.api.nvim_strwidth(left_text)

  local segs = {
    { ' ', 'RosaaiBarBracket' },
    { ICON, 'RosaaiBarIcon' },
    { '  ', 'RosaaiBarBracket' },
    { label, 'RosaaiBarName' },
  }
  if badge then
    table.insert(segs, { '  ', 'RosaaiBarBracket' })
    table.insert(segs, { badge, 'RosaaiBarReview' })
  end

  if M.time_enabled() then
    local right_text = ' ' .. CLOCK .. ' ' .. get_time() .. ' '
    local right_w = vim.api.nvim_strwidth(right_text)
    local pad = width - left_w - right_w
    if pad < 1 then
      pad = 1
    end
    table.insert(segs, { string.rep(' ', pad), 'RosaaiBarBracket' })
    table.insert(segs, { ' ' .. CLOCK .. ' ', 'RosaaiBarIcon' })
    table.insert(segs, { get_time(), 'RosaaiBarTime' })
    table.insert(segs, { ' ', 'RosaaiBarBracket' })
  else
    local pad = width - left_w
    if pad < 1 then
      pad = 1
    end
    table.insert(segs, { string.rep(' ', pad), 'RosaaiBarBracket' })
  end

  return segs
end

function M.chip_segments(width, tool_name)
  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  if ok then
    local t = themes.current()
    -- Petal is rendered as a borderless banner (full-width, text on the left)
    if t.layout == 'banner' or t.name == 'petal' then
      return banner_segments(width or 0, tool_name)
    end
  end
  return inline_segments(tool_name)
end

function M.chip_plain(width, tool_name)
  return chip_bar.segs_text(M.chip_segments(width, tool_name))
end

function M.write_chip_buf(buf, width, tool_name)
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end
  chip.clear(buf)

  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  local theme = ok and themes.current() or nil

  if theme and theme.layout == 'stem' then
    local segs = banner_segments(width or 0, tool_name)
    local text = chip_bar.segs_text(segs)
    local sep = string.rep('─', width or 0)
    api.nvim_buf_set_lines(buf, 0, -1, false, { text, sep })
    chip.apply_segs(buf, 0, segs)
    api.nvim_buf_set_extmark(buf, chip.ns, 1, 0, {
      end_row = 1,
      end_col = #sep,
      hl_group = 'RosaaiBarBracket',
    })
  else
    chip.write_line(buf, M.chip_segments(width, tool_name))
  end
end

function M._stop_timer()
  chip.stop_timer()
end

function M.attach(win, buf, refresh_fn)
  M.setup_hl()
  chip.track(win, { buf = buf, refresh = refresh_fn })
end

function M.detach(win)
  chip.untrack(win)
end

--- Esc-hint winbar fragment showing the terminal escape shortcuts.
--- Uses dedicated hint groups instead of Comment/Normal so the bg tracks the
--- window: when rosaai_dark_bg forces #000 in light mode, the hint blends in
--- (Comment is NOT remapped by the window's winhl, so it would otherwise keep
--- the theme's light bg and show light boxes around the keys).
function M.esc_hint()
  local term_bg = require 'rosavim.helpers.term_bg'
  local text_fg, key_fg, bg
  if term_bg.is_black 'rosaai' then
    -- Match RosaaiNormal (#000 bg / dim light fg) so the hint blends in.
    text_fg, key_fg, bg = '#d4d0c8', '#7B8394', '#000000'
  else
    local normal = api.nvim_get_hl(0, { name = 'Normal' })
    local comment = api.nvim_get_hl(0, { name = 'Comment' })
    text_fg = hex(normal.fg)
    key_fg = hex(comment.fg) or text_fg
    bg = hex(normal.bg) -- nil → NONE (transparent / falls back to WinBar)
  end
  api.nvim_set_hl(0, 'RosaaiHintKey', { fg = key_fg, bg = bg })
  api.nvim_set_hl(0, 'RosaaiHintText', { fg = text_fg, bg = bg })
  -- Leading space lives inside RosaaiHintText so it picks up the hint bg —
  -- otherwise that first cell uses WinBar (→ light Normal) and shows a light
  -- sliver to the left of "Esc" when the bg is forced dark.
  return '%#RosaaiHintText# %#RosaaiHintKey#Esc%#RosaaiHintText# → Normal  %#RosaaiHintKey#│%#RosaaiHintText#  %#RosaaiHintKey#Esc Esc%#RosaaiHintText# → Cancel CLI'
end

return M

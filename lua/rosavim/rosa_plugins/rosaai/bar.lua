--- RosaAI bar - Title chip rendered on the top border of the CLI window
local M = {}

local api = vim.api
local tracked = {} -- win -> { buf, refresh }
local timer = nil

local function hex(n)
  if not n then
    return nil
  end
  return string.format('#%06x', n)
end

local ICON = ''
local CLOCK = '󰥔'

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
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('RosaaiBarHl', { clear = true }),
  callback = function()
    M.setup_hl()
  end,
})

local function get_time()
  return os.date '%H:%M'
end

local function tog_get(key, default)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return default
  end
  local v = toggles.get(key)
  if v == nil then
    return default
  end
  return v
end

function M.chip_enabled()
  return tog_get('rosaai_title', true)
end

function M.time_enabled()
  return tog_get('rosaai_time', true)
end

function M.autoinsert_enabled()
  return tog_get('rosaai_autoinsert', true)
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
  table.insert(segs, { ' ', 'RosaaiBarBracket' })
  return segs
end

local function banner_segments(width, tool_name)
  local label = tool_label(tool_name)
  local left_text = ' ' .. ICON .. '  ' .. label
  local left_w = vim.api.nvim_strwidth(left_text)

  local segs = {
    { ' ', 'RosaaiBarBracket' },
    { ICON, 'RosaaiBarIcon' },
    { '  ', 'RosaaiBarBracket' },
    { label, 'RosaaiBarName' },
  }

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
  local s = ''
  for _, seg in ipairs(M.chip_segments(width, tool_name)) do
    s = s .. seg[1]
  end
  return s
end

local CHIP_NS = api.nvim_create_namespace 'rosaai_chip'

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

function M.write_chip_buf(buf, width, tool_name)
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end
  api.nvim_buf_clear_namespace(buf, CHIP_NS, 0, -1)

  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  local theme = ok and themes.current() or nil

  if theme and theme.layout == 'stem' then
    local segs = banner_segments(width or 0, tool_name)
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
      hl_group = 'RosaaiBarBracket',
    })
  else
    local segs = M.chip_segments(width, tool_name)
    local text = M.chip_plain(width, tool_name)
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

function M.attach(win, buf, refresh_fn)
  M.setup_hl()
  tracked[win] = { buf = buf, refresh = refresh_fn }
  ensure_timer()
end

function M.detach(win)
  tracked[win] = nil
end

--- Esc-hint winbar fragment showing the terminal escape shortcuts.
--- Uses dedicated hint groups instead of Comment/Normal so the bg tracks the
--- window: when rosaai_dark_bg forces #000 in light mode, the hint blends in
--- (Comment is NOT remapped by the window's winhl, so it would otherwise keep
--- the theme's light bg and show light boxes around the keys).
function M.esc_hint()
  local term_bg = require 'rosavim.rosa_plugins.term_bg'
  local text_fg, key_fg, bg
  if term_bg.is_black('rosaai_dark_bg', false) then
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

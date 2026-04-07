--- Rosapick - Visual window picker for Rosavim
local M = {}

local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'

local label_hl = 'RosapickLabel'
local label_active_hl = 'RosapickLabelActive'
local border_hl = 'RosapickBorder'

local function get_hl_color(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  return hl[attr]
end

local function setup_highlights()
  local bg = get_hl_color('Normal', 'bg') or 0x1c1c1c
  local fg = get_hl_color('Normal', 'fg') or 0xa0a0a0
  local border_fg = get_hl_color('FloatBorder', 'fg') or get_hl_color('Comment', 'fg') or 0x3a3a3a

  vim.api.nvim_set_hl(0, label_hl, { fg = border_fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, label_active_hl, { fg = fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, border_hl, { fg = border_fg, bg = bg })
end

local function get_windows()
  local wins = {}
  local current = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative == '' then
      table.insert(wins, { id = win, is_current = win == current })
    end
  end
  return wins
end

local function create_label(win, char, is_current)
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)
  local bufnr = vim.api.nvim_win_get_buf(win)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
  if filename == '' then
    filename = '[No Name]'
  end

  local text = '  ' .. char .. '  ' .. filename .. '  '
  local text_width = vim.fn.strdisplaywidth(text)
  local float_width = math.max(text_width, 10)
  local float_height = 1

  local col = math.floor((width - float_width) / 2)
  local row = math.floor((height - float_height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })

  local hl = is_current and label_active_hl or label_hl
  vim.api.nvim_buf_add_highlight(buf, -1, hl, 0, 0, -1)

  local float = vim.api.nvim_open_win(buf, false, {
    relative = 'win',
    win = win,
    row = row,
    col = col,
    width = float_width,
    height = float_height,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    zindex = 250,
  })

  vim.api.nvim_set_option_value('winblend', 0, { win = float })
  vim.api.nvim_set_option_value('winhighlight', 'NormalFloat:' .. hl .. ',FloatBorder:' .. border_hl, { win = float })

  return { float = float, buf = buf }
end

function M.select()
  local wins = get_windows()
  if #wins <= 1 then
    return nil
  end

  setup_highlights()

  local targets = {}
  local floats = {}

  for i, win in ipairs(wins) do
    local char = chars:sub(i, i)
    targets[char] = win.id
    local label = create_label(win.id, char, win.is_current)
    table.insert(floats, label)
  end

  vim.cmd 'redraw'

  local ok, raw = pcall(vim.fn.getchar)

  for _, f in ipairs(floats) do
    if vim.api.nvim_win_is_valid(f.float) then
      vim.api.nvim_win_close(f.float, true)
    end
    if vim.api.nvim_buf_is_valid(f.buf) then
      vim.api.nvim_buf_delete(f.buf, { force = true })
    end
  end

  if not ok then
    return nil
  end

  if raw == 27 then
    return nil
  end

  local char = string.upper(string.char(raw))
  return targets[char]
end

function M.pick()
  local win = M.select()
  if win then
    vim.api.nvim_set_current_win(win)
  end
end

function M.close()
  local win = M.select()
  if win then
    vim.api.nvim_win_close(win, false)
  end
end

return M

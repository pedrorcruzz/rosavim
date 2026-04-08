--- Rosafile UI - Floating popups for file operations
local M = {}

local ns = vim.api.nvim_create_namespace 'rosafile'

local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  vim.api.nvim_set_hl(0, 'RosafileTitle', { fg = p.title, bold = true })
  vim.api.nvim_set_hl(0, 'RosafileBorder', { fg = p.border })
  vim.api.nvim_set_hl(0, 'RosafileKey', { fg = p.key, bold = true })
  vim.api.nvim_set_hl(0, 'RosafileAction', { fg = p.text })
  vim.api.nvim_set_hl(0, 'RosafileCreate', { fg = p.green })
  vim.api.nvim_set_hl(0, 'RosafileDanger', { fg = p.red, bold = true })
  vim.api.nvim_set_hl(0, 'RosafileDim', { fg = p.dim })
  vim.api.nvim_set_hl(0, 'RosafileInfo', { fg = p.teal })
  vim.api.nvim_set_hl(0, 'RosafileWarn', { fg = p.yellow, bold = true })
  vim.api.nvim_set_hl(0, 'RosafilePath', { fg = p.subtext, italic = true })
end

--- Create a centered floating window
local function create_float(opts)
  local width = opts.width or 50
  local height = opts.height or 12
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosafile'

  local win_opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. (opts.title or 'Rosafile') .. ' ',
    title_pos = 'center',
    zindex = 50,
  }

  if opts.footer then
    win_opts.footer = ' ' .. opts.footer .. ' '
    win_opts.footer_pos = 'center'
  end

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosafileBorder,FloatTitle:RosafileTitle,FloatFooter:RosafileDim'
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false

  return buf, win
end

--- Actions popup - main menu
function M.actions_popup()
  setup_highlights()

  --  pad = left padding for the whole line
  local pad = '       '
  local gap = '    ' -- gap between key and label

  local actions = {
    { key = 'a', label = 'Create here', action = 'create_here', hl = 'RosafileCreate' },
    { key = 'x', label = 'Create from root', action = 'create_root', hl = 'RosafileCreate' },
    { sep = true },
    { key = 'r', label = 'Rename', action = 'rename', hl = 'RosafileInfo' },
    { key = 'c', label = 'Duplicate', action = 'copy', hl = 'RosafileInfo' },
    { key = 'i', label = 'Info', action = 'info', hl = 'RosafileInfo' },
    { sep = true },
    { key = 'd', label = 'Delete', action = 'delete', hl = 'RosafileDanger' },
  }

  local lines = {}
  local highlights = {}
  local ln = 0

  local function add(text, hl)
    table.insert(lines, text)
    if hl then
      table.insert(highlights, { hl, ln })
    end
    ln = ln + 1
  end

  local function add_hl(hl_name, line_nr, col_start, col_end)
    table.insert(highlights, { hl_name, line_nr, col_start, col_end })
  end

  -- Current file context
  local max_path = 38
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= '' then
    local rel = vim.fn.fnamemodify(current_file, ':~:.')
    if #rel > max_path then
      rel = '…' .. rel:sub(-(max_path - 1))
    end
    add(pad .. rel, 'RosafilePath')
  else
    add(pad .. '(no file)', 'RosafileDim')
  end
  add(pad .. string.rep('─', 36), 'RosafileDim')
  add ''

  -- Actions
  for _, a in ipairs(actions) do
    if a.sep then
      add ''
    else
      local line = pad .. a.key .. gap .. a.label
      local key_start = #pad
      local key_end = key_start + #a.key
      local label_start = key_end + #gap
      local label_end = label_start + #a.label

      add(line)
      add_hl('RosafileKey', ln - 1, key_start, key_end)
      add_hl(a.hl, ln - 1, label_start, label_end)
    end
  end

  add ''

  local width = 52
  local height = #lines

  local buf, win = create_float {
    title = ' Rosafile',
    footer = 'q: close',
    width = width,
    height = height,
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
  end

  -- Close keymaps
  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local kopts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)

  -- Action keymaps
  local rosafile = require 'rosavim.rosa_plugins.rosafile'
  for _, a in ipairs(actions) do
    if not a.sep then
      vim.keymap.set('n', a.key, function()
        close()
        vim.schedule(function()
          rosafile[a.action]()
        end)
      end, kopts)
    end
  end
end

--- Input popup - uses vim.ui.input (rendered by snacks)
--- @param opts { title: string, default: string, completion: string|nil, cursor_before_ext: number|nil, on_confirm: function }
function M.input_popup(opts)
  vim.ui.input({
    prompt = opts.title,
    default = opts.default or '',
    completion = opts.completion,
  }, function(input)
    if input and input ~= '' then
      opts.on_confirm(input)
    end
  end)
end

--- Confirm popup for dangerous actions
--- @param opts { title: string, message: string, detail: string|nil, on_confirm: function }
function M.confirm_popup(opts)
  setup_highlights()

  local pad = '       '

  local lines = { '' }
  local highlights = {}
  local ln = 1

  -- Message
  table.insert(lines, pad .. opts.message)
  table.insert(highlights, { 'RosafileWarn', ln })
  ln = ln + 1

  table.insert(lines, '')
  ln = ln + 1

  if opts.detail then
    table.insert(lines, pad .. opts.detail)
    table.insert(highlights, { 'RosafileDim', ln })
    ln = ln + 1

    table.insert(lines, '')
    ln = ln + 1
  end

  -- Separator
  table.insert(lines, pad .. string.rep('─', 30))
  table.insert(highlights, { 'RosafileDim', ln })
  ln = ln + 1

  table.insert(lines, '')
  ln = ln + 1

  -- y / n options
  local confirm_line = pad .. 'y    Confirm          n    Cancel'
  table.insert(lines, confirm_line)
  local y_start = #pad
  table.insert(highlights, { 'RosafileDanger', ln, y_start, y_start + 1 })
  table.insert(highlights, { 'RosafileAction', ln, y_start + 4, y_start + 11 })
  local n_start = y_start + 22
  table.insert(highlights, { 'RosafileKey', ln, n_start, n_start + 1 })
  table.insert(highlights, { 'RosafileAction', ln, n_start + 4, n_start + 10 })
  ln = ln + 1

  table.insert(lines, '')

  local buf, win = create_float {
    title = opts.title or ' Confirm',
    width = 48,
    height = #lines,
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
  end

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local kopts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set('n', 'n', close, kopts)
  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)
  vim.keymap.set('n', 'y', function()
    close()
    vim.schedule(function()
      opts.on_confirm()
    end)
  end, kopts)
end

--- File info popup
function M.info_popup(file)
  setup_highlights()

  local stat = vim.uv.fs_stat(file)
  local rel = vim.fn.fnamemodify(file, ':~:.')
  local dir = vim.fn.fnamemodify(file, ':h')
  local name = vim.fn.fnamemodify(file, ':t')
  local ext = vim.fn.fnamemodify(file, ':e')

  local size_str = 'unknown'
  local modified_str = 'unknown'
  if stat then
    local size = stat.size
    if size < 1024 then
      size_str = size .. ' B'
    elseif size < 1024 * 1024 then
      size_str = string.format('%.1f KB', size / 1024)
    else
      size_str = string.format('%.1f MB', size / (1024 * 1024))
    end
    modified_str = os.date('%Y-%m-%d %H:%M:%S', stat.mtime.sec)
  end

  local buf_lines = vim.api.nvim_buf_line_count(0)

  local pad = '       '
  local label_w = 13 -- width of label column

  local function row(label, value)
    return pad .. label .. string.rep(' ', label_w - #label) .. value
  end

  local info_lines = {
    '',
    row('Name', name),
    row('Extension', ext ~= '' and ext or '(none)'),
    row('Path', rel),
    row('Directory', dir),
    row('Size', size_str),
    row('Lines', tostring(buf_lines)),
    row('Modified', modified_str),
    '',
  }

  local highlights = {}
  for i = 1, 7 do
    table.insert(highlights, { 'RosafileKey', i, #pad, #pad + label_w })
    table.insert(highlights, { 'RosafileAction', i, #pad + label_w, -1 })
  end

  local width = 62
  for _, l in ipairs(info_lines) do
    if #l + 4 > width then
      width = #l + 4
    end
  end

  local buf, win = create_float {
    title = ' File Info',
    footer = 'q: close',
    width = width,
    height = #info_lines,
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, info_lines)
  vim.bo[buf].modifiable = false

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
  end

  local kopts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, kopts)
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, kopts)
end

return M

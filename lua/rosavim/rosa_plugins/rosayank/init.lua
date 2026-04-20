--- Rosayank - Yank history with persistence for Rosavim
local M = {}

local MAX_ENTRIES = 50
local cache_file = vim.fn.stdpath 'cache' .. '/rosayank.json'

--- @class RosayankEntry
--- @field text string
--- @field regtype string

--- @type RosayankEntry[]
local history = {}
local loaded = false

--- Load history from cache file
local function load()
  if loaded then
    return
  end
  loaded = true
  local ok, content = pcall(vim.fn.readfile, cache_file)
  if ok and content[1] then
    local decoded = vim.json.decode(content[1])
    if type(decoded) == 'table' then
      history = decoded
    end
  end
end

--- Save history to cache file
local function save()
  local json = vim.json.encode(history)
  vim.fn.writefile({ json }, cache_file)
end

--- Add a yank entry to history
--- @param entry RosayankEntry
local function push(entry)
  if not entry.text or entry.text == '' then
    return
  end

  -- Skip if identical to the most recent entry
  if history[1] and history[1].text == entry.text then
    return
  end

  table.insert(history, 1, entry)

  -- Trim to max size
  while #history > MAX_ENTRIES do
    table.remove(history)
  end
end

--- Setup autocmds for capturing yanks, highlight, and persistence
function M.setup()
  load()

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('rosayank', { clear = true }),
    callback = function()
      -- Highlight
      vim.highlight.on_yank { timeout = 150 }

      -- Capture yank
      local event = vim.v.event
      if event.operator == 'y' then
        push {
          text = table.concat(event.regcontents, '\n'),
          regtype = event.regtype,
        }
      end
    end,
  })

  -- Save on exit
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('rosayank_save', { clear = true }),
    callback = save,
  })
end

--- Open yank history in Snacks picker
function M.pick()
  load()

  if #history == 0 then
    Snacks.notify.info 'Rosayank: empty history'
    return
  end

  local items = {}
  for i, entry in ipairs(history) do
    local preview = entry.text:gsub('\n', ' '):sub(1, 120)
    table.insert(items, {
      text = string.format('[%d] %s', i, preview),
      idx = i,
      entry = entry,
    })
  end

  Snacks.picker {
    title = ' Rosayank',
    items = items,
    format = function(item)
      local idx = tostring(item.idx)
      local preview = item.entry.text:gsub('\n', '\\n'):sub(1, 100)
      return {
        { idx .. '  ', 'SnacksPickerIdx' },
        { preview },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        -- Set the unnamed register and paste
        vim.fn.setreg('"', item.entry.text, item.entry.regtype)
        vim.api.nvim_put(vim.split(item.entry.text, '\n', { plain = true }), item.entry.regtype, true, true)
      end
    end,
  }
end

--- Open styled floating menu for yank history
function M.menu()
  load()

  local ns = vim.api.nvim_create_namespace 'rosayank_menu'

  -- Highlights
  local p = require('rosavim.rosa_plugins.palette').get()
  vim.api.nvim_set_hl(0, 'RosayankTitle', { fg = p.title, bold = true })
  vim.api.nvim_set_hl(0, 'RosayankBorder', { fg = p.border })
  vim.api.nvim_set_hl(0, 'RosayankIdx', { fg = p.key, bold = true })
  vim.api.nvim_set_hl(0, 'RosayankText', { fg = p.text })
  vim.api.nvim_set_hl(0, 'RosayankDim', { fg = p.dim })
  vim.api.nvim_set_hl(0, 'RosayankDanger', { fg = p.red })
  vim.api.nvim_set_hl(0, 'RosayankHint', { fg = p.dim, italic = true })

  local pad = '   '
  local gap = '  '

  local lines = {}
  local highlights = {}
  local entry_line_map = {} -- line index -> history index
  local ln = 0

  local function add(text)
    table.insert(lines, text)
    ln = ln + 1
  end

  local function add_hl(hl_name, line_nr, col_start, col_end)
    table.insert(highlights, { hl_name, line_nr, col_start, col_end })
  end

  if #history == 0 then
    add ''
    add(pad .. 'No yanks yet.')
    add_hl('RosayankDim', ln - 1, 0, -1)
    add ''
  else
    add ''
    for i, entry in ipairs(history) do
      local preview = entry.text:gsub('\n', '↵ '):sub(1, 60)
      local idx_str = tostring(i)
      local line = pad .. idx_str .. gap .. preview

      add(line)
      entry_line_map[ln - 1] = i

      add_hl('RosayankIdx', ln - 1, #pad, #pad + #idx_str)
      add_hl('RosayankText', ln - 1, #pad + #idx_str + #gap, -1)
    end
    add ''

    -- Separator
    add(pad .. string.rep('─', 40))
    add_hl('RosayankDim', ln - 1, 0, -1)

    -- Help
    add(pad .. '<CR>  paste    dd  remove    DD  clear all')
    add_hl('RosayankIdx', ln - 1, #pad, #pad + 4)
    add_hl('RosayankHint', ln - 1, #pad + 4, #pad + 15)
    add_hl('RosayankDanger', ln - 1, #pad + 15, #pad + 17)
    add_hl('RosayankHint', ln - 1, #pad + 17, #pad + 29)
    add_hl('RosayankDanger', ln - 1, #pad + 29, #pad + 31)
    add_hl('RosayankHint', ln - 1, #pad + 31, -1)
    add ''
  end

  local width = 56
  for _, l in ipairs(lines) do
    if #l + 6 > width then
      width = math.min(#l + 6, 80)
    end
  end
  local height = #lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosayank'

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = '  Rosayank ',
    title_pos = 'center',
    footer = ' q: close ',
    footer_pos = 'center',
    zindex = 50,
  })

  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosayankBorder,FloatTitle:RosayankTitle,FloatFooter:RosayankDim'
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
  end

  -- Place cursor on first entry line
  if #history > 0 then
    vim.api.nvim_win_set_cursor(win, { 2, 0 })
  end

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function refresh()
    close()
    vim.schedule(function()
      M.menu()
    end)
  end

  local kopts = { buffer = buf, silent = true, nowait = true }

  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)

  -- Enter to paste entry under cursor
  vim.keymap.set('n', '<CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local entry_idx = entry_line_map[cursor[1] - 1]
    if not entry_idx then
      return
    end
    local entry = history[entry_idx]
    close()
    vim.schedule(function()
      vim.fn.setreg('"', entry.text, entry.regtype)
      vim.api.nvim_put(vim.split(entry.text, '\n', { plain = true }), entry.regtype, true, true)
    end)
  end, kopts)

  -- dd to remove entry under cursor
  vim.keymap.set('n', 'dd', function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local entry_idx = entry_line_map[cursor[1] - 1]
    if not entry_idx then
      return
    end
    table.remove(history, entry_idx)
    save()
    refresh()
  end, kopts)

  -- visual d to remove selected entries
  vim.keymap.set('v', 'd', function()
    local start_line = vim.fn.line 'v'
    local end_line = vim.fn.line '.'
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    local indices = {}
    for line = start_line, end_line do
      local entry_idx = entry_line_map[line - 1]
      if entry_idx then
        table.insert(indices, entry_idx)
      end
    end

    table.sort(indices, function(a, b)
      return a > b
    end)
    for _, idx in ipairs(indices) do
      table.remove(history, idx)
    end
    save()
    refresh()
  end, kopts)

  -- DD to clear all history
  vim.keymap.set('n', 'DD', function()
    history = {}
    save()
    refresh()
  end, kopts)
end

--- Clear all history
function M.clear()
  history = {}
  save()
  Snacks.notify.info 'Rosayank: history cleared'
end

return M

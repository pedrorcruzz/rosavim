--- Rosapoon - File bookmarking for Rosavim
local M = {}

local cache_dir = vim.fn.stdpath 'cache'
local cache_file = cache_dir .. '/rosapoon.json'

M._state = nil

--- Get the git root for the current directory (used as scope key)
--- @return string
local function get_scope()
  local root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(vim.fn.getcwd()) .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not root or root == '' then
    return vim.fn.getcwd()
  end
  return root
end

--- Load all scopes from cache
--- @return table
local function load_all()
  if M._state then
    return M._state
  end
  local ok, content = pcall(vim.fn.readfile, cache_file)
  if ok and content[1] then
    local decoded = vim.json.decode(content[1])
    if decoded then
      M._state = decoded
      return M._state
    end
  end
  M._state = {}
  return M._state
end

--- Save all scopes to cache
local function save_all()
  local json = vim.json.encode(M._state)
  vim.fn.writefile({ json }, cache_file)
end

--- Get tags for current scope
--- @return string[]
local function get_tags()
  local state = load_all()
  local scope = get_scope()
  if not state[scope] then
    state[scope] = {}
  end
  return state[scope]
end

--- Set tags for current scope
--- @param tags string[]
local function set_tags(tags)
  local state = load_all()
  local scope = get_scope()
  state[scope] = tags
  save_all()
end

--- Toggle the current file as a tag
function M.toggle()
  local file = vim.fn.expand '%:p'
  if file == '' then
    vim.notify('Rosapoon: no file to tag', vim.log.levels.WARN)
    return
  end

  local tags = get_tags()
  for i, tag in ipairs(tags) do
    if tag == file then
      table.remove(tags, i)
      set_tags(tags)
      vim.notify('Rosapoon: untagged', vim.log.levels.INFO)
      return
    end
  end

  table.insert(tags, file)
  set_tags(tags)
  vim.notify('Rosapoon: tagged [' .. #tags .. ']', vim.log.levels.INFO)
end

--- Select a tag by index
--- @param index number
function M.select(index)
  local tags = get_tags()
  if index < 1 or index > #tags then
    vim.notify('Rosapoon: no tag at index ' .. index, vim.log.levels.INFO)
    return
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(tags[index]))
end

--- Cycle through tags
--- @param direction "next"|"prev"
function M.cycle(direction)
  local tags = get_tags()
  if #tags == 0 then
    vim.notify('Rosapoon: no tags', vim.log.levels.INFO)
    return
  end

  local current = vim.fn.expand '%:p'
  local current_idx = nil
  for i, tag in ipairs(tags) do
    if tag == current then
      current_idx = i
      break
    end
  end

  local next_idx
  if not current_idx then
    next_idx = 1
  elseif direction == 'next' then
    next_idx = current_idx % #tags + 1
  else
    next_idx = (current_idx - 2) % #tags + 1
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(tags[next_idx]))
end

--- Get all tags (for external use like incline)
--- @return string[]
function M.tags()
  return get_tags()
end

--- Open a styled menu to manage tags
function M.toggle_tags()
  local ns = vim.api.nvim_create_namespace 'rosapoon'
  local tags = get_tags()
  local scope = get_scope()
  local scope_name = vim.fn.fnamemodify(scope, ':t')
  local current_file = vim.fn.expand '%:p'

  -- Highlights
  vim.api.nvim_set_hl(0, 'RosapoonTitle', { fg = '#cba6f7', bold = true })
  vim.api.nvim_set_hl(0, 'RosapoonBorder', { fg = '#6c7086' })
  vim.api.nvim_set_hl(0, 'RosapoonIdx', { fg = '#89b4fa', bold = true })
  vim.api.nvim_set_hl(0, 'RosapoonFile', { fg = '#cdd6f4' })
  vim.api.nvim_set_hl(0, 'RosapoonActive', { fg = '#a6e3a1', bold = true })
  vim.api.nvim_set_hl(0, 'RosapoonActiveIdx', { fg = '#a6e3a1', bold = true })
  vim.api.nvim_set_hl(0, 'RosapoonDim', { fg = '#6c7086' })
  vim.api.nvim_set_hl(0, 'RosapoonDanger', { fg = '#f38ba8' })
  vim.api.nvim_set_hl(0, 'RosapoonHint', { fg = '#6c7086', italic = true })

  local pad = '   '
  local gap = '  '

  local lines = {}
  local highlights = {}
  local tag_line_map = {} -- line index -> tag index
  local ln = 0

  local function add(text)
    table.insert(lines, text)
    ln = ln + 1
  end

  local function add_hl(hl_name, line_nr, col_start, col_end)
    table.insert(highlights, { hl_name, line_nr, col_start, col_end })
  end

  if #tags == 0 then
    add ''
    add(pad .. 'No tags yet.')
    add_hl('RosapoonDim', ln - 1, 0, -1)
    add ''
    add(pad .. 'Press  o  to tag the current file')
    add_hl('RosapoonIdx', ln - 1, #pad + 7, #pad + 8)
    add_hl('RosapoonDim', ln - 1, 0, #pad + 7)
    add_hl('RosapoonDim', ln - 1, #pad + 8, -1)
    add ''
  else
    add ''
    for i, tag in ipairs(tags) do
      local rel = tag
      if tag:sub(1, #scope) == scope then
        rel = tag:sub(#scope + 2)
      end

      local is_active = tag == current_file
      local idx_str = tostring(i)
      local marker = is_active and ' 󰄬' or ''
      local line = pad .. idx_str .. gap .. rel .. marker

      add(line)
      tag_line_map[ln - 1] = i

      local idx_hl = is_active and 'RosapoonActiveIdx' or 'RosapoonIdx'
      local file_hl = is_active and 'RosapoonActive' or 'RosapoonFile'

      add_hl(idx_hl, ln - 1, #pad, #pad + #idx_str)
      add_hl(file_hl, ln - 1, #pad + #idx_str + #gap, -1)
    end
    add ''

    -- Separator
    add(pad .. string.rep('─', 40))
    add_hl('RosapoonDim', ln - 1, 0, -1)

    -- Help
    add(pad .. '<CR>  jump    dd  remove    DD  remove all    o  tag current')
    add_hl('RosapoonIdx', ln - 1, #pad, #pad + 4)
    add_hl('RosapoonHint', ln - 1, #pad + 4, #pad + 14)
    add_hl('RosapoonDanger', ln - 1, #pad + 14, #pad + 16)
    add_hl('RosapoonHint', ln - 1, #pad + 16, #pad + 28)
    add_hl('RosapoonDanger', ln - 1, #pad + 28, #pad + 30)
    add_hl('RosapoonHint', ln - 1, #pad + 30, #pad + 46)
    add_hl('RosapoonIdx', ln - 1, #pad + 46, #pad + 47)
    add_hl('RosapoonHint', ln - 1, #pad + 47, -1)
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
  vim.bo[buf].filetype = 'rosapoon'

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' 󰛢 Rosapoon [' .. scope_name .. '] ',
    title_pos = 'center',
    footer = ' q: close ',
    footer_pos = 'center',
    zindex = 50,
  })

  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosapoonBorder,FloatTitle:RosapoonTitle,FloatFooter:RosapoonDim'
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
  end

  -- Place cursor on first tag line
  if #tags > 0 then
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
      M.toggle_tags()
    end)
  end

  local kopts = { buffer = buf, silent = true, nowait = true }

  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)

  -- Enter to jump to file under cursor
  vim.keymap.set('n', '<CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local tag_idx = tag_line_map[cursor[1] - 1]
    if not tag_idx then
      return
    end
    close()
    vim.cmd('edit ' .. vim.fn.fnameescape(tags[tag_idx]))
  end, kopts)

  -- dd to remove tag under cursor
  vim.keymap.set('n', 'dd', function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local tag_idx = tag_line_map[cursor[1] - 1]
    if not tag_idx then
      return
    end
    table.remove(tags, tag_idx)
    set_tags(tags)
    refresh()
  end, kopts)

  -- dd in visual mode to remove selected tags
  vim.keymap.set('v', 'd', function()
    local start_line = vim.fn.line 'v'
    local end_line = vim.fn.line '.'
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    local indices = {}
    for line = start_line, end_line do
      local tag_idx = tag_line_map[line - 1]
      if tag_idx then
        table.insert(indices, tag_idx)
      end
    end

    table.sort(indices, function(a, b)
      return a > b
    end)
    for _, idx in ipairs(indices) do
      table.remove(tags, idx)
    end
    set_tags(tags)
    refresh()
  end, kopts)

  -- DD to remove all tags
  vim.keymap.set('n', 'DD', function()
    set_tags {}
    refresh()
  end, kopts)

  -- o to tag current file
  vim.keymap.set('n', 'o', function()
    if current_file == '' then
      return
    end
    -- Check if already tagged
    for _, tag in ipairs(tags) do
      if tag == current_file then
        vim.notify('Rosapoon: already tagged', vim.log.levels.INFO)
        return
      end
    end
    table.insert(tags, current_file)
    set_tags(tags)
    refresh()
  end, kopts)
end

--- Open tags in Snacks picker
function M.picker()
  local tags = get_tags()
  if #tags == 0 then
    vim.notify('Rosapoon: no tags', vim.log.levels.INFO)
    return
  end

  local items = {}
  for i, tag in ipairs(tags) do
    table.insert(items, {
      text = string.format('[%d] %s', i, tag),
      file = tag,
      idx = i,
    })
  end

  Snacks.picker {
    title = '󰛢 Rosapoon',
    items = items,
    format = function(item)
      local idx = tostring(item.idx)
      local rel = vim.fn.fnamemodify(item.file, ':~:.')
      return {
        { idx .. '  ', 'SnacksPickerIdx' },
        { rel },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
      end
    end,
  }
end

return M

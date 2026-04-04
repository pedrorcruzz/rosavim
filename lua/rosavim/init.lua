local M = {}

M.version = '0.1.0'
M.name = 'Rosavim'

--- Open snacks picker listing files in a directory
local function browse_dir(title, dir)
  local files = vim.fn.globpath(dir, '**/*.lua', false, true)
  if #files == 0 then
    vim.notify('No files found', vim.log.levels.INFO)
    return
  end

  local items = {}
  for _, f in ipairs(files) do
    local rel = f:sub(#dir + 2)
    table.insert(items, { text = rel, file = f })
  end
  table.sort(items, function(a, b)
    return a.text < b.text
  end)

  Snacks.picker {
    title = title,
    items = items,
    format = 'file',
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
      end
    end,
  }
end

function M.info()
  local lazy = require 'lazy'
  local stats = lazy.stats()
  local nvim = vim.version()
  local ms = string.format('%.2f', stats.startuptime)
  local config_path = vim.fn.stdpath 'config' .. '/lua/rosavim'

  -- Count rosa plugins
  local rosa_count = 0
  local rosa_path = config_path .. '/rosa_plugins'
  if vim.fn.isdirectory(rosa_path) == 1 then
    for _, entry in ipairs(vim.fn.readdir(rosa_path)) do
      if vim.fn.isdirectory(rosa_path .. '/' .. entry) == 1 then
        rosa_count = rosa_count + 1
      end
    end
  end

  -- Highlights
  local ns = vim.api.nvim_create_namespace 'rosavim_info'
  vim.api.nvim_set_hl(0, 'RosavimInfoTitle', { fg = '#cba6f7', bold = true })
  vim.api.nvim_set_hl(0, 'RosavimInfoBorder', { fg = '#6c7086' })
  vim.api.nvim_set_hl(0, 'RosavimInfoLabel', { fg = '#89b4fa', bold = true })
  vim.api.nvim_set_hl(0, 'RosavimInfoValue', { fg = '#cdd6f4' })
  vim.api.nvim_set_hl(0, 'RosavimInfoDim', { fg = '#6c7086' })
  vim.api.nvim_set_hl(0, 'RosavimInfoGreen', { fg = '#a6e3a1', bold = true })
  vim.api.nvim_set_hl(0, 'RosavimInfoKey', { fg = '#f9e2af', bold = true })

  local pad = '            '
  local gap = '     '
  local label_w = 20

  local function row(label, value)
    return pad .. label .. string.rep(' ', label_w - #label) .. value
  end

  local info_items = {
    { label = 'Neovim', value = 'v' .. nvim.major .. '.' .. nvim.minor .. '.' .. nvim.patch },
    { label = 'Plugins', value = stats.loaded .. ' / ' .. stats.count .. ' loaded', key = 'p', dir = config_path .. '/plugins' },
    { label = 'Rosa Plugins', value = tostring(rosa_count), key = 'r', dir = rosa_path },
    { label = 'Startup', value = ms .. 'ms' },
  }

  local lines = {
    pad .. ' ' .. M.name .. ' v' .. M.version,
    pad .. string.rep('─', 46),
    '',
  }

  local highlights = {
    { 'RosavimInfoGreen', 0 },
    { 'RosavimInfoDim', 1 },
  }

  local key_map = {}

  for _, item in ipairs(info_items) do
    local line
    if item.key then
      line = pad .. item.key .. gap .. item.label .. string.rep(' ', label_w - #item.label) .. item.value
      local ln = #lines
      table.insert(highlights, { 'RosavimInfoKey', ln, #pad, #pad + 1 })
      table.insert(highlights, { 'RosavimInfoLabel', ln, #pad + 1 + #gap, #pad + 1 + #gap + label_w })
      table.insert(highlights, { 'RosavimInfoValue', ln, #pad + 1 + #gap + label_w, -1 })
      key_map[item.key] = { title = item.label, dir = item.dir }
    else
      line = pad .. ' ' .. gap .. item.label .. string.rep(' ', label_w - #item.label) .. item.value
      local ln = #lines
      table.insert(highlights, { 'RosavimInfoLabel', ln, #pad + 1 + #gap, #pad + 1 + #gap + label_w })
      table.insert(highlights, { 'RosavimInfoValue', ln, #pad + 1 + #gap + label_w, -1 })
    end
    table.insert(lines, line)
  end

  table.insert(lines, '')

  -- Float
  local width = 70
  local height = #lines
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = '  ' .. M.name .. ' ',
    title_pos = 'center',
    footer = ' q: close ',
    footer_pos = 'center',
  })

  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosavimInfoBorder,FloatTitle:RosavimInfoTitle,FloatFooter:RosavimInfoDim'
  vim.wo[win].cursorline = false

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
  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)

  for k, item in pairs(key_map) do
    vim.keymap.set('n', k, function()
      close()
      vim.schedule(function()
        browse_dir(' ' .. item.title, item.dir)
      end)
    end, kopts)
  end
end

vim.api.nvim_create_user_command('Rosavim', function()
  M.info()
end, { desc = 'Show Rosavim info' })

return M

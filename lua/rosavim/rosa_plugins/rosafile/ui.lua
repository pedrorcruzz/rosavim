--- Rosafile UI - Floating popups for file operations
local M = {}

local menu = require 'rosavim.helpers.rosa_menu'

local function setup_highlights()
  require('rosavim.helpers.palette').define('Rosafile', function(p)
    return {
      Title = { fg = p.title, bold = true },
      Border = { fg = p.border },
      Key = { fg = p.key, bold = true },
      Action = { fg = p.text },
      Create = { fg = p.green },
      Danger = { fg = p.red, bold = true },
      Dim = { fg = p.dim },
      Info = { fg = p.teal },
      Warn = { fg = p.yellow, bold = true },
      Path = { fg = p.subtext, italic = true },
    }
  end)
end

--- Open a centered rosafile menu (adds this plugin's title/footer padding)
local function open_menu(opts)
  opts.title = ' ' .. (opts.title or 'Rosafile') .. ' '
  if opts.footer then
    opts.footer = ' ' .. opts.footer .. ' '
  end
  opts.hl_prefix = 'Rosafile'
  opts.filetype = 'rosafile'
  return menu.open(opts)
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

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl

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
      add_hl('RosafileKey', b.line(), key_start, key_end)
      add_hl(a.hl, b.line(), label_start, label_end)
    end
  end

  add ''

  -- Action keymaps
  local rosafile = require 'rosavim.rosa_plugins.rosafile'
  local keys = {}
  for _, a in ipairs(actions) do
    if not a.sep then
      table.insert(keys, {
        'n',
        a.key,
        function(ctx)
          ctx.close()
          vim.schedule(function()
            rosafile[a.action]()
          end)
        end,
      })
    end
  end

  open_menu {
    title = ' Rosafile',
    footer = 'q: close',
    width = 52,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    keys = keys,
  }
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

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl

  add ''

  -- Message
  add(pad .. opts.message, 'RosafileWarn')
  add ''

  if opts.detail then
    add(pad .. opts.detail, 'RosafileDim')
    add ''
  end

  -- Separator
  add(pad .. string.rep('─', 30), 'RosafileDim')
  add ''

  -- y / n options
  add(pad .. 'y    Confirm          n    Cancel')
  local y_start = #pad
  add_hl('RosafileDanger', b.line(), y_start, y_start + 1)
  add_hl('RosafileAction', b.line(), y_start + 4, y_start + 11)
  local n_start = y_start + 22
  add_hl('RosafileKey', b.line(), n_start, n_start + 1)
  add_hl('RosafileAction', b.line(), n_start + 4, n_start + 10)
  add ''

  local keys = {
    {
      'n',
      'n',
      function(ctx)
        ctx.close()
      end,
    },
    {
      'n',
      'y',
      function(ctx)
        ctx.close()
        vim.schedule(function()
          opts.on_confirm()
        end)
      end,
    },
  }

  open_menu {
    title = opts.title or ' Confirm',
    width = 48,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    keys = keys,
  }
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

  open_menu {
    title = ' File Info',
    footer = 'q: close',
    width = width,
    height = #info_lines,
    lines = info_lines,
    highlights = highlights,
  }
end

return M

--- Rosakit UI - Floating popups for language tools
local M = {}

local ns = vim.api.nvim_create_namespace 'rosakit'

local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  vim.api.nvim_set_hl(0, 'RosakitTitle', { fg = p.title, bold = true })
  vim.api.nvim_set_hl(0, 'RosakitBorder', { fg = p.border })
  vim.api.nvim_set_hl(0, 'RosakitKey', { fg = p.key, bold = true })
  vim.api.nvim_set_hl(0, 'RosakitSection', { fg = p.green })
  vim.api.nvim_set_hl(0, 'RosakitTool', { fg = p.yellow })
  vim.api.nvim_set_hl(0, 'RosakitDim', { fg = p.dim })
  vim.api.nvim_set_hl(0, 'RosakitStack', { fg = p.pink, bold = true })
  vim.api.nvim_set_hl(0, 'RosakitAction', { fg = p.teal })
end

--- Create a centered floating window
local function create_float(opts)
  local width = opts.width or 52
  local height = opts.height or 14
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosakit'

  local win_opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. (opts.title or 'Rosakit') .. ' ',
    title_pos = 'center',
    zindex = 50,
  }

  if opts.footer then
    win_opts.footer = ' ' .. opts.footer .. ' '
    win_opts.footer_pos = 'center'
  end

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosakitBorder,FloatTitle:RosakitTitle,FloatFooter:RosakitDim'
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false

  return buf, win
end

--- Show workspace selector (for monorepos)
--- @param workspaces { root: string, stack: table }[]
--- @param on_select fun(ws: { root: string, stack: table })
function M.workspace_popup(workspaces, on_select)
  setup_highlights()

  local pad = '       '
  local gap = '    '
  local keys = 'abcdefghijlmnopqrstuvwxyz'

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

  add(pad .. 'Select workspace', 'RosakitDim')
  add(pad .. string.rep('─', 36), 'RosakitDim')
  add ''

  local ws_keys = {}
  for i, ws in ipairs(workspaces) do
    local k = keys:sub(i, i)
    ws_keys[k] = ws
    local name = vim.fn.fnamemodify(ws.root, ':t')
    local line = pad .. k .. gap .. ws.stack.icon .. name .. '  (' .. ws.stack.name .. ')'
    add(line)
    add_hl('RosakitKey', ln - 1, #pad, #pad + 1)
    add_hl('RosakitStack', ln - 1, #pad + 1 + #gap, -1)
  end

  add ''

  local buf, win = create_float {
    title = ' Rosakit',
    footer = 'q: close',
    width = 56,
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
  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)

  for k, ws in pairs(ws_keys) do
    vim.keymap.set('n', k, function()
      close()
      vim.schedule(function()
        on_select(ws)
      end)
    end, kopts)
  end
end

--- Show sections popup for a stack
--- @param stack table
--- @param available_sections { section: table, key: string }[]
--- @param on_select fun(section: table)
--- @param lsp_tools { label: string, cmd: string, icon: string }[]|nil
--- @param on_tool fun(tool: table)|nil
function M.sections_popup(stack, available_sections, on_select, lsp_tools, on_tool)
  setup_highlights()

  local pad = '         '
  local gap = '     '

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

  -- Top separator
  add(pad .. string.rep('─', 40), 'RosakitDim')

  -- Pick a mnemonic key for a label (first letter of each word, then fallback)
  local used_keys = { q = true } -- reserve q for close
  local function pick_key(label)
    -- Try first letter of the label
    local first = label:sub(1, 1):lower()
    if not used_keys[first] then
      used_keys[first] = true
      return first
    end
    -- Try first letter of each word
    for word in label:gmatch '%S+' do
      local c = word:sub(1, 1):lower()
      if c:match '%a' and not used_keys[c] then
        used_keys[c] = true
        return c
      end
    end
    -- Fallback: any letter in the label
    for i = 1, #label do
      local c = label:sub(i, i):lower()
      if c:match '%a' and not used_keys[c] then
        used_keys[c] = true
        return c
      end
    end
    -- Last resort: any free letter
    for i = 1, 26 do
      local c = string.char(96 + i)
      if not used_keys[c] then
        used_keys[c] = true
        return c
      end
    end
    return nil
  end

  -- Sections
  local key_map = {}
  for _, entry in ipairs(available_sections) do
    local s = entry.section
    local k = pick_key(s.label)
    if not k then
      break
    end
    key_map[k] = { type = 'section', data = s }

    local line = pad .. k .. gap .. s.icon .. ' ' .. s.label
    add(line)
    add_hl('RosakitKey', ln - 1, #pad, #pad + #k)
    add_hl('RosakitSection', ln - 1, #pad + #k + #gap, -1)
  end

  -- LSP tools
  if lsp_tools and #lsp_tools > 0 then
    add(pad .. string.rep('─', 40), 'RosakitDim')
    add(pad .. 'LSP Tools', 'RosakitDim')

    for _, tool in ipairs(lsp_tools) do
      local k = pick_key(tool.label)
      if not k then
        break
      end
      key_map[k] = { type = 'tool', data = tool }

      local line = pad .. k .. gap .. tool.icon .. ' ' .. tool.label
      add(line)
      add_hl('RosakitKey', ln - 1, #pad, #pad + #k)
      add_hl('RosakitTool', ln - 1, #pad + #k + #gap, -1)
    end
  end

  add ''

  local buf, win = create_float {
    title = '  Rosakit ' .. stack.icon .. stack.name,
    footer = 'q: close',
    width = 58,
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
  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)

  for k, entry in pairs(key_map) do
    vim.keymap.set('n', k, function()
      close()
      vim.schedule(function()
        if entry.type == 'section' then
          on_select(entry.data)
        elseif entry.type == 'tool' and on_tool then
          on_tool(entry.data)
        end
      end)
    end, kopts)
  end
end

return M

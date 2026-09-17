--- Rosakit UI - Floating popups for language tools
local M = {}

local menu = require 'rosavim.helpers.rosa_menu'

local function setup_highlights()
  require('rosavim.helpers.palette').define('Rosakit', function(p)
    return {
      Title = { fg = p.title, bold = true },
      Border = { fg = p.border },
      Key = { fg = p.key, bold = true },
      Section = { fg = p.green },
      Tool = { fg = p.yellow },
      Dim = { fg = p.dim },
      Stack = { fg = p.pink, bold = true },
      Action = { fg = p.teal },
    }
  end)
end

--- Open a centered rosakit menu (adds this plugin's title/footer padding)
local function open_menu(opts)
  opts.title = ' ' .. (opts.title or 'Rosakit') .. ' '
  if opts.footer then
    opts.footer = ' ' .. opts.footer .. ' '
  end
  opts.hl_prefix = 'Rosakit'
  opts.filetype = 'rosakit'
  return menu.open(opts)
end

--- Show workspace selector (for monorepos)
--- @param workspaces { root: string, stack: table }[]
--- @param on_select fun(ws: { root: string, stack: table })
function M.workspace_popup(workspaces, on_select)
  setup_highlights()

  local pad = '       '
  local gap = '    '
  local key_chars = 'abcdefghijlmnopqrstuvwxyz'

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl

  add(pad .. 'Select workspace', 'RosakitDim')
  add(pad .. string.rep('─', 36), 'RosakitDim')
  add ''

  local ws_keys = {}
  for i, ws in ipairs(workspaces) do
    local k = key_chars:sub(i, i)
    ws_keys[k] = ws
    local name = vim.fn.fnamemodify(ws.root, ':t')
    local line = pad .. k .. gap .. ws.stack.icon .. name .. '  (' .. ws.stack.name .. ')'
    add(line)
    add_hl('RosakitKey', b.line(), #pad, #pad + 1)
    add_hl('RosakitStack', b.line(), #pad + 1 + #gap, -1)
  end

  add ''

  local keys = {}
  for k, ws in pairs(ws_keys) do
    table.insert(keys, {
      'n',
      k,
      function(ctx)
        ctx.close()
        vim.schedule(function()
          on_select(ws)
        end)
      end,
    })
  end

  open_menu {
    title = ' Rosakit',
    footer = 'q: close',
    width = 56,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    keys = keys,
  }
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

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl

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
    add_hl('RosakitKey', b.line(), #pad, #pad + #k)
    add_hl('RosakitSection', b.line(), #pad + #k + #gap, -1)
  end

  -- LSP tools
  if lsp_tools and #lsp_tools > 0 then
    add(pad .. string.rep('─', 40), 'RosakitDim')
    add(pad .. 'Tools', 'RosakitDim')

    for _, tool in ipairs(lsp_tools) do
      local k = pick_key(tool.label)
      if not k then
        break
      end
      key_map[k] = { type = 'tool', data = tool }

      local line = pad .. k .. gap .. tool.icon .. ' ' .. tool.label
      add(line)
      add_hl('RosakitKey', b.line(), #pad, #pad + #k)
      add_hl('RosakitTool', b.line(), #pad + #k + #gap, -1)
    end
  end

  add ''

  local keys = {}
  for k, entry in pairs(key_map) do
    table.insert(keys, {
      'n',
      k,
      function(ctx)
        ctx.close()
        vim.schedule(function()
          if entry.type == 'section' then
            on_select(entry.data)
          elseif entry.type == 'tool' and on_tool then
            on_tool(entry.data)
          end
        end)
      end,
    })
  end

  open_menu {
    title = '  Rosakit ' .. stack.icon .. stack.name,
    footer = 'q: close',
    width = 58,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    keys = keys,
  }
end

return M

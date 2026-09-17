--- Rosapoon - File bookmarking for Rosavim
local M = {}

local store = require 'rosavim.helpers.json_store'

local cache_dir = vim.fn.stdpath 'cache'
local cache_file = cache_dir .. '/rosapoon.json'

M._state = nil

--- Get the git root for the current directory (used as scope key).
--- Cached per cwd: this runs on every incline render, so it must not fork.
local scope_cache = {}

--- @return string
local function get_scope()
  local cwd = vim.fn.getcwd()
  local cached = scope_cache[cwd]
  if cached ~= nil then
    return cached
  end
  local root = vim.fs.root(cwd, '.git') or cwd
  scope_cache[cwd] = root
  return root
end

--- Load all scopes from cache
--- @return table
local function load_all()
  if M._state then
    return M._state
  end
  M._state = store.load(cache_file, {})
  return M._state
end

--- Save all scopes to cache
local function save_all()
  store.save(cache_file, M._state)
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
    Snacks.notify.warn 'Rosapoon: no file to tag'
    return
  end

  local tags = get_tags()
  for i, tag in ipairs(tags) do
    if tag == file then
      table.remove(tags, i)
      set_tags(tags)
      Snacks.notify.info 'Rosapoon: untagged'
      return
    end
  end

  table.insert(tags, file)
  set_tags(tags)
  Snacks.notify.info('Rosapoon: tagged [' .. #tags .. ']')
end

--- Select a tag by index
--- @param index number
function M.select(index)
  local tags = get_tags()
  if index < 1 or index > #tags then
    Snacks.notify.info('Rosapoon: no tag at index ' .. index)
    return
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(tags[index]))
end

--- Cycle through tags
--- @param direction "next"|"prev"
function M.cycle(direction)
  local tags = get_tags()
  if #tags == 0 then
    Snacks.notify.info 'Rosapoon: no tags'
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
  local menu = require 'rosavim.helpers.rosa_menu'
  local tags = get_tags()
  local scope = get_scope()
  local scope_name = vim.fn.fnamemodify(scope, ':t')
  local current_file = vim.fn.expand '%:p'

  require('rosavim.helpers.palette').define('Rosapoon', function(p)
    return {
      Title = { fg = p.title, bold = true },
      Border = { fg = p.border },
      Idx = { fg = p.key, bold = true },
      File = { fg = p.text },
      Active = { fg = p.green, bold = true },
      ActiveIdx = { fg = p.green, bold = true },
      Dim = { fg = p.dim },
      Danger = { fg = p.red },
      Hint = { fg = p.dim, italic = true },
    }
  end)

  local pad = '   '
  local gap = '  '

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl
  local tag_line_map = {} -- line index -> tag index

  if #tags == 0 then
    add ''
    add(pad .. 'No tags yet.')
    add_hl('RosapoonDim', b.line(), 0, -1)
    add ''
    add(pad .. 'Press  o  to tag the current file')
    add_hl('RosapoonIdx', b.line(), #pad + 7, #pad + 8)
    add_hl('RosapoonDim', b.line(), 0, #pad + 7)
    add_hl('RosapoonDim', b.line(), #pad + 8, -1)
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

      add(pad .. idx_str .. gap .. rel .. marker)
      tag_line_map[b.line()] = i

      local idx_hl = is_active and 'RosapoonActiveIdx' or 'RosapoonIdx'
      local file_hl = is_active and 'RosapoonActive' or 'RosapoonFile'

      add_hl(idx_hl, b.line(), #pad, #pad + #idx_str)
      add_hl(file_hl, b.line(), #pad + #idx_str + #gap, -1)
    end
    add ''

    -- Separator
    add(pad .. string.rep('─', 40))
    add_hl('RosapoonDim', b.line(), 0, -1)

    -- Help
    add(pad .. '<CR>  jump    dd  remove    DD  remove all    o  tag current')
    add_hl('RosapoonIdx', b.line(), #pad, #pad + 4)
    add_hl('RosapoonHint', b.line(), #pad + 4, #pad + 14)
    add_hl('RosapoonDanger', b.line(), #pad + 14, #pad + 16)
    add_hl('RosapoonHint', b.line(), #pad + 16, #pad + 28)
    add_hl('RosapoonDanger', b.line(), #pad + 28, #pad + 30)
    add_hl('RosapoonHint', b.line(), #pad + 30, #pad + 46)
    add_hl('RosapoonIdx', b.line(), #pad + 46, #pad + 47)
    add_hl('RosapoonHint', b.line(), #pad + 47, -1)
    add ''
  end

  local width = 56
  for _, l in ipairs(b.lines) do
    if #l + 6 > width then
      width = math.min(#l + 6, 80)
    end
  end

  local function refresh(ctx)
    ctx.close()
    vim.schedule(function()
      M.toggle_tags()
    end)
  end

  local function tag_at_cursor(ctx)
    local cursor = vim.api.nvim_win_get_cursor(ctx.win)
    return tag_line_map[cursor[1] - 1]
  end

  local keys = {
    -- Enter to jump to file under cursor
    {
      'n',
      '<CR>',
      function(ctx)
        local tag_idx = tag_at_cursor(ctx)
        if not tag_idx then
          return
        end
        ctx.close()
        vim.cmd('edit ' .. vim.fn.fnameescape(tags[tag_idx]))
      end,
    },
    -- dd to remove tag under cursor
    {
      'n',
      'dd',
      function(ctx)
        local tag_idx = tag_at_cursor(ctx)
        if not tag_idx then
          return
        end
        table.remove(tags, tag_idx)
        set_tags(tags)
        refresh(ctx)
      end,
    },
    -- d in visual mode to remove selected tags
    {
      'v',
      'd',
      function(ctx)
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
        refresh(ctx)
      end,
    },
    -- DD to remove all tags
    {
      'n',
      'DD',
      function(ctx)
        set_tags {}
        refresh(ctx)
      end,
    },
    -- o to tag current file
    {
      'n',
      'o',
      function(ctx)
        if current_file == '' then
          return
        end
        -- Skip when the file already carries a tag
        for _, tag in ipairs(tags) do
          if tag == current_file then
            Snacks.notify.info 'Rosapoon: already tagged'
            return
          end
        end
        table.insert(tags, current_file)
        set_tags(tags)
        refresh(ctx)
      end,
    },
  }

  local ctx = menu.open {
    title = ' 󰛢 Rosapoon [' .. scope_name .. '] ',
    footer = ' q: close ',
    width = width,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    hl_prefix = 'Rosapoon',
    filetype = 'rosapoon',
    cursorline = true,
    keys = keys,
  }

  -- Place cursor on first tag line
  if #tags > 0 then
    vim.api.nvim_win_set_cursor(ctx.win, { 2, 0 })
  end
end

--- Open tags in Snacks picker
function M.picker()
  local tags = get_tags()
  if #tags == 0 then
    Snacks.notify.info 'Rosapoon: no tags'
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

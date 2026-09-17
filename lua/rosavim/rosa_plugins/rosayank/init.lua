--- Rosayank - Yank history with persistence for Rosavim
local M = {}

local store = require 'rosavim.helpers.json_store'

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
  local decoded = store.load(cache_file, nil)
  if decoded then
    history = decoded
  end
end

--- Save history to cache file
local function save()
  store.save(cache_file, history)
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
      vim.hl.on_yank { timeout = 150 }

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

  local menu = require 'rosavim.helpers.rosa_menu'

  require('rosavim.helpers.palette').define('Rosayank', function(p)
    return {
      Title = { fg = p.title, bold = true },
      Border = { fg = p.border },
      Idx = { fg = p.key, bold = true },
      Text = { fg = p.text },
      Dim = { fg = p.dim },
      Danger = { fg = p.red },
      Hint = { fg = p.dim, italic = true },
    }
  end)

  local pad = '   '
  local gap = '  '

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl
  local entry_line_map = {} -- line index -> history index

  if #history == 0 then
    add ''
    add(pad .. 'No yanks yet.')
    add_hl('RosayankDim', b.line(), 0, -1)
    add ''
  else
    add ''
    for i, entry in ipairs(history) do
      local preview = entry.text:gsub('\n', '↵ '):sub(1, 60)
      local idx_str = tostring(i)

      add(pad .. idx_str .. gap .. preview)
      entry_line_map[b.line()] = i

      add_hl('RosayankIdx', b.line(), #pad, #pad + #idx_str)
      add_hl('RosayankText', b.line(), #pad + #idx_str + #gap, -1)
    end
    add ''

    -- Separator
    add(pad .. string.rep('─', 40))
    add_hl('RosayankDim', b.line(), 0, -1)

    -- Help
    add(pad .. '<CR>  paste    dd  remove    DD  clear all')
    add_hl('RosayankIdx', b.line(), #pad, #pad + 4)
    add_hl('RosayankHint', b.line(), #pad + 4, #pad + 15)
    add_hl('RosayankDanger', b.line(), #pad + 15, #pad + 17)
    add_hl('RosayankHint', b.line(), #pad + 17, #pad + 29)
    add_hl('RosayankDanger', b.line(), #pad + 29, #pad + 31)
    add_hl('RosayankHint', b.line(), #pad + 31, -1)
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
      M.menu()
    end)
  end

  local function entry_at_cursor(ctx)
    local cursor = vim.api.nvim_win_get_cursor(ctx.win)
    return entry_line_map[cursor[1] - 1]
  end

  local keys = {
    -- Enter to paste entry under cursor
    {
      'n',
      '<CR>',
      function(ctx)
        local entry_idx = entry_at_cursor(ctx)
        if not entry_idx then
          return
        end
        local entry = history[entry_idx]
        ctx.close()
        vim.schedule(function()
          vim.fn.setreg('"', entry.text, entry.regtype)
          vim.api.nvim_put(vim.split(entry.text, '\n', { plain = true }), entry.regtype, true, true)
        end)
      end,
    },
    -- dd to remove entry under cursor
    {
      'n',
      'dd',
      function(ctx)
        local entry_idx = entry_at_cursor(ctx)
        if not entry_idx then
          return
        end
        table.remove(history, entry_idx)
        save()
        refresh(ctx)
      end,
    },
    -- visual d to remove selected entries
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
        refresh(ctx)
      end,
    },
    -- DD to clear all history
    {
      'n',
      'DD',
      function(ctx)
        history = {}
        save()
        refresh(ctx)
      end,
    },
  }

  local ctx = menu.open {
    title = '  Rosayank ',
    footer = ' q: close ',
    width = width,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    hl_prefix = 'Rosayank',
    filetype = 'rosayank',
    cursorline = true,
    keys = keys,
  }

  -- Place cursor on first entry line
  if #history > 0 then
    vim.api.nvim_win_set_cursor(ctx.win, { 2, 0 })
  end
end

--- Clear all history
function M.clear()
  history = {}
  save()
  Snacks.notify.info 'Rosayank: history cleared'
end

return M

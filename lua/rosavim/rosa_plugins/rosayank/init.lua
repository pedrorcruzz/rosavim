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

--- Clear all history
function M.clear()
  history = {}
  save()
  Snacks.notify.info 'Rosayank: history cleared'
end

return M

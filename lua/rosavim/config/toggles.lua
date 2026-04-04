local M = {}

local cache_file = vim.fn.stdpath 'cache' .. '/rosavim-toggles'

local defaults = {
  lualine = true,
  dropbar = false,
  autosave = false,
  tscontext = false,
  spell = false,
  spelllang = 'en',
  relativenumber = true,
  linenumber = true,
  indent = false,
  dim = false,
  wrap = false,
}

M._state = nil

function M._load()
  if M._state then
    return M._state
  end
  local ok, content = pcall(vim.fn.readfile, cache_file)
  if ok and content[1] then
    local decoded = vim.json.decode(content[1])
    if decoded then
      M._state = vim.tbl_deep_extend('force', vim.deepcopy(defaults), decoded)
      return M._state
    end
  end
  M._state = vim.deepcopy(defaults)
  return M._state
end

function M._save()
  local json = vim.json.encode(M._state)
  vim.fn.writefile({ json }, cache_file)
end

function M.get(key)
  local state = M._load()
  return state[key]
end

function M.set(key, value)
  local state = M._load()
  state[key] = value
  M._save()
end

function M.toggle(key)
  local state = M._load()
  state[key] = not state[key]
  M._save()
  return state[key]
end

return M

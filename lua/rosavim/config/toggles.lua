local M = {}

local cache_file = vim.fn.stdpath 'cache' .. '/rosavim-toggles'

local defaults = {
  lualine = true,
  lualine_theme = true,
  dropbar = true,
  autosave = false,
  tscontext = false,
  spell = false,
  spelllang = 'en',
  relativenumber = true,
  linenumber = true,
  indent = true,
  dim = false,
  wrap = false,
  -- Autocmd toggles
  lastpos = false,
  dotenv_syntax = true,
  no_auto_comment = true,
  autosave_focuslost = true,
  snacks_explorer = false,
  snacks_explorer_focus = false,
  lsp_ref_highlights = true,
  dbout_no_folding = true,
  copilot = false,
  incline = true,
  bufferline = true,
  picker_hidden = false,
  picker_ignored = true,
  explorer_right = false,
  sidekick_right = true,
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

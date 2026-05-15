--- Rosadirs Storage - Persists project and obsidian directories on disk
local M = {}

local data_dir = vim.fn.stdpath 'data' .. '/rosadirs'
local config_file = data_dir .. '/config.json'

local function ensure_dir()
  if vim.fn.isdirectory(data_dir) == 0 then
    vim.fn.mkdir(data_dir, 'p')
  end
end

local function defaults()
  return {
    projects = {},
    obsidian = {},
  }
end

--- Load the current config from disk
--- @return { projects: string[], obsidian: string[] }
function M.load()
  ensure_dir()
  if vim.fn.filereadable(config_file) == 0 then
    return defaults()
  end

  local ok, content = pcall(vim.fn.readfile, config_file)
  if not ok or not content or #content == 0 then
    return defaults()
  end

  local ok2, data = pcall(vim.fn.json_decode, table.concat(content, '\n'))
  if not ok2 or type(data) ~= 'table' then
    return defaults()
  end

  data.projects = type(data.projects) == 'table' and data.projects or {}
  data.obsidian = type(data.obsidian) == 'table' and data.obsidian or {}
  return data
end

--- Save config to disk
--- @param data { projects: string[], obsidian: string[] }
function M.save(data)
  ensure_dir()
  local ok, encoded = pcall(vim.fn.json_encode, data)
  if not ok then
    return false, 'failed to encode'
  end
  local ok2, err = pcall(vim.fn.writefile, { encoded }, config_file)
  if not ok2 then
    return false, err
  end
  return true
end

--- Get the path to the config file (useful for diagnostics)
function M.config_path()
  return config_file
end

return M

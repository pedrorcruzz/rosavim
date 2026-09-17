--- Rosadirs Storage - Persists project and obsidian directories on disk
local M = {}

local store = require 'rosavim.helpers.json_store'

local data_dir = vim.fn.stdpath 'data' .. '/rosadirs'
local config_file = data_dir .. '/config.json'

local function ensure_dir()
  if vim.fn.isdirectory(data_dir) == 0 then
    vim.fn.mkdir(data_dir, 'p')
  end
end

--- Load the current config from disk
--- @return { projects: string[], obsidian: string[] }
function M.load()
  ensure_dir()
  local data = store.load(config_file, nil)
  if not data then
    return { projects = {}, obsidian = {} }
  end

  data.projects = type(data.projects) == 'table' and data.projects or {}
  data.obsidian = type(data.obsidian) == 'table' and data.obsidian or {}
  return data
end

--- Save config to disk
--- @param data { projects: string[], obsidian: string[] }
function M.save(data)
  ensure_dir()
  return store.save(config_file, data)
end

--- Get the path to the config file (useful for diagnostics)
function M.config_path()
  return config_file
end

return M

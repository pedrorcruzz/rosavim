--- Rosadirs - Dynamic directory manager for Projects and Obsidian vaults
---
--- Stores user-defined directories in stdpath('data')/rosadirs/config.json
--- so they can be added/removed at runtime without editing plugin files.
local M = {}

local storage = require 'rosavim.rosa_plugins.rosadirs.storage'

local cache = nil

local function data()
  if cache == nil then
    cache = storage.load()
  end
  return cache
end

local function persist()
  if cache then
    storage.save(cache)
  end
end

--- Invalidate the in-memory cache and re-read from disk
function M.reload_cache()
  cache = nil
  return data()
end

--- Build obsidian workspace specs from the configured vault paths
local function build_obsidian_workspaces()
  local vaults = M.obsidian()
  local workspaces = {}
  for i, path in ipairs(vaults) do
    local name = vim.fn.fnamemodify(path, ':t')
    if name == '' or name == '*' then
      name = 'vault-' .. i
    end
    table.insert(workspaces, { name = name, path = path })
  end
  return workspaces
end

--- Apply current rosadirs state to live plugins without restarting Neovim.
---
--- - neovim-project: updates `config.options.projects` in place — next
---   `:NeovimProjectDiscover` reads the new list.
--- - obsidian.nvim: if already loaded, re-runs `Workspace.setup` with the new
---   vaults. If the plugin was never loaded (cond=false at startup because no
---   vaults were configured), a restart is still required for the first vault.
---
--- @return { projects: boolean, obsidian: 'reloaded'|'pending_restart'|'noop' }
function M.apply()
  local status = { projects = false, obsidian = 'noop' }

  local ok_np, np_config = pcall(require, 'neovim-project.config')
  if ok_np and type(np_config.options) == 'table' then
    np_config.options.projects = M.projects()
    status.projects = true
  end

  local workspaces = build_obsidian_workspaces()
  local obsidian_loaded = package.loaded['obsidian'] ~= nil

  if obsidian_loaded and #workspaces > 0 then
    local ok_ob, obsidian = pcall(require, 'obsidian')
    if ok_ob and obsidian.Workspace and obsidian.Workspace.setup then
      local ok_setup = pcall(obsidian.Workspace.setup, workspaces)
      status.obsidian = ok_setup and 'reloaded' or 'pending_restart'
    else
      status.obsidian = 'pending_restart'
    end
  elseif not obsidian_loaded and #workspaces > 0 then
    -- First vault added since startup — plugin was skipped via cond
    status.obsidian = 'pending_restart'
  elseif obsidian_loaded and #workspaces == 0 then
    -- Plugin loaded but list cleared in this session — can't unload mid-session
    status.obsidian = 'pending_restart'
  end

  return status
end

--- Return a copy of the directories for a section
--- @param section 'projects' | 'obsidian'
--- @return string[]
function M.list(section)
  local d = data()
  return vim.deepcopy(d[section] or {})
end

--- Convenience shortcuts
function M.projects()
  return M.list 'projects'
end

function M.obsidian()
  return M.list 'obsidian'
end

--- Add a directory to a section. Returns true on success, false + reason otherwise.
--- @param section 'projects' | 'obsidian'
--- @param dir string
--- @return boolean ok, string|nil reason
function M.add(section, dir)
  if not dir or dir == '' then
    return false, 'empty path'
  end

  local d = data()
  d[section] = d[section] or {}

  for _, existing in ipairs(d[section]) do
    if existing == dir then
      return false, 'already exists'
    end
  end

  table.insert(d[section], dir)
  persist()
  return true
end

--- Remove a directory by value. Returns true if removed.
--- @param section 'projects' | 'obsidian'
--- @param dir string
function M.remove(section, dir)
  local d = data()
  if not d[section] then
    return false
  end

  for i, existing in ipairs(d[section]) do
    if existing == dir then
      table.remove(d[section], i)
      persist()
      return true
    end
  end
  return false
end

--- Clear all directories in a section
--- @param section 'projects' | 'obsidian'
function M.clear(section)
  local d = data()
  d[section] = {}
  persist()
end

--- Clear everything (projects + obsidian)
function M.clear_all()
  local d = data()
  d.projects = {}
  d.obsidian = {}
  persist()
end

--- Open the management UI
function M.open()
  require('rosavim.rosa_plugins.rosadirs.ui').main_menu()
end

--- Path of the JSON config (for debugging)
function M.config_path()
  return storage.config_path()
end

return M

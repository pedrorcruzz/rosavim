--- Rosakit - Language-aware project navigator for Rosavim
local M = {}

local stacks = require 'rosavim.rosa_plugins.rosakit.stacks'
local ui = require 'rosavim.rosa_plugins.rosakit.ui'

--- Collect files for a section in a given root
--- @param root string
--- @param section table
--- @return string[]
local function collect_files(root, section)
  local files = {}
  local seen = {}

  for _, dir in ipairs(section.dirs) do
    local full_dir = root .. '/' .. dir
    if dir == '.' then
      full_dir = root
    end

    if vim.fn.isdirectory(full_dir) == 1 then
      if section.patterns then
        -- Use glob patterns
        for _, pattern in ipairs(section.patterns) do
          local matches = vim.fn.glob(full_dir .. '/' .. pattern, false, true)
          for _, f in ipairs(matches) do
            if not seen[f] and not f:match 'node_modules' and not f:match 'vendor' and not f:match '%.git/' then
              seen[f] = true
              table.insert(files, f)
            end
          end
        end
      else
        -- Recursively find all files in directory
        local all = vim.fn.globpath(full_dir, '**/*', false, true)
        for _, f in ipairs(all) do
          if
            vim.fn.isdirectory(f) == 0
            and not seen[f]
            and not f:match 'node_modules'
            and not f:match 'vendor'
            and not f:match '%.git/'
          then
            seen[f] = true
            table.insert(files, f)
          end
        end
      end
    end
  end

  return files
end

--- Get sections that actually have files
--- @param root string
--- @param stack table
--- @return { section: table, key: string }[]
local function get_available_sections(root, stack)
  local available = {}
  local keys = 'abcdefghijlmnopqrstuvwxyz'
  local ki = 1

  for _, section in ipairs(stack.sections) do
    -- Quick check: does at least one dir/pattern exist?
    local has_files = false
    for _, dir in ipairs(section.dirs) do
      local full_dir = root .. '/' .. dir
      if dir == '.' then
        full_dir = root
      end
      if vim.fn.isdirectory(full_dir) == 1 then
        if section.patterns then
          for _, pattern in ipairs(section.patterns) do
            if vim.fn.glob(full_dir .. '/' .. pattern) ~= '' then
              has_files = true
              break
            end
          end
        else
          has_files = true
        end
      end
      if has_files then
        break
      end
    end

    if has_files and ki <= #keys then
      table.insert(available, {
        section = section,
        key = keys:sub(ki, ki),
      })
      ki = ki + 1
    end
  end

  return available
end

--- Open section in snacks picker
--- @param root string
--- @param section table
local function open_section_picker(root, section)
  local files = collect_files(root, section)

  if #files == 0 then
    vim.notify('Rosakit: no files found in ' .. section.label, vim.log.levels.INFO)
    return
  end

  -- Make paths relative
  local items = {}
  for _, f in ipairs(files) do
    local rel = f
    if f:sub(1, #root) == root then
      rel = f:sub(#root + 2)
    end
    table.insert(items, { text = rel, file = f })
  end

  table.sort(items, function(a, b)
    return a.text < b.text
  end)

  Snacks.picker {
    title = section.icon .. ' ' .. section.label,
    items = items,
    format = 'file',
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
      end
    end,
  }
end

--- Execute an LSP tool command
--- @param tool table
local function run_lsp_tool(tool)
  if tool.cmd:sub(1, 1) == '!' then
    -- Shell command
    vim.cmd(tool.cmd)
  else
    -- Vim command
    local ok, err = pcall(vim.cmd, tool.cmd)
    if not ok then
      vim.notify('Rosakit: ' .. (err or 'command failed'), vim.log.levels.WARN)
    end
  end
end

--- Show sections for a specific workspace
--- @param ws { root: string, stack: table }
function M.show_sections(ws)
  local available = get_available_sections(ws.root, ws.stack)

  if #available == 0 then
    vim.notify('Rosakit: no sections found for ' .. ws.stack.name, vim.log.levels.INFO)
    return
  end

  ui.sections_popup(ws.stack, available, function(section)
    open_section_picker(ws.root, section)
  end, ws.stack.lsp_tools, function(tool)
    run_lsp_tool(tool)
  end)
end

--- Main entry point
function M.open()
  local root = vim.fn.getcwd()

  -- Force fresh detection (clear cached modules)
  package.loaded['rosavim.rosa_plugins.rosakit.stacks'] = nil
  stacks = require 'rosavim.rosa_plugins.rosakit.stacks'

  local workspaces = stacks.detect_workspaces(root)

  if #workspaces == 0 then
    vim.notify('Rosakit: no stack detected in ' .. vim.fn.fnamemodify(root, ':t'), vim.log.levels.INFO)
    return
  end

  if #workspaces == 1 then
    -- Single stack: go directly to sections
    M.show_sections(workspaces[1])
  else
    -- Multiple stacks (monorepo): show workspace selector first
    ui.workspace_popup(workspaces, function(ws)
      M.show_sections(ws)
    end)
  end
end

--- Run LSP code action from current buffer's language server
function M.lsp_actions()
  vim.lsp.buf.code_action()
end

return M

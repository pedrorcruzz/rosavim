--- Rosaai tools - Registry of supported AI CLI tools
--- Each tool declares its command, icon and the executable name used for
--- availability detection. Only tools whose binary is in $PATH are surfaced.
local M = {}

M.list = {
  {
    name = 'claude',
    label = 'Claude',
    icon = '󰚩',
    cmd = { 'claude' },
    resume = { '--resume' },
    continue = { '--continue' },
    binary = 'claude',
  },
  {
    name = 'claude-yolo',
    label = 'Claude (YOLO)',
    icon = '󰚩',
    cmd = { 'claude', '--dangerously-skip-permissions' },
    resume = { '--resume' },
    continue = { '--continue' },
    binary = 'claude',
  },
  {
    name = 'cursor',
    label = 'Cursor',
    icon = '󰨞',
    cmd = { 'cursor-agent' },
    resume = { '--resume' },
    continue = { '--continue' },
    binary = 'cursor-agent',
  },
  {
    name = 'cursor-yolo',
    label = 'Cursor (YOLO)',
    icon = '󰨞',
    cmd = { 'cursor-agent', '--yolo' },
    resume = { '--resume' },
    continue = { '--continue' },
    binary = 'cursor-agent',
  },
  {
    name = 'openclaude',
    label = 'OpenClaude',
    icon = '󰚩',
    cmd = { 'openclaude' },
    resume = { '--resume' },
    continue = { '--continue' },
    binary = 'openclaude',
  },
  {
    name = 'gemini',
    label = 'Gemini',
    icon = '󰊭',
    cmd = { 'gemini' },
    binary = 'gemini',
  },
}

--- Check if a tool's binary is installed
function M.is_available(tool)
  return vim.fn.executable(tool.binary) == 1
end

--- Return the subset of tools whose binary is available on this machine
function M.available()
  local result = {}
  for _, t in ipairs(M.list) do
    if M.is_available(t) then
      table.insert(result, t)
    end
  end
  return result
end

--- Look up a tool by its name
function M.get(name)
  for _, t in ipairs(M.list) do
    if t.name == name then
      return t
    end
  end
  return nil
end

return M

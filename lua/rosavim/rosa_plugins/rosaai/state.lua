--- Rosaai state - Tracks open terminal sessions per CLI tool
--- A session lives across hide/show: the terminal buffer + job are kept
--- alive so the chat history persists when the user toggles the window.
local M = {}

M.sessions = {} -- name -> { tool, buf, job, started }
M.active = nil -- name of the currently visible session (nil when hidden)
M.win = nil -- shared window id used to render the active session

function M.get(name)
  return M.sessions[name]
end

function M.set(name, session)
  M.sessions[name] = session
end

--- Drop a session and its buffer (called when the underlying job exits)
function M.remove(name)
  local s = M.sessions[name]
  if s and s.buf and vim.api.nvim_buf_is_valid(s.buf) then
    pcall(vim.api.nvim_buf_delete, s.buf, { force = true })
  end
  M.sessions[name] = nil
  if M.active == name then
    M.active = nil
  end
end

function M.all()
  return M.sessions
end

--- Iterate sessions whose buffer is still valid
function M.alive()
  local result = {}
  for name, s in pairs(M.sessions) do
    if s.buf and vim.api.nvim_buf_is_valid(s.buf) then
      result[name] = s
    end
  end
  return result
end

return M

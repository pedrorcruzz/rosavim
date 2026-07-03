--- RosaAI state - Tracks open terminal sessions and their visible slots
--- A session lives across hide/show: the terminal buffer + job are kept
--- alive so the chat history persists when the user toggles the window.
--- Each layout position (right/left/bottom/float) is an independent SLOT
--- that can render one session, so several CLIs can be visible at once
--- (e.g. Claude pinned right while Cursor sits at the bottom).
local M = {}

local api = vim.api

M.sessions = {} -- name -> { tool, buf, job, started }
M.slots = {} -- pos -> { win, name } — one visible CLI per layout position
M.active = nil -- name of the most-recently-focused visible session (compat)
M.win = nil -- window id of the most-recently-focused slot (compat)

function M.get(name)
  return M.sessions[name]
end

function M.set(name, session)
  M.sessions[name] = session
end

--- Drop a session and its buffer (called when the underlying job exits or
--- when the user kills a CLI). Also clears any slot that was showing it.
function M.remove(name)
  local s = M.sessions[name]
  if s and s.buf and api.nvim_buf_is_valid(s.buf) then
    pcall(api.nvim_buf_delete, s.buf, { force = true })
  end
  M.sessions[name] = nil
  for pos, sl in pairs(M.slots) do
    if sl.name == name then
      M.slots[pos] = nil
    end
  end
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
    if s.buf and api.nvim_buf_is_valid(s.buf) then
      result[name] = s
    end
  end
  return result
end

--- The slot record ({ win, name }) at a position, if its window is valid.
function M.slot(pos)
  local sl = M.slots[pos]
  if sl and sl.win and api.nvim_win_is_valid(sl.win) then
    return sl
  end
  return nil
end

function M.set_slot(pos, win, name)
  M.slots[pos] = { win = win, name = name }
end

function M.clear_slot(pos)
  M.slots[pos] = nil
end

--- Position currently showing `name` (with a valid window), or nil.
function M.pos_of(name)
  for pos, sl in pairs(M.slots) do
    if sl.name == name and sl.win and api.nvim_win_is_valid(sl.win) then
      return pos
    end
  end
  return nil
end

--- Position hosting a given window id, or nil.
function M.pos_of_win(win)
  for pos, sl in pairs(M.slots) do
    if sl.win == win and api.nvim_win_is_valid(sl.win) then
      return pos
    end
  end
  return nil
end

--- Run fn(pos, win, name) for every slot with a valid window; prunes stale ones.
function M.each_slot(fn)
  for pos, sl in pairs(M.slots) do
    if sl.win and api.nvim_win_is_valid(sl.win) then
      fn(pos, sl.win, sl.name)
    else
      M.slots[pos] = nil
    end
  end
end

--- Whether any slot is currently visible.
function M.any_visible()
  for _, sl in pairs(M.slots) do
    if sl.win and api.nvim_win_is_valid(sl.win) then
      return true
    end
  end
  return false
end

return M

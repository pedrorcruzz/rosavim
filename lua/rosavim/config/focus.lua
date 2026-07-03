--- Directional window focus with float fallback.
--- `wincmd h/j/k/l` only navigates between regular splits — when the cursor
--- can't move in the requested direction, fall back to the RosaAI CLI float
--- if it's open on that side, so <leader>1..4 can reach the float too.
local M = {}

local cmd_for = { h = 'wincmd h', j = 'wincmd j', k = 'wincmd k', l = 'wincmd l' }

local function rosaai_state()
  local ok, state = pcall(require, 'rosavim.rosa_plugins.rosaai.state')
  if not ok then
    return nil
  end
  return state
end

local function position_matches(dir, pos)
  if pos == 'float' then
    return true
  end
  if dir == 'l' and pos == 'right' then
    return true
  end
  if dir == 'h' and pos == 'left' then
    return true
  end
  if dir == 'j' and pos == 'bottom' then
    return true
  end
  return false
end

function M.go(dir)
  local before = vim.api.nvim_get_current_win()
  vim.cmd(cmd_for[dir])
  local after = vim.api.nvim_get_current_win()
  if before ~= after then
    return
  end

  -- No split to move into that way — fall back to a RosaAI slot pinned on
  -- that side, if one is open (so <leader>1..4 can reach the floats too).
  local state = rosaai_state()
  if not state then
    return
  end
  local target
  state.each_slot(function(pos, win)
    if win ~= before and position_matches(dir, pos) then
      target = target or win
    end
  end)
  if target then
    pcall(vim.api.nvim_set_current_win, target)
    if vim.bo[vim.api.nvim_win_get_buf(target)].buftype == 'terminal' then
      vim.cmd 'startinsert'
    end
  end
end

return M

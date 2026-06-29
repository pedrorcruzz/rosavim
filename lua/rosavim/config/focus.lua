--- Directional window focus with float fallback.
--- `wincmd h/j/k/l` only navigates between regular splits — when the cursor
--- can't move in the requested direction, fall back to the Rosaai CLI float
--- if it's open on that side, so <leader>1..4 can reach the float too.
local M = {}

local cmd_for = { h = 'wincmd h', j = 'wincmd j', k = 'wincmd k', l = 'wincmd l' }

local function rosaai_position()
  local ok, layout = pcall(require, 'rosavim.rosa_plugins.rosaai.layout')
  if not ok then
    return nil
  end
  return layout.current_position()
end

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

  local pos = rosaai_position()
  if not pos or not position_matches(dir, pos) then
    return
  end
  local state = rosaai_state()
  if not state or not state.win or not vim.api.nvim_win_is_valid(state.win) then
    return
  end
  if state.win == before then
    return
  end
  pcall(require('rosavim.rosa_plugins.rosaai').focus)
end

return M

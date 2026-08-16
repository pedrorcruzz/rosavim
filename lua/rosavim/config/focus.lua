--- Directional window focus with panel-float fallback.
--- `wincmd h/j/k/l` only navigates the native window tree — the Rosaterm and
--- RosaAI panels are floats (`relative = 'editor'`), so they are invisible to
--- it, and from inside a float it lands on an arbitrary editor window. When
--- the native move can't reach the right window, fall back to a geometric
--- pick over every focusable panel/editor window, so focus walks
--- editor -> panel and panel -> panel (two Rosaterm side by side).
local M = {}

local api = vim.api

local cmd_for = { h = 'wincmd h', j = 'wincmd j', k = 'wincmd k', l = 'wincmd l' }

--- panel_reserve spacers are invisible layout-only splits parked under a
--- float; landing on one looks like "focus jumped nowhere".
local function is_spacer(buf)
  return vim.bo[buf].filetype == 'rosa_spacer'
end

--- A float only counts as a navigation target when it's one of our panels
--- (Rosaterm / RosaAI) or a terminal. Anything else floating — completion
--- menus, hovers, notifications — must never steal a directional move.
local function float_is_panel(buf)
  local ft = vim.bo[buf].filetype
  return ft:sub(1, 8) == 'rosaterm' or ft:sub(1, 6) == 'rosaai' or vim.bo[buf].buftype == 'terminal'
end

local function rect(win)
  local pos = api.nvim_win_get_position(win)
  return {
    win = win,
    top = pos[1],
    left = pos[2],
    height = api.nvim_win_get_height(win),
    width = api.nvim_win_get_width(win),
  }
end

--- Every window worth focusing, as rects.
local function candidates(cur)
  local out = {}
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local ok, cfg = pcall(api.nvim_win_get_config, win)
    local buf = ok and api.nvim_win_get_buf(win) or nil
    if ok and buf and win ~= cur and cfg.focusable ~= false and not is_spacer(buf) then
      local floating = cfg.relative ~= nil and cfg.relative ~= ''
      if not floating or float_is_panel(buf) then
        out[#out + 1] = rect(win)
      end
    end
  end
  return out
end

--- Overlap on the axis perpendicular to the move, so a right-hand panel that
--- sits in a different row band isn't picked over the one beside the cursor.
local function overlaps(a, b, dir)
  if dir == 'h' or dir == 'l' then
    return a.top < b.top + b.height and b.top < a.top + a.height
  end
  return a.left < b.left + b.width and b.left < a.left + a.width
end

--- Is `c` on the `dir` side of `from`, and how far? `adjacent` means it starts
--- past the current window's far edge — a real neighbour. Centers alone aren't
--- enough: the editor is a full-screen window *behind* the panels, so by center
--- it looks like it sits to the right of a left-hand panel.
local function beyond(from, c, dir)
  local fr, fc = from.top + from.height / 2, from.left + from.width / 2
  local cr, cc = c.top + c.height / 2, c.left + c.width / 2
  if dir == 'l' then
    return cc > fc, cc - fc, c.left >= from.left + from.width
  elseif dir == 'h' then
    return cc < fc, fc - cc, c.left + c.width <= from.left
  elseif dir == 'j' then
    return cr > fr, cr - fr, c.top >= from.top + from.height
  end
  return cr < fr, fr - cr, c.top + c.height <= from.top
end

--- Cursor cell (0-based, screen grid) to break ties between two candidates
--- lying the same way — moving down should land on the panel under the
--- cursor, not on whichever window the tabpage lists first.
local function cursor_cell(from)
  -- win_screenpos/winline/wincol are all 1-based; nvim_win_get_position is 0-based.
  local ok, pos = pcall(vim.fn.win_screenpos, from.win)
  if ok and pos and pos[1] > 0 then
    return pos[1] + vim.fn.winline() - 2, pos[2] + vim.fn.wincol() - 2
  end
  return from.top + from.height / 2, from.left + from.width / 2
end

--- How far the cursor sits from `c` on the axis perpendicular to the move
--- (0 when it's already within the candidate's span).
local function perp_gap(c, dir, crow, ccol)
  local lo, hi, at
  if dir == 'h' or dir == 'l' then
    lo, hi, at = c.top, c.top + c.height, crow
  else
    lo, hi, at = c.left, c.left + c.width, ccol
  end
  return math.max(0, lo - at, at - hi)
end

--- Nearest window in `dir`. Ranked: true neighbours first, then windows merely
--- centered that way (a panel overlaying the editor), and anything that
--- doesn't overlap the perpendicular axis last.
local function pick(cur, dir)
  local from = rect(cur)
  local crow, ccol = cursor_cell(from)
  local best, best_score
  for _, c in ipairs(candidates(cur)) do
    local ok, dist, adjacent = beyond(from, c, dir)
    if ok then
      local score = dist + perp_gap(c, dir, crow, ccol) + (adjacent and 0 or 1e3) + (overlaps(from, c, dir) and 0 or 1e5)
      if not best_score or score < best_score then
        best, best_score = c.win, score
      end
    end
  end
  return best
end

local function focus_insert_enabled()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return true
  end
  local v = toggles.get 'rosaterm_focus_insert'
  return v == nil or v
end

local function focus(win)
  pcall(api.nvim_set_current_win, win)
  local buf = api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= 'terminal' then
    return
  end
  if vim.bo[buf].filetype == 'rosaterm' and not focus_insert_enabled() then
    return
  end
  vim.cmd 'startinsert'
end

function M.go(dir)
  local before = api.nvim_get_current_win()
  local cfg = api.nvim_win_get_config(before)
  local floating = cfg.relative ~= nil and cfg.relative ~= ''

  -- From a float the native move is meaningless (it drops the cursor on some
  -- editor window regardless of direction), so go straight to geometry.
  if not floating then
    vim.cmd(cmd_for[dir])
    local after = api.nvim_get_current_win()
    if after ~= before and not is_spacer(api.nvim_win_get_buf(after)) then
      return
    end
    if after ~= before then
      pcall(api.nvim_set_current_win, before) -- landed on a spacer; undo
    end
  end

  local target = pick(before, dir)
  if target then
    focus(target)
  end
end

return M

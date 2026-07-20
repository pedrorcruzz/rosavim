--- panel_reserve - Keep editor text out from under an edge-pinned float panel.
--- Floats don't participate in window layout, so nvim happily draws editor text
--- under a RosaAI/rosaterm float pinned to an edge. Two mechanisms, one per axis:
---   - horizontal panel (bottom) → a real 1-off SPACER split at the very bottom
---     shrinks every editor window so buffer text (even the LAST line at
---     end-of-file) can never render under the float. `scrolloff` alone can't do
---     this: it parks the cursor but cannot reserve rows past EOF, so the final
---     lines slid under the panel. The spacer is invisible (it sits entirely
---     under the float) and its window separator is blanked on the editor side.
---   - vertical panel (right/left) → inflate `sidescrolloff` (reserve columns;
---     only bites with nowrap, so `wrap` is forced off while such a panel is
---     open and restored afterwards). Columns park cleanly at EOL, so the cheap
---     cursor-park is kept here instead of a vsplit spacer.
--- Every mutated window option is saved once and restored when the last claim
--- drops. Both plugins share this module so the behaviour is identical in each
--- (rosaterm + rosaai).
local M = {}

local api = vim.api

-- win -> { sidescrolloff, wrap, fillchars } captured before the first mutate.
local saved = {}
-- id -> { rows = number?, cols = number? } — one active reservation per panel.
local claims = {}
-- When true, M.set/M.clear defer apply() so a batch of updates reflows once.
local batching = false
-- The shared bottom spacer that reserves real rows for horizontal panels.
local spacer = { win = nil, buf = nil }

--- Run `fn` with all autocmds suppressed, restoring `eventignore` even on error.
--- Spacer create/resize/close must not fan out into the panel reflow autocmds
--- (WinNew/WinResized/WinClosed) — the float is `relative='editor'` (absolute),
--- so it needs no reflow when the spacer moves, and suppressing avoids a loop.
local function without_events(fn)
  local save = vim.o.eventignore
  vim.o.eventignore = 'all'
  local ok, err = pcall(fn)
  vim.o.eventignore = save
  if not ok then
    error(err)
  end
end

--- A real editable buffer window: non-float, buftype '' (skips terminals,
--- explorers/nofile, help, quickfix, the spacer, and the panels themselves).
local function is_editor_win(win)
  local ok, cfg = pcall(api.nvim_win_get_config, win)
  if not ok or (cfg.relative and cfg.relative ~= '') then
    return false
  end
  local buf = api.nvim_win_get_buf(win)
  return vim.bo[buf].buftype == ''
end

local function spacer_valid()
  return spacer.win ~= nil and api.nvim_win_is_valid(spacer.win)
end

--- First normal editor window, used as the split base (`botright` splits the
--- whole tabpage bottom, but we still switch to a non-float base first so the
--- `:split` never runs from a floating window).
local function first_editor_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if is_editor_win(w) then
      return w
    end
  end
  return nil
end

local function close_spacer()
  if spacer_valid() then
    without_events(function()
      pcall(api.nvim_win_close, spacer.win, true)
    end)
  end
  spacer.win = nil
end

--- Ensure a bottom spacer of `rows` real rows exists (or is gone when rows<=0).
--- `rows` intentionally over-reserves by ~1 vs the float's outer height so the
--- last editor line always clears the float border. Idempotent: only creates or
--- resizes when the height actually differs, so repeated apply() calls are free.
local function ensure_spacer(rows)
  if rows <= 0 then
    close_spacer()
    return
  end

  if spacer_valid() then
    if api.nvim_win_get_height(spacer.win) ~= rows then
      without_events(function()
        pcall(api.nvim_win_set_height, spacer.win, rows)
      end)
    end
    return
  end

  local base = first_editor_win()
  if not base then
    return -- nothing to reserve against yet
  end

  if not (spacer.buf and api.nvim_buf_is_valid(spacer.buf)) then
    spacer.buf = api.nvim_create_buf(false, true)
    vim.bo[spacer.buf].buftype = 'nofile'
    vim.bo[spacer.buf].bufhidden = 'hide'
    vim.bo[spacer.buf].swapfile = false
    vim.bo[spacer.buf].modifiable = false
    pcall(api.nvim_buf_set_name, spacer.buf, 'rosa://panel-spacer')
  end

  local cur = api.nvim_get_current_win()
  without_events(function()
    api.nvim_set_current_win(base)
    vim.cmd('botright ' .. rows .. 'split')
    spacer.win = api.nvim_get_current_win()
    api.nvim_win_set_buf(spacer.win, spacer.buf)
    vim.wo[spacer.win].winfixheight = true
    vim.wo[spacer.win].number = false
    vim.wo[spacer.win].relativenumber = false
    vim.wo[spacer.win].signcolumn = 'no'
    vim.wo[spacer.win].cursorline = false
    vim.wo[spacer.win].statuscolumn = ''
    vim.wo[spacer.win].winhl = 'EndOfBuffer:Normal'
    -- Blank the spacer's own tildes and its side of any separator.
    api.nvim_win_call(spacer.win, function()
      vim.opt_local.fillchars:append { eob = ' ', horiz = ' ', horizup = ' ', horizdown = ' ' }
    end)
    if api.nvim_win_is_valid(cur) then
      api.nvim_set_current_win(cur)
    end
  end)
end

--- The editor side of the spacer separator (`horiz*`) blanked so the boundary is
--- invisible; the float border then reads as the only divider. Preserves every
--- other fillchar the user set.
local function blank_separator(win)
  api.nvim_win_call(win, function()
    vim.opt_local.fillchars:append { horiz = ' ', horizup = ' ', horizdown = ' ' }
  end)
end

--- Recompute the reservation from every active claim and apply it. Horizontal
--- rows drive the bottom spacer; vertical cols drive sidescrolloff+nowrap on
--- each editor window. Idempotent: options are set to max(saved, needed), never
--- accumulated. When both axes drop to zero everything is fully restored.
local function apply()
  local rows, cols = 0, 0
  for _, c in pairs(claims) do
    if c.rows and c.rows > rows then
      rows = c.rows
    end
    if c.cols and c.cols > cols then
      cols = c.cols
    end
  end

  ensure_spacer(rows)

  if rows == 0 and cols == 0 then
    M.release()
    return
  end

  for _, win in ipairs(api.nvim_list_wins()) do
    if is_editor_win(win) then
      if saved[win] == nil then
        saved[win] = {
          sidescrolloff = vim.wo[win].sidescrolloff,
          wrap = vim.wo[win].wrap,
          fillchars = vim.wo[win].fillchars,
        }
      end
      local s = saved[win]
      -- Horizontal: hide the spacer's window separator on the editor side.
      if rows > 0 then
        blank_separator(win)
      else
        vim.wo[win].fillchars = s.fillchars
      end
      -- Vertical: park the cursor `cols` columns before the panel. sidescrolloff
      -- is a no-op with wrap on, so force nowrap while a vertical panel is open.
      if cols > 0 then
        vim.wo[win].wrap = false
        vim.wo[win].sidescrolloff = math.max(s.sidescrolloff, cols)
      else
        vim.wo[win].wrap = s.wrap
        vim.wo[win].sidescrolloff = s.sidescrolloff
      end
    end
  end
end

--- Register/replace a reservation claim. `spec` = { rows = n } and/or
--- { cols = n }; nil/empty drops the claim. Idempotent per id.
function M.set(id, spec)
  if not spec or (not spec.rows and not spec.cols) then
    claims[id] = nil
  else
    claims[id] = spec
  end
  if not batching then
    apply()
  end
end

--- Drop a claim (e.g. its panel closed or became a native split).
function M.clear(id)
  claims[id] = nil
  if not batching then
    apply()
  end
end

--- Derive a claim straight from a window's live geometry. `axis` is
--- 'horizontal' (reserve rows) or 'vertical' (reserve cols). A nil/invalid
--- window or a native split (relative == '') clears the claim — native splits
--- already reserve real space, so no reservation is needed.
function M.track(id, win, axis)
  if not win or not api.nvim_win_is_valid(win) then
    M.clear(id)
    return
  end
  local ok, cfg = pcall(api.nvim_win_get_config, win)
  if not ok or not cfg.relative or cfg.relative == '' then
    M.clear(id)
    return
  end
  local pad = (cfg.border and cfg.border ~= 'none') and 2 or 0
  if axis == 'horizontal' then
    M.set(id, { rows = cfg.height + pad + 1 }) -- inner + border + 1 gap
  else
    M.set(id, { cols = cfg.width + pad + 1 })
  end
end

--- Run `fn` (a burst of set/track/clear calls) and reflow exactly once at the
--- end — avoids an intermediate release()+reinflate flicker when a panel is
--- swapped for another in the same tick.
function M.batch(fn)
  batching = true
  local ok, err = pcall(fn)
  batching = false
  apply()
  if not ok then
    error(err)
  end
end

--- Restore every option we changed, drop the spacer, and forget saved values.
function M.release()
  close_spacer()
  for win, opts in pairs(saved) do
    if api.nvim_win_is_valid(win) then
      pcall(function()
        vim.wo[win].sidescrolloff = opts.sidescrolloff
        vim.wo[win].wrap = opts.wrap
        vim.wo[win].fillchars = opts.fillchars
      end)
    end
  end
  saved = {}
end

local group = api.nvim_create_augroup('RosaPanelReserve', { clear = true })

-- Editor windows opened AFTER a panel is up (a new split, a file open) must also
-- get the reservation, so re-apply whenever a window/buffer appears while any
-- claim is active.
api.nvim_create_autocmd({ 'WinNew', 'BufWinEnter' }, {
  group = group,
  callback = function()
    if next(claims) ~= nil then
      vim.schedule(apply)
    end
  end,
})

-- The spacer is an empty window pinned under the float; never let the cursor
-- rest there. If focus lands on it (e.g. <C-w>j into the bottom), bounce to the
-- previous window, falling back to the window above.
api.nvim_create_autocmd('WinEnter', {
  group = group,
  callback = function()
    if not spacer_valid() or api.nvim_get_current_win() ~= spacer.win then
      return
    end
    vim.schedule(function()
      if not spacer_valid() or api.nvim_get_current_win() ~= spacer.win then
        return
      end
      local prev = vim.fn.win_getid(vim.fn.winnr '#')
      if prev ~= 0 and prev ~= spacer.win and api.nvim_win_is_valid(prev) then
        pcall(api.nvim_set_current_win, prev)
      else
        pcall(vim.cmd, 'wincmd k')
      end
    end)
  end,
})

-- If the spacer is closed out from under us (e.g. :qa logic, external :close),
-- forget it and re-apply so it is recreated while a claim is still active.
api.nvim_create_autocmd('WinClosed', {
  group = group,
  callback = function(args)
    local closed = tonumber(args.match)
    if closed and spacer.win == closed then
      spacer.win = nil
      if next(claims) ~= nil then
        vim.schedule(apply)
      end
    end
  end,
})

return M

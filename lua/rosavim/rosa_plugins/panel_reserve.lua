--- panel_reserve - Keep editor windows/text out from under an edge-pinned float.
--- Floats don't participate in window layout, so nvim happily draws editor
--- windows (and their text) under a RosaAI/rosaterm float pinned to an edge.
--- The fix, one per axis, is a real but invisible SPACER window that reserves
--- genuine layout space so nvim's own splitting keeps editor windows clear of
--- the float:
---   - horizontal panel (bottom) → a real SPACER split at the very bottom
---     shrinks the editor region so buffer text (even the LAST line at EOF) can
---     never render under the float.
---   - vertical panel (right/left) → a real VSPLIT spacer (`winfixwidth`) on the
---     same edge reserves columns, so a `:vsplit` divides only the remaining
---     editor width instead of extending the new pane under the float.
--- Each spacer sits entirely under the float (invisible) and carries the
--- `rosa_spacer` filetype so the plugins' compute_main_area() skip it. Both
--- plugins share this module so the behaviour is identical in each
--- (rosaterm + rosaai).
local M = {}

local api = vim.api

-- win -> { fillchars } captured before the first mutate (bottom-spacer
-- separator blanking is the only editor-window option we touch).
local saved = {}
-- id -> { rows = n } and/or { cols = n, side = 'left'|'right' } — one active
-- reservation per panel.
local claims = {}
-- When true, M.set/M.clear defer apply() so a batch of updates reflows once.
local batching = false
-- The bottom spacer that reserves real rows for horizontal panels.
local spacer = { win = nil, buf = nil }
-- Left/right spacers that reserve real columns for vertical panels.
local vspacers = { left = { win = nil }, right = { win = nil } }
-- Shared invisible buffer backing every spacer window.
local shared_buf = nil

--- Run `fn` with all autocmds suppressed, restoring `eventignore` even on error.
--- Spacer create/resize/close must not fan out into the panel reflow autocmds
--- (WinNew/WinResized/WinClosed) — the float is `relative='editor'` (absolute),
--- so it needs no reflow when a spacer moves, and suppressing avoids a loop.
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
--- explorers/nofile, help, quickfix, the spacers, and the panels themselves).
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

local function vspacer_valid(side)
  local vs = vspacers[side]
  return vs.win ~= nil and api.nvim_win_is_valid(vs.win)
end

--- True for any of our spacer windows (bottom / left / right).
local function is_spacer_win(win)
  if spacer_valid() and win == spacer.win then
    return true
  end
  return (vspacer_valid 'left' and win == vspacers.left.win) or (vspacer_valid 'right' and win == vspacers.right.win)
end

--- First normal editor window, used as the split base (the edge modifier
--- `botright`/`topleft` decides where the spacer actually lands; we only switch
--- to a non-float base so the `:split` never runs from a floating window).
local function first_editor_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if is_editor_win(w) then
      return w
    end
  end
  return nil
end

--- Bottom-most editor window (largest bottom edge). Base for a `belowright`
--- spacer so it lands at the true bottom of the editor region even when editor
--- windows are stacked.
local function bottom_editor_win()
  local best, best_bottom = nil, -1
  for _, w in ipairs(api.nvim_list_wins()) do
    if is_editor_win(w) then
      local pos = api.nvim_win_get_position(w)
      local bottom = pos[1] + api.nvim_win_get_height(w)
      if bottom > best_bottom then
        best, best_bottom = w, bottom
      end
    end
  end
  return best or first_editor_win()
end

--- Is a full-height side panel (Snacks Explorer, a vertical spacer, etc.)
--- currently docked to the left/right edge? Such a panel is a native split,
--- non-editor buffer, edge-anchored and near full-height. When present, the
--- bottom spacer must NOT be a full-width `botright` split: that restructure
--- steals the panel's bottom rows and shortens it (the explorer "gets cut off"
--- when a horizontal rosaterm opens over an already-open explorer). Instead the
--- bottom spacer is confined to the editor region with `belowright`.
local function has_side_panel()
  local cols = vim.o.columns
  local lines = vim.o.lines - vim.o.cmdheight - 1
  for _, w in ipairs(api.nvim_list_wins()) do
    local ok, cfg = pcall(api.nvim_win_get_config, w)
    if ok and (not cfg.relative or cfg.relative == '') then -- native split
      if not is_editor_win(w) and not (spacer_valid() and w == spacer.win) then
        local pos = api.nvim_win_get_position(w)
        local h = api.nvim_win_get_height(w)
        local width = api.nvim_win_get_width(w)
        local touches_left = pos[2] <= 1
        local touches_right = pos[2] + width >= cols - 1
        if (touches_left or touches_right) and h >= lines * 0.6 then
          return true
        end
      end
    end
  end
  return false
end

--- The shared invisible spacer buffer. `rosa_spacer` filetype lets the plugins'
--- compute_main_area() skip every spacer window (they are layout-only, never a
--- side panel that should slide the floats).
local function get_spacer_buf()
  if not (shared_buf and api.nvim_buf_is_valid(shared_buf)) then
    shared_buf = api.nvim_create_buf(false, true)
    vim.bo[shared_buf].buftype = 'nofile'
    vim.bo[shared_buf].bufhidden = 'hide'
    vim.bo[shared_buf].swapfile = false
    vim.bo[shared_buf].modifiable = false
    vim.bo[shared_buf].filetype = 'rosa_spacer'
    pcall(api.nvim_buf_set_name, shared_buf, 'rosa://panel-spacer')
  end
  return shared_buf
end

--- Common window-local styling for a spacer window. `axis` fixes the size on
--- the reserved dimension so `equalalways` can't redistribute it away.
local function style_spacer_win(win, axis)
  vim.wo[win].winfixheight = axis == 'horizontal'
  vim.wo[win].winfixwidth = axis == 'vertical'
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].cursorline = false
  vim.wo[win].statuscolumn = ''
  vim.wo[win].winhl = 'EndOfBuffer:Normal'
  -- Blank the spacer's own tildes and its side of any separator.
  api.nvim_win_call(win, function()
    vim.opt_local.fillchars:append { eob = ' ', horiz = ' ', horizup = ' ', horizdown = ' ' }
  end)
end

local function close_spacer()
  if spacer_valid() then
    without_events(function()
      pcall(api.nvim_win_close, spacer.win, true)
      -- Freed rows otherwise land entirely on the adjacent pane; re-equalize so
      -- stacked editors reclaim the space evenly. Skip when a side panel is
      -- docked (its height must not be disturbed — mirrors the create guard).
      if not has_side_panel() then
        pcall(vim.cmd, 'wincmd =')
      end
    end)
  end
  spacer.win = nil
end

local function close_vspacer(side)
  if vspacer_valid(side) then
    without_events(function()
      pcall(api.nvim_win_close, vspacers[side].win, true)
      -- Closing the spacer hands its columns to the ONE adjacent editor,
      -- leaving panes lopsided (wide neighbour, narrow rest). Re-equalize so
      -- the reclaimed width is shared evenly — the mirror of the create-time
      -- equalize, so open→close returns to the original balanced layout.
      pcall(vim.cmd, 'wincmd =')
    end)
  end
  vspacers[side].win = nil
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

  local base = bottom_editor_win()
  if not base then
    return -- nothing to reserve against yet
  end

  spacer.buf = get_spacer_buf()

  -- A full-width `botright` split spans the whole tabpage and shortens any open
  -- side panel (Snacks Explorer, a vertical spacer). When a side panel is
  -- docked, confine the spacer to the editor region with `belowright` on the
  -- bottom-most editor window so the panel keeps its full height. With no side
  -- panel, `botright` still spans every editor pane (correct EOF coverage).
  local side_panel = has_side_panel()
  local split_cmd = side_panel and ('belowright ' .. rows .. 'split') or ('botright ' .. rows .. 'split')
  local cur = api.nvim_get_current_win()
  without_events(function()
    api.nvim_set_current_win(base)
    vim.cmd(split_cmd)
    spacer.win = api.nvim_get_current_win()
    api.nvim_win_set_buf(spacer.win, spacer.buf)
    style_spacer_win(spacer.win, 'horizontal')
    -- Same crush as the vertical spacer: the `<rows>split` steals the reserved
    -- rows from the single bottom-most pane. Equalize so stacked editors share
    -- the loss (winfixheight pins the spacer). Skipped when a side panel is
    -- docked — there the spacer is deliberately confined with `belowright` and
    -- equalizing would resize the panel we just took care to preserve.
    if not side_panel then
      pcall(vim.cmd, 'wincmd =')
    end
    if api.nvim_win_is_valid(cur) then
      api.nvim_set_current_win(cur)
    end
  end)
end

--- Ensure a `side` (left/right) vertical spacer of `cols` real columns exists
--- (or is gone when cols<=0). A full-height `topleft`/`botright` vsplit docks it
--- to the correct edge; `winfixwidth` keeps `:vsplit`'s equalization from
--- resizing it, so new editor panes divide only the remaining width.
local function ensure_vspacer(side, cols)
  local vs = vspacers[side]
  if cols <= 0 then
    close_vspacer(side)
    return
  end

  if vspacer_valid(side) then
    if api.nvim_win_get_width(vs.win) ~= cols then
      without_events(function()
        pcall(api.nvim_win_set_width, vs.win, cols)
      end)
    end
    return
  end

  local base = first_editor_win()
  if not base then
    return -- nothing to reserve against yet
  end

  local buf = get_spacer_buf()
  local modifier = side == 'left' and 'topleft' or 'botright'
  local cur = api.nvim_get_current_win()
  without_events(function()
    api.nvim_set_current_win(base)
    vim.cmd(modifier .. ' ' .. cols .. 'vsplit')
    vs.win = api.nvim_get_current_win()
    api.nvim_win_set_buf(vs.win, buf)
    style_spacer_win(vs.win, 'vertical')
    -- A `<cols>vsplit` carves ALL reserved columns out of the single adjacent
    -- editor, crushing it (e.g. 141|50 instead of 96|95) when the panel opens
    -- over pre-existing splits. Equalize so the editor panes share the
    -- remaining width evenly — matching the "open panel first, then split"
    -- flow. winfixwidth pins the spacer at `cols`, so equalization only
    -- redistributes the editor region and never pushes a pane under the float.
    pcall(vim.cmd, 'wincmd =')
    if api.nvim_win_is_valid(cur) then
      api.nvim_set_current_win(cur)
    end
  end)
end

--- The editor side of the bottom spacer separator (`horiz*`) blanked so the
--- boundary is invisible; the float border then reads as the only divider.
--- Preserves every other fillchar the user set.
local function blank_separator(win)
  api.nvim_win_call(win, function()
    vim.opt_local.fillchars:append { horiz = ' ', horizup = ' ', horizdown = ' ' }
  end)
end

--- Recompute the reservation from every active claim and apply it. Horizontal
--- rows drive the bottom spacer; vertical cols drive a per-side vsplit spacer.
--- Idempotent: spacers are created/resized to the needed size, never
--- accumulated. When every axis drops to zero, everything is fully restored.
local function apply()
  local rows, left_cols, right_cols = 0, 0, 0
  for _, c in pairs(claims) do
    if c.rows and c.rows > rows then
      rows = c.rows
    end
    if c.cols then
      if c.side == 'left' then
        if c.cols > left_cols then
          left_cols = c.cols
        end
      elseif c.cols > right_cols then
        right_cols = c.cols
      end
    end
  end

  -- Vertical spacers first, so the bottom spacer sees them as side panels and
  -- confines itself beside them (belowright) instead of spanning underneath.
  ensure_vspacer('right', right_cols)
  ensure_vspacer('left', left_cols)
  ensure_spacer(rows)

  if rows == 0 and left_cols == 0 and right_cols == 0 then
    M.release()
    return
  end

  -- Bottom spacer: hide its window separator on the editor side. (Vertical
  -- spacers keep the normal WinSeparator so the editor↔panel divider — and the
  -- divider between two editor vsplit panes — stay visible.)
  for _, win in ipairs(api.nvim_list_wins()) do
    if is_editor_win(win) then
      if saved[win] == nil then
        saved[win] = { fillchars = vim.wo[win].fillchars }
      end
      if rows > 0 then
        blank_separator(win)
      else
        vim.wo[win].fillchars = saved[win].fillchars
      end
    end
  end
end

--- Register/replace a reservation claim. `spec` = { rows = n } and/or
--- { cols = n, side = 'left'|'right' }; nil/empty drops the claim. Idempotent
--- per id.
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
    -- Reserve exactly the float's outer width so the reserved columns sit under
    -- the float; which edge it docks to is derived from the window's center.
    local pos = api.nvim_win_get_position(win)
    local center = pos[2] + (cfg.width + pad) / 2
    local side = center < vim.o.columns / 2 and 'left' or 'right'
    M.set(id, { cols = cfg.width + pad, side = side })
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

--- Restore every option we changed, drop all spacers, and forget saved values.
function M.release()
  close_spacer()
  close_vspacer 'left'
  close_vspacer 'right'
  for win, opts in pairs(saved) do
    if api.nvim_win_is_valid(win) then
      pcall(function()
        vim.wo[win].fillchars = opts.fillchars
      end)
    end
  end
  saved = {}
end

local group = api.nvim_create_augroup('RosaPanelReserve', { clear = true })

-- Editor windows opened AFTER a panel is up (a new split, a file open) must also
-- respect the reservation, so re-apply whenever a window/buffer appears while any
-- claim is active.
api.nvim_create_autocmd({ 'WinNew', 'BufWinEnter' }, {
  group = group,
  callback = function()
    if next(claims) ~= nil then
      vim.schedule(apply)
    end
  end,
})

-- A spacer is an empty window pinned under the float; never let the cursor rest
-- there. If focus lands on one (e.g. <C-w>j/l into an edge), bounce to the
-- previous window, falling back to the nearest editor window.
api.nvim_create_autocmd('WinEnter', {
  group = group,
  callback = function()
    if not is_spacer_win(api.nvim_get_current_win()) then
      return
    end
    vim.schedule(function()
      if not is_spacer_win(api.nvim_get_current_win()) then
        return
      end
      local prev = vim.fn.win_getid(vim.fn.winnr '#')
      if prev ~= 0 and not is_spacer_win(prev) and api.nvim_win_is_valid(prev) then
        pcall(api.nvim_set_current_win, prev)
      else
        local ed = first_editor_win()
        if ed then
          pcall(api.nvim_set_current_win, ed)
        end
      end
    end)
  end,
})

-- If a spacer is closed out from under us (e.g. :qa logic, external :close),
-- forget it and re-apply so it is recreated while a claim is still active.
api.nvim_create_autocmd('WinClosed', {
  group = group,
  callback = function(args)
    local closed = tonumber(args.match)
    if not closed then
      return
    end
    local dropped = false
    if spacer.win == closed then
      spacer.win = nil
      dropped = true
    end
    for _, side in ipairs { 'left', 'right' } do
      if vspacers[side].win == closed then
        vspacers[side].win = nil
        dropped = true
      end
    end
    if dropped and next(claims) ~= nil then
      vim.schedule(apply)
    end
  end,
})

return M

--- panel_reserve - Keep the cursor out from under an edge-pinned float panel.
--- Floats don't participate in window layout, so nvim happily draws editor
--- text under a RosaAI/rosaterm float pinned to an edge. We can't reserve real
--- columns/rows without a split, but we CAN park the CURSOR before the panel:
---   - horizontal panel (bottom) → inflate `scrolloff`     (reserve rows)
---   - vertical panel (right/left) → inflate `sidescrolloff` (reserve columns;
---     only bites with nowrap, so `wrap` is forced off while such a panel is
---     open and restored afterwards)
--- The buffer can still be scrolled to view any line/column — the cursor just
--- stops before the panel. Every mutated window option is saved once and
--- restored when the last claim drops. Both plugins share this module so the
--- behaviour is identical in each (rosaterm + rosaai).
local M = {}

local api = vim.api

-- win -> { scrolloff, sidescrolloff, wrap } captured before the first inflate.
local saved = {}
-- id -> { rows = number?, cols = number? } — one active reservation per panel.
local claims = {}
-- When true, M.set/M.clear defer apply() so a batch of updates reflows once.
local batching = false

--- A real editable buffer window: non-float, buftype '' (skips terminals,
--- explorers/nofile, help, quickfix, and the panels themselves).
local function is_editor_win(win)
  local ok, cfg = pcall(api.nvim_win_get_config, win)
  if not ok or (cfg.relative and cfg.relative ~= '') then
    return false
  end
  local buf = api.nvim_win_get_buf(win)
  return vim.bo[buf].buftype == ''
end

--- Recompute the reservation from every active claim and apply it to each
--- editor window. Idempotent: scrolloff/sidescrolloff are set to
--- max(saved, needed), never accumulated. When both axes drop to zero the
--- saved options are fully restored.
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

  if rows == 0 and cols == 0 then
    M.release()
    return
  end

  for _, win in ipairs(api.nvim_list_wins()) do
    if is_editor_win(win) then
      if saved[win] == nil then
        saved[win] = {
          scrolloff = vim.wo[win].scrolloff,
          sidescrolloff = vim.wo[win].sidescrolloff,
          wrap = vim.wo[win].wrap,
        }
      end
      local s = saved[win]
      -- Horizontal: park the cursor `rows` lines above the panel.
      vim.wo[win].scrolloff = math.max(s.scrolloff, rows)
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
--- already reserve real space, so no cursor parking is needed.
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

--- Restore every option we changed and forget the saved values.
function M.release()
  for win, opts in pairs(saved) do
    if api.nvim_win_is_valid(win) then
      pcall(function()
        vim.wo[win].scrolloff = opts.scrolloff
        vim.wo[win].sidescrolloff = opts.sidescrolloff
        vim.wo[win].wrap = opts.wrap
      end)
    end
  end
  saved = {}
end

-- Editor windows opened AFTER a panel is up (a new split, a file open) must
-- also get the reservation, so re-apply whenever a window/buffer appears while
-- any claim is active.
api.nvim_create_autocmd({ 'WinNew', 'BufWinEnter' }, {
  group = api.nvim_create_augroup('RosaPanelReserve', { clear = true }),
  callback = function()
    if next(claims) ~= nil then
      vim.schedule(apply)
    end
  end,
})

return M

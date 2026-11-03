local M = {}

local function store()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  return ok and toggles or nil
end

--- The vertical slot (RosaAI 'vertical' mode + Rosaterm vertical splits)
--- is always the OPPOSITE of wherever the explorer currently sits. The
--- explorer's side is the single source of truth (<leader>lasr); this never
--- writes back to it.
function M.vertical()
  local t = store()
  return (t and t.get 'explorer_right') and 'left' or 'right'
end

--- Resolve a stored rosaai_position preference ('vertical' | 'bottom' |
--- 'float', or a legacy literal 'right'/'left') into the concrete slot used
--- for geometry/state. Only 'vertical' is dynamic; bottom/float pass through.
function M.resolve_position(pref)
  if pref == 'right' or pref == 'left' or pref == nil then
    pref = 'vertical'
  end
  if pref == 'vertical' then
    return M.vertical()
  end
  return pref
end

function M.explorer()
  local t = store()
  return (t and t.get 'explorer_right') and 'right' or 'left'
end

local function reopen_explorer()
  local ok, snacks = pcall(require, 'snacks')
  if not ok then
    return
  end
  local pickers = snacks.picker.get { source = 'explorer' }
  if not pickers or #pickers == 0 then
    return
  end
  for _, p in ipairs(pickers) do
    pcall(function()
      p:close()
    end)
  end
  local cur = vim.api.nvim_get_current_win()
  vim.schedule(function()
    pcall(snacks.explorer)
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(cur) then
        pcall(vim.api.nvim_set_current_win, cur)
      end
    end)
  end)
end

function M.apply(opts)
  opts = opts or {}
  pcall(function()
    require('rosavim.rosa_plugins.rosaterm').reload_splits 'vertical'
  end)
  if not opts.skip_rosaai then
    pcall(function()
      require('rosavim.rosa_plugins.rosaai').relayout()
    end)
  end
end

function M.set_explorer(side)
  local t = store()
  if not t then
    return false
  end
  local want = side == 'right'
  if t.get 'explorer_right' == want then
    return false
  end
  t.set('explorer_right', want)
  pcall(function()
    Snacks.config.picker.sources.explorer.layout.layout.position = side
  end)
  reopen_explorer()
  return true
end

--- Set the RosaAI position preference ('vertical' | 'bottom' | 'float').
--- A concrete 'right'/'left' (from a resolved slot, e.g. cli.lua re-syncing
--- after a move) normalizes to 'vertical' — the explorer is never touched
--- here; the vertical slot's actual side is always derived from it.
function M.set_panel(pref, opts)
  local t = store()
  if not t then
    return
  end
  if pref == 'right' or pref == 'left' then
    pref = 'vertical'
  end
  local changed = t.get 'rosaai_position' ~= pref
  t.set('rosaai_position', pref)
  if changed then
    M.apply(opts)
  end
end

return M

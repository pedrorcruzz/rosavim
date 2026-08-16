local M = {}

local function store()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  return ok and toggles or nil
end

local function opposite(side)
  return side == 'right' and 'left' or 'right'
end

function M.vertical()
  local t = store()
  local pos = t and t.get 'rosaai_position'
  if pos == 'right' or pos == 'left' then
    return pos
  end
  return (t and t.get 'explorer_right') and 'left' or 'right'
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

function M.set_panel(side, opts)
  local t = store()
  if not t then
    return
  end
  local changed = t.get 'rosaai_position' ~= side
  t.set('rosaai_position', side)
  if side == 'right' or side == 'left' then
    changed = M.set_explorer(opposite(side)) or changed
  end
  if changed then
    M.apply(opts)
  end
end

return M

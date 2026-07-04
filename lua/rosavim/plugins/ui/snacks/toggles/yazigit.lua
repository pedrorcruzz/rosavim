local toggles = require 'rosavim.config.toggles'
local term_bg = require 'rosavim.rosa_plugins.term_bg'

-- Force-black background for the yazi and lazygit floats, mirroring the
-- rosaterm/rosaai scheme: a light-mode toggle (default on) and a dark-mode
-- toggle (default off). See rosavim.rosa_plugins.term_bg for the mechanism.

--- Apply the current yazi bg override to a specific window.
local function apply_yazi(win)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.wo[win].winhighlight = term_bg.float_winhl('yazi_dark_bg', true, 'RosaYaziNormal')
  end
end

--- Re-apply to every open yazi window (used when toggling live).
local function refresh_yazi()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'yazi' then
      apply_yazi(win)
    end
  end
end

return function()
  -- yazi renders in a floating terminal (filetype 'yazi'); paint its bg on open.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'yazi',
    callback = function(ev)
      apply_yazi(vim.fn.bufwinid(ev.buf))
    end,
  })

  -- Yazi — LIGHT mode (default on)
  Snacks.toggle({
    name = 'Yazi Dark Background (Light Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'yazi_dark_bg'
    end,
    set = function(state)
      toggles.set('yazi_dark_bg', state)
      refresh_yazi()
    end,
  }):map '<leader>layd'

  -- Yazi — DARK mode (default off)
  Snacks.toggle({
    name = 'Yazi Dark Background (Dark Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'yazi_dark_bg_dm'
    end,
    set = function(state)
      toggles.set('yazi_dark_bg_dm', state)
      refresh_yazi()
    end,
  }):map '<leader>layD'

  -- Lazygit — LIGHT mode (default on). Applied at open time (see snacks/keys.lua).
  Snacks.toggle({
    name = 'Lazygit Dark Background (Light Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'lazygit_dark_bg'
    end,
    set = function(state)
      toggles.set('lazygit_dark_bg', state)
    end,
  }):map '<leader>lagd'

  -- Lazygit — DARK mode (default off)
  Snacks.toggle({
    name = 'Lazygit Dark Background (Dark Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'lazygit_dark_bg_dm'
    end,
    set = function(state)
      toggles.set('lazygit_dark_bg_dm', state)
    end,
  }):map '<leader>lagD'
end

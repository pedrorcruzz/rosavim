local toggles = require 'rosavim.config.toggles'
local term_bg = require 'rosavim.helpers.term_bg'

return function()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'yazi',
    callback = function()
      term_bg.define 'yazi'
    end,
  })

  -- All — flips every Force Dark BG switch at once (rosaterm, rosaai, yazi,
  -- lazygit), one per background. Reads as on only while every tool is on, so
  -- it follows the individual toggles instead of keeping its own state.
  Snacks.toggle({
    name = 'Force Dark Background: All (Light Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return term_bg.all_enabled 'light'
    end,
    set = function(state)
      term_bg.set_all('light', state)
    end,
  }):map '<leader>lqfa'

  Snacks.toggle({
    name = 'Force Dark Background: All (Dark Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return term_bg.all_enabled 'dark'
    end,
    set = function(state)
      term_bg.set_all('dark', state)
    end,
  }):map '<leader>lqfA'

  -- Yazi — LIGHT mode (default on)
  Snacks.toggle({
    name = 'Yazi Dark Background (Light Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'yazi_dark_bg'
    end,
    set = function(state)
      toggles.set('yazi_dark_bg', state)
      term_bg.refresh_tool 'yazi'
    end,
  }):map '<leader>lqfy'

  -- Yazi — DARK mode (default off)
  Snacks.toggle({
    name = 'Yazi Dark Background (Dark Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'yazi_dark_bg_dm'
    end,
    set = function(state)
      toggles.set('yazi_dark_bg_dm', state)
      term_bg.refresh_tool 'yazi'
    end,
  }):map '<leader>lqfY'

  Snacks.toggle({
    name = 'Lazygit Dark Background (Light Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'lazygit_dark_bg'
    end,
    set = function(state)
      toggles.set('lazygit_dark_bg', state)
      term_bg.refresh_tool 'lazygit'
    end,
  }):map '<leader>lqfg'

  -- Lazygit — DARK mode (default off)
  Snacks.toggle({
    name = 'Lazygit Dark Background (Dark Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'lazygit_dark_bg_dm'
    end,
    set = function(state)
      toggles.set('lazygit_dark_bg_dm', state)
      term_bg.refresh_tool 'lazygit'
    end,
  }):map '<leader>lqfG'
end

local toggles = require 'rosavim.config.toggles'
local term_bg = require 'rosavim.helpers.term_bg'

return function()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'yazi',
    callback = function()
      term_bg.define 'yazi'
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
      term_bg.define 'yazi'
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
      term_bg.define 'yazi'
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
      term_bg.define 'lazygit'
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
      term_bg.define 'lazygit'
    end,
  }):map '<leader>lqfG'
end

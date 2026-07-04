local toggles = require 'rosavim.config.toggles'

return function()
  -- Title chip (show/hide)
  Snacks.toggle({
    name = 'RosaAI Title',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaai_title'
    end,
    set = function(state)
      toggles.set('rosaai_title', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.refresh_chips()
      end
    end,
  }):map '<leader>laat'

  -- Time inside chip
  Snacks.toggle({
    name = 'RosaAI Time',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaai_time'
    end,
    set = function(state)
      toggles.set('rosaai_time', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.refresh_chips()
      end
    end,
  }):map '<leader>laah'

  -- Auto insert when opening a CLI
  Snacks.toggle({
    name = 'RosaAI Auto Insert',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosaai_autoinsert'
    end,
    set = function(state)
      toggles.set('rosaai_autoinsert', state)
    end,
  }):map '<leader>laai'

  -- Auto focus when sending a message
  Snacks.toggle({
    name = 'RosaAI Auto Focus',
    get = function()
      return toggles.get 'rosaai_auto_focus'
    end,
    set = function(state)
      toggles.set('rosaai_auto_focus', state)
    end,
  }):map '<leader>laaf'

  -- Theme picker (popup) — lives under <leader>lq (Theme group)
  vim.keymap.set('n', '<leader>lqa', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_theme()
  end, { desc = 'RosaAI: Select Theme' })

  -- Position picker (popup)
  vim.keymap.set('n', '<leader>laap', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_position()
  end, { desc = 'RosaAI: Select Position' })

  -- Size picker (popup)
  vim.keymap.set('n', '<leader>laaz', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_size()
  end, { desc = 'RosaAI: Select Size' })

  -- Vertical border (right/left/float)
  Snacks.toggle({
    name = 'RosaAI Vertical Border',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaai_vertical_border'
    end,
    set = function(state)
      toggles.set('rosaai_vertical_border', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.relayout()
      end
    end,
  }):map '<leader>laab'

  -- Horizontal border (bottom)
  Snacks.toggle({
    name = 'RosaAI Horizontal Border',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaai_horizontal_border'
    end,
    set = function(state)
      toggles.set('rosaai_horizontal_border', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.relayout()
      end
    end,
  }):map '<leader>laaB'

  -- Dark bg in LIGHT mode: on = force #000 (default), off = follow theme bg.
  Snacks.toggle({
    name = 'RosaAI Dark Background (Light Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'rosaai_dark_bg'
    end,
    set = function(state)
      toggles.set('rosaai_dark_bg', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.relayout()
      end
    end,
  }):map '<leader>laad'

  -- Dark bg in DARK mode: on = force #000, off = follow theme bg (default off).
  Snacks.toggle({
    name = 'RosaAI Dark Background (Dark Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return toggles.get 'rosaai_dark_bg_dm'
    end,
    set = function(state)
      toggles.set('rosaai_dark_bg_dm', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.relayout()
      end
    end,
  }):map '<leader>laaD'
end

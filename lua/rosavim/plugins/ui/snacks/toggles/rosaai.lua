local toggles = require 'rosavim.config.toggles'

return function()
  -- Title chip (show/hide)
  Snacks.toggle({
    name = 'Rosaai Title',
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
    name = 'Rosaai Time',
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
    name = 'Rosaai Auto Insert',
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
    name = 'Rosaai Auto Focus',
    get = function()
      return toggles.get 'rosaai_auto_focus'
    end,
    set = function(state)
      toggles.set('rosaai_auto_focus', state)
    end,
  }):map '<leader>laaf'

  -- Theme picker (popup)
  vim.keymap.set('n', '<leader>laas', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_theme()
  end, { desc = 'Rosaai: Select Theme' })

  -- Position picker (popup)
  vim.keymap.set('n', '<leader>laap', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_position()
  end, { desc = 'Rosaai: Select Position' })

  -- Size picker (popup)
  vim.keymap.set('n', '<leader>laaz', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_size()
  end, { desc = 'Rosaai: Select Size' })

  -- Vertical border (right/left/float)
  Snacks.toggle({
    name = 'Rosaai Vertical Border',
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
    name = 'Rosaai Horizontal Border',
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
end

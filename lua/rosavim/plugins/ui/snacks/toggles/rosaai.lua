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
  }):map '<leader>lqat'

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
  }):map '<leader>lqah'

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
  }):map '<leader>lqai'

  -- Auto focus when sending a message
  Snacks.toggle({
    name = 'RosaAI Auto Focus',
    get = function()
      return toggles.get 'rosaai_auto_focus'
    end,
    set = function(state)
      toggles.set('rosaai_auto_focus', state)
    end,
  }):map '<leader>lqaf'

  -- Master switch for the whole Review feature (keybinds, badge, auto-open).
  -- When off, <leader>ar / <leader>ab are removed (hidden from which-key) and
  -- no baseline is captured.
  Snacks.toggle({
    name = 'RosaAI Review',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosaai_review'
    end,
    set = function(state)
      toggles.set('rosaai_review', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.apply_review_keymaps()
      end
      local rok, review = pcall(require, 'rosavim.rosa_plugins.rosaai.review')
      if rok then
        if not state and review.is_open() then
          review.close()
        end
        review.refresh_pending()
      end
      if ok and rosaai.refresh_chips then
        rosaai.refresh_chips()
      end
    end,
  }):map '<leader>lqaR'

  -- Auto-open the review panel after the AI edits files
  Snacks.toggle({
    name = 'RosaAI Auto Review',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosaai_auto_review'
    end,
    set = function(state)
      toggles.set('rosaai_auto_review', state)
    end,
  }):map '<leader>lqar'

  -- Show the pending-review count badge on the CLI chip
  Snacks.toggle({
    name = 'RosaAI Review Badge',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaai_review_badge'
    end,
    set = function(state)
      toggles.set('rosaai_review_badge', state)
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.refresh_chips()
      end
    end,
  }):map '<leader>lqac'

  -- Theme picker (popup) — lives under <leader>lq (Theme group)
  vim.keymap.set('n', '<leader>lqas', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_theme()
  end, { desc = 'RosaAI: Select Theme' })

  -- Position picker (popup)
  vim.keymap.set('n', '<leader>lqap', function()
    require('rosavim.rosa_plugins.rosaai.ui').pick_position()
  end, { desc = 'RosaAI: Select Position' })

  -- Size picker (popup)
  vim.keymap.set('n', '<leader>lqaz', function()
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
  }):map '<leader>lqab'

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
  }):map '<leader>lqaB'

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
  }):map '<leader>lqad'

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
  }):map '<leader>lqaD'
end

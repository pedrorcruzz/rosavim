local toggles = require 'rosavim.config.toggles'

return function()
  Snacks.toggle({
    name = 'Rosaterm Theme',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaterm_title'
    end,
    set = function(state)
      toggles.set('rosaterm_title', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_chips()
      end
    end,
  }):map '<leader>latt'

  Snacks.toggle({
    name = 'Rosaterm Time',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaterm_time'
    end,
    set = function(state)
      toggles.set('rosaterm_time', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_chips()
      end
    end,
  }):map '<leader>lath'

  Snacks.toggle({
    name = 'Rosaterm Auto Insert',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosaterm_autoinsert'
    end,
    set = function(state)
      toggles.set('rosaterm_autoinsert', state)
    end,
  }):map '<leader>lati'

  -- Display name: ON = "Rosaterm", OFF = "Terminal"
  Snacks.toggle({
    name = 'Rosaterm Full Name',
    wk_desc = { enabled = 'Use ', disabled = 'Use ' },
    get = function()
      return toggles.get 'rosaterm_name_full'
    end,
    set = function(state)
      toggles.set('rosaterm_name_full', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_chips()
      end
    end,
  }):map '<leader>latn'

  -- Chip icon visibility (show/hide)
  Snacks.toggle({
    name = 'Rosaterm Icon',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaterm_icon_visible'
    end,
    set = function(state)
      toggles.set('rosaterm_icon_visible', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_chips()
      end
    end,
  }):map '<leader>latc'

  -- Chip icon style picker: 'rosa' (󰧱) vs 'terminal' ()
  vim.keymap.set('n', '<leader>lats', function()
    local styles = {
      { name = 'rosa', glyph = '󰧱', label = 'Rosa' },
      { name = 'terminal', glyph = '', label = 'Terminal' }, -- nf-md-console U+F018D
    }
    local current = toggles.get 'rosaterm_icon_style'
    vim.ui.select(styles, {
      prompt = 'Rosaterm · select icon',
      kind = 'rosaterm_icon',
      format_item = function(s)
        local marker = s.name == current and ' ●' or ''
        return s.glyph .. '  ' .. s.label .. marker
      end,
    }, function(choice)
      if not choice then
        return
      end
      toggles.set('rosaterm_icon_style', choice.name)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_chips()
      end
      Snacks.notify.info('Rosaterm icon: ' .. choice.label)
    end)
  end, { desc = 'Rosaterm: Select Icon' })

  -- Vertical border (vsplit). When on, the vertical split becomes a pinned
  -- float with a rounded border. When off, it's a native split (no border).
  Snacks.toggle({
    name = 'Rosaterm Vertical Border',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaterm_vertical_border'
    end,
    set = function(state)
      toggles.set('rosaterm_vertical_border', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.reload_splits 'vertical'
      end
    end,
  }):map '<leader>latb'

  -- Horizontal border (split). Same mechanism — float-pinned when on.
  Snacks.toggle({
    name = 'Rosaterm Horizontal Border',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaterm_horizontal_border'
    end,
    set = function(state)
      toggles.set('rosaterm_horizontal_border', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.reload_splits 'horizontal'
      end
    end,
  }):map '<leader>latB'

  -- Size picker (popup): compact / default / wide — like RosaAI's <leader>laaz
  vim.keymap.set('n', '<leader>latz', function()
    require('rosavim.rosa_plugins.rosaterm').pick_size()
  end, { desc = 'Rosaterm: Select Size' })

  -- Theme selector — uses vim.ui.select so it follows the snacks picker style
  vim.keymap.set('n', '<leader>lqr', function()
    local themes = require 'rosavim.rosa_plugins.rosaterm.themes'
    local current = themes.current().name
    vim.ui.select(themes.list, {
      prompt = 'Rosaterm · select theme',
      kind = 'rosaterm_theme',
      format_item = function(t)
        local marker = t.name == current and ' ●' or ''
        return t.icon .. ' ' .. t.label .. marker
      end,
    }, function(choice)
      if not choice then
        return
      end
      themes.set(choice.name)
      Snacks.notify.info('Rosaterm theme: ' .. choice.label)
    end)
  end, { desc = 'Rosaterm: Select Theme' })
end

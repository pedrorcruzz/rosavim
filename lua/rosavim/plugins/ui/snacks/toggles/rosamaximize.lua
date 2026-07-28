local toggles = require 'rosavim.config.toggles'

local function refresh()
  local ok, rosamaximize = pcall(require, 'rosavim.rosa_plugins.rosamaximize')
  if ok then
    rosamaximize.refresh()
  end
end

return function()
  Snacks.toggle({
    name = 'Rosamaximize Lualine',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosamaximize_lualine'
    end,
    set = function(state)
      toggles.set('rosamaximize_lualine', state)
      refresh()
    end,
  }):map '<leader>laml'

  Snacks.toggle({
    name = 'Rosamaximize Badge',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosamaximize_badge'
    end,
    set = function(state)
      toggles.set('rosamaximize_badge', state)
      refresh()
    end,
  }):map '<leader>lamb'

  -- Display: ON = "max" text + icon, OFF = icon only
  Snacks.toggle({
    name = 'Rosamaximize Name',
    wk_desc = { enabled = 'Icon only ', disabled = 'Show name ' },
    get = function()
      return toggles.get 'rosamaximize_name'
    end,
    set = function(state)
      toggles.set('rosamaximize_name', state)
      refresh()
    end,
  }):map '<leader>lamn'

  -- Badge border picker: none / rounded / straight (persisted)
  vim.keymap.set('n', '<leader>lams', function()
    local borders = {
      { name = 'none', label = 'None', glyph = '󰝤' },
      { name = 'rounded', label = 'Rounded', glyph = '󰐝' },
      { name = 'single', label = 'Straight', glyph = '󰝘' },
    }
    local current = toggles.get 'rosamaximize_border'
    vim.ui.select(borders, {
      prompt = 'Rosamaximize · select border',
      kind = 'rosamaximize_border',
      format_item = function(b)
        return b.glyph .. '  ' .. b.label .. (b.name == current and ' ●' or '')
      end,
    }, function(choice)
      if not choice then
        return
      end
      toggles.set('rosamaximize_border', choice.name)
      refresh()
      Snacks.notify.info('Rosamaximize border: ' .. choice.label)
    end)
  end, { desc = 'Rosamaximize: Select Border' })
end

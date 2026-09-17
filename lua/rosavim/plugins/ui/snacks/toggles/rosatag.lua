local toggles = require 'rosavim.config.toggles'

--- No-op until Rosatag loads: with no html/jsx buffer open there is nothing
--- to re-attach, the new state is read on load.
local function refresh()
  if package.loaded['rosavim.rosa_plugins.rosatag'] then
    require('rosavim.rosa_plugins.rosatag').refresh()
  end
end

return function()
  Snacks.toggle({
    name = 'Rosatag',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosatag'
    end,
    set = function(state)
      toggles.set('rosatag', state)
      refresh()
    end,
  }):map '<leader>lv'

  Snacks.toggle({
    name = 'Rosatag Auto Close Tag',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosatag_close'
    end,
    set = function(state)
      toggles.set('rosatag_close', state)
      refresh()
    end,
  }):map '<leader>latc'

  Snacks.toggle({
    name = 'Rosatag Auto Live Rename Tag',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosatag_rename'
    end,
    set = function(state)
      toggles.set('rosatag_rename', state)
      refresh()
    end,
  }):map '<leader>latr'
end

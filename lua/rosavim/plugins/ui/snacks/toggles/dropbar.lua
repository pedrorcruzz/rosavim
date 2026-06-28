local toggles = require 'rosavim.config.toggles'

return function()
  -- Compact path (parent + filename only). Off = full relative path (default).
  Snacks.toggle({
    name = 'Dropbar Compact Path',
    wk_desc = { enabled = 'Show full ', disabled = 'Show compact ' },
    get = function()
      return toggles.get 'dropbar_compact'
    end,
    set = function(state)
      toggles.set('dropbar_compact', state)
      local ok, dconfigs = pcall(require, 'dropbar.configs')
      if ok then
        dconfigs.opts.sources.path.max_depth = state and 2 or 16
      end
    end,
  }):map '<leader>laud'

  -- Preview file on hover when navigating dropbar
  Snacks.toggle({
    name = 'Dropbar Path Preview',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'dropbar_path_preview'
    end,
    set = function(state)
      toggles.set('dropbar_path_preview', state)
      local ok, dconfigs = pcall(require, 'dropbar.configs')
      if ok then
        dconfigs.opts.sources.path.preview = state
      end
    end,
  }):map '<leader>laup'
end

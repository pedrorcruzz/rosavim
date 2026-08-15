return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosatag',
  name = 'rosatag',
  ft = require('rosavim.rosa_plugins.rosatag.config').filetypes,
  config = function()
    require('rosavim.rosa_plugins.rosatag').setup()
  end,
  -- <leader>kr is buffer-local (set on attach), toggles in snacks/toggles/rosatag.lua
}

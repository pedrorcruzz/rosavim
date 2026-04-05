return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosasave',
  name = 'rosasave',
  event = { 'InsertLeave', 'TextChanged' },
  config = function()
    require('rosavim.rosa_plugins.rosasave').setup()
  end,
  -- Toggle keymap defined in snacks/toggles.lua
}

return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosasave',
  name = 'rosasave',
  -- Only pay for the module when autosave is actually on; the toggle
  -- requires the module directly, so flipping it later still works.
  event = require('rosavim.config.toggles').get 'autosave' and { 'InsertLeave', 'TextChanged' } or nil,
  config = function()
    require('rosavim.rosa_plugins.rosasave').setup()
  end,
  -- Toggle keymap defined in snacks/toggles.lua
}

return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosasave',
  name = 'rosasave',
  event = { 'InsertLeave', 'TextChanged' },
  config = function()
    require('rosavim.rosa_plugins.rosasave').setup()
  end,
  keys = {
    {
      '<leader>ls',
      function()
        local toggles = require 'rosavim.config.toggles'
        local rosasave = require 'rosavim.rosa_plugins.rosasave'
        local new_val = rosasave.toggle()
        toggles.set('autosave', new_val)
        vim.notify('Rosasave: ' .. (new_val and 'On' or 'Off'), vim.log.levels.INFO)
      end,
      desc = 'Rosasave: Toggle',
    },
  },
}

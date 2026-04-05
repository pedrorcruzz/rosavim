return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosasweep',
  name = 'rosasweep',
  event = 'VeryLazy',
  config = function()
    require('rosavim.rosa_plugins.rosasweep').setup()
  end,
}

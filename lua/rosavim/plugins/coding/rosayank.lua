return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosayank',
  name = 'rosayank',
  event = { 'TextYankPost' },
  config = function()
    require('rosavim.rosa_plugins.rosayank').setup()
  end,
  keys = {
    {
      '<leader>p',
      function()
        require('rosavim.rosa_plugins.rosayank').pick()
      end,
      mode = { 'n', 'x' },
      desc = 'Rosayank: History',
    },
  },
}

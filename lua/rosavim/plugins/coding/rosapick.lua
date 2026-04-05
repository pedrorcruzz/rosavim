return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosapick',
  name = 'rosapick',
  lazy = true,
  keys = {
    {
      '<leader>m',
      function()
        require('rosavim.rosa_plugins.rosapick').pick()
      end,
      desc = 'Rosapick',
    },
  },
}

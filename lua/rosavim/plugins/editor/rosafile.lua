return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '<leader>xx',
        function()
          require('rosavim.rosa_plugins.rosafile').open()
        end,
        desc = 'Rosafile: Menu',
      },
      {
        '<leader>xa',
        function()
          require('rosavim.rosa_plugins.rosafile').create_here()
        end,
        desc = 'Rosafile: Create here',
      },
      {
        '<leader>xr',
        function()
          require('rosavim.rosa_plugins.rosafile').create_root()
        end,
        desc = 'Rosafile: Create from root',
      },
      {
        '<leader>xn',
        function()
          require('rosavim.rosa_plugins.rosafile').rename()
        end,
        desc = 'Rosafile: Rename',
      },
      {
        '<leader>xc',
        function()
          require('rosavim.rosa_plugins.rosafile').copy()
        end,
        desc = 'Rosafile: Duplicate',
      },
      {
        '<leader>xi',
        function()
          require('rosavim.rosa_plugins.rosafile').info()
        end,
        desc = 'Rosafile: Info',
      },
      {
        '<leader>xd',
        function()
          require('rosavim.rosa_plugins.rosafile').delete()
        end,
        desc = 'Rosafile: Delete',
      },
    },
  },
}

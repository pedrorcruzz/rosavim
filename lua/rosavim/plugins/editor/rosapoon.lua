return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '<leader>oo',
        function()
          require('rosavim.rosa_plugins.rosapoon').toggle()
        end,
        desc = 'Rosapoon: Pin',
      },
      {
        '<leader>oe',
        function()
          require('rosavim.rosa_plugins.rosapoon').toggle_tags()
        end,
        desc = 'Rosapoon: Menu',
      },
      {
        '<leader>o1',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(1)
        end,
        desc = 'Rosapoon: Jump 1',
      },
      {
        '<leader>o2',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(2)
        end,
        desc = 'Rosapoon: Jump 2',
      },
      {
        '<leader>o3',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(3)
        end,
        desc = 'Rosapoon: Jump 3',
      },
      {
        '<leader>o4',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(4)
        end,
        desc = 'Rosapoon: Jump 4',
      },
      {
        '<leader>o5',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(5)
        end,
        desc = 'Rosapoon: Jump 5',
      },
      {
        '<leader>o6',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(6)
        end,
        desc = 'Rosapoon: Jump 6',
      },
      {
        '<leader>o7',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(7)
        end,
        desc = 'Rosapoon: Jump 7',
      },
      {
        '<leader>o8',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(8)
        end,
        desc = 'Rosapoon: Jump 8',
      },
      {
        '<leader>o9',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(9)
        end,
        desc = 'Rosapoon: Jump 9',
      },
      {
        '<leader>o0',
        function()
          require('rosavim.rosa_plugins.rosapoon').select(10)
        end,
        desc = 'Rosapoon: Jump 10',
      },
      {
        '<leader>of',
        function()
          require('rosavim.rosa_plugins.rosapoon').picker()
        end,
        desc = 'Rosapoon: Search',
      },
      {
        '<leader>oj',
        function()
          require('rosavim.rosa_plugins.rosapoon').cycle 'prev'
        end,
        desc = 'Rosapoon: Prev',
      },
      {
        '<leader>ok',
        function()
          require('rosavim.rosa_plugins.rosapoon').cycle 'next'
        end,
        desc = 'Rosapoon: Next',
      },
    },
  },
}

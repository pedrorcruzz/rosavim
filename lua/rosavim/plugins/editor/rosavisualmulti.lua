return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosavisualmulti',
  name = 'rosavisualmulti',
  lazy = true,
  config = function()
    require('rosavim.rosa_plugins.rosavisualmulti').setup()
  end,
  keys = {
    {
      '<C-n>',
      function()
        require('rosavim.rosa_plugins.rosavisualmulti').find_under()
      end,
      desc = 'Rosavisualmulti: Select Word / Next',
    },
    {
      '<C-Down>',
      function()
        require('rosavim.rosa_plugins.rosavisualmulti').add_down()
      end,
      desc = 'Rosavisualmulti: Cursor Down',
    },
    {
      '<C-Up>',
      function()
        require('rosavim.rosa_plugins.rosavisualmulti').add_up()
      end,
      desc = 'Rosavisualmulti: Cursor Up',
    },
    {
      '<C-n>',
      function()
        require('rosavim.rosa_plugins.rosavisualmulti').from_visual()
      end,
      mode = 'x',
      desc = 'Rosavisualmulti: Cursors From Selection',
    },
    {
      '<leader>kvv',
      function()
        require('rosavim.rosa_plugins.rosavisualmulti').menu()
      end,
      desc = 'Rosavisualmulti: Menu',
    },
    {
      '<leader>kva',
      function()
        require('rosavim.rosa_plugins.rosavisualmulti').select_all()
      end,
      desc = 'Rosavisualmulti: Select All Occurrences',
    },
    {
      '<leader>kvr',
      function()
        require('rosavim.rosa_plugins.rosavisualmulti').rename()
      end,
      desc = 'Rosavisualmulti: Rename Selection',
    },
  },
}

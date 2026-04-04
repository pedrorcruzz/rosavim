return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '<leader>nn',
        function()
          require('rosavim.rosa_plugins.rosatest').open()
        end,
        desc = 'Rosatest: Menu',
      },
      {
        '<leader>nr',
        function()
          require('rosavim.rosa_plugins.rosatest').run_nearest()
        end,
        desc = 'Rosatest: Run Nearest',
      },
      {
        '<leader>nf',
        function()
          require('rosavim.rosa_plugins.rosatest').run_file()
        end,
        desc = 'Rosatest: Run File',
      },
      {
        '<leader>na',
        function()
          require('rosavim.rosa_plugins.rosatest').run_all()
        end,
        desc = 'Rosatest: Run All',
      },
      {
        '<leader>nl',
        function()
          require('rosavim.rosa_plugins.rosatest').run_last()
        end,
        desc = 'Rosatest: Run Last',
      },
      {
        '<leader>ns',
        function()
          require('rosavim.rosa_plugins.rosatest').stop()
        end,
        desc = 'Rosatest: Stop',
      },
      {
        '<leader>no',
        function()
          require('rosavim.rosa_plugins.rosatest').toggle_output()
        end,
        desc = 'Rosatest: Toggle Output',
      },
      {
        '<leader>np',
        function()
          require('rosavim.rosa_plugins.rosatest').pick_test_files()
        end,
        desc = 'Rosatest: Pick Test File',
      },
    },
  },
}

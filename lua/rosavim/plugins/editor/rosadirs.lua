return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '<leader>lp',
        function()
          require('rosavim.rosa_plugins.rosadirs').open()
        end,
        desc = 'Rosadirs: Manage Projects & Obsidian',
      },
    },
  },
}

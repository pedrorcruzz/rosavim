return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '<leader>lo',
        function()
          require('rosavim.rosa_plugins.rosasnippets').open()
        end,
        desc = 'Rosasnippets: Manage Snippets',
      },
    },
  },
}

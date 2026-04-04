return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '<leader>kk',
        function()
          require('rosavim.rosa_plugins.rosakit').open()
        end,
        desc = 'Rosakit: Menu',
      },
      {
        '<leader>ka',
        function()
          require('rosavim.rosa_plugins.rosakit').lsp_actions()
        end,
        desc = 'Rosakit: LSP Actions',
      },
    },
  },
}

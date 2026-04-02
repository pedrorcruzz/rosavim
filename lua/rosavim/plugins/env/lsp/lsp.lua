return {
  {
    'antosha417/nvim-lsp-file-operations',
    config = true,
    event = 'BufReadPost',
  },

  {
    'folke/lazydev.nvim',
    opts = {},
    ft = 'lua',
  },
  -- { 'j-hui/fidget.nvim', opts = {} },
  {
    'SmiteshP/nvim-navic',
    opts = {
      lsp = {
        auto_attach = true,
      },
    },
    lazy = true,
  },
}

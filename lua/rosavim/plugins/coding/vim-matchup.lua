return {
  'andymass/vim-matchup',
  event = 'BufReadPost',
  init = function()
    vim.g.matchup_treesitter_stopline = 500
  end,
  config = function()
    require('match-up').setup {
      treesitter = {
        stopline = 500,
      },
    }
  end,
}

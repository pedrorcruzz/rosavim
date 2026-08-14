return {
  'andymass/vim-matchup',
  event = 'BufReadPost',
  init = function()
    vim.g.matchup_treesitter_stopline = 500
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_matchparen_deferred_show_delay = 50
    vim.g.matchup_matchparen_deferred_hide_delay = 300
    vim.g.matchup_matchparen_timeout = 100
    vim.g.matchup_matchparen_insert_timeout = 30
  end,
  config = function()
    require('match-up').setup {
      treesitter = {
        stopline = 500,
      },
    }
  end,
}

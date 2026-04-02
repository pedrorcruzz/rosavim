return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
  end,
  keys = {
    { '<leader>vb', '<cmd>DBUIToggle<cr>', desc = 'DBUI: Toggle' },
    { '<leader>va', '<cmd>DBUIAddConnection<cr>', desc = 'DBUI: Add Connection' },
    { '<leader>vf', '<cmd>DBUIFindBuffer<cr>', desc = 'DBUI: Find Buffer' },
  },
}

return {
  'OXY2DEV/markview.nvim',
  lazy = true,
  ft = { 'markdown' },
  cmd = { 'MarkviewToggle', 'MarkviewOpen', 'MarkviewClose' },
  keys = {
    { '<leader>ut', '<cmd>Markview Toggle<cr>', desc = 'Markview: Toggle' },
  },
}

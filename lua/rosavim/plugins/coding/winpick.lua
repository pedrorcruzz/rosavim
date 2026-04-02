return {
  'gbrlsnchs/winpick.nvim',
  lazy = true,
  keys = {
    { '<leader>m', "<cmd>lua local w=require('winpick');local id=w.select();if id then vim.api.nvim_set_current_win(id) end<cr>", desc = 'Pick a Window' },
  },
  opts = {
    border = 'none', --single, double, none, rounded, shadow
    prompt = '',
    filter = nil,
    format_label = nil,
    chars = nil,
  },
  config = function(_, opts)
    require('winpick').setup(opts)
  end,
}

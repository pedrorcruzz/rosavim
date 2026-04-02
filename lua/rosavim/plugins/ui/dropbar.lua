local dropbar_enabled = false

return {
  'Bekaboo/dropbar.nvim',
  config = function()
    require('dropbar').setup {
      bar = {
        enable = function(buf, win)
          return dropbar_enabled
            and vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_get_option_value('buftype', { buf = buf }) == ''
            and vim.api.nvim_win_get_config(win).relative == ''
            and vim.api.nvim_get_option_value('modifiable', { buf = buf })
        end,
      },
    }
  end,
  keys = {
    {
      '<leader>zz',
      function()
        require('dropbar.api').pick()
      end,
      mode = 'n',
      desc = 'Pick symbols in winbar',
    },
    {
      '<leader>lb',
      function()
        dropbar_enabled = not dropbar_enabled
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if not dropbar_enabled then
            vim.api.nvim_set_option_value('winbar', '', { scope = 'local', win = win })
          else
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_exec_autocmds('BufWinEnter', { buffer = buf })
          end
        end
      end,
      mode = 'n',
      desc = 'Dropbar: Toggle',
    },
  },
}

local toggles = require 'rosavim.config.toggles'

return {
  'Bekaboo/dropbar.nvim',
  event = toggles.get 'dropbar' and { 'BufReadPost', 'BufNewFile' } or nil,
  config = function()
    require('dropbar').setup {
      bar = {
        enable = function(buf, win)
          return toggles.get 'dropbar'
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
    -- Dropbar toggle moved to snacks/toggles.lua
  },
}

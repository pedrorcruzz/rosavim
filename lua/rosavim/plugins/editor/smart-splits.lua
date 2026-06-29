return {
  'mrjones2014/smart-splits.nvim',
  lazy = true,
  keys = {
    {
      '<C-h>',
      function()
        require('smart-splits').move_cursor_left()
      end,
      desc = 'Move to left split',
    },
    {
      '<C-j>',
      function()
        require('smart-splits').move_cursor_down()
      end,
      desc = 'Move to below split',
    },
    {
      '<C-k>',
      function()
        require('smart-splits').move_cursor_up()
      end,
      desc = 'Move to above split',
    },
    {
      '<C-l>',
      function()
        require('smart-splits').move_cursor_right()
      end,
      desc = 'Move to right split',
    },
    {
      '<C-\\>',
      function()
        require('smart-splits').move_cursor_previous()
      end,
      desc = 'Move to previous split',
    },
    {
      '<left>',
      function()
        local ok, rt = pcall(require, 'rosavim.rosa_plugins.rosaterm')
        if ok and rt.resize_arrow 'left' then
          return
        end
        require('smart-splits').resize_left()
      end,
      desc = 'Resize left',
    },
    {
      '<down>',
      function()
        local ok, rt = pcall(require, 'rosavim.rosa_plugins.rosaterm')
        if ok and rt.resize_arrow 'down' then
          return
        end
        require('smart-splits').resize_down()
      end,
      desc = 'Resize down',
    },
    {
      '<up>',
      function()
        local ok, rt = pcall(require, 'rosavim.rosa_plugins.rosaterm')
        if ok and rt.resize_arrow 'up' then
          return
        end
        require('smart-splits').resize_up()
      end,
      desc = 'Resize up',
    },
    {
      '<right>',
      function()
        local ok, rt = pcall(require, 'rosavim.rosa_plugins.rosaterm')
        if ok and rt.resize_arrow 'right' then
          return
        end
        require('smart-splits').resize_right()
      end,
      desc = 'Resize right',
    },
  },
}

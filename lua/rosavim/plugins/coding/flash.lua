return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',

    ---@type Flash.Config
    opts = {
      -- labels = 'asdfghjklqwertyuiopzxcvbnm',
      labels = 'fghjklqwetyupzcvbnm',

      search = {
        mode = 'search', --search, exact, fuzzy
      },
      -- jump = {
      --   pos = "end", --start,end, range
      -- },

      modes = {
        char = {
          -- if true, so use flash.nvim as a replacement for the default f/F/t/T keys
          enabled = true,
          highlight = { backdrop = false },
        },
      },
    },

    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = 'c',
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },
}

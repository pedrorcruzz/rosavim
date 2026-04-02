return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    lazy = true,
    cmd = { 'ToggleTerm' },
    keys = {
      { '<c-\\>', desc = 'Toggle terminal' },
      { '<leader>cii', '<cmd>ToggleTerm 3 direction=horizontal<CR>', desc = 'ToggleTerm: Horizontal Split' },
      { '<leader>cie', '<cmd>ToggleTerm 4 direction=vertical<CR>', desc = 'ToggleTerm: Vertical Split' },
      { '<S-x>', desc = 'ToggleTerm: Horizontal' },
      { '<S-z>', desc = 'ToggleTerm: Float' },
      { '<leader>lg', desc = 'ToggleTerm: LazyGit' },
    },
    opts = {
      size = 16,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = false,
      persist_mode = false,
      insert_mappings = true,
      persist_size = false,
      direction = 'float',
      close_on_exit = true,
      highlights = {
        Normal = { link = 'Normal' },
        NormalFloat = { link = 'NormalFloat' },
        FloatBorder = { link = 'FloatBorder' },
      },
      winbar = {
        enabled = false,
        name_formatter = function(term)
          return term.name
        end,
      },
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    },
    config = function(_, opts)
      require('toggleterm').setup(opts)

      local Terminal = require('toggleterm.terminal').Terminal

      local function create_terminal(direction, size, keymap)
        local term = Terminal:new {
          direction = direction,
          size = size,
          on_open = function(term)
            vim.cmd 'stopinsert'
            vim.opt_local.winbar = nil

            vim.schedule(function()
              vim.cmd 'redrawstatus!'
            end)
          end,
        }

        vim.keymap.set({ 'n', 't' }, keymap, function()
          term:toggle()
        end, { desc = 'Toggle Terminal (' .. direction .. ')' })
      end

      create_terminal('horizontal', 20, '<S-x>')
      create_terminal('float', nil, '<S-z>')

      local lazygit = Terminal:new {
        cmd = 'lazygit',
        hidden = true,
        direction = 'float',
        float_opts = { border = 'none', width = 100000, height = 100000 },
        on_open = function(_)
          vim.cmd 'startinsert!'
          vim.opt_local.winbar = nil
        end,
        count = 99,
      }

      -- vim.keymap.set('n', '<leader>lg', function()
      --   lazygit:toggle()
      -- end, { desc = 'ToggleTerm: LazyGit' })
    end,
  },
}

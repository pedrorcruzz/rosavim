return {
  { -- Copilot
    'zbirenbaum/copilot.lua',
    lazy = true,
    event = 'InsertEnter',
    cmd = 'Copilot',
    cond = vim.fn.executable 'node' == 1,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<Tab>',
          next = '<C-l>',
          prev = '<C-h>',
          dismiss = '<C-d>',
        },
      },
      panel = {
        enabled = true,
      },
      experimental = {
        ghost_text = false,
      },
    },
    config = function(_, opts)
      require('copilot').setup(opts)
      local toggles = require 'rosavim.config.toggles'
      if not toggles.get 'copilot' then
        vim.cmd 'Copilot disable'
      end
    end,
    keys = {
      { '<leader>ai', '', desc = '+copilot' },
      { '<leader>aia', '<cmd>Copilot auth<cr>', desc = 'Copilot: Auth' },
      {
        '<leader>aii',
        function()
          local toggles = require 'rosavim.config.toggles'
          local enabled = toggles.toggle 'copilot'
          if enabled then
            vim.cmd 'Copilot enable'
          else
            vim.cmd 'Copilot disable'
          end
          vim.notify('Copilot: ' .. (enabled and 'enabled' or 'disabled'))
        end,
        desc = 'Copilot: Toggle',
      },
      { '<leader>aip', '<cmd>Copilot panel<cr>', desc = 'Copilot: Panel' },
    },
  },

  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = { 'fang2hou/blink-copilot' },
    opts = {
      sources = {
        default = { 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}

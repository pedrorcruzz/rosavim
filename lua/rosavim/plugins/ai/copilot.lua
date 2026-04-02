local copilot_autotoggle = false

return {
  { -- Copilot
    'zbirenbaum/copilot.lua',
    lazy = true,
    event = copilot_autotoggle and 'InsertEnter' or nil,
    cmd = 'Copilot',
    cond = vim.fn.executable 'node' == 1,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = copilot_autotoggle,
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
    keys = {
      { '<leader>ia', '<cmd>Copilot auth<cr>', desc = 'Copilot: Auth' },
      { '<leader>ie', '<cmd>Copilot enable<cr>', desc = 'Copilot: Enable' },
      { '<leader>id', '<cmd>Copilot disable<cr>', desc = 'Copilot: Disable' },
      { '<leader>ii', '<cmd>Copilot toggle<cr>', desc = 'Copilot: Toggle' },
      { '<leader>ip', '<cmd>Copilot panel<cr>', desc = 'Copilot: Panel' },
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

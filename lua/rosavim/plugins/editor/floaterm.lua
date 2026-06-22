return {
  'nvzone/floaterm',
  lazy = true,
  dependencies = {
    { 'nvzone/volt', lazy = true },
  },
  cmd = 'FloatermToggle',
  keys = {
    {
      '<S-z>',
      '<cmd>FloatermToggle<cr>',
      mode = { 'n', 'i', 'v', 't' },
      desc = 'Toggle Floaterm',
    },
  },

  opts = {
    border = false,

    size = { h = 75, w = 80 },

    mappings = {
      term = function(buf)
        local api = require 'floaterm.api'

        vim.keymap.set({ 'n', 't' }, '<C-j>', function()
          api.cycle_term_bufs 'next'
        end, { buffer = buf, desc = 'Floaterm next terminal' })

        vim.keymap.set({ 'n', 't' }, '<C-k>', function()
          api.cycle_term_bufs 'prev'
        end, { buffer = buf, desc = 'Floaterm prev terminal' })
      end,
    },

    terminals = {
      { name = 'Terminal' },
      -- { name = 'Fastfetch', cmd = 'fastfetch' },
    },
  },
}

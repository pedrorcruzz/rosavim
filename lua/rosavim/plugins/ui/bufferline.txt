local bufferline_active = true

return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'echasnovski/mini.bufremove',
  },
  lazy = true,
  event = 'VeryLazy',
  opts = {
    options = {
      show_bufferline = bufferline_active,
      close_command = function(bufnum)
        require('mini.bufremove').delete(bufnum, false)
      end,
      right_mouse_command = function(bufnum)
        require('mini.bufremove').delete(bufnum, false)
      end,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(_, _, diagnostics)
        local symbols = {
          error = { icon = '', hl = 'DiagnosticError' },
          warning = { icon = '', hl = 'DiagnosticWarn' },
          info = { icon = '', hl = 'DiagnosticInfo' },
          hint = { icon = '', hl = 'DiagnosticHint' },
        }
        local result = {}
        for name, count in pairs(diagnostics) do
          local sym = symbols[name]
          if sym and count > 0 then
            table.insert(result, string.format('%%#%s#%s%%*%d', sym.hl, sym.icon, count))
          end
        end
        return table.concat(result, ' ')
      end,

      offsets = {
        {
          filetype = 'snacks_picker_list',
          text = 'Snacks Explorer',
          highlight = 'Directory',
          text_align = 'left',
          separator = true,
        },
        {
          filetype = 'snacks_layout_box',
          text = '',
          highlight = 'Directory',
          text_align = 'left',
          separator = true,
        },
      },
    },
  },

  config = function(_, opts)
    require('bufferline').setup(opts)
    vim.opt.showtabline = bufferline_active and 2 or 0

    vim.api.nvim_set_hl(0, 'BufferLineErrorSelected', { link = 'BufferLineBufferSelected' })
    vim.api.nvim_set_hl(0, 'BufferLineWarningSelected', { link = 'BufferLineBufferSelected' })
    vim.api.nvim_set_hl(0, 'BufferLineInfoSelected', { link = 'BufferLineBufferSelected' })
    vim.api.nvim_set_hl(0, 'BufferLineHintSelected', { link = 'BufferLineBufferSelected' })
  end,

  keys = {
    {
      '<leader>lj',
      function()
        local loaded = package.loaded['bufferline']
        if not loaded then
          require('lazy').load { plugins = { 'bufferline.nvim' } }
        end

        bufferline_active = not bufferline_active

        require('bufferline').setup {
          options = {
            show_bufferline = bufferline_active,
            offsets = {
              {
                filetype = 'snacks_picker_list',
                text = 'Snacks Explorer',
                highlight = 'Directory',
                text_align = 'left',
                separator = true,
              },
              {
                filetype = 'snacks_layout_box',
                text = 'Snacks Explorer',
                highlight = 'Directory',
                text_align = 'left',
                separator = true,
              },
            },
          },
        }
        vim.opt.showtabline = bufferline_active and 2 or 0

        vim.api.nvim_set_hl(0, 'BufferLineErrorSelected', { link = 'BufferLineBufferSelected' })
        vim.api.nvim_set_hl(0, 'BufferLineWarningSelected', { link = 'BufferLineBufferSelected' })
        vim.api.nvim_set_hl(0, 'BufferLineInfoSelected', { link = 'BufferLineBufferSelected' })
        vim.api.nvim_set_hl(0, 'BufferLineHintSelected', { link = 'BufferLineBufferSelected' })
      end,
      desc = 'Bufferline: Toggle',
    },
    { '<leader>bb', '<cmd>BufferLinePick<cr>', desc = 'Pick Buffer' },
    {
      '<leader>bf',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Find Buffers',
    },

    { '<leader>bp', '<cmd>BufferLinePickClose<cr>', desc = 'Pick Close Buffer' },
    { '<leader>bh', '<cmd>BufferLineCloseLeft<cr>', desc = 'Close Left' },
    { '<leader>bl', '<cmd>BufferLineCloseRight<cr>', desc = 'Close Right' },
    { '<leader>bC', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close Others' },
    { '<leader>bj', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<leader>bk', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '<leader>bq', '<cmd>BufferLineSortByDirectory<cr>', desc = 'Sort Directory' },
    { '<leader>be', '<cmd>BufferLineSortByExtension<cr>', desc = 'Sort Extension' },
    { '<leader>br', '<cmd>BufferLineSortByRelativeDirectory<cr>', desc = 'Sort Relative Directory' },
  },
}

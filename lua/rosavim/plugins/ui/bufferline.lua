local toggles = require 'rosavim.config.toggles'

return {
  'akinsho/bufferline.nvim',
  dependencies = {
    { 'echasnovski/mini.icons', lazy = true },
    'echasnovski/mini.bufremove',
  },
  lazy = true,
  event = 'VeryLazy',
  opts = {
    options = {
      show_bufferline = toggles.get 'bufferline',
      close_command = function(bufnum)
        require('mini.bufremove').delete(bufnum, false)
      end,
      right_mouse_command = function(bufnum)
        require('mini.bufremove').delete(bufnum, false)
      end,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(_, _, diagnostics)
        local symbols = {
          error = { icon = '', hl = 'DiagnosticError' },
          warning = { icon = '', hl = 'DiagnosticWarn' },
          info = { icon = '', hl = 'DiagnosticInfo' },
          hint = { icon = '', hl = 'DiagnosticHint' },
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
    local active = toggles.get 'bufferline'
    vim.opt.showtabline = active and 2 or 0

    -- Fix devicon and remaining highlight backgrounds to match theme
    local function fix_bufferline_hls()
      local bl_fill = vim.api.nvim_get_hl(0, { name = 'BufferLineFill' })
      local bl_sel = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferSelected' })
      for _, hl_name in ipairs(vim.fn.getcompletion('BufferLine', 'highlight')) do
        local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
        local target_bg = hl_name:find 'Selected' and bl_sel.bg or bl_fill.bg
        if hl.bg ~= target_bg then
          hl.bg = target_bg
          vim.api.nvim_set_hl(0, hl_name, hl)
        end
      end
      vim.api.nvim_set_hl(0, 'BufferLineErrorSelected', { link = 'BufferLineBufferSelected' })
      vim.api.nvim_set_hl(0, 'BufferLineWarningSelected', { link = 'BufferLineBufferSelected' })
      vim.api.nvim_set_hl(0, 'BufferLineInfoSelected', { link = 'BufferLineBufferSelected' })
      vim.api.nvim_set_hl(0, 'BufferLineHintSelected', { link = 'BufferLineBufferSelected' })
    end

    vim.schedule(fix_bufferline_hls)
    vim.api.nvim_create_autocmd({ 'BufEnter', 'ColorScheme' }, {
      callback = fix_bufferline_hls,
    })
  end,

  keys = {
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

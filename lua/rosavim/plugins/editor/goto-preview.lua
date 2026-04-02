return {
  'rmagatti/goto-preview',
  lazy = true,
  dependencies = { 'rmagatti/logger.nvim' },
  config = function()
    require('goto-preview').setup {
      -- width = 120,
      -- height = 15,
      default_mappings = false,
      post_open_hook = function(bufnr, winid)
        vim.keymap.set('n', '<leader>Q', function()
          vim.api.nvim_win_close(winid, true)
          vim.cmd('vsplit | buffer ' .. bufnr)
        end, { buffer = bufnr, desc = 'Expand preview (vsplit)' })

        vim.keymap.set('n', '<leader>M', function()
          vim.api.nvim_win_close(winid, true)
          vim.cmd('buffer ' .. bufnr)
        end, { buffer = bufnr, desc = 'Expand preview (replace window)' })
      end,
    }

    local gp = require 'goto-preview'
    vim.keymap.set('n', 'gp', gp.goto_preview_definition, { noremap = true, desc = 'Preview Definition' })
    vim.keymap.set('n', 'gP', gp.close_all_win, { noremap = true, desc = 'Close All Preview Windows' })
    -- vim.keymap.set('n', 'gpt', gp.goto_preview_type_definition, { noremap = true })
    -- vim.keymap.set('n', 'gpi', gp.goto_preview_implementation, { noremap = true })
    -- vim.keymap.set('n', 'gpD', gp.goto_preview_declaration, { noremap = true })
    -- vim.keymap.set('n', 'gpr', gp.goto_preview_references, { noremap = true })
  end,
}

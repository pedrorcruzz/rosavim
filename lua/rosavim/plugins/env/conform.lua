return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      local conform = require 'conform'

      local enable_auto_format_on_focus = false

      local function has_biome()
        return vim.fn.filereadable(vim.fn.getcwd() .. '/node_modules/.bin/biome') == 1
      end

      conform.setup {
        formatters_by_ft = {
          javascript = has_biome() and { 'biome' } or { 'prettierd', 'prettier' },
          typescript = has_biome() and { 'biome' } or { 'prettierd', 'prettier' },
          javascriptreact = has_biome() and { 'biome' } or { 'prettierd', 'prettier' },
          typescriptreact = has_biome() and { 'biome' } or { 'prettierd', 'prettier' },
          json = has_biome() and { 'biome' } or { 'prettierd' },
          html = { 'prettierd', 'prettier' },
          css = { 'prettierd', 'prettier' },
          htmldjango = { 'djlint' },
          python = { 'autopep8', 'black' },
          ruby = { 'rubocop' },
          lua = { 'stylua' },
          php = { 'php_cs_fixer' },
          go = { 'goimports' },
          java = { 'google-java-format' },
          blade = { 'blade-formatter' },
          sql = { 'sql_formatter' },
          mysql = { 'sql_formatter' },
        },

        formatters = {
          ['biome-organize-imports'] = {
            command = 'biome',
            args = { 'format', '--organize-imports', '--assists-enabled' },
            stdin = true,
          },
        },

        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        },
      }

      vim.keymap.set({ 'n', 'v' }, '<leader>lf', function()
        conform.format {
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        }
      end, { desc = 'Format current file' })

      if enable_auto_format_on_focus then
        vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
          pattern = '*',
          callback = function(args)
            local buf = args.buf or vim.api.nvim_get_current_buf()
            if require('lazyvim.util').format.enabled(buf) and vim.fn.mode() == 'n' then
              vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(buf) then
                  require('conform').format { bufnr = buf }
                end
              end, 100)
            end
          end,
        })
      end
    end,
  },
}

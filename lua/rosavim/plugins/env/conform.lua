return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      local conform = require 'conform'

      local enable_auto_format_on_focus = false

      local web = { 'biome', 'prettierd', 'prettier', stop_after_first = true }

      conform.setup {
        formatters_by_ft = {
          javascript = web,
          typescript = web,
          javascriptreact = web,
          typescriptreact = web,
          json = web,
          vue = { 'prettierd', 'prettier', stop_after_first = true },
          html = { 'superhtml', 'prettierd', 'prettier', stop_after_first = true },
          css = { 'prettierd', 'prettier', stop_after_first = true },
          htmldjango = { 'djlint' },
          python = { 'black', 'autopep8', stop_after_first = true },
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
          biome = { require_cwd = true },
          black = { require_cwd = true },
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

      local function autoformat_enabled(buf)
        local baf = vim.b[buf].autoformat
        if baf ~= nil then
          return baf
        end
        return vim.g.autoformat == nil or vim.g.autoformat
      end

      if enable_auto_format_on_focus then
        vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
          pattern = '*',
          callback = function(args)
            local buf = args.buf or vim.api.nvim_get_current_buf()
            if autoformat_enabled(buf) and vim.fn.mode() == 'n' then
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

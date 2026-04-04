return {
  'mfussenegger/nvim-lint',
  event = 'BufReadPost',
  config = function()
    local lint = require 'lint'

    ---@param candidates string[][]
    ---@return string[]?
    local function available(candidates)
      local result = {}
      for _, entry in ipairs(candidates) do
        local exe, name = entry[1], entry[2]
        if vim.fn.executable(exe) == 1 then
          table.insert(result, name)
        end
      end
      return #result > 0 and result or nil
    end

    local js = available {
      { 'eslint_d', 'eslint_d' },
      { 'eslint', 'eslint' },
      { 'biomejs', 'biomejs' },
    }

    lint.linters_by_ft = {
      markdown = available { { 'markdownlint', 'markdownlint' } },
      elixir = available { { 'credo', 'credo' } },
      javascript = js,
      typescript = js,
      typescriptreact = js,
      javascriptreact = js,
      python = available { { 'pylint', 'pylint' }, { 'mypy', 'mypy' } },
      php = available { { 'phpcs', 'phpcs' } },
      go = available { { 'golangci-lint', 'golangcilint' } },
      java = available { { 'checkstyle', 'checkstyle' } },
      dockerfile = available { { 'hadolint', 'hadolint' } },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}

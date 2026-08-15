return {
  'mfussenegger/nvim-lint',
  event = 'BufReadPost',
  config = function()
    local lint = require 'lint'

    ---@param candidates (string|string[])[]
    ---@return string[]?
    local function available(candidates)
      local result = {}
      for _, entry in ipairs(candidates) do
        local exe = type(entry) == 'table' and entry[1] or entry
        local name = type(entry) == 'table' and entry[2] or entry
        if vim.fn.executable(exe) == 1 then
          table.insert(result, name)
        end
      end
      return #result > 0 and result or nil
    end

    local web = available {
      'eslint_d',
      'eslint',
      { 'biome', 'biomejs' },
    }

    lint.linters_by_ft = {
      markdown = available { 'markdownlint' },
      elixir = available { 'credo' },
      javascript = web,
      typescript = web,
      typescriptreact = web,
      javascriptreact = web,
      python = available { 'pylint', 'mypy' },
      php = available { 'phpcs' },
      go = available { { 'golangci-lint', 'golangcilint' } },
      java = available { 'checkstyle' },
      dockerfile = available { 'hadolint' },
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

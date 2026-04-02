return {
  'mfussenegger/nvim-lint',
  event = 'BufReadPost',
  config = function()
    local lint = require 'lint'

    local has_exe = function(exe)
      return vim.fn.executable(exe) == 1
    end

    local js_linters = {}
    if has_exe 'eslint_d' then
      table.insert(js_linters, 'eslint_d')
    end
    if has_exe 'eslint' then
      table.insert(js_linters, 'eslint')
    end
    if has_exe 'biomejs' then
      table.insert(js_linters, 'biomejs')
    end
    js_linters = #js_linters > 0 and js_linters or nil

    local python_linters = {}
    if has_exe 'pylint' then
      table.insert(python_linters, 'pylint')
    end
    if has_exe 'mypy' then
      table.insert(python_linters, 'mypy')
    end
    python_linters = #python_linters > 0 and python_linters or nil

    local markdown_linters = {}
    if has_exe 'markdownlint' then
      table.insert(markdown_linters, 'markdownlint')
    end
    markdown_linters = #markdown_linters > 0 and markdown_linters or nil

    local elixir_linters = {}
    if has_exe 'credo' then
      table.insert(elixir_linters, 'credo')
    end
    elixir_linters = #elixir_linters > 0 and elixir_linters or nil

    local php_linters = {}
    if has_exe 'phpcs' then
      table.insert(php_linters, 'phpcs')
    end
    php_linters = #php_linters > 0 and php_linters or nil

    local go_linters = {}
    if has_exe 'golangci-lint' then
      table.insert(go_linters, 'golangcilint')
    end
    go_linters = #go_linters > 0 and go_linters or nil

    local java_linters = {}
    if has_exe 'checkstyle' then
      table.insert(java_linters, 'checkstyle')
    end
    java_linters = #java_linters > 0 and java_linters or nil

    local dockerfile_linters = {}
    if has_exe 'hadolint' then
      table.insert(dockerfile_linters, 'hadolint')
    end
    dockerfile_linters = #dockerfile_linters > 0 and dockerfile_linters or nil

    lint.linters_by_ft = {
      markdown = markdown_linters,
      elixir = elixir_linters,
      javascript = js_linters,
      typescript = js_linters,
      typescriptreact = js_linters,
      javascriptreact = js_linters,
      python = python_linters,
      php = php_linters,
      go = go_linters,
      java = java_linters,
      dockerfile = dockerfile_linters,
    }

    for ft, linters in pairs(lint.linters_by_ft) do
      if not linters or #linters == 0 then
        lint.linters_by_ft[ft] = nil
      end
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}

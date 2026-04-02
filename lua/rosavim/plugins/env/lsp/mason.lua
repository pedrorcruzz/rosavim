-- Capabilities globais para todos os LSP servers
vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  },
})

-- Ativa todos os servers (configs em lsp/*.lua)
vim.lsp.enable {
  'vtsls',
  'tailwindcss',
  'emmet_ls',
  'pyright',
  'intelephense',
  'jsonls',
  'gopls',
  'jdtls',
  'sqlls',
  'lua_ls',
}

return {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {
      ui = {
        border = 'rounded',
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    event = 'VeryLazy',
    opts = {
      ensure_installed = {
        -- LSP Servers
        'vtsls',
        'tailwindcss-language-server',
        'emmet-ls',
        'pyright',
        'intelephense',
        'json-lsp',
        'gopls',
        'jdtls',
        'sqlls',
        'lua-language-server',
        -- Formatters
        'stylua',
        'superhtml',
        'prettierd',
        'autopep8',
        'sql-formatter',
        'blade-formatter',
        'goimports',
        'google-java-format',
        -- Linters
        'djlint',
        'biome',
        'mypy',
        'eslint_d',
        -- Debuggers
        'php-debug-adapter',
        'go-debug-adapter',
        'debugpy',
        'java-debug-adapter',
      },
    },
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
}

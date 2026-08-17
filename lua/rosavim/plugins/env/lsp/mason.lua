local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
local ok, blink = pcall(require, 'blink.cmp')
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.lsp.enable {
  'tsc',
  -- vtsls is temporary, Vue projects only. Removal checklist in lsp/vtsls.lua
  'vtsls',
  'vue_language_server',
  'tailwindcss',
  'emmet_ls',
  'basedpyright',
  'intelephense',
  'jsonls',
  'gopls',
  'sqlls',
  'lua_ls',
  'css_lsp',
  'superhtml',
  'marksman',
}

return {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {
      ui = {
        border = 'rounded',
        icons = {
          package_installed = '󰄳',
          package_pending = '󰦗',
          package_uninstalled = '󰅙',
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
        'tsc',
        'vtsls',
        'vue-language-server',
        'tailwindcss-language-server',
        'css-lsp',
        'emmet-ls',
        'superhtml',
        'basedpyright',
        'intelephense',
        'json-lsp',
        'gopls',
        'sqlls',
        'lua-language-server',
        'marksman',
        -- Formatters
        'stylua',
        'prettierd',
        'autopep8',
        'sql-formatter',
        'blade-formatter',
        'goimports',
        -- Linters
        'djlint',
        'biome',
        'mypy',
        'eslint_d',
        -- Debuggers
        'php-debug-adapter',
        'go-debug-adapter',
        'debugpy',
      },
    },
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
}

local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
end

-- Capabilities are registered by blink.cmp itself (plugin/blink-cmp.lua calls
-- vim.lsp.config('*', ...) on load); blink is non-lazy so this happens before
-- the first server starts.
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
    cmd = { 'MasonToolsInstall', 'MasonToolsUpdate', 'MasonToolsClean' },
    opts = {
      run_on_start = true,
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

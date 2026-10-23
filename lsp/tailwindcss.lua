return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'html',
    'htmldjango',
    'css',
    'scss',
    'sass',
    'less',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
    'php',
    'blade',
  },
  -- Only start where Tailwind is actually in use. A config file marks v3
  -- projects; v4 has no config file (CSS-first), so fall back to checking the
  -- nearest package.json for a tailwindcss dependency. A bare package.json as
  -- marker would spin the server up in every Node project.
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local config = vim.fs.find({
      'tailwind.config.js',
      'tailwind.config.ts',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
      'postcss.config.js',
      'postcss.config.ts',
      'postcss.config.cjs',
      'postcss.config.mjs',
    }, { path = fname, upward = true })[1]
    if config then
      return on_dir(vim.fs.dirname(config))
    end
    for _, pkg in ipairs(vim.fs.find('package.json', { path = fname, upward = true, limit = math.huge })) do
      local ok, data = pcall(vim.fn.readfile, pkg)
      if ok and table.concat(data, '\n'):find('"tailwindcss"', 1, true) then
        return on_dir(vim.fs.dirname(pkg))
      end
    end
  end,
  settings = {
    tailwindCSS = {
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidConfigPath = 'error',
        invalidScreen = 'error',
        invalidTailwindDirective = 'error',
        invalidVariant = 'error',
        recommendedVariantOrder = 'warning',
      },
      experimental = {
        -- No catch-all '"..."' pattern: matching every quoted string makes the
        -- server run completion/hover/color queries on unrelated strings.
        classRegex = {
          [[class= "([^"]*)]],
          [[class: "([^"]*)]],
        },
      },
      validate = true,
    },
  },
}

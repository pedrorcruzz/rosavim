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
  -- Only start where Tailwind is actually configured; package.json/node_modules
  -- here would spin the server up in every Node project.
  root_markers = {
    'tailwind.config.js',
    'tailwind.config.ts',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'postcss.config.js',
    'postcss.config.ts',
    'postcss.config.cjs',
    'postcss.config.mjs',
  },
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

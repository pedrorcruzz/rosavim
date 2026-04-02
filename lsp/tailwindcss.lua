return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = { 'html', 'jsx', 'tsx' },
  root_markers = {
    'tailwind.config.js',
    'tailwind.config.ts',
    'postcss.config.js',
    'postcss.config.ts',
    'package.json',
    'node_modules',
    '.git',
  },
  init_options = {
    userLanguages = {
      elixir = 'html-eex',
      eelixir = 'html-eex',
      heex = 'html-eex',
    },
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
        classRegex = {
          [[class= "([^"]*)]],
          [[class: "([^"]*)]],
          '~H""".*class="([^"]*)".*"""',
          '~F""".*class="([^"]*)".*"""',
          '"([^"]*)"',
        },
      },
      validate = true,
    },
  },
}

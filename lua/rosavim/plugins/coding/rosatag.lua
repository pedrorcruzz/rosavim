return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosatag',
  name = 'rosatag',
  -- Kept in sync with rosatag/config.lua M.filetypes; inlined so the spec
  -- import does not require the module at startup.
  ft = {
    'html',
    'htmldjango',
    'xml',
    'svg',
    'php',
    'blade',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
    'astro',
    'templ',
    'eruby',
    'handlebars',
    'twig',
  },
  config = function()
    require('rosavim.rosa_plugins.rosatag').setup()
  end,
  -- <leader>kr is buffer-local (set on attach), toggles in snacks/toggles/rosatag.lua
}

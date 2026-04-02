return {
  'adibhanna/laravel.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
  },
  ft = { 'php', 'blade' },
  keys = {
    -- Core
    { '<leader>kla', '<cmd>Artisan<cr>', desc = 'Laravel Artisan' },
    { '<leader>kls', '<cmd>LaravelStatus<cr>', desc = 'Laravel Status' },
    { '<leader>klr', '<cmd>LaravelRoute<cr>', desc = 'Laravel Routes' },
    { '<leader>klg', '<cmd>LaravelMake<cr>', desc = 'Laravel Make' },

    -- Composer
    { '<leader>klcc', ':Composer', desc = 'Composer [name]' },
    { '<leader>klci', ':Composer install', desc = 'Composer Install' },
    { '<leader>klcu', '<cmd>Composer update<cr>', desc = 'Composer Update' },
    { '<leader>klcr', '<cmd>ComposerRequire<cr> ', desc = 'Composer Require Package' },
    { '<leader>klcd', '<cmd>ComposerDependencies<cr>', desc = 'Composer Dependencies' },
    { '<leader>klcx', '<cmd>ComposerRemove<cr> ', desc = 'Composer Remove Package' },

    -- Navigation
    { '<leader>kle', '<cmd>LaravelController<cr> ', desc = 'Goto Controller' },
    { '<leader>klm', '<cmd>LaravelModel<cr> ', desc = 'Goto Model' },
    { '<leader>klv', '<cmd>LaravelView<cr> ', desc = 'Goto View' },
    { '<leader>kll', '<cmd>LaravelGoto<cr>', desc = 'Laravel Goto Definition' },

    -- Diagrams
    { '<leader>klds', '<cmd>LaravelSchema<cr>', desc = 'Show DB Schema' },
    { '<leader>klde', '<cmd>LaravelSchemaExport<cr>', desc = 'Export DB Schema' },
    { '<leader>klda', '<cmd>LaravelArchitecture<cr>', desc = 'Show App Architecture' },

    -- Cache
    { '<leader>klxx', ':LaravelCompletions', desc = 'Show Laravel Completions [type]' },
    { '<leader>klxc', '<cmd>LaravelClearCache<cr>', desc = 'Clear Laravel Cache' },
    { '<leader>klxo', '<cmd>LaravelCompletions<cr> ', desc = 'Show Laravel Completions' },

    -- IDE Helper
    { '<leader>klhh', ':LaravelIdeHelper', desc = 'Generate IDE Helper files [action]' },
    { '<leader>klhi', '<cmd>LaravelInstallIdeHelper<cr>', desc = 'Install Laravel IDE Helper package' },
    { '<leader>klhc', '<cmd>LaravelIdeHelperCheck<cr> ', desc = 'Check IDE Helper status and files' },
    { '<leader>klhg', '<cmd>LaravelIdeHelper<cr>', desc = 'Generate IDE Helper files' },
    { '<leader>klhr', '<cmd>LaravelIdeHelperClean<cr> ', desc = 'Remove generated files (keep package)' },
    { '<leader>klhu', '<cmd>LaravelRemoveIdeHelper<cr> ', desc = 'Completely remove IDE Helper package and files' },

    -- Laravel Sail
    { '<leader>klnn', ':Sail', desc = 'Run Sail command [command]' },
    { '<leader>klnu', '<cmd>SailUp<cr>', desc = 'Start Sail containers' },
    { '<leader>klnd', '<cmd>SailDown<cr>', desc = 'Stop Sail containers' },
    { '<leader>klnr', '<cmd>SailRestart<cr>', desc = 'Restart Sail containers' },
    { '<leader>klnt', '<cmd>SailTest<cr>', desc = 'Run tests throught Sail' },
    { '<leader>klns', '<cmd>SailShare<cr>', desc = 'Share application via tunnel' },
    { '<leader>klno', '<cmd>SailShell<cr>', desc = 'Open shell in container' },
  },
  config = function()
    require('laravel').setup {
      notifications = false,
      debug = false,
      keymaps = false,
      sail = {
        enabled = true,
        auto_detect = true,
      },
    }
  end,
}

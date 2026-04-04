return {
  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'BufReadPost',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'typescript',
        'tsx',
        'bash',
        'c',
        'html',
        'go',
        'lua',
        'markdown',
        'vim',
        'vimdoc',
        'heex',
        'eex',
        'javascript',
        'json5',
        'php',
        'python',
        'php_only',
        'markdown_inline',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      endwise = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = '<c-v>',
          },
        },
        move = { enable = true, set_jumps = true },
      },
    },
    config = function(_, opts)
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

      parser_config.blade = {
        install_info = {
          url = 'https://github.com/EmranMR/tree-sitter-blade',
          files = { 'src/parser.c' },
          branch = 'main',
        },
        filetype = 'blade',
      }

      vim.filetype.add {
        pattern = {
          ['.*%.blade%.php'] = 'blade',
          ['.*%.html'] = 'htmldjango',
          ['.*%.html%.jinja'] = 'htmldjango',
          ['.*%.html%.jinja2'] = 'htmldjango',
          ['.*%.html%.j2'] = 'htmldjango',
        },
      }

      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    cmd = 'TSContextToggle',
    event = require('rosavim.config.toggles').get 'tscontext' and { 'BufReadPost', 'BufNewFile' } or nil,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local toggles = require 'rosavim.config.toggles'
      local context = require 'treesitter-context'

      context.setup {
        enable = toggles.get 'tscontext',
        max_lines = 0,
      }

      vim.api.nvim_create_user_command('TSContextToggle', function()
        local new_val = toggles.toggle 'tscontext'
        context.toggle()
        if new_val then
          vim.notify('TSContext: On', vim.log.levels.INFO)
        else
          vim.notify('TSContext: Off', vim.log.levels.INFO)
        end
      end, { desc = 'Toggle Treesitter Context' })
    end,
  },
}

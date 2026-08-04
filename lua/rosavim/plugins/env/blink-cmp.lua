return {
  {
    'moyiz/blink-emoji.nvim',
    ft = { 'markdown', 'norg', 'gitcommit' },
    lazy = true,
  },

  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      -- VSCode-format snippet library, picked up from the runtimepath by
      -- blink's built-in snippets source (no engine plugin needed).
      { 'rafamadriz/friendly-snippets', event = 'InsertEnter' },

      { 'mikavilpas/blink-ripgrep.nvim', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
      -- { 'bydlw98/blink-cmp-env', lazy = true },
    },

    opts = {
      -- Native engine: expansion via vim.snippet, custom snippets read from
      -- <config>/snippets/<filetype>.json (VSCode format). Jumping between
      -- placeholders uses vim.snippet's built-in <Tab>/<S-Tab> session maps.
      snippets = { preset = 'default' },
      keymap = {
        preset = 'none',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-j>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<S-k>'] = { 'select_prev', 'fallback' },
        ['<S-j>'] = { 'select_next', 'fallback' },
        ['<UP>'] = { 'select_prev', 'fallback' },
        ['<DOWN>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'propo',
      },

      signature = {
        enabled = false,
        -- auto_show = true,
        window = { border = 'none' },
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 400,
          window = { border = 'rounded' },
        },
        ghost_text = { enabled = false },
        menu = {
          border = 'rounded',
          scrollbar = false,
          draw = {
            treesitter = { 'lsp' },
          },
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'emoji' }, --laravel
        per_filetype = {
          sql = { 'dadbod' },
          mysql = { 'dadbod' },
          plsql = { 'dadbod' },
        },
        providers = {
          -- laravel = {
          --   name = 'laravel',
          --   module = 'laravel.blink_source',
          -- },
          snippets = {
            opts = {
              -- Same inheritance the old luasnip filetype_extend provided.
              extended_filetypes = {
                typescript = { 'javascript' },
                typescriptreact = { 'javascript' },
                django = { 'python' },
              },
            },
          },
          ripgrep = {
            module = 'blink-ripgrep',
            name = 'Ripgrep',
            opts = {
              prefix_min_len = 3,
              context_size = 5,
              max_filesize = '1M',
              project_root_marker = '.git',
              project_root_fallback = true,
              search_casing = '--ignore-case',
              additional_rg_options = {},
              fallback_to_regex_highlighting = true,
              ignore_paths = {},
              additional_paths = {},
              toggles = {
                on_off = nil,
                debug = nil,
              },
              future_features = {
                backend = { use = 'ripgrep' },
              },
              debug = false,
            },
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.labelDetails = { description = '(rg)' }
              end
              return items
            end,
          },
          -- env = {
          --   name = 'Env',
          --   module = 'blink-cmp-env',
          --   opts = {
          --     item_kind = vim.lsp.protocol.CompletionItemKind.Variable,
          --     show_braces = false,
          --     show_documentation_window = true,
          --   },
          -- },
          emoji = {
            module = 'blink-emoji',
            name = 'Emoji',
            score_offset = 15,
            opts = { insert = true },
            should_show_items = function()
              return vim.tbl_contains({ 'gitcommit', 'markdown', 'norg' }, vim.o.filetype)
            end,
          },
          dadbod = {
            module = 'vim_dadbod_completion.blink',
          },
        },
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },

    opts_extend = { 'sources.default' },
  },
}

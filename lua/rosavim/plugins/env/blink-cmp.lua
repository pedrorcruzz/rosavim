return {
  {
    'moyiz/blink-emoji.nvim',
    ft = { 'markdown', 'norg', 'gitcommit' },
    lazy = true,
  },

  {
    'saghen/blink.cmp',
    -- Non-lazy on purpose: blink's plugin file registers LSP capabilities via
    -- vim.lsp.config('*'), which must run before the first server starts.
    -- Blink defers its own heavy parts internally.
    lazy = false,
    version = '1.*',
    dependencies = {
      -- VSCode-format snippet library, picked up from the runtimepath by
      -- blink's built-in snippets source (no engine plugin needed).
      { 'rafamadriz/friendly-snippets', event = 'InsertEnter' },

      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
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
          window = {
            border = 'rounded',
            winhighlight = table.concat({
              'Normal:BlinkCmpDoc',
              'FloatBorder:BlinkCmpDocBorder',
              'EndOfBuffer:BlinkCmpDoc',
              '@markup.raw.block.markdown:None',
              '@markup.raw.block:None',
              '@markup.raw.delimiter.markdown:None',
            }, ','),
          },
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

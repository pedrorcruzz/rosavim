local toggles = require 'rosavim.config.toggles'

return {
  enabled = true,
  hidden = toggles.get 'picker_hidden',
  ignored = toggles.get 'picker_ignored',
  layout = {
    preset = toggles.get 'picker_layout',
    preview = toggles.get 'picker_preview',
    -- Snacks only honours `border` per box inside the layout tree (a top-level
    -- `border` field is ignored). So rewrite every visible box border (the ones
    -- the presets set to `true`) to the chosen style. Read live on each open so
    -- the <leader>lasb toggle takes effect without a restart.
    config = function(layout)
      local border = toggles.get 'picker_border'
      local function walk(box)
        if type(box) ~= 'table' then
          return
        end
        if box.border == true then
          box.border = border
        end
        for _, child in ipairs(box) do
          walk(child)
        end
      end
      walk(layout.layout)
      return layout
    end,
  },
  sources = {
    files = {
      hidden = toggles.get 'picker_hidden',
      ignored = toggles.get 'picker_ignored',
    },
    explorer = {
      finder = 'explorer',
      diagnostics = true,
      diagnostics_open = false,
      layout = { layout = { position = toggles.get 'explorer_right' and 'right' or 'left', width = 34 }, preview = toggles.get 'explorer_preview' },
      focus = 'list',
      auto_close = false,
      git_untracked = true,
      git_status_open = false,
    },
    -- Hide third-party / generated code so :Snacks.picker.todo_comments() only
    -- surfaces TODO/WARN/NOTE comments written by the user, not those from libs.
    todo_comments = {
      hidden = false,
      ignored = false,
      -- Two-pass finder: pass 1 is the normal grep (respects .gitignore); pass 2
      -- disables .gitignore but whitelists only the allowed task-file names
      -- (todo/task/tarefas, any case) so those git-ignored files still surface.
      -- Results are merged and de-duplicated by their "file:line:col:text" key.
      finder = function(opts, ctx)
        local grep = require('snacks.picker.source.grep').grep
        local rosatodo = require 'rosavim.rosa_plugins.rosatodo'
        local opts2 = vim.tbl_extend('force', opts, {
          ignored = true, -- --no-ignore
          exclude = {}, -- excludes are folded into args (after the whitelist)
          args = rosatodo.pass2_args(opts.exclude),
        })
        local pass1 = grep(opts, ctx)
        local pass2 = grep(opts2, ctx)
        return function(cb)
          local seen = {}
          local function dedup(item)
            local key = item.text
            if key ~= nil then
              if seen[key] then
                return
              end
              seen[key] = true
            end
            cb(item)
          end
          pass1(dedup)
          pass2(dedup)
        end
      end,
      exclude = {
        '**/node_modules/**',
        '**/bower_components/**',
        '**/__pycache__/**',
        '**/.venv/**',
        '**/venv/**',
        '**/env/**',
        '**/site-packages/**',
        '**/.tox/**',
        '**/vendor/**',
        '**/dist/**',
        '**/build/**',
        '**/out/**',
        '**/target/**',
        '**/.next/**',
        '**/.nuxt/**',
        '**/.svelte-kit/**',
        '**/.turbo/**',
        '**/.cache/**',
        '**/.parcel-cache/**',
        '**/coverage/**',
        '**/.git/**',
        '**/.idea/**',
        '**/.gradle/**',
        '**/.mvn/**',
        '**/Pods/**',
        '**/DerivedData/**',
        '**/*.min.js',
        '**/*.min.css',
        '**/*.map',
        '**/*.lock',
        '**/package-lock.json',
        '**/yarn.lock',
        '**/pnpm-lock.yaml',
        '**/bun.lockb',
        '**/composer.lock',
        '**/Cargo.lock',
        '**/poetry.lock',
      },
    },
  },
  styles = {
    enabled = true,
  },
  -- Remap Ctrl-d / Ctrl-u to scroll the PREVIEW (defaults scroll the list).
  -- List still moves with <C-n>/<C-p>; <C-f>/<C-b> also scroll the preview.
  win = {
    input = {
      keys = {
        ['<C-h>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
        ['<C-l>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
        ['<c-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
        ['<c-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
      },
    },
    list = {
      keys = {
        ['<C-h>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
        ['<C-l>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
        ['<c-d>'] = 'preview_scroll_down',
        ['<c-u>'] = 'preview_scroll_up',
      },
    },
  },
  icons = {
    files = {
      enabled = true,
      dir = ' ',
      dir_open = '󰝰 ',
      file = ' ',
      test_dir = ' ',
    },
    diagnostics = {
      Error = ' ',
      Warn = ' ',
      Hint = ' ',
      Info = ' ',
    },
    lsp = {
      unavailable = '',
      enabled = ' ',
      disabled = ' ',
      attached = '󰖩 ',
    },
    kinds = {
      Array = ' ',
      Boolean = '󰨙 ',
      Class = ' ',
      Color = ' ',
      Control = ' ',
      Collapsed = ' ',
      Constant = '󰏿 ',
      Constructor = ' ',
      Copilot = ' ',
      Enum = ' ',
      EnumMember = ' ',
      Event = ' ',
      Field = ' ',
      File = ' ',
      Folder = ' ',
      Function = '󰊕 ',
      Interface = ' ',
      Key = ' ',
      Keyword = ' ',
      Method = '󰊕 ',
      Module = ' ',
      Namespace = '󰦮 ',
      Null = ' ',
      Number = '󰎠 ',
      Object = ' ',
      Operator = ' ',
      Package = ' ',
      Property = ' ',
      Reference = ' ',
      Snippet = '󱄽 ',
      String = ' ',
      Struct = '󰆼 ',
      Text = ' ',
      TypeParameter = ' ',
      Unit = ' ',
      Unknown = ' ',
      Value = ' ',
      Variable = '󰀫 ',
    },
  },
}

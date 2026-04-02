return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },

  keys = {
    {
      '<leader>jj',
      function()
        Snacks.picker.smart {
          cwd = vim.fn.expand '~/Developer/second-brain',
        }
      end,
      desc = 'Search notes (Second Brain)',
    },

    { '<leader>jo', '<cmd>Obsidian open<cr>', desc = 'Open Obsidian app' },
    { '<leader>jd', '<cmd>Obsidian today<cr>', desc = 'Daily note' },
    { '<leader>jy', '<cmd>Obsidian today -1<cr>', desc = 'Yesterday daily note' },
    { '<leader>jt', '<cmd>Obsidian today +1<cr>', desc = 'Tomorrow daily note' },
    { '<leader>jg', '<cmd>Obsidian dailies<cr>', desc = 'List dailies' },
    { '<leader>js', '<cmd>Obsidian search<cr>', desc = 'Search notes (Obsidian)' },
    { '<leader>jr', '<cmd>Obsidian rename<cr>', desc = 'Rename note' },
    { '<leader>je', '<cmd>Obsidian extract<cr>', desc = 'Extract note' },
    { '<leader>jl', '<cmd>Obsidian link_new<cr>', desc = 'Link new note' },
    { '<leader>ja', '<cmd>Obsidian template<cr>', desc = 'New note from template' },
    { '<leader>jz', '<cmd>Obsidian new<cr>', desc = 'New note' },
    { '<leader>jb', '<cmd>Obsidian backlinks<cr>', desc = 'Backlinks' },
    { '<leader>jp', '<cmd>Obsidian paste_img<cr>', desc = 'Paste image' },
    { '<leader>jc', '<cmd>Obsidian toggle_checkbox<cr>', desc = 'Toggle checkbox' },
    {
      '<leader>jm',
      function()
        return require('obsidian').util.toggle_checkbox()
      end,
      desc = 'Toggle checkbox (util)',
    },
  },

  config = function()
    require('obsidian').setup {
      workspaces = {
        {
          name = 'personal',
          path = '~/Developer/second-brain',
        },
        {
          name = 'work',
          path = '~/Developer/second-brain',
          overrides = {
            notes_subdir = 'Home/Anotacoes/NotasRealocar',
          },
        },
      },

      legacy_commands = false,
      log_level = vim.log.levels.INFO,
      notes_subdir = 'Home/Anotacoes/NotasRealocar',

      daily_notes = {
        folder = 'DailyNotes',
        date_format = 'n-%Y-%m-%d',
        alias_format = '%B %-d, %Y',
        default_tags = { 'diarias' },
        template = 'Templates/template daily note.md',
      },

      completion = {
        blink = true,
        min_chars = 2,
        create_new = true,
      },

      checkbox = {
        order = { ' ', 'x', '>', '~', '!' },
      },

      note_id_func = function(title)
        if title then
          return title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        end
        return tostring(os.time())
      end,

      note_path_func = function(spec)
        local path = spec.dir / spec.title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        return path:with_suffix '.md'
      end,

      preferred_link_style = 'wiki',

      wiki_link_func = function(opts)
        return require('obsidian.util').wiki_link_id_prefix(opts)
      end,

      markdown_link_func = function(opts)
        return require('obsidian.util').markdown_link(opts)
      end,

      frontmatter = {
        enabled = true,
        func = function(note)
          if note.title then
            note:add_alias(note.title)
          end

          local out = {
            id = note.id,
            aliases = note.aliases,
            tags = note.tags,
          }

          if note.metadata and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,
      },

      templates = {
        folder = 'Templates',
        date_format = '%Y-%m-%d',
        time_format = '%H:%M',
      },

      follow_url_func = function(url)
        vim.fn.jobstart { 'open', url }
      end,

      follow_img_func = function(img)
        vim.fn.jobstart { 'qlmanage', '-p', img }
      end,

      open = {
        func = function(uri)
          vim.ui.open(uri, {
            cmd = { 'open', '-a', '/Applications/Obsidian.app' },
          })
        end,
      },

      picker = {
        name = 'snacks.pick',
        note_mappings = {
          new = '<C-x>',
          insert_link = '<C-l>',
        },
        tag_mappings = {
          tag_note = '<C-x>',
          insert_tag = '<C-l>',
        },
      },

      search = {
        sort_by = 'modified',
        sort_reversed = true,
        max_lines = 1000,
      },

      open_notes_in = 'current',

      ui = {
        enable = false,
      },

      attachments = {
        img_folder = 'assets/Imagens',
        img_name_func = function()
          return string.format('%s-', os.time())
        end,
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format('![%s](%s)', path.name, path)
        end,
        confirm_img_paste = true,
      },
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function()
        vim.keymap.set('n', 'gf', function()
          return require('obsidian').util.gf_passthrough()
        end, { expr = true, buffer = true })

        vim.keymap.set('n', '<cr>', function()
          return require('obsidian').util.smart_action()
        end, { expr = true, buffer = true })
      end,
    })
  end,
}

local toggles = require 'rosavim.config.toggles'

return function()
  -- Rosasave
  Snacks.toggle({
    name = 'Rosasave',
    get = function()
      local ok, rosasave = pcall(require, 'rosavim.rosa_plugins.rosasave')
      return ok and rosasave.is_enabled() or false
    end,
    set = function(state)
      local rosasave = require 'rosavim.rosa_plugins.rosasave'
      if state then
        rosasave.enable()
      else
        rosasave.disable()
      end
      toggles.set('autosave', state)
    end,
  }):map '<leader>ls'

  -- Incline
  Snacks.toggle({
    name = 'Incline',
    get = function()
      return toggles.get 'incline'
    end,
    set = function(state)
      toggles.set('incline', state)
      if not package.loaded['incline'] then
        require('lazy').load { plugins = { 'incline.nvim' } }
      end
      if state then
        require('incline').enable()
      else
        require('incline').disable()
      end
    end,
  }):map '<leader>lc'

  -- Copilot
  Snacks.toggle({
    name = 'Copilot',
    get = function()
      return toggles.get 'copilot'
    end,
    set = function(state)
      toggles.set('copilot', state)
      if state then
        vim.cmd 'Copilot enable'
      else
        vim.cmd 'Copilot disable'
      end
    end,
  }):map '<leader>aii'

  -- Rosamaximize
  local rosamaximize = require 'rosavim.rosa_plugins.rosamaximize'
  Snacks.toggle({
    name = 'Rosamaximize',
    notify = false,
    get = function()
      return rosamaximize.is_maximized()
    end,
    set = function(state)
      if state then
        rosamaximize.maximize()
      else
        rosamaximize.restore()
      end
    end,
  }):map '<leader>cm'

  -- Git Blame
  Snacks.toggle({
    name = 'Git Blame',
    get = function()
      return toggles.get 'git_blame'
    end,
    set = function(state)
      toggles.set('git_blame', state)
      require('gitsigns').toggle_current_line_blame(state)
    end,
  }):map '<leader>gt'

  -- Bufferline
  Snacks.toggle({
    name = 'Bufferline',
    get = function()
      return toggles.get 'bufferline'
    end,
    set = function(state)
      toggles.set('bufferline', state)
      if not package.loaded['bufferline'] then
        require('lazy').load { plugins = { 'bufferline.nvim' } }
      end
      require('bufferline').setup {
        options = {
          show_bufferline = state,
          offsets = {
            {
              filetype = 'snacks_picker_list',
              text = 'Snacks Explorer',
              highlight = 'Directory',
              text_align = 'left',
              separator = true,
            },
            {
              filetype = 'snacks_layout_box',
              text = '',
              highlight = 'Directory',
              text_align = 'left',
              separator = true,
            },
          },
        },
      }
      vim.opt.showtabline = state and 2 or 0

      vim.api.nvim_set_hl(0, 'BufferLineErrorSelected', { link = 'BufferLineBufferSelected' })
      vim.api.nvim_set_hl(0, 'BufferLineWarningSelected', { link = 'BufferLineBufferSelected' })
      vim.api.nvim_set_hl(0, 'BufferLineInfoSelected', { link = 'BufferLineBufferSelected' })
      vim.api.nvim_set_hl(0, 'BufferLineHintSelected', { link = 'BufferLineBufferSelected' })
    end,
  }):map '<leader>lb'

  -- Render Markdown
  Snacks.toggle({
    name = 'Render Markdown',
    get = function()
      return toggles.get 'render_markdown'
    end,
    set = function(state)
      toggles.set('render_markdown', state)
      if not package.loaded['render-markdown'] then
        require('lazy').load { plugins = { 'render-markdown.nvim' } }
      end
      if state then
        vim.cmd 'RenderMarkdown enable'
      else
        vim.cmd 'RenderMarkdown disable'
      end
    end,
  }):map '<leader>uu'

  -- Render Markdown theme (preset) picker — lives under <leader>lq (Theme group)
  vim.keymap.set('n', '<leader>lqm', function()
    local presets = {
      { name = 'none', label = 'None (default)' },
      { name = 'lazy', label = 'Lazy' },
      { name = 'obsidian', label = 'Obsidian' },
    }
    local current = toggles.get 'render_markdown_theme'
    vim.ui.select(presets, {
      prompt = 'Render Markdown · select theme',
      kind = 'render_markdown_theme',
      format_item = function(t)
        local marker = t.name == current and ' ●' or ''
        return t.label .. marker
      end,
    }, function(choice)
      if not choice then
        return
      end
      toggles.set('render_markdown_theme', choice.name)
      if not package.loaded['render-markdown'] then
        require('lazy').load { plugins = { 'render-markdown.nvim' } }
      end
      local rm = require 'render-markdown'
      -- Rebuild config from the new preset, then honor the on/off toggle.
      -- setup() resets the internal enabled flag, so re-apply it explicitly.
      rm.setup { preset = choice.name }
      rm.disable()
      if toggles.get 'render_markdown' then
        rm.enable()
      end
      Snacks.notify.info('Render Markdown theme: ' .. choice.label)
    end)
  end, { desc = 'Render Markdown: Select Theme' })

  -- Image Preview
  Snacks.toggle({
    name = 'Image Preview',
    get = function()
      return toggles.get 'image_preview'
    end,
    set = function(state)
      toggles.set('image_preview', state)
      if state then
        Snacks.image.hover()
      end
    end,
  }):map '<leader>lm'

  -- Dropbar
  Snacks.toggle({
    name = 'Dropbar',
    get = function()
      return toggles.get 'dropbar'
    end,
    set = function(state)
      toggles.set('dropbar', state)
      if not package.loaded['dropbar'] then
        require('lazy').load { plugins = { 'dropbar.nvim' } }
      end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if not state then
          vim.api.nvim_set_option_value('winbar', '', { scope = 'local', win = win })
        else
          local buf = vim.api.nvim_win_get_buf(win)
          vim.api.nvim_exec_autocmds('BufWinEnter', { buffer = buf })
        end
      end
    end,
  }):map '<leader>lu'
end

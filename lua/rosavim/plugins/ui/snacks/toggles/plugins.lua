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

  -- Sidekick Auto Focus
  Snacks.toggle({
    name = 'Sidekick Auto Focus',
    get = function()
      return toggles.get 'sidekick_auto_focus'
    end,
    set = function(state)
      toggles.set('sidekick_auto_focus', state)
    end,
  }):map '<leader>al'

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

  -- Markview
  Snacks.toggle({
    name = 'Markview',
    get = function()
      return toggles.get 'markview'
    end,
    set = function(state)
      toggles.set('markview', state)
      if not package.loaded['markview'] then
        require('lazy').load { plugins = { 'markview.nvim' } }
      end
      if state then
        vim.cmd 'Markview Enable'
      else
        vim.cmd 'Markview Disable'
      end
    end,
  }):map '<leader>uu'

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

local toggles = require 'rosavim.config.toggles'

return function()
  -- Snacks
  Snacks.toggle({
    name = 'Explorer Startup',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'snacks_explorer'
    end,
    set = function(state)
      toggles.set('snacks_explorer', state)
    end,
  }):map '<leader>lase'

  Snacks.toggle({
    name = 'Explorer Focus',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'snacks_explorer_focus'
    end,
    set = function(state)
      toggles.set('snacks_explorer_focus', state)
    end,
  }):map '<leader>lasf'

  Snacks.toggle({
    name = 'Explorer Position',
    wk_desc = { enabled = 'Left ', disabled = 'Right ' },
    get = function()
      return toggles.get 'explorer_right'
    end,
    set = function(state)
      toggles.set('explorer_right', state)
      local pos = state and 'right' or 'left'
      Snacks.config.picker.sources.explorer.layout.layout.position = pos
    end,
  }):map '<leader>lasr'

  Snacks.toggle({
    name = 'Picker Hidden Files',
    get = function()
      return toggles.get 'picker_hidden'
    end,
    set = function(state)
      toggles.set('picker_hidden', state)
      Snacks.config.picker.hidden = state
      Snacks.config.picker.sources.files.hidden = state
    end,
  }):map '<leader>lash'

  Snacks.toggle({
    name = 'Picker Ignored Files',
    get = function()
      return toggles.get 'picker_ignored'
    end,
    set = function(state)
      toggles.set('picker_ignored', state)
      Snacks.config.picker.ignored = state
    end,
  }):map '<leader>lasi'

  -- Editor
  Snacks.toggle({
    name = 'Last Cursor Position',
    get = function()
      return toggles.get 'lastpos'
    end,
    set = function(state)
      toggles.set('lastpos', state)
    end,
  }):map '<leader>laec'

  Snacks.toggle({
    name = 'Dotenv Syntax',
    get = function()
      return toggles.get 'dotenv_syntax'
    end,
    set = function(state)
      toggles.set('dotenv_syntax', state)
    end,
  }):map '<leader>laed'

  Snacks.toggle({
    name = 'No Auto Comment',
    get = function()
      return toggles.get 'no_auto_comment'
    end,
    set = function(state)
      toggles.set('no_auto_comment', state)
    end,
  }):map '<leader>laeo'

  Snacks.toggle({
    name = 'Autosave (FocusLost)',
    get = function()
      return toggles.get 'autosave_focuslost'
    end,
    set = function(state)
      toggles.set('autosave_focuslost', state)
    end,
  }):map '<leader>laes'

  -- LSP
  Snacks.toggle({
    name = 'Custom LSP Reference Highlights',
    get = function()
      return toggles.get 'lsp_ref_highlights'
    end,
    set = function(state)
      toggles.set('lsp_ref_highlights', state)
      if state then
        local hl = { bold = true, bg = 'none', fg = '#FFFFFF' }
        vim.api.nvim_set_hl(0, 'LspReferenceRead', hl)
        vim.api.nvim_set_hl(0, 'LspReferenceWrite', hl)
        vim.api.nvim_set_hl(0, 'LspReferenceText', hl)
      else
        vim.cmd.colorscheme(vim.g.colors_name)
      end
    end,
  }):map '<leader>lalh'

  -- Sidekick
  Snacks.toggle({
    name = 'Sidekick Position',
    wk_desc = { enabled = 'Left ', disabled = 'Right ' },
    get = function()
      return toggles.get 'sidekick_right'
    end,
    set = function(state)
      toggles.set('sidekick_right', state)
    end,
  }):map '<leader>laae'

  -- DBUI
  Snacks.toggle({
    name = 'DBUI No Folding',
    get = function()
      return toggles.get 'dbout_no_folding'
    end,
    set = function(state)
      toggles.set('dbout_no_folding', state)
    end,
  }):map '<leader>ladf'
end

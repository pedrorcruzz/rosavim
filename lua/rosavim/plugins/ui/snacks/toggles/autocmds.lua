local toggles = require 'rosavim.config.toggles'

return function()
  -- Snacks
  Snacks.toggle({
    name = 'Snacks Explorer (startup)',
    get = function()
      return toggles.get 'snacks_explorer'
    end,
    set = function(state)
      toggles.set('snacks_explorer', state)
    end,
  }):map '<leader>lase'

  Snacks.toggle({
    name = 'Snacks Explorer Focus',
    get = function()
      return toggles.get 'snacks_explorer_focus'
    end,
    set = function(state)
      toggles.set('snacks_explorer_focus', state)
    end,
  }):map '<leader>lasf'

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
    name = 'LSP Reference Highlights',
    get = function()
      return toggles.get 'lsp_ref_highlights'
    end,
    set = function(state)
      toggles.set('lsp_ref_highlights', state)
    end,
  }):map '<leader>lalh'

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

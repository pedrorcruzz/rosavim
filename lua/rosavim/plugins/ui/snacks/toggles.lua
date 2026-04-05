local toggles = require 'rosavim.config.toggles'

local function persist_toggle(snacks_toggle, key)
  local orig_toggle = snacks_toggle.toggle
  snacks_toggle.toggle = function(self)
    orig_toggle(self)
    toggles.set(key, self:get())
  end
  return snacks_toggle
end

-- Built-in Snacks toggles (vim options)
persist_toggle(Snacks.toggle.option('wrap', { name = 'Wrap' }), 'wrap'):map '<leader>lw'
persist_toggle(Snacks.toggle.option('relativenumber', { name = 'Relative Number' }), 'relativenumber'):map '<leader>lg'
persist_toggle(Snacks.toggle.line_number(), 'linenumber'):map '<leader>ln'
Snacks.toggle.zen():map '<leader>lz'
persist_toggle(Snacks.toggle.indent(), 'indent'):map '<leader>li'
persist_toggle(Snacks.toggle.dim(), 'dim'):map '<leader>lk'

-- Spell
Snacks.toggle({
  name = 'Spellcheck',
  get = function()
    return vim.o.spell
  end,
  set = function(state)
    vim.o.spell = state
    toggles.set('spell', state)
  end,
}):map '<leader>ljj'

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

-- TSContext
Snacks.toggle({
  name = 'TSContext',
  get = function()
    return toggles.get 'tscontext'
  end,
  set = function(state)
    toggles.set('tscontext', state)
    local ok, context = pcall(require, 'treesitter-context')
    if ok then
      context.toggle()
    end
  end,
}):map '<leader>lt'

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

-- Autocmd Toggles: Snacks
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

-- Autocmd Toggles: Editor
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

-- Autocmd Toggles: LSP
Snacks.toggle({
  name = 'LSP Reference Highlights',
  get = function()
    return toggles.get 'lsp_ref_highlights'
  end,
  set = function(state)
    toggles.set('lsp_ref_highlights', state)
  end,
}):map '<leader>lalh'

-- Autocmd Toggles: DBUI
Snacks.toggle({
  name = 'DBUI No Folding',
  get = function()
    return toggles.get 'dbout_no_folding'
  end,
  set = function(state)
    toggles.set('dbout_no_folding', state)
  end,
}):map '<leader>ladf'

-- Restore persisted states
if toggles.get 'indent' then
  Snacks.toggle.indent():set(true)
end
if toggles.get 'dim' then
  Snacks.toggle.dim():set(true)
end

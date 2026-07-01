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
      Snacks.config.picker.sources.explorer.hidden = state
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
      Snacks.config.picker.sources.files.ignored = state
      Snacks.config.picker.sources.explorer.ignored = state
    end,
  }):map '<leader>lasi'

  -- Picker Layout — uses vim.ui.select (rendered by snacks)
  vim.keymap.set('n', '<leader>lqp', function()
    local presets = {
      { name = 'default', icon = '󰠲 ' },
      { name = 'telescope', icon = '󰭎 ' },
      { name = 'ivy', icon = '󰌪 ' },
      { name = 'dropdown', icon = '󰍜 ' },
      { name = 'vertical', icon = '󰯋 ' },
      { name = 'vscode', icon = '󰨞 ' },
    }
    local current = toggles.get 'picker_layout'
    vim.ui.select(presets, {
      prompt = 'Picker · select layout',
      kind = 'picker_layout',
      format_item = function(p)
        return p.icon .. p.name .. (p.name == current and ' ●' or '')
      end,
    }, function(choice)
      if not choice then
        return
      end
      toggles.set('picker_layout', choice.name)
      Snacks.config.picker.layout.preset = choice.name
      Snacks.notify.info('Picker layout: ' .. choice.name)
    end)
  end, { desc = 'Picker Layout' })

  -- Picker Preview
  Snacks.toggle({
    name = 'Picker Preview',
    get = function()
      return toggles.get 'picker_preview'
    end,
    set = function(state)
      toggles.set('picker_preview', state)
      Snacks.config.picker.layout.preview = state
    end,
  }):map '<leader>lasp'

  -- Explorer Preview (default off). Separate from the picker preview above —
  -- toggles the preview pane of the Snacks explorer source specifically.
  Snacks.toggle({
    name = 'Explorer Preview',
    get = function()
      return toggles.get 'explorer_preview'
    end,
    set = function(state)
      toggles.set('explorer_preview', state)
      Snacks.config.picker.sources.explorer.layout.preview = state
    end,
  }):map '<leader>lasP'

  -- Picker Border — uses vim.ui.select (rendered by snacks)
  vim.keymap.set('n', '<leader>lasb', function()
    local borders = {
      { name = 'none', icon = '󰹞 ' },
      { name = 'single', icon = '󰡎 ' },
      { name = 'double', icon = '󰡏 ' },
      { name = 'rounded', icon = '󰄮 ' },
      { name = 'solid', icon = '󰝤 ' },
      { name = 'shadow', icon = '󰘸 ' },
    }
    local current = toggles.get 'picker_border'
    vim.ui.select(borders, {
      prompt = 'Picker · select border',
      kind = 'picker_border',
      format_item = function(b)
        return b.icon .. b.name .. (b.name == current and ' ●' or '')
      end,
    }, function(choice)
      if not choice then
        return
      end
      -- Two paths: (1) the picker layout's `config` hook (picker.lua) reads
      -- `picker_border` live and rewrites the picker box borders; (2) the
      -- vim.ui.select popups use `border = true`, which resolves to `winborder`,
      -- so set it too to keep those popups in sync. The top-level
      -- `Snacks.config.picker.layout.border` field is never consumed.
      toggles.set('picker_border', choice.name)
      vim.o.winborder = choice.name
      Snacks.notify.info('Picker border: ' .. choice.name)
    end)
  end, { desc = 'Picker Border' })

  -- Which-Key Preset — uses vim.ui.select (rendered by snacks)
  vim.keymap.set('n', '<leader>lqw', function()
    local presets = {
      { name = 'classic', icon = '󰌌 ' },
      { name = 'modern', icon = '󰏗 ' },
      { name = 'helix', icon = '󰜥 ' },
    }
    local current = toggles.get 'whichkey_preset'
    vim.ui.select(presets, {
      prompt = 'Which-Key · select preset',
      kind = 'whichkey_preset',
      format_item = function(p)
        return p.icon .. p.name .. (p.name == current and ' ●' or '')
      end,
    }, function(choice)
      if not choice then
        return
      end
      toggles.set('whichkey_preset', choice.name)
      require('which-key').setup { preset = choice.name, win = { border = toggles.get 'whichkey_border' } }
      Snacks.notify.info('Which-Key preset: ' .. choice.name)
    end)
  end, { desc = 'Which-Key Preset' })

  -- Which-Key Border — uses vim.ui.select (rendered by snacks)
  vim.keymap.set('n', '<leader>lqb', function()
    local borders = {
      { name = 'none', icon = '󰹞 ' },
      { name = 'single', icon = '󰡎 ' },
      { name = 'double', icon = '󰡏 ' },
      { name = 'shadow', icon = '󰘸 ' },
    }
    local current = toggles.get 'whichkey_border'
    vim.ui.select(borders, {
      prompt = 'Which-Key · select border',
      kind = 'whichkey_border',
      format_item = function(b)
        return b.icon .. b.name .. (b.name == current and ' ●' or '')
      end,
    }, function(choice)
      if not choice then
        return
      end
      toggles.set('whichkey_border', choice.name)
      require('which-key').setup { preset = toggles.get 'whichkey_preset', win = { border = choice.name } }
      Snacks.notify.info('Which-Key border: ' .. choice.name)
    end)
  end, { desc = 'Which-Key Border' })

  -- Editor
  Snacks.toggle({
    name = 'Last Cursor Position',
    get = function()
      return toggles.get 'lastpos'
    end,
    set = function(state)
      toggles.set('lastpos', state)
    end,
  }):map '<leader>ld'

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
        local fg = vim.o.background == 'light' and '#000000' or '#FFFFFF'
        local hl = { bold = true, bg = 'none', fg = fg }
        vim.api.nvim_set_hl(0, 'LspReferenceRead', hl)
        vim.api.nvim_set_hl(0, 'LspReferenceWrite', hl)
        vim.api.nvim_set_hl(0, 'LspReferenceText', hl)
      else
        vim.cmd.colorscheme(vim.g.colors_name)
      end
    end,
  }):map '<leader>lalh'

  Snacks.toggle({
    name = 'Virtual Text (current line)',
    get = function()
      return toggles.get 'virtual_text_current_line'
    end,
    set = function(state)
      toggles.set('virtual_text_current_line', state)
      vim.diagnostic.config {
        virtual_text = { current_line = state },
      }
    end,
  }):map '<leader>lalv'

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

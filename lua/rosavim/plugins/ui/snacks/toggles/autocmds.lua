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

  -- Picker Layout (popup selector)
  vim.keymap.set('n', '<leader>lasl', function()
    local palette = require('rosavim.rosa_plugins.palette').get()
    local ns = vim.api.nvim_create_namespace 'picker_layout'
    vim.api.nvim_set_hl(0, 'PickerLayoutTitle', { fg = palette.title, bold = true })
    vim.api.nvim_set_hl(0, 'PickerLayoutBorder', { fg = palette.border })
    vim.api.nvim_set_hl(0, 'PickerLayoutKey', { fg = palette.key, bold = true })
    vim.api.nvim_set_hl(0, 'PickerLayoutName', { fg = palette.green })
    vim.api.nvim_set_hl(0, 'PickerLayoutActive', { fg = palette.pink, bold = true })
    vim.api.nvim_set_hl(0, 'PickerLayoutDim', { fg = palette.dim })

    local presets = {
      { key = 'd', name = 'default', icon = '󰠲 ' },
      { key = 't', name = 'telescope', icon = '󰭎 ' },
      { key = 'i', name = 'ivy', icon = '󰌪 ' },
      { key = 'r', name = 'dropdown', icon = '󰍜 ' },
      { key = 'v', name = 'vertical', icon = '󰯋 ' },
      { key = 'c', name = 'vscode', icon = '󰨞 ' },
    }

    local current = toggles.get 'picker_layout'
    local pad = '       '
    local gap = '    '
    local lines = {}
    local highlights = {}
    local ln = 0

    local function add(text, hl)
      table.insert(lines, text)
      if hl then
        table.insert(highlights, { hl, ln })
      end
      ln = ln + 1
    end

    local function add_hl(hl_name, line_nr, col_start, col_end)
      table.insert(highlights, { hl_name, line_nr, col_start, col_end })
    end

    add(pad .. 'Select picker layout', 'PickerLayoutDim')
    add(pad .. string.rep('─', 36), 'PickerLayoutDim')
    add ''

    for _, p in ipairs(presets) do
      local active = p.name == current
      local marker = active and ' ●' or ''
      local line = pad .. p.key .. gap .. p.icon .. p.name .. marker
      add(line)
      add_hl('PickerLayoutKey', ln - 1, #pad, #pad + #p.key)
      if active then
        add_hl('PickerLayoutActive', ln - 1, #pad + #p.key + #gap, -1)
      else
        add_hl('PickerLayoutName', ln - 1, #pad + #p.key + #gap, -1)
      end
    end

    add ''

    local width = 48
    local height = #lines
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'

    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      width = width,
      height = height,
      style = 'minimal',
      border = 'rounded',
      title = ' 󰠲 Picker Layout ',
      title_pos = 'center',
      footer = ' q: close ',
      footer_pos = 'center',
      zindex = 50,
    })
    vim.wo[win].winhl = 'Normal:Normal,FloatBorder:PickerLayoutBorder,FloatTitle:PickerLayoutTitle,FloatFooter:PickerLayoutDim'
    vim.wo[win].cursorline = false

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    for _, hl in ipairs(highlights) do
      vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
    end

    local function close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    local kopts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set('n', 'q', close, kopts)
    vim.keymap.set('n', '<Esc>', close, kopts)

    for _, p in ipairs(presets) do
      vim.keymap.set('n', p.key, function()
        close()
        vim.schedule(function()
          toggles.set('picker_layout', p.name)
          Snacks.config.picker.layout.preset = p.name
          Snacks.notify.info('Picker layout: ' .. p.name)
        end)
      end, kopts)
    end
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

  -- Picker Border (popup selector)
  vim.keymap.set('n', '<leader>lasb', function()
    local palette = require('rosavim.rosa_plugins.palette').get()
    local ns = vim.api.nvim_create_namespace 'picker_border'
    vim.api.nvim_set_hl(0, 'PickerBorderTitle', { fg = palette.title, bold = true })
    vim.api.nvim_set_hl(0, 'PickerBorderBorder', { fg = palette.border })
    vim.api.nvim_set_hl(0, 'PickerBorderKey', { fg = palette.key, bold = true })
    vim.api.nvim_set_hl(0, 'PickerBorderName', { fg = palette.green })
    vim.api.nvim_set_hl(0, 'PickerBorderActive', { fg = palette.pink, bold = true })
    vim.api.nvim_set_hl(0, 'PickerBorderDim', { fg = palette.dim })

    local borders = {
      { key = 'n', name = 'none', icon = '󰹞 ' },
      { key = 's', name = 'single', icon = '󰡎 ' },
      { key = 'd', name = 'double', icon = '󰡏 ' },
      { key = 'r', name = 'rounded', icon = '󰄮 ' },
      { key = 'o', name = 'solid', icon = '󰝤 ' },
      { key = 'w', name = 'shadow', icon = '󰘸 ' },
    }

    local current = toggles.get 'picker_border'
    local pad = '       '
    local gap = '    '
    local lines = {}
    local highlights = {}
    local ln = 0

    local function add(text, hl)
      table.insert(lines, text)
      if hl then
        table.insert(highlights, { hl, ln })
      end
      ln = ln + 1
    end

    local function add_hl(hl_name, line_nr, col_start, col_end)
      table.insert(highlights, { hl_name, line_nr, col_start, col_end })
    end

    add(pad .. 'Select picker border', 'PickerBorderDim')
    add(pad .. string.rep('─', 36), 'PickerBorderDim')
    add ''

    for _, b in ipairs(borders) do
      local active = b.name == current
      local marker = active and ' ●' or ''
      local line = pad .. b.key .. gap .. b.icon .. b.name .. marker
      add(line)
      add_hl('PickerBorderKey', ln - 1, #pad, #pad + #b.key)
      if active then
        add_hl('PickerBorderActive', ln - 1, #pad + #b.key + #gap, -1)
      else
        add_hl('PickerBorderName', ln - 1, #pad + #b.key + #gap, -1)
      end
    end

    add ''

    local width = 48
    local height = #lines
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'

    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      width = width,
      height = height,
      style = 'minimal',
      border = 'rounded',
      title = ' 󰡎 Picker Border ',
      title_pos = 'center',
      footer = ' q: close ',
      footer_pos = 'center',
      zindex = 50,
    })
    vim.wo[win].winhl = 'Normal:Normal,FloatBorder:PickerBorderBorder,FloatTitle:PickerBorderTitle,FloatFooter:PickerBorderDim'
    vim.wo[win].cursorline = false

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    for _, hl in ipairs(highlights) do
      vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
    end

    local function close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    local kopts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set('n', 'q', close, kopts)
    vim.keymap.set('n', '<Esc>', close, kopts)

    for _, b in ipairs(borders) do
      vim.keymap.set('n', b.key, function()
        close()
        vim.schedule(function()
          toggles.set('picker_border', b.name)
          Snacks.config.picker.layout.border = b.name
          Snacks.notify.info('Picker border: ' .. b.name)
        end)
      end, kopts)
    end
  end, { desc = 'Picker Border' })

  -- Which-Key Preset (popup selector)
  vim.keymap.set('n', '<leader>lawp', function()
    local palette = require('rosavim.rosa_plugins.palette').get()
    local ns = vim.api.nvim_create_namespace 'whichkey_preset'
    vim.api.nvim_set_hl(0, 'WKPresetTitle', { fg = palette.title, bold = true })
    vim.api.nvim_set_hl(0, 'WKPresetBorder', { fg = palette.border })
    vim.api.nvim_set_hl(0, 'WKPresetKey', { fg = palette.key, bold = true })
    vim.api.nvim_set_hl(0, 'WKPresetName', { fg = palette.green })
    vim.api.nvim_set_hl(0, 'WKPresetActive', { fg = palette.pink, bold = true })
    vim.api.nvim_set_hl(0, 'WKPresetDim', { fg = palette.dim })

    local presets = {
      { key = 'c', name = 'classic', icon = '󰌌 ' },
      { key = 'm', name = 'modern', icon = '󰏗 ' },
      { key = 'h', name = 'helix', icon = '󰜥 ' },
    }

    local current = toggles.get 'whichkey_preset'
    local pad = '       '
    local gap = '    '
    local lines = {}
    local highlights = {}
    local ln = 0

    local function add(text, hl)
      table.insert(lines, text)
      if hl then
        table.insert(highlights, { hl, ln })
      end
      ln = ln + 1
    end

    local function add_hl(hl_name, line_nr, col_start, col_end)
      table.insert(highlights, { hl_name, line_nr, col_start, col_end })
    end

    add(pad .. 'Select which-key preset', 'WKPresetDim')
    add(pad .. string.rep('─', 36), 'WKPresetDim')
    add ''

    for _, p in ipairs(presets) do
      local active = p.name == current
      local marker = active and ' ●' or ''
      local line = pad .. p.key .. gap .. p.icon .. p.name .. marker
      add(line)
      add_hl('WKPresetKey', ln - 1, #pad, #pad + #p.key)
      if active then
        add_hl('WKPresetActive', ln - 1, #pad + #p.key + #gap, -1)
      else
        add_hl('WKPresetName', ln - 1, #pad + #p.key + #gap, -1)
      end
    end

    add ''

    local width = 48
    local height = #lines
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'

    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      width = width,
      height = height,
      style = 'minimal',
      border = 'rounded',
      title = ' 󰌌 Which-Key Preset ',
      title_pos = 'center',
      footer = ' q: close ',
      footer_pos = 'center',
      zindex = 50,
    })
    vim.wo[win].winhl = 'Normal:Normal,FloatBorder:WKPresetBorder,FloatTitle:WKPresetTitle,FloatFooter:WKPresetDim'
    vim.wo[win].cursorline = false

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    for _, hl in ipairs(highlights) do
      vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
    end

    local function close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    local kopts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set('n', 'q', close, kopts)
    vim.keymap.set('n', '<Esc>', close, kopts)

    for _, p in ipairs(presets) do
      vim.keymap.set('n', p.key, function()
        close()
        vim.schedule(function()
          toggles.set('whichkey_preset', p.name)
          require('which-key').setup { preset = p.name, win = { border = toggles.get 'whichkey_border' } }
          Snacks.notify.info('Which-Key preset: ' .. p.name)
        end)
      end, kopts)
    end
  end, { desc = 'Which-Key Preset' })

  -- Which-Key Border (popup selector)
  vim.keymap.set('n', '<leader>lawb', function()
    local palette = require('rosavim.rosa_plugins.palette').get()
    local ns = vim.api.nvim_create_namespace 'whichkey_border'
    vim.api.nvim_set_hl(0, 'WKBorderTitle', { fg = palette.title, bold = true })
    vim.api.nvim_set_hl(0, 'WKBorderBorder', { fg = palette.border })
    vim.api.nvim_set_hl(0, 'WKBorderKey', { fg = palette.key, bold = true })
    vim.api.nvim_set_hl(0, 'WKBorderName', { fg = palette.green })
    vim.api.nvim_set_hl(0, 'WKBorderActive', { fg = palette.pink, bold = true })
    vim.api.nvim_set_hl(0, 'WKBorderDim', { fg = palette.dim })

    local borders = {
      { key = 'n', name = 'none', icon = '󰹞 ' },
      { key = 's', name = 'single', icon = '󰡎 ' },
      { key = 'd', name = 'double', icon = '󰡏 ' },
      { key = 'w', name = 'shadow', icon = '󰘸 ' },
    }

    local current = toggles.get 'whichkey_border'
    local pad = '       '
    local gap = '    '
    local lines = {}
    local highlights = {}
    local ln = 0

    local function add(text, hl)
      table.insert(lines, text)
      if hl then
        table.insert(highlights, { hl, ln })
      end
      ln = ln + 1
    end

    local function add_hl(hl_name, line_nr, col_start, col_end)
      table.insert(highlights, { hl_name, line_nr, col_start, col_end })
    end

    add(pad .. 'Select which-key border', 'WKBorderDim')
    add(pad .. string.rep('─', 36), 'WKBorderDim')
    add ''

    for _, b in ipairs(borders) do
      local active = b.name == current
      local marker = active and ' ●' or ''
      local line = pad .. b.key .. gap .. b.icon .. b.name .. marker
      add(line)
      add_hl('WKBorderKey', ln - 1, #pad, #pad + #b.key)
      if active then
        add_hl('WKBorderActive', ln - 1, #pad + #b.key + #gap, -1)
      else
        add_hl('WKBorderName', ln - 1, #pad + #b.key + #gap, -1)
      end
    end

    add ''

    local width = 48
    local height = #lines
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'

    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      width = width,
      height = height,
      style = 'minimal',
      border = 'rounded',
      title = ' 󰡎 Which-Key Border ',
      title_pos = 'center',
      footer = ' q: close ',
      footer_pos = 'center',
      zindex = 50,
    })
    vim.wo[win].winhl = 'Normal:Normal,FloatBorder:WKBorderBorder,FloatTitle:WKBorderTitle,FloatFooter:WKBorderDim'
    vim.wo[win].cursorline = false

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    for _, hl in ipairs(highlights) do
      vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
    end

    local function close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    local kopts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set('n', 'q', close, kopts)
    vim.keymap.set('n', '<Esc>', close, kopts)

    for _, b in ipairs(borders) do
      vim.keymap.set('n', b.key, function()
        close()
        vim.schedule(function()
          toggles.set('whichkey_border', b.name)
          require('which-key').setup { preset = toggles.get 'whichkey_preset', win = { border = b.name } }
          Snacks.notify.info('Which-Key border: ' .. b.name)
        end)
      end, kopts)
    end
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

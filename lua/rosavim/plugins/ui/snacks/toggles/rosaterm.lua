local toggles = require 'rosavim.config.toggles'

return function()
  Snacks.toggle({
    name = 'Rosaterm Theme',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaterm_title'
    end,
    set = function(state)
      toggles.set('rosaterm_title', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_chips()
      end
    end,
  }):map '<leader>latt'

  Snacks.toggle({
    name = 'Rosaterm Time',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get 'rosaterm_time'
    end,
    set = function(state)
      toggles.set('rosaterm_time', state)
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_chips()
      end
    end,
  }):map '<leader>lath'

  Snacks.toggle({
    name = 'Rosaterm Auto Insert',
    wk_desc = { enabled = 'Disable ', disabled = 'Enable ' },
    get = function()
      return toggles.get 'rosaterm_autoinsert'
    end,
    set = function(state)
      toggles.set('rosaterm_autoinsert', state)
    end,
  }):map '<leader>lati'

  -- Theme selector (popup)
  vim.keymap.set('n', '<leader>lats', function()
    local palette = require('rosavim.rosa_plugins.palette').get()
    local themes = require 'rosavim.rosa_plugins.rosaterm.themes'
    local ns = vim.api.nvim_create_namespace 'rosaterm_theme_picker'
    vim.api.nvim_set_hl(0, 'RosatermPickerTitle', { fg = palette.title, bold = true })
    vim.api.nvim_set_hl(0, 'RosatermPickerBorder', { fg = palette.border })
    vim.api.nvim_set_hl(0, 'RosatermPickerKey', { fg = palette.key, bold = true })
    vim.api.nvim_set_hl(0, 'RosatermPickerName', { fg = palette.green })
    vim.api.nvim_set_hl(0, 'RosatermPickerActive', { fg = palette.pink, bold = true })
    vim.api.nvim_set_hl(0, 'RosatermPickerDim', { fg = palette.dim })

    local current = themes.current().name
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

    add(pad .. 'Select Rosaterm theme', 'RosatermPickerDim')
    add(pad .. string.rep('─', 36), 'RosatermPickerDim')
    add ''

    local entries = {}
    local seen_keys = {}
    for _, t in ipairs(themes.list) do
      local key = t.label:sub(1, 1):lower()
      local i = 2
      while seen_keys[key] and i <= #t.label do
        key = t.label:sub(i, i):lower()
        i = i + 1
      end
      seen_keys[key] = true
      table.insert(entries, { key = key, theme = t })
      local active = t.name == current
      local marker = active and ' ●' or ''
      local line = pad .. key .. gap .. t.icon .. ' ' .. t.label .. marker
      add(line)
      add_hl('RosatermPickerKey', ln - 1, #pad, #pad + #key)
      if active then
        add_hl('RosatermPickerActive', ln - 1, #pad + #key + #gap, -1)
      else
        add_hl('RosatermPickerName', ln - 1, #pad + #key + #gap, -1)
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
      title = ' 󰧱 Rosaterm Theme ',
      title_pos = 'center',
      footer = ' q: close ',
      footer_pos = 'center',
      zindex = 50,
    })
    vim.wo[win].winhl =
      'Normal:Normal,FloatBorder:RosatermPickerBorder,FloatTitle:RosatermPickerTitle,FloatFooter:RosatermPickerDim'
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

    for _, e in ipairs(entries) do
      vim.keymap.set('n', e.key, function()
        close()
        vim.schedule(function()
          themes.set(e.theme.name)
          Snacks.notify.info('Rosaterm theme: ' .. e.theme.label)
        end)
      end, kopts)
    end
  end, { desc = 'Rosaterm: Select Theme' })
end

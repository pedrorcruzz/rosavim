--- Dashboard gif toggles — manage the chafa-rendered animation on the dashboard.
---
--- Keys registered (under <leader>lqd):
---   <leader>lqdt  toggle gif on/off (persisted)
---   <leader>lqds  pick an image/gif from dashboard_img/ (persisted)
---   <leader>lqdc  rosa-style popup to edit height/width/indent individually
---
--- All changes hot-reload via Snacks.dashboard.update(); no restart required.
local toggles = require 'rosavim.config.toggles'

local dashboard_dir = vim.fn.stdpath 'config' .. '/lua/rosavim/plugins/ui/dashboard_img'

local IMG_EXTS = {
  ['.gif'] = true,
  ['.png'] = true,
  ['.jpg'] = true,
  ['.jpeg'] = true,
  ['.webp'] = true,
  ['.bmp'] = true,
}

local ns = vim.api.nvim_create_namespace 'rosadashboardgif'

local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  vim.api.nvim_set_hl(0, 'RosaGifTitle', { fg = p.title, bold = true })
  vim.api.nvim_set_hl(0, 'RosaGifBorder', { fg = p.border })
  vim.api.nvim_set_hl(0, 'RosaGifKey', { fg = p.key, bold = true })
  vim.api.nvim_set_hl(0, 'RosaGifAction', { fg = p.text })
  vim.api.nvim_set_hl(0, 'RosaGifValue', { fg = p.pink, bold = true })
  vim.api.nvim_set_hl(0, 'RosaGifDim', { fg = p.dim })
end

local function create_float(opts)
  local width = opts.width or 52
  local height = opts.height or 12
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosadashboardgif'

  local win_opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. (opts.title or 'Dashboard Gif') .. ' ',
    title_pos = 'center',
    zindex = 50,
  }
  if opts.footer then
    win_opts.footer = ' ' .. opts.footer .. ' '
    win_opts.footer_pos = 'center'
  end

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosaGifBorder,FloatTitle:RosaGifTitle,FloatFooter:RosaGifDim'
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  return buf, win
end

local function refresh_dashboard()
  local ok, dashboard = pcall(function()
    return Snacks.dashboard
  end)
  if not ok or not dashboard then
    return
  end
  -- Update only re-renders if a dashboard buffer exists. If we're not on the
  -- dashboard, this is a no-op (the new values will be picked up next open).
  pcall(dashboard.update)
end

local function list_images()
  if vim.fn.isdirectory(dashboard_dir) == 0 then
    return {}
  end
  local entries = vim.fn.readdir(dashboard_dir)
  local images = {}
  for _, name in ipairs(entries) do
    local ext = name:match '^.+(%..+)$'
    if ext and IMG_EXTS[ext:lower()] then
      table.insert(images, name)
    end
  end
  table.sort(images)
  return images
end

local function pick_gif()
  local images = list_images()
  if #images == 0 then
    Snacks.notify.warn('Dashboard gif: no images found in ' .. dashboard_dir)
    return
  end

  local current = toggles.get 'dashboard_gif_name'
  local items = {}
  for _, name in ipairs(images) do
    local label = name == current and (name .. '  (current)') or name
    table.insert(items, { text = label, file = name })
  end

  Snacks.picker {
    title = ' Dashboard gif',
    items = items,
    format = 'text',
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      toggles.set('dashboard_gif_name', item.file)
      Snacks.notify.info('Dashboard gif: ' .. item.file)
      refresh_dashboard()
    end,
  }
end

local function prompt_dimension(label, key, default)
  vim.ui.input({
    prompt = label .. ' (current ' .. default .. '): ',
    default = tostring(default),
  }, function(input)
    if not input or input == '' then
      return
    end
    local n = tonumber(input)
    if not n then
      Snacks.notify.warn('Dashboard gif: invalid number "' .. input .. '"')
      return
    end
    toggles.set(key, n)
    Snacks.notify.info(string.format('Dashboard gif: %s = %d', label:lower(), n))
    refresh_dashboard()
  end)
end

local function config_popup()
  setup_highlights()

  local current_name = toggles.get 'dashboard_gif_name'
  local h = toggles.get 'dashboard_gif_height'
  local w = toggles.get 'dashboard_gif_width'
  local i = toggles.get 'dashboard_gif_indent'

  local pad = '       '
  local gap = '    '
  local label_w = 11

  local lines = {}
  local highlights = {}
  local ln = 0

  local function add(text)
    table.insert(lines, text)
    ln = ln + 1
  end

  local function add_hl(hl, line_nr, col_start, col_end)
    table.insert(highlights, { hl, line_nr, col_start, col_end })
  end

  local function values_row(label, value)
    return pad .. label .. string.rep(' ', label_w - #label) .. value
  end

  add(pad .. current_name)
  add_hl('RosaGifDim', ln - 1, #pad, -1)

  add(pad .. string.rep('─', 30))
  add_hl('RosaGifDim', ln - 1, #pad, -1)

  add(values_row('Height', tostring(h)))
  add_hl('RosaGifAction', ln - 1, #pad, #pad + label_w)
  add_hl('RosaGifValue', ln - 1, #pad + label_w, -1)

  add(values_row('Width', tostring(w)))
  add_hl('RosaGifAction', ln - 1, #pad, #pad + label_w)
  add_hl('RosaGifValue', ln - 1, #pad + label_w, -1)

  add(values_row('Indent', tostring(i)))
  add_hl('RosaGifAction', ln - 1, #pad, #pad + label_w)
  add_hl('RosaGifValue', ln - 1, #pad + label_w, -1)

  add(pad .. string.rep('─', 30))
  add_hl('RosaGifDim', ln - 1, #pad, -1)

  add ''

  local actions = {
    { key = 'h', label = 'Edit height', action = 'height' },
    { key = 'w', label = 'Edit width', action = 'width' },
    { key = 'i', label = 'Edit indent', action = 'indent' },
  }

  for _, a in ipairs(actions) do
    local line = pad .. a.key .. gap .. a.label
    local key_start = #pad
    local key_end = key_start + #a.key
    local label_start = key_end + #gap
    local label_end = label_start + #a.label

    add(line)
    add_hl('RosaGifKey', ln - 1, key_start, key_end)
    add_hl('RosaGifAction', ln - 1, label_start, label_end)
  end

  add ''

  local width_win = 52
  local height_win = #lines

  local buf, win = create_float {
    title = ' Dashboard Gif Config',
    footer = 'q: close',
    width = width_win,
    height = height_win,
  }

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

  local action_handlers = {
    height = function()
      prompt_dimension('Height', 'dashboard_gif_height', h)
    end,
    width = function()
      prompt_dimension('Width', 'dashboard_gif_width', w)
    end,
    indent = function()
      prompt_dimension('Indent', 'dashboard_gif_indent', i)
    end,
  }

  for _, a in ipairs(actions) do
    vim.keymap.set('n', a.key, function()
      close()
      vim.schedule(action_handlers[a.action])
    end, kopts)
  end
end

return function()
  -- On/off toggle — hot-reloads on next dashboard update
  Snacks.toggle({
    name = 'Dashboard Gif',
    get = function()
      return toggles.get 'dashboard_gif'
    end,
    set = function(state)
      toggles.set('dashboard_gif', state)
      refresh_dashboard()
    end,
  }):map '<leader>lqdt'

  vim.keymap.set('n', '<leader>lqds', pick_gif, { desc = 'Dashboard gif: Select image' })
  vim.keymap.set('n', '<leader>lqdc', config_popup, { desc = 'Dashboard gif: Configure dimensions' })
end

--- Rosadirs UI - Floating popups for the directory manager
local M = {}

local ns = vim.api.nvim_create_namespace 'rosadirs'

local SECTION_LABEL = {
  projects = 'Projects',
  obsidian = 'Obsidian',
}

local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  vim.api.nvim_set_hl(0, 'RosadirsTitle', { fg = p.title, bold = true })
  vim.api.nvim_set_hl(0, 'RosadirsBorder', { fg = p.border })
  vim.api.nvim_set_hl(0, 'RosadirsKey', { fg = p.key, bold = true })
  vim.api.nvim_set_hl(0, 'RosadirsAction', { fg = p.text })
  vim.api.nvim_set_hl(0, 'RosadirsCreate', { fg = p.green })
  vim.api.nvim_set_hl(0, 'RosadirsDanger', { fg = p.red, bold = true })
  vim.api.nvim_set_hl(0, 'RosadirsDim', { fg = p.dim })
  vim.api.nvim_set_hl(0, 'RosadirsInfo', { fg = p.teal })
  vim.api.nvim_set_hl(0, 'RosadirsWarn', { fg = p.yellow, bold = true })
  vim.api.nvim_set_hl(0, 'RosadirsCount', { fg = p.pink, bold = true })
end

--- Create a centered floating window
local function create_float(opts)
  local width = opts.width or 56
  local height = opts.height or 12
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosadirs'

  local win_opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. (opts.title or 'Rosadirs') .. ' ',
    title_pos = 'center',
    zindex = 50,
  }

  if opts.footer then
    win_opts.footer = ' ' .. opts.footer .. ' '
    win_opts.footer_pos = 'center'
  end

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosadirsBorder,FloatTitle:RosadirsTitle,FloatFooter:RosadirsDim'
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false

  return buf, win
end

--- Apply changes to live plugins and emit a friendly notification.
--- @param section 'projects' | 'obsidian' | nil
local function apply_and_notify(section)
  local status = require('rosavim.rosa_plugins.rosadirs').apply()

  -- Only mention obsidian state if the change affected obsidian
  local mentions_obsidian = section == 'obsidian' or section == nil
  if mentions_obsidian and status.obsidian == 'pending_restart' then
    Snacks.notify.info 'Rosadirs: changes applied. Restart Neovim to (re)load Obsidian.'
  else
    Snacks.notify.info 'Rosadirs: changes applied'
  end
end

--- Prompt the user for a directory path
--- @param section 'projects' | 'obsidian'
local function prompt_add(section)
  local prompt = section == 'projects' and 'Project path (use /* for subfolders): ' or 'Obsidian vault path: '

  vim.ui.input({
    prompt = prompt,
    default = '~/',
    completion = 'dir',
  }, function(input)
    if not input or input == '' or input == '~/' then
      return
    end

    -- Strip trailing whitespace
    input = input:gsub('%s+$', '')

    local ok, reason = require('rosavim.rosa_plugins.rosadirs').add(section, input)
    if not ok then
      Snacks.notify.warn('Rosadirs: ' .. (reason or 'failed to add'))
      return
    end
    Snacks.notify.info('Rosadirs: added to ' .. SECTION_LABEL[section] .. ' — ' .. input)
    apply_and_notify(section)
  end)
end

--- Show a snacks picker listing dirs in a section so the user can remove one
--- @param section 'projects' | 'obsidian'
local function pick_remove(section)
  local rosadirs = require 'rosavim.rosa_plugins.rosadirs'
  local list = rosadirs.list(section)

  if #list == 0 then
    Snacks.notify.info('Rosadirs: no ' .. SECTION_LABEL[section] .. ' directories')
    return
  end

  local items = {}
  for _, dir in ipairs(list) do
    table.insert(items, { text = dir, dir = dir })
  end

  Snacks.picker {
    title = ' Remove ' .. SECTION_LABEL[section] .. ' directory',
    items = items,
    format = 'text',
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      if rosadirs.remove(section, item.dir) then
        Snacks.notify.info('Rosadirs: removed ' .. item.dir)
        apply_and_notify(section)
      end
    end,
  }
end

--- Confirm + clear a section (or everything when section == nil)
--- @param section 'projects' | 'obsidian' | nil
local function confirm_clear(section)
  local rosadirs = require 'rosavim.rosa_plugins.rosadirs'

  local title, message, detail
  if section then
    local count = #rosadirs.list(section)
    if count == 0 then
      Snacks.notify.info('Rosadirs: no ' .. SECTION_LABEL[section] .. ' directories')
      return
    end
    title = ' Clear ' .. SECTION_LABEL[section]
    message = 'Remove all ' .. count .. ' ' .. SECTION_LABEL[section] .. ' directories?'
    detail = 'This cannot be undone.'
  else
    local total = #rosadirs.list 'projects' + #rosadirs.list 'obsidian'
    if total == 0 then
      Snacks.notify.info 'Rosadirs: nothing to clear'
      return
    end
    title = ' Clear EVERYTHING'
    message = 'Remove ALL ' .. total .. ' directories (projects + obsidian)?'
    detail = 'This cannot be undone.'
  end

  M.confirm_popup {
    title = title,
    message = message,
    detail = detail,
    on_confirm = function()
      if section then
        rosadirs.clear(section)
        Snacks.notify.info('Rosadirs: cleared ' .. SECTION_LABEL[section])
      else
        rosadirs.clear_all()
        Snacks.notify.info 'Rosadirs: cleared everything'
      end
      apply_and_notify(section)
    end,
  }
end

--- Main menu
function M.main_menu()
  setup_highlights()

  local rosadirs = require 'rosavim.rosa_plugins.rosadirs'
  local projects = rosadirs.list 'projects'
  local obsidian = rosadirs.list 'obsidian'

  local actions = {
    { key = 'a', label = 'Add project', action = 'add_project', hl = 'RosadirsCreate' },
    { key = 'd', label = 'Remove project', action = 'remove_project', hl = 'RosadirsInfo' },
    { key = 'c', label = 'Clear projects', action = 'clear_projects', hl = 'RosadirsDanger' },
    { sep = true },
    { key = 'A', label = 'Add obsidian vault', action = 'add_obsidian', hl = 'RosadirsCreate' },
    { key = 'D', label = 'Remove obsidian vault', action = 'remove_obsidian', hl = 'RosadirsInfo' },
    { key = 'C', label = 'Clear obsidian vaults', action = 'clear_obsidian', hl = 'RosadirsDanger' },
    { sep = true },
    { key = 'X', label = 'Clear EVERYTHING', action = 'clear_all', hl = 'RosadirsDanger' },
  }

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

  -- Section counts
  local label_w = 12
  local function counts_row(label, count)
    return pad .. label .. string.rep(' ', label_w - #label) .. count
  end

  local p_line = counts_row('Projects', tostring(#projects))
  add(p_line)
  add_hl('RosadirsAction', ln - 1, #pad, #pad + label_w)
  add_hl('RosadirsCount', ln - 1, #pad + label_w, -1)

  local o_line = counts_row('Obsidian', tostring(#obsidian))
  add(o_line)
  add_hl('RosadirsAction', ln - 1, #pad, #pad + label_w)
  add_hl('RosadirsCount', ln - 1, #pad + label_w, -1)

  add(pad .. string.rep('─', 38), 'RosadirsDim')
  add ''

  for _, a in ipairs(actions) do
    if a.sep then
      add ''
    else
      local line = pad .. a.key .. gap .. a.label
      local key_start = #pad
      local key_end = key_start + #a.key
      local label_start = key_end + #gap
      local label_end = label_start + #a.label

      add(line)
      add_hl('RosadirsKey', ln - 1, key_start, key_end)
      add_hl(a.hl, ln - 1, label_start, label_end)
    end
  end

  add ''

  local width = 56
  local height = #lines

  local buf, win = create_float {
    title = ' Rosadirs',
    footer = 'q: close',
    width = width,
    height = height,
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
    add_project = function()
      prompt_add 'projects'
    end,
    remove_project = function()
      pick_remove 'projects'
    end,
    clear_projects = function()
      confirm_clear 'projects'
    end,
    add_obsidian = function()
      prompt_add 'obsidian'
    end,
    remove_obsidian = function()
      pick_remove 'obsidian'
    end,
    clear_obsidian = function()
      confirm_clear 'obsidian'
    end,
    clear_all = function()
      confirm_clear(nil)
    end,
  }

  for _, a in ipairs(actions) do
    if not a.sep then
      vim.keymap.set('n', a.key, function()
        close()
        vim.schedule(function()
          local handler = action_handlers[a.action]
          if handler then
            handler()
          end
        end)
      end, kopts)
    end
  end
end

--- Confirm popup for destructive actions
--- @param opts { title: string, message: string, detail: string|nil, on_confirm: function }
function M.confirm_popup(opts)
  setup_highlights()

  local pad = '       '

  local lines = { '' }
  local highlights = {}
  local ln = 1

  table.insert(lines, pad .. opts.message)
  table.insert(highlights, { 'RosadirsWarn', ln })
  ln = ln + 1

  table.insert(lines, '')
  ln = ln + 1

  if opts.detail then
    table.insert(lines, pad .. opts.detail)
    table.insert(highlights, { 'RosadirsDim', ln })
    ln = ln + 1

    table.insert(lines, '')
    ln = ln + 1
  end

  table.insert(lines, pad .. string.rep('─', 30))
  table.insert(highlights, { 'RosadirsDim', ln })
  ln = ln + 1

  table.insert(lines, '')
  ln = ln + 1

  local confirm_line = pad .. 'y    Confirm          n    Cancel'
  table.insert(lines, confirm_line)
  local y_start = #pad
  table.insert(highlights, { 'RosadirsDanger', ln, y_start, y_start + 1 })
  table.insert(highlights, { 'RosadirsAction', ln, y_start + 4, y_start + 11 })
  local n_start = y_start + 22
  table.insert(highlights, { 'RosadirsKey', ln, n_start, n_start + 1 })
  table.insert(highlights, { 'RosadirsAction', ln, n_start + 4, n_start + 10 })
  ln = ln + 1

  table.insert(lines, '')

  local buf, win = create_float {
    title = opts.title or ' Confirm',
    width = 52,
    height = #lines,
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
  vim.keymap.set('n', 'n', close, kopts)
  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)
  vim.keymap.set('n', 'y', function()
    close()
    vim.schedule(function()
      opts.on_confirm()
    end)
  end, kopts)
end

return M

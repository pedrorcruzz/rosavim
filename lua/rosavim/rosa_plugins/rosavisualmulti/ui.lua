local M = {}

local api = vim.api
local state = require 'rosavim.rosa_plugins.rosavisualmulti.state'
local cursors = require 'rosavim.rosa_plugins.rosavisualmulti.cursors'
local edit = require 'rosavim.rosa_plugins.rosavisualmulti.edit'
local insert = require 'rosavim.rosa_plugins.rosavisualmulti.insert'

local ns = api.nvim_create_namespace 'rosavm_menu'

local function entries_idle()
  return {
    { key = 'w', icon = '󰆿 ', label = 'Select word under cursor', run = cursors.find_under },
    { key = 'a', icon = '󰒅 ', label = 'Select all occurrences', run = cursors.select_all },
    { key = 'j', icon = '󰁅 ', label = 'Add cursor down', run = cursors.add_down },
    { key = 'k', icon = '󰁝 ', label = 'Add cursor up', run = cursors.add_up },
    {
      key = '/',
      icon = '󰍉 ',
      label = 'Cursors from regex',
      run = function()
        M.regex()
      end,
    },
  }
end

local function entries_active()
  return {
    { key = 'n', icon = '󰒭 ', label = 'Next occurrence', run = cursors.next_occurrence },
    { key = 'N', icon = '󰒮 ', label = 'Previous occurrence', run = cursors.prev_occurrence },
    { key = 'a', icon = '󰒅 ', label = 'Select all occurrences', run = cursors.select_all },
    { key = 'j', icon = '󰁅 ', label = 'Add cursor down', run = cursors.add_down },
    { key = 'k', icon = '󰁝 ', label = 'Add cursor up', run = cursors.add_up },
    { key = 'q', icon = '󰩹 ', label = 'Skip and take next', run = cursors.skip },
    { key = 'Q', icon = '󰅗 ', label = 'Remove cursor', run = cursors.remove_current },
    {
      key = 'i',
      icon = '󰙊 ',
      label = 'Insert before',
      run = function()
        insert.begin 'i'
      end,
    },
    {
      key = 'A',
      icon = '󰙊 ',
      label = 'Append at line end',
      run = function()
        insert.begin 'A'
      end,
    },
    {
      key = 'c',
      icon = '󰏫 ',
      label = 'Change selection',
      run = function()
        insert.begin 'c'
      end,
    },
    { key = 'd', icon = '󰆴 ', label = 'Delete selection', run = edit.delete },
    { key = 'D', icon = '󰗨 ', label = 'Delete whole lines', run = edit.delete_lines },
    { key = 'y', icon = '󰆏 ', label = 'Yank selection', run = edit.yank },
    {
      key = 'p',
      icon = '󰆐 ',
      label = 'Paste over selection',
      run = function()
        edit.paste(false)
      end,
    },
    {
      key = 'u',
      icon = '󰬴 ',
      label = 'Lowercase',
      run = function()
        edit.transform(string.lower)
      end,
    },
    {
      key = 'U',
      icon = '󰬈 ',
      label = 'Uppercase',
      run = function()
        edit.transform(string.upper)
      end,
    },
    {
      key = 'r',
      icon = '󰳽 ',
      label = 'Rename selection',
      run = function()
        M.rename()
      end,
    },
    {
      key = 's',
      icon = '󰛔 ',
      label = 'Surround selection',
      run = function()
        M.surround()
      end,
    },
    {
      key = '/',
      icon = '󰍉 ',
      label = 'Cursors from regex',
      run = function()
        M.regex()
      end,
    },
    {
      key = '.',
      icon = '󰹠 ',
      label = 'Run normal command',
      run = function()
        M.run_normal()
      end,
    },
    {
      key = '@',
      icon = '󰼍 ',
      label = 'Run macro from register',
      run = function()
        M.run_macro()
      end,
    },
    {
      key = 'l',
      icon = '󰉣 ',
      label = 'Align cursors',
      run = function()
        edit.align()
        cursors.sync()
      end,
    },
    {
      key = 'L',
      icon = '󰉣 ',
      label = 'Align on character',
      run = function()
        M.align_char()
      end,
    },
    {
      key = '#',
      icon = '󰎠 ',
      label = 'Number the cursors',
      run = function()
        M.numbers()
      end,
    },
    {
      key = 'x',
      icon = '󰅚 ',
      label = 'Exit',
      run = function()
        require('rosavim.rosa_plugins.rosavisualmulti').stop()
      end,
    },
  }
end

local function hl_setup()
  local p = require('rosavim.helpers.palette').get()
  api.nvim_set_hl(0, 'RosavmTitle', { fg = p.title, bold = true })
  api.nvim_set_hl(0, 'RosavmBorder', { fg = p.border })
  api.nvim_set_hl(0, 'RosavmKey', { fg = p.key, bold = true })
  api.nvim_set_hl(0, 'RosavmText', { fg = p.text })
  api.nvim_set_hl(0, 'RosavmDim', { fg = p.dim })
end

local function prompt(opts, on_confirm)
  hl_setup()
  local default = opts.default or ''
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].filetype = 'rosavisualmulti'
  api.nvim_buf_set_lines(buf, 0, -1, false, { default })

  local width = math.max(34, math.min(#default + 24, 70))
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor(vim.o.lines * 0.35),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    title = opts.title,
    title_pos = 'center',
    footer = ' <CR> confirm  ·  <Esc> cancel ',
    footer_pos = 'center',
    zindex = 70,
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosavmBorder,FloatTitle:RosavmTitle,FloatFooter:RosavmDim'

  local done = false
  local function finish(value)
    if done then
      return
    end
    done = true
    pcall(vim.cmd, 'stopinsert')
    if api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
    vim.schedule(function()
      on_confirm(value)
    end)
  end

  vim.keymap.set({ 'n', 'i' }, '<CR>', function()
    finish(api.nvim_buf_get_lines(buf, 0, 1, false)[1] or '')
  end, { buffer = buf, nowait = true })
  vim.keymap.set({ 'n', 'i' }, '<Esc>', function()
    finish(nil)
  end, { buffer = buf, nowait = true })
  vim.keymap.set('n', 'q', function()
    finish(nil)
  end, { buffer = buf, nowait = true })

  vim.cmd 'startinsert!'
end

local function require_cursors()
  if state.session() and state.count() > 0 then
    return true
  end
  pcall(function()
    Snacks.notify.warn('No cursors selected', { title = 'Rosavisualmulti' })
  end)
  return false
end

function M.rename()
  if not require_cursors() then
    return
  end
  local items = edit.snapshot()
  local first = edit.text_of(items[#items])
  local same = true
  for _, item in ipairs(items) do
    if edit.text_of(item) ~= first then
      same = false
      break
    end
  end
  local title = ('󰳽  Rename %d '):format(#items)
  prompt({ default = same and first or '', title = title }, function(input)
    if input == nil then
      return
    end
    edit.replace(function()
      return input
    end)
    if input == '' then
      edit.collapse 'start'
    end
    cursors.sync()
  end)
end

function M.regex()
  prompt({ title = '󰍉  Cursors from regex ' }, function(input)
    if not input or input == '' then
      return
    end
    cursors.from_regex(input)
  end)
end

function M.run_normal()
  if not require_cursors() then
    return
  end
  prompt({ title = '󰹠  Normal command ' }, function(input)
    if not input or input == '' then
      return
    end
    edit.run_normal(input)
    cursors.sync()
  end)
end

function M.run_macro()
  if not require_cursors() then
    return
  end
  prompt({ title = '󰼍  Macro register ', default = 'q' }, function(input)
    if not input or input == '' then
      return
    end
    edit.run_macro(input:sub(1, 1))
    cursors.sync()
  end)
end

function M.align_char()
  if not require_cursors() then
    return
  end
  prompt({ title = '󰉣  Align on character ' }, function(input)
    if not input or input == '' then
      return
    end
    edit.align_char(input)
    cursors.sync()
  end)
end

function M.surround()
  if not require_cursors() then
    return
  end
  prompt({ title = '󰛔  Surround with ' }, function(input)
    if not input or input == '' then
      return
    end
    local pairs_map = { ['('] = ')', ['['] = ']', ['{'] = '}', ['<'] = '>' }
    local open = input:sub(1, 1)
    local close = pairs_map[open] or open
    edit.transform(function(text)
      return open .. text .. close
    end)
    cursors.sync()
  end)
end

function M.numbers()
  if not require_cursors() then
    return
  end
  prompt({ title = '󰎠  Number from ', default = '1' }, function(input)
    local n = tonumber(input)
    if not n then
      return
    end
    local items = edit.snapshot()
    local total = #items
    edit.replace(function(item)
      return tostring(n + (total - item.index))
    end)
    cursors.sync()
  end)
end

function M.menu()
  hl_setup()

  local live = state.active() and state.count() > 0
  local entries = live and entries_active() or entries_idle()

  local pad = '  '
  local lines, highlights, map = {}, {}, {}
  table.insert(lines, '')
  for _, e in ipairs(entries) do
    local text = ('%s%s  %s%s'):format(pad, e.key, e.icon, e.label)
    table.insert(lines, text)
    local ln = #lines - 1
    map[ln] = e
    table.insert(highlights, { 'RosavmKey', ln, #pad, #pad + #e.key })
    table.insert(highlights, { 'RosavmText', ln, #pad + #e.key + 2, -1 })
  end
  table.insert(lines, '')

  local width = 44
  for _, l in ipairs(lines) do
    if #l + 6 > width then
      width = math.min(#l + 6, 80)
    end
  end

  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosavisualmulti'

  local title = live and (' 󰆿 Rosavisualmulti · ' .. state.count() .. ' cursors ') or ' 󰆿 Rosavisualmulti '
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = #lines,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
    footer = ' q: close ',
    footer_pos = 'center',
    zindex = 60,
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosavmBorder,FloatTitle:RosavmTitle,FloatFooter:RosavmDim'
  vim.wo[win].cursorline = true

  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  for _, h in ipairs(highlights) do
    pcall(api.nvim_buf_set_extmark, buf, ns, h[2], h[3], { end_col = h[4] == -1 and #lines[h[2] + 1] or h[4], hl_group = h[1] })
  end
  pcall(api.nvim_win_set_cursor, win, { 2, 0 })

  local function close()
    if api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
  end

  local function run(entry)
    close()
    if entry then
      vim.schedule(function()
        entry.run()
        if state.session() then
          cursors.sync()
        end
      end)
    end
  end

  vim.keymap.set('n', 'q', close, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<Esc>', close, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<CR>', function()
    run(map[api.nvim_win_get_cursor(win)[1] - 1])
  end, { buffer = buf, nowait = true })
  for ln, entry in pairs(map) do
    vim.keymap.set('n', entry.key, function()
      run(map[ln])
    end, { buffer = buf, nowait = true })
  end
end

return M

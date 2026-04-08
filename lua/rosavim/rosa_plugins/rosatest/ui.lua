--- Rosatest UI - floating popup windows for test results
local M = {}

local ns = vim.api.nvim_create_namespace 'rosatest'

--- Highlight groups
local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  vim.api.nvim_set_hl(0, 'RosatestPassed', { fg = p.green, bold = true })
  vim.api.nvim_set_hl(0, 'RosatestFailed', { fg = p.red, bold = true })
  vim.api.nvim_set_hl(0, 'RosatestSkipped', { fg = p.yellow, bold = true })
  vim.api.nvim_set_hl(0, 'RosatestRunning', { fg = p.key, bold = true })
  vim.api.nvim_set_hl(0, 'RosatestTitle', { fg = p.title, bold = true })
  vim.api.nvim_set_hl(0, 'RosatestBorder', { fg = p.border })
  vim.api.nvim_set_hl(0, 'RosatestHeader', { fg = p.teal, bold = true })
  vim.api.nvim_set_hl(0, 'RosatestDim', { fg = p.dim })
  vim.api.nvim_set_hl(0, 'RosatestIcon', { fg = p.pink })
end

--- Icon definitions
local icons = {
  passed = ' ',
  failed = ' ',
  skipped = '󰒭 ',
  running = '󰑮 ',
  suite = '󰙨 ',
  file = ' ',
  separator = '─',
  arrow = ' ',
}

--- Create a floating window
--- @param opts { title: string, width: number|nil, height: number|nil, lines: string[], highlights: table[]|nil }
--- @return number bufnr, number winnr
local function create_float(opts)
  local width = opts.width or math.floor(vim.o.columns * 0.7)
  local height = opts.height or math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosatest'

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. (opts.title or 'Rosatest') .. ' ',
    title_pos = 'center',
    footer = ' q: close │ r: raw output │ R: rerun ',
    footer_pos = 'center',
  })

  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosatestBorder,FloatTitle:RosatestTitle,FloatFooter:RosatestDim'
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  if opts.lines then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, opts.lines)
  end

  if opts.highlights then
    for _, hl in ipairs(opts.highlights) do
      vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
    end
  end

  return buf, win
end

--- Build formatted result lines with highlights
--- @param summary RosatestSummary
--- @param runner_name string
--- @param elapsed number
--- @return string[] lines, table[] highlights
local function format_results(summary, runner_name, elapsed)
  local result_lines = {}
  local highlights = {}
  local ln = 0

  local function add(text, hl)
    table.insert(result_lines, text)
    if hl then
      table.insert(highlights, { hl, ln })
    end
    ln = ln + 1
  end

  -- Header
  local status_icon = summary.failed > 0 and icons.failed or icons.passed
  local status_hl = summary.failed > 0 and 'RosatestFailed' or 'RosatestPassed'
  local status_text = summary.failed > 0 and 'FAILED' or 'PASSED'

  add(string.format('  %s %s  %s', icons.suite, runner_name:upper(), status_text), status_hl)
  add ''
  add(
    string.format(
      '   %s %d passed   %s %d failed   %s %d skipped   ⏱  %.2fs',
      icons.passed,
      summary.passed,
      icons.failed,
      summary.failed,
      icons.skipped,
      summary.skipped,
      elapsed
    ),
    'RosatestHeader'
  )
  add('  ' .. string.rep(icons.separator, 60), 'RosatestDim')
  add ''

  -- Individual test results
  if #summary.results > 0 then
    -- Group: failed first, then passed, then skipped
    local order = { 'failed', 'passed', 'skipped' }
    local grouped = { failed = {}, passed = {}, skipped = {} }
    for _, r in ipairs(summary.results) do
      table.insert(grouped[r.status] or grouped.passed, r)
    end

    for _, status in ipairs(order) do
      local group = grouped[status]
      if #group > 0 then
        local icon = icons[status]
        local hl = status == 'passed' and 'RosatestPassed'
          or status == 'failed' and 'RosatestFailed'
          or 'RosatestSkipped'

        for _, r in ipairs(group) do
          add(string.format('  %s %s', icon, r.name), hl)
        end
        add ''
      end
    end
  else
    add('  No individual test results parsed. Check raw output (r).', 'RosatestDim')
    add ''
  end

  return result_lines, highlights
end

--- State for current popup
M._state = {
  buf = nil,
  win = nil,
  summary = nil,
  runner_name = nil,
  elapsed = nil,
  showing_raw = false,
  rerun_fn = nil,
}

--- Show test results popup
--- @param summary RosatestSummary
--- @param runner_name string
--- @param elapsed number
--- @param rerun_fn function|nil
function M.show_results(summary, runner_name, elapsed, rerun_fn)
  setup_highlights()

  -- Close existing popup
  M.close()

  M._state.summary = summary
  M._state.runner_name = runner_name
  M._state.elapsed = elapsed
  M._state.showing_raw = false
  M._state.rerun_fn = rerun_fn

  local result_lines, highlights = format_results(summary, runner_name, elapsed)

  local buf, win = create_float {
    title = icons.suite .. ' Rosatest',
    lines = result_lines,
    highlights = highlights,
  }

  M._state.buf = buf
  M._state.win = win

  vim.bo[buf].modifiable = false

  -- Keymaps
  local kopts = { buffer = buf, silent = true }
  vim.keymap.set('n', 'q', function()
    M.close()
  end, kopts)
  vim.keymap.set('n', '<Esc>', function()
    M.close()
  end, kopts)
  vim.keymap.set('n', 'r', function()
    M.toggle_raw()
  end, kopts)
  vim.keymap.set('n', 'R', function()
    M.close()
    if M._state.rerun_fn then
      M._state.rerun_fn()
    end
  end, kopts)
end

--- Toggle between formatted and raw output
function M.toggle_raw()
  if not M._state.buf or not vim.api.nvim_buf_is_valid(M._state.buf) then
    return
  end

  M._state.showing_raw = not M._state.showing_raw
  vim.bo[M._state.buf].modifiable = true

  if M._state.showing_raw then
    vim.api.nvim_buf_set_lines(M._state.buf, 0, -1, false, M._state.summary.raw_output)
    vim.api.nvim_buf_clear_namespace(M._state.buf, ns, 0, -1)
  else
    local result_lines, highlights = format_results(M._state.summary, M._state.runner_name, M._state.elapsed)
    vim.api.nvim_buf_set_lines(M._state.buf, 0, -1, false, result_lines)
    vim.api.nvim_buf_clear_namespace(M._state.buf, ns, 0, -1)
    for _, hl in ipairs(highlights) do
      vim.api.nvim_buf_add_highlight(M._state.buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
    end
  end

  vim.bo[M._state.buf].modifiable = false
end

--- Show "running" indicator
--- @param runner_name string
--- @param cmd string[]
function M.show_running(runner_name, cmd)
  setup_highlights()
  M.close()

  local lines_content = {
    '',
    string.format('  %s Running tests with %s...', icons.running, runner_name:upper()),
    '',
    string.format('  %s %s', icons.arrow, table.concat(cmd, ' ')),
    '',
  }

  local buf, win = create_float {
    title = icons.running .. ' Rosatest - Running',
    lines = lines_content,
    highlights = {
      { 'RosatestRunning', 1 },
      { 'RosatestDim', 3 },
    },
    height = 8,
  }

  M._state.buf = buf
  M._state.win = win

  vim.bo[buf].modifiable = false

  vim.keymap.set('n', 'q', function()
    M.close()
  end, { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', function()
    M.close()
  end, { buffer = buf, silent = true })
end

--- Actions popup - main menu
function M.actions_popup()
  setup_highlights()

  local pad = '       '
  local gap = '    '

  local actions = {
    { key = 'r', label = 'Run nearest', action = 'run_nearest', hl = 'RosatestPassed' },
    { key = 'f', label = 'Run file', action = 'run_file', hl = 'RosatestPassed' },
    { key = 'a', label = 'Run all', action = 'run_all', hl = 'RosatestPassed' },
    { key = 'l', label = 'Run last', action = 'run_last', hl = 'RosatestPassed' },
    { sep = true },
    { key = 'o', label = 'Toggle output', action = 'toggle_output', hl = 'RosatestHeader' },
    { key = 'p', label = 'Pick test file', action = 'pick_test_files', hl = 'RosatestHeader' },
    { sep = true },
    { key = 's', label = 'Stop', action = 'stop', hl = 'RosatestFailed' },
  }

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

  -- Current file
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= '' then
    local rel = vim.fn.fnamemodify(current_file, ':~:.')
    add(pad .. rel, 'RosatestDim')
  else
    add(pad .. '(no file)', 'RosatestDim')
  end
  add(pad .. string.rep('─', 36), 'RosatestDim')
  add ''

  -- Actions
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
      add_hl('RosatestRunning', ln - 1, key_start, key_end)
      add_hl(a.hl, ln - 1, label_start, label_end)
    end
  end

  add ''

  local width = 48
  local height = #lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'rosatest'

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' 󰙨 Rosatest ',
    title_pos = 'center',
    footer = ' q: close ',
    footer_pos = 'center',
  })

  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosatestBorder,FloatTitle:RosatestTitle,FloatFooter:RosatestDim'
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[1], hl[2], hl[3] or 0, hl[4] or -1)
  end

  local function close_menu()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local kopts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set('n', 'q', close_menu, kopts)
  vim.keymap.set('n', '<Esc>', close_menu, kopts)

  local rosatest = require 'rosavim.rosa_plugins.rosatest'
  for _, a in ipairs(actions) do
    if not a.sep then
      vim.keymap.set('n', a.key, function()
        close_menu()
        vim.schedule(function()
          rosatest[a.action]()
        end)
      end, kopts)
    end
  end
end

--- Close the popup
function M.close()
  if M._state.win and vim.api.nvim_win_is_valid(M._state.win) then
    vim.api.nvim_win_close(M._state.win, true)
  end
  M._state.win = nil
  M._state.buf = nil
end

return M

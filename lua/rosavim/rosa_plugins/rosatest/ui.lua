--- Rosatest UI - floating popup windows for test results
local M = {}

local menu = require 'rosavim.helpers.rosa_menu'

--- Highlight groups
local function setup_highlights()
  require('rosavim.helpers.palette').define('Rosatest', function(p)
    return {
      Passed = { fg = p.green, bold = true },
      Failed = { fg = p.red, bold = true },
      Skipped = { fg = p.yellow, bold = true },
      Running = { fg = p.key, bold = true },
      Title = { fg = p.title, bold = true },
      Border = { fg = p.border },
      Header = { fg = p.teal, bold = true },
      Dim = { fg = p.dim },
      Icon = { fg = p.pink },
    }
  end)
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

--- Create a floating results window (defaults to 70% of the screen)
--- @param opts { title: string, width: number|nil, height: number|nil, lines: string[], highlights: table[]|nil, keys: table[]|nil }
--- @return number bufnr, number winnr
local function create_float(opts)
  local ctx = menu.open {
    title = ' ' .. (opts.title or 'Rosatest') .. ' ',
    footer = ' q: close │ r: raw output │ R: rerun ',
    width = opts.width or math.floor(vim.o.columns * 0.7),
    height = opts.height or math.floor(vim.o.lines * 0.7),
    lines = opts.lines,
    highlights = opts.highlights,
    hl_prefix = 'Rosatest',
    filetype = 'rosatest',
    cursorline = true,
    keys = opts.keys,
  }
  return ctx.buf, ctx.win
end

--- Build formatted result lines with highlights
--- @param summary RosatestSummary
--- @param runner_name string
--- @param elapsed number
--- @return string[] lines, table[] highlights
local function format_results(summary, runner_name, elapsed)
  local b = menu.builder()
  local add = b.add

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
        local hl = status == 'passed' and 'RosatestPassed' or status == 'failed' and 'RosatestFailed' or 'RosatestSkipped'

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

  return b.lines, b.highlights
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
    keys = {
      {
        'n',
        'q',
        function()
          M.close()
        end,
      },
      {
        'n',
        '<Esc>',
        function()
          M.close()
        end,
      },
      {
        'n',
        'r',
        function()
          M.toggle_raw()
        end,
      },
      {
        'n',
        'R',
        function()
          M.close()
          if M._state.rerun_fn then
            M._state.rerun_fn()
          end
        end,
      },
    },
  }

  M._state.buf = buf
  M._state.win = win
end

--- Toggle between formatted and raw output
function M.toggle_raw()
  if not M._state.buf or not vim.api.nvim_buf_is_valid(M._state.buf) then
    return
  end

  M._state.showing_raw = not M._state.showing_raw

  if M._state.showing_raw then
    menu.set_content(M._state.buf, M._state.summary.raw_output, {})
  else
    local result_lines, highlights = format_results(M._state.summary, M._state.runner_name, M._state.elapsed)
    menu.set_content(M._state.buf, result_lines, highlights)
  end
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
    keys = {
      {
        'n',
        'q',
        function()
          M.close()
        end,
      },
      {
        'n',
        '<Esc>',
        function()
          M.close()
        end,
      },
    },
  }

  M._state.buf = buf
  M._state.win = win
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

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl

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
      add_hl('RosatestRunning', b.line(), key_start, key_end)
      add_hl(a.hl, b.line(), label_start, label_end)
    end
  end

  add ''

  local rosatest = require 'rosavim.rosa_plugins.rosatest'
  local keys = {}
  for _, a in ipairs(actions) do
    if not a.sep then
      table.insert(keys, {
        'n',
        a.key,
        function(ctx)
          ctx.close()
          vim.schedule(function()
            rosatest[a.action]()
          end)
        end,
      })
    end
  end

  menu.open {
    title = ' 󰙨 Rosatest ',
    footer = ' q: close ',
    width = 48,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    hl_prefix = 'Rosatest',
    filetype = 'rosatest',
    keys = keys,
  }
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

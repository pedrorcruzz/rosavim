--- Rosatest - Lightweight test runner for Rosavim
local M = {}

local runners = require 'rosavim.rosa_plugins.rosatest.runners'
local ui = require 'rosavim.rosa_plugins.rosatest.ui'

--- Current job state
M._job = nil
M._last_run = nil

--- Run tests
--- @param mode "nearest"|"file"|"all"
--- @param opts { file: string|nil, line: number|nil }|nil
function M.run(mode, opts)
  opts = opts or {}
  local file = opts.file or vim.fn.expand '%:p'
  local line = opts.line or vim.fn.line '.'
  local ft = vim.bo.filetype
  local cwd = vim.fn.getcwd()

  -- Convert absolute path to relative
  if file:sub(1, #cwd) == cwd then
    file = file:sub(#cwd + 2)
  end

  local runner, runner_name = runners.detect(ft)
  if not runner then
    vim.notify('Rosatest: no runner detected for this project', vim.log.levels.WARN)
    return
  end

  local cmd
  if mode == 'nearest' then
    cmd = runner.cmd_nearest(file, line)
  elseif mode == 'file' then
    cmd = runner.cmd_file(file)
  elseif mode == 'all' then
    cmd = runner.cmd_all()
  end

  if not cmd then
    vim.notify('Rosatest: failed to generate command', vim.log.levels.WARN)
    return
  end

  -- Save for rerun
  local rerun_fn = function()
    M.run(mode, opts)
  end
  M._last_run = rerun_fn

  -- Cancel previous job
  if M._job then
    vim.fn.jobstop(M._job)
    M._job = nil
  end

  -- Show running indicator
  ui.show_running(runner_name, cmd)

  local output_chunks = {}
  local start_time = vim.uv.hrtime()

  M._job = vim.fn.jobstart(cmd, {
    cwd = vim.fn.getcwd(),
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line_data in ipairs(data) do
          if line_data ~= '' then
            table.insert(output_chunks, line_data)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line_data in ipairs(data) do
          if line_data ~= '' then
            table.insert(output_chunks, line_data)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      M._job = nil
      local elapsed = (vim.uv.hrtime() - start_time) / 1e9

      vim.schedule(function()
        local full_output = table.concat(output_chunks, '\n')
        local summary = runner.parse(full_output)

        -- If no individual results parsed, use exit code as fallback
        if summary.total == 0 then
          if exit_code == 0 then
            summary.passed = 1
            summary.total = 1
          else
            summary.failed = 1
            summary.total = 1
          end
        end

        ui.show_results(summary, runner_name, elapsed, rerun_fn)
      end)
    end,
  })
end

--- Run nearest test
function M.run_nearest()
  M.run('nearest')
end

--- Run all tests in the current file
function M.run_file()
  M.run('file', { file = vim.fn.expand '%:p' })
end

--- Run all tests in the project
function M.run_all()
  M.run 'all'
end

--- Re-run last test
function M.run_last()
  if M._last_run then
    M._last_run()
  else
    vim.notify('Rosatest: no tests run yet', vim.log.levels.INFO)
  end
end

--- Stop running test
function M.stop()
  if M._job then
    vim.fn.jobstop(M._job)
    M._job = nil
    ui.close()
    vim.notify('Rosatest: test cancelled', vim.log.levels.INFO)
  end
end

--- Toggle results popup
function M.toggle_output()
  if ui._state.win and vim.api.nvim_win_is_valid(ui._state.win) then
    ui.close()
  elseif ui._state.summary then
    ui.show_results(ui._state.summary, ui._state.runner_name, ui._state.elapsed, M._last_run)
  else
    vim.notify('Rosatest: no results available', vim.log.levels.INFO)
  end
end

--- Open the Rosatest actions menu
function M.open()
  ui.actions_popup()
end

--- Pick test files using Snacks picker
function M.pick_test_files()
  local ok, snacks = pcall(require, 'snacks')
  if not ok then
    vim.notify('Rosatest: snacks.nvim is required for the picker', vim.log.levels.ERROR)
    return
  end

  -- Test file patterns by language
  local test_patterns = {
    '**/*_test.go',
    '**/*.test.ts',
    '**/*.test.tsx',
    '**/*.test.js',
    '**/*.test.jsx',
    '**/*.spec.ts',
    '**/*.spec.tsx',
    '**/*.spec.js',
    '**/*.spec.jsx',
    '**/test_*.py',
    '**/*_test.py',
    '**/*Test.php',
    '**/*_test.php',
    '**/*PestTest.php',
    '**/*Test.java',
  }

  -- Find test files
  local test_files = {}
  for _, pattern in ipairs(test_patterns) do
    local files = vim.fn.glob(pattern, false, true)
    for _, f in ipairs(files) do
      -- Filter node_modules and vendor
      if not f:match 'node_modules' and not f:match 'vendor' and not f:match '%.git' then
        table.insert(test_files, f)
      end
    end
  end

  -- Remove duplicates
  local seen = {}
  local unique = {}
  for _, f in ipairs(test_files) do
    if not seen[f] then
      seen[f] = true
      table.insert(unique, f)
    end
  end
  table.sort(unique)

  if #unique == 0 then
    vim.notify('Rosatest: no test files found', vim.log.levels.INFO)
    return
  end

  -- Use snacks picker
  snacks.picker {
    title = '󰙨 Rosatest - Test Files',
    items = vim.tbl_map(function(f)
      return { text = f, file = f }
    end, unique),
    format = function(item)
      local icon = ' '
      local ext = vim.fn.fnamemodify(item.file, ':e')
      local ext_icons = {
        go = ' ',
        ts = ' ',
        tsx = ' ',
        js = ' ',
        jsx = ' ',
        py = ' ',
        php = ' ',
        java = ' ',
      }
      icon = ext_icons[ext] or icon
      return { { icon, 'RosaTestIcon' }, { item.file } }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        -- Open file and run tests
        vim.cmd('edit ' .. item.file)
        vim.schedule(function()
          M.run('file', { file = vim.fn.fnamemodify(item.file, ':p') })
        end)
      end
    end,
  }
end

return M

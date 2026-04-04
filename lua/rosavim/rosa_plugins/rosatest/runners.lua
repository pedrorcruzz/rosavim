--- Runner definitions for each test framework
--- Each runner defines: detect(), cmd_file(file), cmd_nearest(file, line), cmd_all(), parse(output)

local M = {}

--- @class RosaTestResult
--- @field name string
--- @field status "passed"|"failed"|"skipped"
--- @field output string[]

--- @class RosaTestSummary
--- @field passed number
--- @field failed number
--- @field skipped number
--- @field total number
--- @field results RosaTestResult[]
--- @field raw_output string[]

local function lines(str)
  local result = {}
  for line in str:gmatch '[^\r\n]+' do
    table.insert(result, line)
  end
  return result
end

-- ── Go (go test -v / gotestsum) ──────────────────────────────────────

M.go = {
  detect = function()
    return vim.fn.glob('go.mod') ~= '' or vim.fn.glob('go.sum') ~= ''
  end,
  cmd_file = function(file)
    local dir = vim.fn.fnamemodify(file, ':h')
    return { 'go', 'test', '-v', '-count=1', './' .. dir .. '/...' }
  end,
  cmd_nearest = function(file, line)
    local test_name = nil
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
    for i = #buf_lines, 1, -1 do
      local match = buf_lines[i]:match 'func%s+(Test%w+)'
      if match then
        test_name = match
        break
      end
    end
    local dir = vim.fn.fnamemodify(file, ':h')
    if test_name then
      return { 'go', 'test', '-v', '-count=1', '-run', '^' .. test_name .. '$', './' .. dir .. '/...' }
    end
    return { 'go', 'test', '-v', '-count=1', './' .. dir .. '/...' }
  end,
  cmd_all = function()
    return { 'go', 'test', '-v', '-count=1', './...' }
  end,
  parse = function(output)
    local results = {}
    local passed, failed, skipped = 0, 0, 0
    for _, line in ipairs(lines(output)) do
      local status, name = line:match '%-%-%-% (%u+):%s+(.+)%s+%('
      if status and name then
        local s = status == 'PASS' and 'passed' or status == 'FAIL' and 'failed' or 'skipped'
        if s == 'passed' then
          passed = passed + 1
        elseif s == 'failed' then
          failed = failed + 1
        else
          skipped = skipped + 1
        end
        table.insert(results, { name = name, status = s, output = {} })
      end
      local skip_name = line:match '%-%-%-% SKIP:%s+(.+)%s+%('
      if skip_name then
        skipped = skipped + 1
        table.insert(results, { name = skip_name, status = 'skipped', output = {} })
      end
    end
    return {
      passed = passed,
      failed = failed,
      skipped = skipped,
      total = passed + failed + skipped,
      results = results,
      raw_output = lines(output),
    }
  end,
}

-- ── Jest ─────────────────────────────────────────────────────────────

M.jest = {
  detect = function()
    return vim.fn.filereadable('jest.config.ts') == 1
      or vim.fn.filereadable('jest.config.js') == 1
      or vim.fn.filereadable('jest.config.mjs') == 1
  end,
  cmd_file = function(file)
    return { 'npx', 'jest', '--no-coverage', '--verbose', '--forceExit', file }
  end,
  cmd_nearest = function(file, line)
    local test_name = nil
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
    for i = #buf_lines, 1, -1 do
      local match = buf_lines[i]:match "[it|test|describe]%(%s*['\"](.+)['\"]"
      if match then
        test_name = match
        break
      end
    end
    if test_name then
      return { 'npx', 'jest', '--no-coverage', '--verbose', '--forceExit', '-t', test_name, file }
    end
    return { 'npx', 'jest', '--no-coverage', '--verbose', '--forceExit', file }
  end,
  cmd_all = function()
    return { 'npx', 'jest', '--no-coverage', '--verbose', '--forceExit' }
  end,
  parse = function(output)
    local results = {}
    local passed, failed, skipped = 0, 0, 0
    for _, line in ipairs(lines(output)) do
      local p_name = line:match '✓%s+(.+)%s+%('
        or line:match '√%s+(.+)%s+%('
        or line:match 'PASS%s+(.+)'
      local f_name = line:match '✕%s+(.+)' or line:match '✗%s+(.+)' or line:match '×%s+(.+)'
      local s_name = line:match '○%s+skipped%s+(.+)'

      if f_name then
        failed = failed + 1
        table.insert(results, { name = vim.trim(f_name), status = 'failed', output = {} })
      elseif s_name then
        skipped = skipped + 1
        table.insert(results, { name = vim.trim(s_name), status = 'skipped', output = {} })
      elseif p_name and line:match '✓' then
        passed = passed + 1
        table.insert(results, { name = vim.trim(p_name), status = 'passed', output = {} })
      end
    end
    -- fallback: parse summary line
    if passed == 0 and failed == 0 then
      local p = output:match 'Tests:%s+(%d+) passed' or '0'
      local f = output:match '(%d+) failed' or '0'
      passed = tonumber(p) or 0
      failed = tonumber(f) or 0
    end
    return {
      passed = passed,
      failed = failed,
      skipped = skipped,
      total = passed + failed + skipped,
      results = results,
      raw_output = lines(output),
    }
  end,
}

-- ── Vitest ───────────────────────────────────────────────────────────

M.vitest = {
  detect = function()
    return vim.fn.filereadable('vitest.config.ts') == 1
      or vim.fn.filereadable('vitest.config.js') == 1
      or vim.fn.filereadable('vitest.config.mts') == 1
      or (vim.fn.filereadable('vite.config.ts') == 1 and vim.fn.glob('**/*.test.ts') ~= '')
  end,
  cmd_file = function(file)
    return { 'npx', 'vitest', 'run', '--reporter=verbose', file }
  end,
  cmd_nearest = function(file, line)
    local test_name = nil
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
    for i = #buf_lines, 1, -1 do
      local match = buf_lines[i]:match "[it|test|describe]%(%s*['\"](.+)['\"]"
      if match then
        test_name = match
        break
      end
    end
    if test_name then
      return { 'npx', 'vitest', 'run', '--reporter=verbose', '-t', test_name, file }
    end
    return { 'npx', 'vitest', 'run', '--reporter=verbose', file }
  end,
  cmd_all = function()
    return { 'npx', 'vitest', 'run', '--reporter=verbose' }
  end,
  parse = function(output)
    local results = {}
    local passed, failed, skipped = 0, 0, 0
    for _, line in ipairs(lines(output)) do
      local p_name = line:match '✓%s+(.+)' or line:match '√%s+(.+)'
      local f_name = line:match '×%s+(.+)' or line:match '✗%s+(.+)'
      local s_name = line:match '↓%s+(.+)'

      if f_name then
        failed = failed + 1
        table.insert(results, { name = vim.trim(f_name), status = 'failed', output = {} })
      elseif s_name then
        skipped = skipped + 1
        table.insert(results, { name = vim.trim(s_name), status = 'skipped', output = {} })
      elseif p_name then
        passed = passed + 1
        table.insert(results, { name = vim.trim(p_name), status = 'passed', output = {} })
      end
    end
    if passed == 0 and failed == 0 then
      local p = output:match 'Tests%s+(%d+) passed' or '0'
      local f = output:match '(%d+) failed' or '0'
      passed = tonumber(p) or 0
      failed = tonumber(f) or 0
    end
    return {
      passed = passed,
      failed = failed,
      skipped = skipped,
      total = passed + failed + skipped,
      results = results,
      raw_output = lines(output),
    }
  end,
}

-- ── Pytest ───────────────────────────────────────────────────────────

M.pytest = {
  detect = function()
    return vim.fn.filereadable('pytest.ini') == 1
      or vim.fn.filereadable('pyproject.toml') == 1
      or vim.fn.filereadable('setup.py') == 1
      or vim.fn.filereadable('setup.cfg') == 1
      or vim.fn.glob('**/test_*.py') ~= ''
      or vim.fn.glob('**/*_test.py') ~= ''
  end,
  cmd_file = function(file)
    local python = vim.fn.filereadable('.venv/bin/python') == 1 and '.venv/bin/python' or 'python'
    return { python, '-m', 'pytest', '-v', '--tb=short', '--no-header', file }
  end,
  cmd_nearest = function(file, line)
    local test_name = nil
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
    for i = #buf_lines, 1, -1 do
      local match = buf_lines[i]:match 'def%s+(test_%w+)'
        or buf_lines[i]:match 'class%s+(Test%w+)'
      if match then
        test_name = match
        break
      end
    end
    local python = vim.fn.filereadable('.venv/bin/python') == 1 and '.venv/bin/python' or 'python'
    if test_name then
      return { python, '-m', 'pytest', '-v', '--tb=short', '--no-header', '-k', test_name, file }
    end
    return { python, '-m', 'pytest', '-v', '--tb=short', '--no-header', file }
  end,
  cmd_all = function()
    local python = vim.fn.filereadable('.venv/bin/python') == 1 and '.venv/bin/python' or 'python'
    return { python, '-m', 'pytest', '-v', '--tb=short', '--no-header' }
  end,
  parse = function(output)
    local results = {}
    local passed, failed, skipped = 0, 0, 0
    for _, line in ipairs(lines(output)) do
      local name_p = line:match '(.+)%s+PASSED'
      local name_f = line:match '(.+)%s+FAILED'
      local name_s = line:match '(.+)%s+SKIPPED'

      if name_f then
        failed = failed + 1
        table.insert(results, { name = vim.trim(name_f), status = 'failed', output = {} })
      elseif name_s then
        skipped = skipped + 1
        table.insert(results, { name = vim.trim(name_s), status = 'skipped', output = {} })
      elseif name_p then
        passed = passed + 1
        table.insert(results, { name = vim.trim(name_p), status = 'passed', output = {} })
      end
    end
    return {
      passed = passed,
      failed = failed,
      skipped = skipped,
      total = passed + failed + skipped,
      results = results,
      raw_output = lines(output),
    }
  end,
}

-- ── Pest (PHP) ───────────────────────────────────────────────────────

M.pest = {
  detect = function()
    return vim.fn.filereadable('vendor/bin/pest') == 1
  end,
  cmd_file = function(file)
    return { 'vendor/bin/pest', '--colors=never', file }
  end,
  cmd_nearest = function(file, line)
    local test_name = nil
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
    for i = #buf_lines, 1, -1 do
      local match = buf_lines[i]:match "[it|test]%(%s*['\"](.+)['\"]"
      if match then
        test_name = match
        break
      end
    end
    if test_name then
      return { 'vendor/bin/pest', '--colors=never', '--filter', test_name, file }
    end
    return { 'vendor/bin/pest', '--colors=never', file }
  end,
  cmd_all = function()
    return { 'vendor/bin/pest', '--colors=never' }
  end,
  parse = function(output)
    local results = {}
    local passed, failed, skipped = 0, 0, 0
    for _, line in ipairs(lines(output)) do
      local p_name = line:match '✓%s+(.+)' or line:match 'PASS%s+(.+)'
      local f_name = line:match '✕%s+(.+)' or line:match 'FAIL%s+(.+)'
      local s_name = line:match '→%s+(.+)' or line:match 'SKIP%s+(.+)'

      if f_name then
        failed = failed + 1
        table.insert(results, { name = vim.trim(f_name), status = 'failed', output = {} })
      elseif s_name then
        skipped = skipped + 1
        table.insert(results, { name = vim.trim(s_name), status = 'skipped', output = {} })
      elseif p_name then
        passed = passed + 1
        table.insert(results, { name = vim.trim(p_name), status = 'passed', output = {} })
      end
    end
    return {
      passed = passed,
      failed = failed,
      skipped = skipped,
      total = passed + failed + skipped,
      results = results,
      raw_output = lines(output),
    }
  end,
}

-- ── PHPUnit ──────────────────────────────────────────────────────────

M.phpunit = {
  detect = function()
    return vim.fn.filereadable('vendor/bin/phpunit') == 1 or vim.fn.filereadable('phpunit.xml') == 1
  end,
  cmd_file = function(file)
    return { 'vendor/bin/phpunit', '--colors=never', file }
  end,
  cmd_nearest = function(file, line)
    local test_name = nil
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
    for i = #buf_lines, 1, -1 do
      local match = buf_lines[i]:match 'function%s+(test%w+)'
      if match then
        test_name = match
        break
      end
    end
    if test_name then
      return { 'vendor/bin/phpunit', '--colors=never', '--filter', test_name, file }
    end
    return { 'vendor/bin/phpunit', '--colors=never', file }
  end,
  cmd_all = function()
    return { 'vendor/bin/phpunit', '--colors=never' }
  end,
  parse = function(output)
    local results = {}
    local passed, failed, skipped = 0, 0, 0
    local p = output:match 'OK %((%d+) test' or '0'
    local f = output:match 'Failures: (%d+)' or '0'
    local e = output:match 'Errors: (%d+)' or '0'
    passed = tonumber(p) or 0
    failed = (tonumber(f) or 0) + (tonumber(e) or 0)
    return {
      passed = passed,
      failed = failed,
      skipped = skipped,
      total = passed + failed + skipped,
      results = results,
      raw_output = lines(output),
    }
  end,
}

-- ── Java (Gradle) ────────────────────────────────────────────────────

M.java = {
  detect = function()
    return vim.fn.filereadable('build.gradle') == 1
      or vim.fn.filereadable('build.gradle.kts') == 1
      or vim.fn.filereadable('pom.xml') == 1
  end,
  cmd_file = function(file)
    local class_name = vim.fn.fnamemodify(file, ':t:r')
    if vim.fn.filereadable 'build.gradle' == 1 or vim.fn.filereadable 'build.gradle.kts' == 1 then
      return { './gradlew', 'test', '--tests', '*' .. class_name, '--info' }
    end
    return { 'mvn', 'test', '-Dtest=' .. class_name }
  end,
  cmd_nearest = function(file, line)
    local class_name = vim.fn.fnamemodify(file, ':t:r')
    local test_name = nil
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
    for i = #buf_lines, 1, -1 do
      local match = buf_lines[i]:match 'void%s+(%w+)%s*%(' or buf_lines[i]:match 'fun%s+(%w+)%s*%('
      if match then
        test_name = match
        break
      end
    end
    if vim.fn.filereadable 'build.gradle' == 1 or vim.fn.filereadable 'build.gradle.kts' == 1 then
      if test_name then
        return { './gradlew', 'test', '--tests', '*' .. class_name .. '.' .. test_name, '--info' }
      end
      return { './gradlew', 'test', '--tests', '*' .. class_name, '--info' }
    end
    if test_name then
      return { 'mvn', 'test', '-Dtest=' .. class_name .. '#' .. test_name }
    end
    return { 'mvn', 'test', '-Dtest=' .. class_name }
  end,
  cmd_all = function()
    if vim.fn.filereadable 'build.gradle' == 1 or vim.fn.filereadable 'build.gradle.kts' == 1 then
      return { './gradlew', 'test', '--info' }
    end
    return { 'mvn', 'test' }
  end,
  parse = function(output)
    local results = {}
    local passed, failed, skipped = 0, 0, 0
    for _, line in ipairs(lines(output)) do
      -- Gradle test output
      local name_p = line:match '(.+)%s+PASSED'
      local name_f = line:match '(.+)%s+FAILED'
      local name_s = line:match '(.+)%s+SKIPPED'

      if name_f then
        failed = failed + 1
        table.insert(results, { name = vim.trim(name_f), status = 'failed', output = {} })
      elseif name_s then
        skipped = skipped + 1
        table.insert(results, { name = vim.trim(name_s), status = 'skipped', output = {} })
      elseif name_p then
        passed = passed + 1
        table.insert(results, { name = vim.trim(name_p), status = 'passed', output = {} })
      end
    end
    return {
      passed = passed,
      failed = failed,
      skipped = skipped,
      total = passed + failed + skipped,
      results = results,
      raw_output = lines(output),
    }
  end,
}

--- Detect the appropriate runner for the current project/file
--- @param filetype string|nil
--- @return table|nil runner, string|nil name
function M.detect(filetype)
  -- Priority order based on filetype
  local ft_map = {
    go = { 'go' },
    python = { 'pytest' },
    php = { 'pest', 'phpunit' },
    java = { 'java' },
    javascript = { 'vitest', 'jest' },
    typescript = { 'vitest', 'jest' },
    typescriptreact = { 'vitest', 'jest' },
    javascriptreact = { 'vitest', 'jest' },
  }

  local candidates = ft_map[filetype] or { 'go', 'vitest', 'jest', 'pytest', 'pest', 'phpunit', 'java' }

  for _, name in ipairs(candidates) do
    local runner = M[name]
    if runner and runner.detect() then
      return runner, name
    end
  end

  return nil, nil
end

return M

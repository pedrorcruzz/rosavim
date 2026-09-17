return {
  'mfussenegger/nvim-lint',
  event = 'BufReadPost',
  config = function()
    local lint = require 'lint'

    ---@param entry string|string[]
    ---@return string exe, string name
    local function split(entry)
      if type(entry) == 'table' then
        return entry[1], entry[2]
      end
      return entry, entry
    end

    --- Every installed candidate. For linters that complement each other and
    --- are meant to run side by side.
    ---@param candidates (string|string[])[]
    ---@return string[]?
    local function available(candidates)
      local result = {}
      for _, entry in ipairs(candidates) do
        local exe, name = split(entry)
        if vim.fn.executable(exe) == 1 then
          table.insert(result, name)
        end
      end
      return #result > 0 and result or nil
    end

    --- Only the first installed candidate. For linters that overlap, so the
    --- same issue is not reported twice.
    ---@param candidates (string|string[])[]
    ---@return string[]?
    local function first_available(candidates)
      for _, entry in ipairs(candidates) do
        local exe, name = split(entry)
        if vim.fn.executable(exe) == 1 then
          return { name }
        end
      end
      return nil
    end

    lint.linters_by_ft = {
      markdown = available { 'markdownlint' },
      elixir = available { 'credo' },
      python = available { 'pylint', 'mypy' },
      php = available { 'phpcs' },
      go = available { { 'golangci-lint', 'golangcilint' } },
      java = available { 'checkstyle' },
      dockerfile = available { 'hadolint' },
    }

    -- eslint and biome cover much of the same ground, so a web buffer runs
    -- whichever one the project configures instead of both. Mason installs both
    -- binaries globally, which makes the config file the only useful signal.
    local eslint = first_available { 'eslint_d', 'eslint' }
    local biome = first_available { { 'biome', 'biomejs' } }

    local eslint_markers = {
      'eslint.config.js',
      'eslint.config.mjs',
      'eslint.config.cjs',
      'eslint.config.ts',
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.json',
      '.eslintrc.yml',
      '.eslintrc.yaml',
      '.eslintrc',
    }
    local biome_markers = { 'biome.json', 'biome.jsonc' }

    local web_filetypes = {
      javascript = true,
      typescript = true,
      javascriptreact = true,
      typescriptreact = true,
      vue = true,
    }

    local cache = {}

    ---@param dir string
    ---@param markers string[]
    ---@return boolean
    local function holds(dir, markers)
      for _, marker in ipairs(markers) do
        if vim.uv.fs_stat(dir .. '/' .. marker) then
          return true
        end
      end
      return false
    end

    --- Walk up to the repository root and take the nearest config. eslint wins
    --- a tie inside one directory: it carries project rules biome cannot
    --- express, and its presence is the deliberate choice of the two.
    ---@param dir string
    ---@return string[]?
    local function for_dir(dir)
      local hit = cache[dir]
      if hit ~= nil then
        return hit or nil
      end

      local dirs = { dir }
      for parent in vim.fs.parents(dir) do
        table.insert(dirs, parent)
      end

      -- biome needs no config file to be useful, so it is the last resort
      local result = biome
      for _, candidate in ipairs(dirs) do
        if holds(candidate, eslint_markers) then
          result = eslint
          break
        end
        if holds(candidate, biome_markers) then
          result = biome
          break
        end
        if vim.uv.fs_stat(candidate .. '/.git') then
          break
        end
      end

      cache[dir] = result or false
      return result
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    -- BufReadPost, not BufEnter: re-entering an already-linted buffer should
    -- not respawn linter processes.
    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function(args)
        if not web_filetypes[vim.bo[args.buf].filetype] then
          lint.try_lint()
          return
        end

        local name = vim.api.nvim_buf_get_name(args.buf)
        if name == '' then
          return
        end

        local linters = for_dir(vim.fs.dirname(name))
        if linters then
          lint.try_lint(linters)
        end
      end,
    })
  end,
}

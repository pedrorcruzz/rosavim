local M = {}

function M.check()
  local rosavim = require 'rosavim'

  vim.health.start(rosavim.name .. ' v' .. rosavim.version)

  -- Neovim version
  local nvim = vim.version()
  if nvim.minor >= 10 then
    vim.health.ok('Neovim v' .. nvim.major .. '.' .. nvim.minor .. '.' .. nvim.patch)
  else
    vim.health.error('Neovim >= 0.10 required', 'Update Neovim')
  end

  -- Git
  if vim.fn.executable 'git' == 1 then
    vim.health.ok('git found')
  else
    vim.health.error('git not found')
  end

  -- Node
  if vim.fn.executable 'node' == 1 then
    vim.health.ok('node found')
  else
    vim.health.warn('node not found (needed for some LSPs and plugins)')
  end

  -- Ripgrep
  if vim.fn.executable 'rg' == 1 then
    vim.health.ok('ripgrep found')
  else
    vim.health.warn('ripgrep not found (needed for telescope/snacks live grep)')
  end

  -- fd
  if vim.fn.executable 'fd' == 1 then
    vim.health.ok('fd found')
  else
    vim.health.warn('fd not found (needed for file pickers)')
  end

  -- Lazy
  local lazy_ok, lazy = pcall(require, 'lazy')
  if lazy_ok then
    local stats = lazy.stats()
    vim.health.ok(stats.loaded .. '/' .. stats.count .. ' plugins loaded in ' .. string.format('%.2fms', stats.startuptime))
  else
    vim.health.error('lazy.nvim not found')
  end
end

return M

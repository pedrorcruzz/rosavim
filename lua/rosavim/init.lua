local M = {}

M.version = '0.1.0'
M.name = 'Rosavim'

function M.info()
  local lazy = require 'lazy'
  local stats = lazy.stats()
  local nvim = vim.version()
  local lines = {
    M.name .. ' v' .. M.version,
    '',
    'Neovim: v' .. nvim.major .. '.' .. nvim.minor .. '.' .. nvim.patch,
    'Plugins: ' .. stats.loaded .. '/' .. stats.count,
    'Startup: ' .. string.format('%.2fms', stats.startuptime),
  }
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = M.name })
end

vim.api.nvim_create_user_command('Rosavim', function()
  M.info()
end, { desc = 'Show Rosavim info' })

return M
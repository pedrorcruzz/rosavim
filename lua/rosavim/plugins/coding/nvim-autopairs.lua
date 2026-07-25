local state_file = vim.fn.stdpath 'data' .. '/rosavim-autopair-off'

local function disabled()
  return vim.uv.fs_stat(state_file) ~= nil
end

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  keys = {
    {
      '<leader>lt',
      function()
        local ap = require 'nvim-autopairs'
        if disabled() then
          vim.fn.delete(state_file)
          ap.enable()
          vim.notify('Autopair ativado', vim.log.levels.INFO, { title = 'Autopair' })
        else
          vim.fn.writefile({}, state_file)
          ap.disable()
          vim.notify('Autopair desativado', vim.log.levels.WARN, { title = 'Autopair' })
        end
      end,
      desc = 'Toggle autopair',
    },
  },
  config = function()
    local ap = require 'nvim-autopairs'
    ap.setup {}
    if disabled() then
      ap.disable()
    end
  end,
}

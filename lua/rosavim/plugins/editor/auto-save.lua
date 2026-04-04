local toggles = require 'rosavim.config.toggles'

return {
  'okuuva/auto-save.nvim',
  version = '^1.0.0',
  cmd = 'ASToggle',
  event = { 'InsertLeave', 'TextChanged' },
  opts = {
    enabled = toggles.get 'autosave',
    trigger_events = {
      immediate_save = { 'BufLeave', 'FocusLost', 'QuitPre', 'VimSuspend' },
      defer_save = { 'InsertLeave', 'TextChanged' },
      cancel_deferred_save = { 'InsertEnter' },
    },
    condition = nil,
    write_all_buffers = false,
    noautocmd = false,
    lockmarks = false,
    debounce_delay = 600,
    debug = false,
  },
  keys = {
    {
      '<leader>ls',
      function()
        local new_val = toggles.toggle 'autosave'
        vim.cmd 'ASToggle'
        if new_val then
          vim.notify('Auto Save: On', vim.log.levels.INFO)
        else
          vim.notify('Auto Save: Off', vim.log.levels.INFO)
        end
      end,
      desc = 'Auto Save: Toggle',
    },
  },
}

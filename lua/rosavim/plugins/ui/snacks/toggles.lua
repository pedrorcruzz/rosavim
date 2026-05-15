local toggles = require 'rosavim.config.toggles'

local function persist_toggle(snacks_toggle, key)
  local orig_toggle = snacks_toggle.toggle
  snacks_toggle.toggle = function(self)
    orig_toggle(self)
    toggles.set(key, self:get())
  end
  return snacks_toggle
end

-- Load toggle modules
require('rosavim.plugins.ui.snacks.toggles.options')(persist_toggle)
require('rosavim.plugins.ui.snacks.toggles.plugins')()
require('rosavim.plugins.ui.snacks.toggles.appearance')()
require('rosavim.plugins.ui.snacks.toggles.autocmds')()
require('rosavim.plugins.ui.snacks.toggles.dashboard_gif')()

-- Restore persisted states
if toggles.get 'indent' then
  Snacks.toggle.indent():set(true)
end
if toggles.get 'dim' then
  Snacks.toggle.dim():set(true)
end
if not toggles.get 'markview' then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    once = true,
    callback = function()
      vim.schedule(function()
        vim.cmd 'Markview Disable'
      end)
    end,
  })
end

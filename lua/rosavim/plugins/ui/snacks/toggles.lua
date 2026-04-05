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

-- Restore persisted states
if toggles.get 'indent' then
  Snacks.toggle.indent():set(true)
end
if toggles.get 'dim' then
  Snacks.toggle.dim():set(true)
end

local toggles = require 'rosavim.config.toggles'

return function()
  Snacks.toggle({
    name = 'BufferLine Diagnostics Indicator',
    wk_desc = { enabled = 'Hide ', disabled = 'Show ' },
    get = function()
      return toggles.get_or('bufferline_diagnostics', true)
    end,
    set = function(state)
      toggles.set('bufferline_diagnostics', state)
      vim.cmd 'redrawtabline'
    end,
  }):map '<leader>labb'
end

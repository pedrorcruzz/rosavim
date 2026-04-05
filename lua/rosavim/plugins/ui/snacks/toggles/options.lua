local toggles = require 'rosavim.config.toggles'

return function(persist_toggle)
  persist_toggle(Snacks.toggle.option('wrap', { name = 'Wrap' }), 'wrap'):map '<leader>lw'
  persist_toggle(Snacks.toggle.option('relativenumber', { name = 'Relative Number' }), 'relativenumber'):map '<leader>lg'
  persist_toggle(Snacks.toggle.line_number(), 'linenumber'):map '<leader>ln'
  Snacks.toggle.zen():map '<leader>lz'
  persist_toggle(Snacks.toggle.indent(), 'indent'):map '<leader>li'
  persist_toggle(Snacks.toggle.dim(), 'dim'):map '<leader>lk'

  -- Spell
  Snacks.toggle({
    name = 'Spellcheck',
    get = function()
      return vim.o.spell
    end,
    set = function(state)
      vim.o.spell = state
      toggles.set('spell', state)
    end,
  }):map '<leader>ljj'
end

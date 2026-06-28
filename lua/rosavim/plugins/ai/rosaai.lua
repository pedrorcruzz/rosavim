--- Rosaai - Plugin spec wiring keymaps for the native AI CLI integration
return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosaai',
  name = 'rosaai',
  lazy = true,
  keys = {
    { '<leader>a', '', desc = '+ai', mode = { 'n', 'v' } },
    {
      '<c-.>',
      function()
        require('rosavim.rosa_plugins.rosaai').focus()
      end,
      desc = 'Rosaai: Focus',
      mode = { 'n', 't', 'i', 'x' },
    },

    -- Smart toggle: picker on the very first open, then reuses the last layout
    {
      '<leader>aa',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker()
      end,
      desc = 'Rosaai: Toggle CLI',
    },
    {
      '<leader>aa',
      function()
        require('rosavim.rosa_plugins.rosaai').ask_with_preview()
      end,
      mode = 'x',
      desc = 'Rosaai: Ask (preview + prompt)',
    },

    -- Direct layout switchers
    {
      '<leader>av',
      function()
        require('rosavim.rosa_plugins.rosaai').show_in 'right'
      end,
      desc = 'Rosaai: Open Vertical',
    },
    {
      '<leader>ah',
      function()
        require('rosavim.rosa_plugins.rosaai').show_in 'bottom'
      end,
      desc = 'Rosaai: Open Horizontal',
    },
    {
      '<leader>af',
      function()
        require('rosavim.rosa_plugins.rosaai').show_in 'float'
      end,
      desc = 'Rosaai: Open Float',
    },

    -- Selection / prompts / sends
    {
      '<leader>as',
      function()
        require('rosavim.rosa_plugins.rosaai').select()
      end,
      desc = 'Rosaai: Select CLI',
    },
    {
      '<leader>at',
      function()
        require('rosavim.rosa_plugins.rosaai').send { msg = '{this}' }
      end,
      mode = { 'x', 'n' },
      desc = 'Rosaai: Send This',
    },
    {
      '<leader>aF',
      function()
        require('rosavim.rosa_plugins.rosaai').send { msg = '{file}' }
      end,
      desc = 'Rosaai: Send File',
    },
    {
      '<leader>av',
      function()
        require('rosavim.rosa_plugins.rosaai').send { msg = '{selection}' }
      end,
      mode = { 'x' },
      desc = 'Rosaai: Send Visual Selection',
    },
    {
      '<leader>ap',
      function()
        require('rosavim.rosa_plugins.rosaai').prompt()
      end,
      mode = { 'n', 'x' },
      desc = 'Rosaai: Select Prompt',
    },

    -- Per-tool toggles
    {
      '<leader>ac',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'claude'
      end,
      desc = 'Rosaai: Toggle Claude',
    },
    {
      '<leader>aC',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'claude-yolo'
      end,
      desc = 'Rosaai: Toggle Claude (YOLO)',
    },
    {
      '<leader>au',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'cursor'
      end,
      desc = 'Rosaai: Toggle Cursor',
    },
    {
      '<leader>aU',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'cursor-yolo'
      end,
      desc = 'Rosaai: Toggle Cursor (YOLO)',
    },
    {
      '<leader>ao',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'openclaude'
      end,
      desc = 'Rosaai: Toggle OpenClaude',
    },
    {
      '<leader>ag',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'gemini'
      end,
      desc = 'Rosaai: Toggle Gemini',
    },
  },
}

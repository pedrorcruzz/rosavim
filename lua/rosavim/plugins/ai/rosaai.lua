--- RosaAI - Plugin spec wiring keymaps for the native AI CLI integration
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
      desc = 'RosaAI: Focus',
      mode = { 'n', 't', 'i', 'x' },
    },

    -- Smart toggle: picker on the very first open, then reuses the last layout
    {
      '<leader>aa',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker()
      end,
      desc = 'RosaAI: Toggle CLI',
    },
    {
      '<leader>aa',
      function()
        require('rosavim.rosa_plugins.rosaai').ask_with_preview()
      end,
      mode = 'x',
      desc = 'RosaAI: Ask (preview + prompt)',
    },

    -- Direct layout switchers
    {
      '<leader>av',
      function()
        require('rosavim.rosa_plugins.rosaai').open_in_layout 'right'
      end,
      desc = 'RosaAI: Open Vertical',
    },
    {
      '<leader>ah',
      function()
        require('rosavim.rosa_plugins.rosaai').open_in_layout 'bottom'
      end,
      desc = 'RosaAI: Open Horizontal',
    },
    {
      '<leader>af',
      function()
        require('rosavim.rosa_plugins.rosaai').open_in_layout 'float'
      end,
      desc = 'RosaAI: Open Float',
    },

    -- Selection / prompts / sends
    {
      '<leader>as',
      function()
        require('rosavim.rosa_plugins.rosaai').select()
      end,
      desc = 'RosaAI: Select CLI',
    },
    {
      '<leader>at',
      function()
        require('rosavim.rosa_plugins.rosaai').send { msg = '{this}' }
      end,
      mode = { 'x', 'n' },
      desc = 'RosaAI: Send This',
    },
    {
      '<leader>aF',
      function()
        require('rosavim.rosa_plugins.rosaai').send { msg = '{file}' }
      end,
      desc = 'RosaAI: Send File',
    },
    {
      '<leader>av',
      function()
        require('rosavim.rosa_plugins.rosaai').send { msg = '{selection}' }
      end,
      mode = { 'x' },
      desc = 'RosaAI: Send Visual Selection',
    },
    {
      '<leader>ap',
      function()
        require('rosavim.rosa_plugins.rosaai').prompt()
      end,
      mode = { 'n', 'x' },
      desc = 'RosaAI: Select Prompt',
    },

    -- Per-tool toggles
    {
      '<leader>ac',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'claude'
      end,
      desc = 'RosaAI: Toggle Claude',
    },
    {
      '<leader>aC',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'claude-yolo'
      end,
      desc = 'RosaAI: Toggle Claude (YOLO)',
    },
    {
      '<leader>au',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'cursor'
      end,
      desc = 'RosaAI: Toggle Cursor',
    },
    {
      '<leader>aU',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'cursor-yolo'
      end,
      desc = 'RosaAI: Toggle Cursor (YOLO)',
    },
    {
      '<leader>ao',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'openclaude'
      end,
      desc = 'RosaAI: Toggle OpenClaude',
    },
    {
      '<leader>ag',
      function()
        require('rosavim.rosa_plugins.rosaai').toggle_with_picker 'gemini'
      end,
      desc = 'RosaAI: Toggle Gemini',
    },
  },
}

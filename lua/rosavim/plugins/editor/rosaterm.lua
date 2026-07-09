-- While the RosaAI float (or any rosaai panel) is focused, swallow the
-- rosaterm horizontal toggle so it doesn't pop up over the AI window.
local function focused_on_rosaai()
  return vim.bo.filetype:sub(1, 6) == 'rosaai'
end

return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosaterm',
  name = 'rosaterm',
  lazy = true,
  keys = {
    {
      '<c-\\>',
      function()
        require('rosavim.rosa_plugins.rosaterm').toggle_float()
      end,
      mode = { 'n', 'i', 'v', 't' },
      desc = 'Rosaterm: Toggle Float',
    },
    {
      '<S-z>',
      function()
        require('rosavim.rosa_plugins.rosaterm').toggle_float()
      end,
      mode = { 'n', 'i', 'v', 't' },
      desc = 'Rosaterm: Toggle Float',
    },
    {
      '<S-x>',
      function()
        if focused_on_rosaai() then
          return
        end
        require('rosavim.rosa_plugins.rosaterm').toggle_horizontal('h_main', 17, 'Terminal')
      end,
      mode = { 'n', 't' },
      desc = 'Rosaterm: Horizontal',
    },
    {
      '<leader>cii',
      function()
        require('rosavim.rosa_plugins.rosaterm').toggle_vertical('v_ci', 70, 'Terminal')
      end,
      desc = 'Rosaterm: Vertical Split',
    },
    {
      '<leader>cie',
      function()
        require('rosavim.rosa_plugins.rosaterm').toggle_horizontal('h_ci', 16, 'Terminal')
      end,
      desc = 'Rosaterm: Horizontal Split',
    },
  },
}

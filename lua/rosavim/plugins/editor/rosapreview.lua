return {
  dir = vim.fn.stdpath 'config' .. '/lua/rosavim/rosa_plugins/rosapreview',
  name = 'rosapreview',
  event = 'LspAttach',
  config = function()
    require('rosavim.rosa_plugins.rosapreview').setup()
  end,
  keys = {
    {
      'gp',
      function()
        require('rosavim.rosa_plugins.rosapreview').definition()
      end,
      desc = 'Rosapreview: Definition',
    },
    {
      'gP',
      function()
        require('rosavim.rosa_plugins.rosapreview').close_all()
      end,
      desc = 'Rosapreview: Close All',
    },
    -- {
    --   'gpt',
    --   function()
    --     require('rosavim.rosa_plugins.rosapreview').type_definition()
    --   end,
    --   desc = 'Rosapreview: Type Definition',
    -- },
    -- {
    --   'gpi',
    --   function()
    --     require('rosavim.rosa_plugins.rosapreview').implementation()
    --   end,
    --   desc = 'Rosapreview: Implementation',
    -- },
    -- {
    --   'gpD',
    --   function()
    --     require('rosavim.rosa_plugins.rosapreview').declaration()
    --   end,
    --   desc = 'Rosapreview: Declaration',
    -- },
    -- {
    --   'gpr',
    --   function()
    --     require('rosavim.rosa_plugins.rosapreview').references()
    --   end,
    --   desc = 'Rosapreview: References',
    -- },
  },
}

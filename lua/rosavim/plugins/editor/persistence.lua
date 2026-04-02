return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {},
  keys = {
    --   {
    --     '<leader>R',
    --     function()
    --       require('persistence').load()
    --     end,
    --     desc = 'Restore Last Session',
    --   },
    --   {
    --     '<leader>S',
    --     function()
    --       require('persistence').save()
    --     end,
    --     desc = 'Save Session',
    --   },
  },
}

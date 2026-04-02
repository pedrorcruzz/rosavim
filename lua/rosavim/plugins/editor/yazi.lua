---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>y', '<cmd>Yazi<cr>', desc = 'Yazi' },
  },
  ---@type YaziConfig
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = 'g?',
    },
  },
}

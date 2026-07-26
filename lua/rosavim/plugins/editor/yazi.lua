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
    -- Full-screen and above the RosaAI/rosaterm floats (chips top out at 60), so
    -- a pinned panel can't bleed over yazi. Mirrors the lazygit float behaviour.
    floating_window_scaling_factor = 1.0,
    yazi_floating_window_zindex = 70,
    keymaps = {
      show_help = 'g?',
    },
  },
}

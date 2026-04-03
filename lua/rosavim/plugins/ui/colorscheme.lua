-- Custom Colorscheme
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = '#4c4c4c' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { fg = '#4c4c4c' })
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpBorder', { fg = '#4c4c4c' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocSeparator', { fg = '#606060' })
    vim.api.nvim_set_hl(0, 'MiniIconsPurple', { fg = '#777BB4', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsAzure', { fg = '#007FFF', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsBlue', { fg = '#0000FF', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsCyan', { fg = '#60A5FA', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsGrey', { fg = '#A0A0A0', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsOrange', { fg = '#F59E0C', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsYellow', { fg = '#FFDE21', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsRed', { fg = '#F87171', bg = 'none' })
    vim.api.nvim_set_hl(0, 'MiniIconsGreen', { fg = '#9FF8BB', bg = 'none' })
  end,
})

local appearance = require 'rosavim.config.appearance'

vim.keymap.set('n', '<leader>lqt', function()
  appearance.toggle()
end, { desc = 'Toggle Dark/Light' })

vim.keymap.set('n', '<leader>lqs', function()
  Snacks.picker.colorschemes()
end, { desc = 'Search Colorscheme' })

vim.keymap.set('n', '<leader>lqe', function()
  appearance.toggle_transparent()
end, { desc = 'Toggle Transparent' })

return {
  {
    'LazyVim/LazyVim',
    init = function()
      vim.g.lazyvim_check_order = false
      vim.schedule(function()
        local ok, util = pcall(require, 'lazyvim.util')
        if ok then
          pcall(function()
            rawset(util, 'info', function(...) end)
          end)
        end
      end)
    end,
    opts = {
      colorscheme = require('rosavim.config.appearance').get_colorscheme() or 'min-theme',
    },
  },
}

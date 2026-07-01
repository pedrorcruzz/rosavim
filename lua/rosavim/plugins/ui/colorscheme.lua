-- Custom Colorscheme
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = '#4c4c4c' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { fg = '#4c4c4c' })
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpBorder', { fg = '#4c4c4c' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocSeparator', { fg = '#3a3a3a' })
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

-- Dark/Light and Transparent toggles moved to snacks/toggles.lua

-- Colorscheme selector — same vim.ui.select popup style as the rosaterm/
-- rosaai theme pickers (<leader>lqr / <leader>lqa) instead of the full
-- Snacks.picker UI. Applying fires the ColorScheme autocmd, which persists
-- the choice to the appearance cache.
vim.keymap.set('n', '<leader>lqs', function()
  local current = vim.g.colors_name
  -- Only our own rosa colorschemes (not every installed scheme).
  local items = { 'rosamin', 'rosaesthetic' }
  vim.ui.select(items, {
    prompt = 'Theme · select',
    kind = 'colorscheme',
    format_item = function(name)
      return name .. (name == current and ' ●' or '')
    end,
  }, function(choice)
    if not choice then
      return
    end
    ---@diagnostic disable-next-line: undefined-global
    pcall(vim.cmd.colorscheme, choice)
    Snacks.notify.info('Theme: ' .. choice)
  end)
end, { desc = 'Select Theme' })

-- Apply the default (or cached) colorscheme as soon as the rosa themes are
-- ready. Runs once, defensively — covers the fresh-install case where no
-- cache file exists and nothing else has set `g:colors_name` yet.
local function apply_default_colorscheme()
  local cs = require('rosavim.config.appearance').get_colorscheme() or 'rosamin'
  if vim.g.colors_name ~= cs then
    pcall(vim.cmd.colorscheme, cs)
  end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone',
  once = true,
  callback = apply_default_colorscheme,
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    -- Last-resort: if nothing set a colorscheme by VimEnter (e.g. LazyDone
    -- fired before colorscheme plugins loaded), force it now.
    vim.schedule(apply_default_colorscheme)
  end,
})

return {}

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

-- Drive the terminal cursor color from the Cursor highlight so it follows the
-- active theme. Neovim's TUI does not emit OSC 12 on its own, so we send it
-- explicitly whenever the colorscheme changes (OSC 12 is a standard escape
-- sequence most terminals honor), and reset it on exit so the shell cursor
-- returns to the terminal default. Note: terminals with an inverted/reverse
-- cursor mode enabled ignore OSC 12 — disable that mode for this to take effect
-- (in Ghostty: `cursor-invert-fg-bg = false`).
-- Only our own themes define an explicit Cursor bg; guard on them so we never
-- emit the default reverse cursor (which resolves to black) before a theme has
-- been applied at startup.
local rosa_schemes = { rosamin = true, rosavintage = true, rosanight = true }
local function sync_terminal_cursor_color()
  if not rosa_schemes[vim.g.colors_name] then
    return
  end
  local hl = vim.api.nvim_get_hl(0, { name = 'Cursor', link = false })
  if hl.bg then
    io.write(string.format('\027]12;#%06x\007', hl.bg))
    io.flush()
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = vim.schedule_wrap(sync_terminal_cursor_color),
})
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    -- Emit once now and again after a short delay: at startup the terminal may
    -- not yet honor OSC 12 (the escape gets dropped, leaving the cursor on its
    -- previous color until the next theme change), and the colorscheme may not
    -- be applied on the first tick either. The delayed re-emit lands once both
    -- are ready.
    vim.schedule(sync_terminal_cursor_color)
    vim.defer_fn(sync_terminal_cursor_color, 200)
  end,
})
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    io.write '\027]112\007' -- reset cursor color to terminal default
    io.flush()
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
  local items = { 'rosamin', 'rosavintage', 'rosanight' }
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

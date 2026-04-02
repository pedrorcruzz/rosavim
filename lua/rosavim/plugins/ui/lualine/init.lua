local theme = require 'rosavim.plugins.ui.lualine.theme'
local sections = require 'rosavim.plugins.ui.lualine.sections'

local lualine_visible = true
local use_custom_theme = true

local sep = {
  section = { left = '', right = '' },
  component = { left = '', right = '' },
  mode = { left = '', right = '' },
  location = { left = '', right = '' },
}

local lualine_config = {
  options = {
    theme = use_custom_theme and theme.create() or 'auto',
    section_separators = sep.section,
    component_separators = sep.component,
    globalstatus = true,
  },
  sections = sections.build(sep),
  inactive_sections = sections.inactive_sections,
}

function ToggleLualine()
  local lualine = require 'lualine'
  if not package.loaded['lualine'] then
    lualine.setup(lualine_config)
  end
  lualine_visible = not lualine_visible
  lualine.hide { unhide = lualine_visible }
end

vim.keymap.set('n', '<leader>ll', ToggleLualine, { desc = 'Toggle Lualine' })

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  lazy = true,
  dependencies = {
    -- { 'nvim-tree/nvim-web-devicons', lazy = true, enabled = vim.g.have_nerd_font },
    { 'echasnovski/mini.icons' },
    { 'AndreM222/copilot-lualine', lazy = true },
  },
  config = function()
    vim.o.laststatus = 3
    local lualine = require 'lualine'
    lualine.setup(lualine_config)
    lualine.hide { unhide = lualine_visible }
  end,
}

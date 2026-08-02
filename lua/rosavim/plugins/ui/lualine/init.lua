-- Lualine and Lualine Theme toggles moved to snacks/toggles.lua

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
    -- Build the config INSIDE config() (not at module load): the custom theme
    -- (theme.create) reads the active colorscheme's Normal bg / transparent
    -- state, which is only set once the colorscheme has been applied. Building
    -- it at module-load time (during lazy's spec collection) ran before the
    -- colorscheme, baking in a stale centre-bar colour until a manual theme /
    -- transparent toggle re-ran it.
    local theme = require 'rosavim.plugins.ui.lualine.theme'
    local sections = require 'rosavim.plugins.ui.lualine.sections'
    local toggles = require 'rosavim.config.toggles'
    local sep = sections.get_sep()
    local lualine = require 'lualine'
    lualine.setup {
      options = {
        theme = toggles.get 'lualine_theme' and theme.create() or 'auto',
        section_separators = sep.section,
        component_separators = sep.component,
        globalstatus = true,
      },
      sections = sections.build(sep),
      inactive_sections = sections.inactive_sections,
    }
    lualine.hide { unhide = toggles.get 'lualine' }
  end,
}

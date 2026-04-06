local toggles = require 'rosavim.config.toggles'

return function()
  -- Dark/Light mode
  Snacks.toggle({
    name = 'Light Mode',
    get = function()
      return vim.o.background == 'light'
    end,
    set = function(state)
      local new_mode = state and 'light' or 'dark'
      vim.o.background = new_mode
      vim.fn.writefile({ new_mode }, vim.fn.stdpath 'cache' .. '/rosavim-background')
      local name = vim.g.colors_name
      if name then
        vim.cmd('colorscheme ' .. name)
      end
    end,
  }):map '<leader>lqt'

  -- Transparent
  Snacks.toggle({
    name = 'Transparent',
    get = function()
      local appearance = require 'rosavim.config.appearance'
      return appearance.get_transparent()
    end,
    set = function(state)
      local appearance = require 'rosavim.config.appearance'
      appearance._transparent = state
      vim.fn.writefile({ state and 'true' or 'false' }, vim.fn.stdpath 'cache' .. '/rosavim-transparent')
      local name = vim.g.colors_name
      if name then
        vim.cmd('colorscheme ' .. name)
      end
    end,
  }):map '<leader>lqe'

  -- Lualine (visibility)
  Snacks.toggle({
    name = 'Lualine',
    get = function()
      return toggles.get 'lualine'
    end,
    set = function(state)
      toggles.set('lualine', state)
      local lualine = require 'lualine'
      lualine.hide { unhide = state }
    end,
  }):map '<leader>ll'

  -- Lualine Theme (Auto/Custom)
  Snacks.toggle({
    name = 'Lualine Custom Theme',
    get = function()
      return toggles.get 'lualine_theme'
    end,
    set = function(state)
      toggles.set('lualine_theme', state)
      local theme = require 'rosavim.plugins.ui.lualine.theme'
      local lualine = require 'lualine'
      local sections = require 'rosavim.plugins.ui.lualine.sections'
      local sep = sections.sep
      local config = {
        options = {
          theme = state and theme.create() or 'auto',
          section_separators = sep.section,
          component_separators = sep.component,
          globalstatus = true,
        },
        sections = sections.build(sep),
        inactive_sections = sections.inactive_sections,
      }
      lualine.setup(config)
      lualine.hide { unhide = toggles.get 'lualine' }
    end,
  }):map '<leader>lql'
end

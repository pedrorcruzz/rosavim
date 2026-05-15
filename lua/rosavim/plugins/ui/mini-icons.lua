return {
  'echasnovski/mini.icons',
  lazy = true,
  opts = {
    file = {
      ['docker-compose.yml'] = { glyph = '󰡨', hl = 'MiniIconsAzure' },
      ['docker-compose.yaml'] = { glyph = '󰡨', hl = 'MiniIconsAzure' },
      ['docker-compose.override.yml'] = { glyph = '󰡨', hl = 'MiniIconsPurple' },
      ['docker-compose.override.yaml'] = { glyph = '󰡨', hl = 'MiniIconsPurle' },
      ['docker-compose.prod.yml'] = { glyph = '󰡨', hl = 'MiniIconsGreen' },
      ['docker-compose.prod.yaml'] = { glyph = '󰡨', hl = 'MiniIconsGreen' },
      ['Dockerfile'] = { glyph = '󰡨', hl = 'MiniIconsAzure' },

      ['go.mod'] = { glyph = '', hl = 'MiniIconsRed' },
      ['go.sum'] = { glyph = '', hl = 'MiniIconsPurple' },
      ['Makefile'] = { glyph = '', hl = 'MiniIconsRed' },
      ['README.md'] = { glyph = '', hl = 'MiniIconsCyan' },
      ['package.json'] = { glyph = '', hl = 'MiniIconsGreen' },
      ['package-lock.json'] = { glyph = '', hl = 'MiniIconsGreen' },
      ['.gitignore'] = { glyph = '', hl = 'MiniIconsRed' },
      ['LICENSE'] = { glyph = '', hl = 'RosatestFileIcon' },
      ['.env'] = { glyph = '', hl = 'MiniIconsGreen' },
      ['.env.example'] = { glyph = '', hl = 'RosaWhiteIcon' },
      ['.env.example.docker'] = { glyph = '', hl = 'MiniIconsGreen' },
      ['.env.example.docker-prod'] = { glyph = '', hl = 'MiniIconsGreen' },

      ['tsconfig.node.json'] = { glyph = '', hl = 'MiniIconsAzure' },

      ['tailwind.config.js'] = { glyph = '󱏿', hl = 'MiniIconsCyan' },
      ['tailwind.config.ts'] = { glyph = '󱏿', hl = 'MiniIconsCyan' },
      ['tailwind.config.mjs'] = { glyph = '󱏿', hl = 'MiniIconsCyan' },

      ['vite.config.ts'] = { glyph = '', hl = 'MiniIconsYellow' },
      ['vite.config.js'] = { glyph = '', hl = 'MiniIconsYellow' },

      ['biome.json'] = { glyph = '', hl = 'MiniIconsYellow' },
      ['commitlint.config.mjs'] = { glyph = '', hl = 'MiniIconsYellow' },

      ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
      ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
    },

    extension = {
      go = { glyph = '', hl = 'MiniIconsCyan' },
      txt = { glyph = '', hl = 'MiniIconsGrey' },
      lua = { glyph = '', hl = 'MiniIconsAzure' },
      php = { glyph = '', hl = 'MiniIconsPurple' },
      html = { glyph = '', hl = 'MiniIconsOrange' },
      css = { glyph = '', hl = 'MiniIconsPurple' },
      js = { glyph = '', hl = 'MiniIconsYellow' },
      mjs = { glyph = '', hl = 'MiniIconsYellow' },
      ts = { glyph = '', hl = 'MiniIconsAzure' },
      tsx = { glyph = '', hl = 'MiniIconsAzure' },
      jsx = { glyph = '', hl = 'MiniIconsCyan' },
      json = { glyph = '', hl = 'MiniIconsOrange' },
      lock = { glyph = '', hl = 'MiniIconsGrey' },
      zsh = { glyph = '', hl = 'MiniIconsGreen' },
      md = { glyph = '', hl = 'MiniIconsCyan' },
    },

    -- directory = {
    --   ['layout'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['sidebar'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['hooks'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['routes'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['styles'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['utils'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['public'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['node_modules'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['.git'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['.vscode'] = { glyph = '', hl = 'MiniIconsGrey' },
    --   ['src'] = { glyph = '', hl = 'MiniIconsRed' },
    --   ['components'] = { glyph = '', hl = 'MiniIconsGreen' },
    -- },

    filetype = {
      dotenv = { glyph = '', hl = 'MiniIconsYellow' },
    },
  },

  init = function()
    package.preload['nvim-web-devicons'] = function()
      require('mini.icons').mock_nvim_web_devicons()
      return package.loaded['nvim-web-devicons']
    end
  end,

  config = function(_, opts)
    local mini_icons = require 'mini.icons'
    mini_icons.setup(opts)
    vim.api.nvim_set_hl(0, 'RosatestFileIcon', { fg = '#cdd6f4' })
    vim.api.nvim_set_hl(0, 'RosaWhiteIcon', { fg = '#ffffff' })

    local use_theme_directory_color = true

    local original_get = mini_icons.get

    mini_icons.get = function(category, name)
      if category == 'file' and name and (name:find '%.test' or name:find '_test') then
        return '󰙨', 'RosatestFileIcon'
      end

      if use_theme_directory_color and category == 'directory' then
        return '', 'Directory'
      end

      return original_get(category, name)
    end

    mini_icons.mock_nvim_web_devicons()
  end,
}

return {
  'vyfor/cord.nvim',
  lazy = true,
  event = 'VeryLazy',
  build = ':Cord update',
  init = function()
    -- Keep cord from auto-starting on load; setup runs only when Discord is up
    vim.g.cord_defer_startup = true
  end,
  config = function()
    -- Async check so startup never blocks on a process scan
    vim.system({ 'pgrep', 'Discord' }, {}, function(out)
      if out.code ~= 0 then
        return
      end
      vim.schedule(function()
        require('cord').setup {
          editor = {
            client = '1342537926969524325', -- Rosavim
            -- client = '1233867420330889286', -- Neovim
            icon = 'https://raw.githubusercontent.com/pedrorcruzz/rosavim/main/assets/logo/rosavim.png',
            tooltip = 'Rosavim',
          },
          display = {
            theme = 'minecraft',
            -- theme = 'default',
            -- theme = 'atom',
            -- theme = 'catppuccin',
            -- theme = 'minecraft',
            -- theme = 'void',
            -- theme = 'classic',
            flavor = 'accent', -- 'dark' | 'light' | 'accent'
            view = 'full', -- 'full' | 'editor' | 'asset' | 'auto'
          },
          timestamp = {
            enabled = true,
            shared = true,
          },
          text = {
            workspace = function(opts)
              return opts.workspace and ('Working on ' .. opts.workspace) or nil
            end,
            editing = function(opts)
              return 'Editing ' .. opts.filename
            end,
            viewing = function(opts)
              return 'Reading ' .. opts.filename
            end,
            file_browser = function(opts)
              return 'Browsing ' .. (opts.workspace or opts.name or 'files')
            end,
            plugin_manager = 'Managing plugins',
            vcs = 'Committing changes',
            terminal = function(opts)
              if opts.filetype == 'rosaai' then
                return 'Using RosaAI'
              end
              return 'Using Terminal'
            end,
          },
          assets = {
            rosaai = {
              name = 'RosaAI',
              tooltip = 'RosaAI',
              type = 'terminal',
            },
          },
        }
      end)
    end)
  end,
}

return {
  'mistweaverco/discord.nvim',
  lazy = true,
  event = 'VeryLazy',
  config = function()
    local is_discord_running = os.execute 'pgrep Discord > /dev/null'

    if is_discord_running ~= 0 then
      return
    end

    require('discord').setup {
      auto_connect = false,
      logo = 'https://logosrated.net/wp-content/uploads/parser/Neovim-Logo-1.png', -- Logo Neovim: https://logosrated.net/wp-content/uploads/parser/Neovim-Logo-1.png
      logo_tooltip = nil,
      main_image = 'language',
      client_id = '1342537926969524325', -- Neovim: 1233867420330889286 || Rosavim: 1342537926969524325
      log_level = nil,
      debounce_timeout = 10,
      blacklist = {},
      file_assets = {},
      show_time = true,
      global_timer = true,

      editing_text = 'Editing %s',
      file_explorer_text = 'Browsing %s',
      git_commit_text = 'Committing changes',
      plugin_manager_text = 'Managing plugins',
      reading_text = 'Reading %s',
      workspace_text = 'Working on %s',
      line_number_text = 'Line %s out of %s',
      terminal_text = 'Using Terminal',
    }
  end,
}

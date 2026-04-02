local header = {
  [[
    ██████╗  ██████╗ ███████╗ █████╗ ██╗   ██╗██╗███╗   ███╗
    ██╔══██╗██╔═══██╗██╔════╝██╔══██╗██║   ██║██║████╗ ████║
    ██████╔╝██║   ██║███████╗███████║██║   ██║██║██╔████╔██║
    ██╔══██╗██║   ██║╚════██║██╔══██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║  ██║╚██████╔╝███████║██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
  ]],
}

local obsidian_action = function()
  Snacks.picker.smart { cwd = vim.fn.expand '~/Developer/second-brain/' }
end

local browse_action = function()
  Snacks.gitbrowse()
end

local menu = {
  { icon = ' ', key = 'p', desc = 'Projects', action = ':NeovimProjectDiscover' },
  { icon = ' ', key = 'o', desc = 'Obsidian', action = obsidian_action },
  { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
  { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
  { icon = ' ', key = 'n', desc = 'New file', action = ':enew' },
  { icon = ' ', key = 'd', desc = 'Database UI', action = ':DBUIToggle' },
  { icon = ' ', key = 'w', desc = 'Yazi', action = ':Yazi cwd' },
  { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
  { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
  { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
  { icon = ' ', key = 'x', desc = 'Colorscheme', action = ':e ~/.config/nvim/lua/rosavim/plugins/ui/colorscheme.lua' },
  { icon = ' ', key = 'b', desc = 'Browse Repo', action = browse_action },
  { icon = ' ', key = 'i', desc = 'Rosavim', action = ':Rosavim' },
  { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
}

return {
  enabled = true,
  preset = {
    keys = menu,
    header = header,
  },
  sections = {
    -- Wide version (180 columns or more)
    {
      enabled = function()
        return (vim.o.columns >= 180)
      end,
      {
        section = 'header',
        indent = 64,
        enabled = function()
          return not (vim.o.columns < 135)
        end,
      },
      { section = 'rosavim_startup', indent = 64 },
      {
        pane = 1,
        { padding = 0 },
        { section = 'keys', gap = 0 },
      },
      {
        pane = 2,
        {
          padding = 10,
        },
        {
          icon = ' ',
          title = 'Recent Files',
          section = 'recent_files',
          indent = 3,
          padding = 1,
          limit = 7,
        },
        {
          icon = ' ',
          title = 'Projects',
          section = 'projects',
          limit = 4,
          indent = 3,
        },
      },
      {
        padding = 2,
      },
      {
        section = 'terminal',
        cmd = 'chafa -f symbols -c full --speed=0.8 --clear --stretch $HOME/.config/nvim/lua/rosavim/plugins/ui/dashboard_img/gopher.gif; sleep .1',
        height = 8,
        width = 20,
        indent = 50,
      },
    },

    -- Slim version (less than 180 columns)
    {
      enabled = function()
        return (vim.o.columns < 180)
      end,
      {
        { section = 'header' },
        { section = 'rosavim_startup', padding = 1 },
        { section = 'keys', gap = 0 },
        {
          padding = 1,
        },
        {
          icon = ' ',
          title = 'Recent Files',
          section = 'recent_files',
          padding = 1,
        },
        {
          icon = ' ',
          title = 'Projects',
          section = 'projects',
          padding = 3,
        },
      },
    },
  },
}

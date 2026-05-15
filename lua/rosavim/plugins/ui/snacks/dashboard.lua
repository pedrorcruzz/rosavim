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

-- Dashboard gif (chafa) — managed via <leader>lqd toggles.
-- The terminal section is a function so it's re-evaluated on every render,
-- which lets the gif/dimensions hot-reload after Snacks.dashboard.update().
local function gif_section()
  local toggles = require 'rosavim.config.toggles'
  return {
    section = 'terminal',
    enabled = toggles.get 'dashboard_gif',
    cmd = string.format(
      'chafa -f symbols -c full --speed=0.8 --clear --stretch $HOME/.config/nvim/lua/rosavim/plugins/ui/dashboard_img/%s; sleep .1',
      toggles.get 'dashboard_gif_name' or 'gopher.gif'
    ),
    ttl = 0,
    height = toggles.get 'dashboard_gif_height' or 8,
    width = toggles.get 'dashboard_gif_width' or 20,
    indent = toggles.get 'dashboard_gif_indent' or 50,
  }
end

-- Obsidian vault is read from Rosadirs (<leader>lp to add/remove)
local obsidian_action = function()
  local ok, rosadirs = pcall(require, 'rosavim.rosa_plugins.rosadirs')
  local vaults = ok and rosadirs.obsidian() or {}
  if #vaults == 0 then
    Snacks.notify.warn 'Rosadirs: no Obsidian vault configured (<leader>lp to add)'
    return
  end
  Snacks.picker.smart { cwd = vim.fn.expand(vaults[1]) }
end

local browse_action = function()
  Snacks.gitbrowse()
end

local projects_action = function()
  local ok, rosadirs = pcall(require, 'rosavim.rosa_plugins.rosadirs')
  local projects = ok and rosadirs.projects() or {}
  if #projects == 0 then
    Snacks.notify.warn 'Rosadirs: no project directories configured (<leader>lp to add)'
    return
  end
  vim.cmd 'NeovimProjectDiscover'
end

local menu = {
  { icon = ' ', key = 'p', desc = 'Projects', action = projects_action },
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
          action = function(dir)
            vim.fn.chdir(dir)
            local ok, session_manager = pcall(require, 'session_manager')
            if ok then
              session_manager.load_current_dir_session()
            else
              Snacks.dashboard.pick()
            end
          end,
        },
      },
      {
        padding = 2,
      },
      gif_section,
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
          action = function(dir)
            vim.fn.chdir(dir)
            local ok, session_manager = pcall(require, 'session_manager')
            if ok then
              session_manager.load_current_dir_session()
            else
              Snacks.dashboard.pick()
            end
          end,
        },
      },
    },
  },
}

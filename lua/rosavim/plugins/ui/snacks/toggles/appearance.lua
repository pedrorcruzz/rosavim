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
      -- Ensure native statusline stays visible when lualine is off
      if not toggles.get 'lualine' then
        vim.defer_fn(function()
          vim.o.laststatus = 3
        end, 100)
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
      appearance.reload()
      if not toggles.get 'lualine' then
        vim.defer_fn(function()
          vim.o.laststatus = 3
        end, 100)
      end
    end,
  }):map '<leader>lqe'

  -- Borderless (<leader>lqn) — ON paints a tool's borders the same colour as
  -- its bg (seamless look) in every rosa theme; OFF (default) keeps each
  -- theme's own border colour. One toggle per tool plus All, all persisted;
  -- the repaint itself lives in rosavim.config.borderless and runs from the
  -- ColorScheme autocmd, so re-applying the scheme takes effect live.
  local borderless = require 'rosavim.config.borderless'

  local function reapply()
    local name = vim.g.colors_name
    if name then
      vim.cmd('colorscheme ' .. name)
    end
  end

  Snacks.toggle({
    name = 'Borderless: All',
    get = function()
      return borderless.all_enabled()
    end,
    set = function(state)
      borderless.set_all(state)
      reapply()
    end,
  }):map '<leader>lqna'

  for _, tool in ipairs(borderless.tools) do
    Snacks.toggle({
      name = 'Borderless: ' .. tool.name,
      get = function()
        return toggles.get(tool.key)
      end,
      set = function(state)
        toggles.set(tool.key, state)
        reapply()
      end,
    }):map(tool.map)
  end

  -- Invert Backgrounds (<leader>lqi<theme>) — swap a theme's editor surface
  -- with its explorer/tab chrome surface. One persisted toggle per theme, so
  -- each can be inverted independently; the swap itself lives in
  -- rosavim.config.invert_bg, which also owns the shade pairs.
  -- Array, not a map: pairs() order is nondeterministic and would shuffle
  -- the which-key listing between sessions.
  for _, entry in ipairs { { 'j', 'rosajet' }, { 'm', 'rosamin' }, { 'v', 'rosavintage' } } do
    local key, theme = entry[1], entry[2]
    Snacks.toggle({
      name = 'Invert BG: ' .. theme,
      get = function()
        return toggles.get(theme .. '_invert')
      end,
      set = function(state)
        toggles.set(theme .. '_invert', state)
        -- Toggling another theme's switch just records it; Snacks already
        -- reports the on/off state, so there is nothing extra to say.
        if vim.g.colors_name ~= theme then
          return
        end
        -- Live reload, no restart: re-applying the scheme rebuilds every group
        -- from the real palette and fires the ColorScheme autocmd that runs the
        -- swap (so turning it OFF restores the originals too).
        require('rosavim.config.appearance').reload()
        -- lualine builds its own colour table and never sees those groups: in
        -- 'auto' it re-reads the theme file, in Custom it samples Normal.bg —
        -- both only on setup, so it needs an explicit rebuild.
        pcall(function()
          require('rosavim.plugins.ui.lualine.sections').reload()
        end)
      end,
    }):map('<leader>lqi' .. key)
  end

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
      if not state then
        -- hide() can leave the rendered bar behind after a re-setup reset
        -- lualine's restore cache; wipe it now and once things settle
        local sections = require 'rosavim.plugins.ui.lualine.sections'
        sections.clear_stale()
        vim.defer_fn(function()
          if not toggles.get 'lualine' then
            sections.clear_stale()
          end
        end, 100)
      end
      -- rosanight and rosajet paint the native statusline bg differently while
      -- lualine is off; re-apply the scheme so it updates without a restart
      if vim.g.colors_name == 'rosanight' or vim.g.colors_name == 'rosajet' then
        vim.cmd('colorscheme ' .. vim.g.colors_name)
      end
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
      local sep = sections.get_sep()
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

  -- Lualine Bar Y Transparent — ON (default) makes the y/centre bar transparent
  -- (blends with the theme bg); OFF restores the original solid #1a1a1a bar.
  -- sections.reload() re-runs lualine.setup, which re-resolves the theme fresh
  -- (theme.create() for custom, dofile of the rosanight theme for 'auto'), so
  -- the toggle takes effect in BOTH lualine theme modes.
  Snacks.toggle({
    name = 'Lualine Bar Y Transparent',
    get = function()
      return toggles.get 'lualine_bar_y_transparent'
    end,
    set = function(state)
      toggles.set('lualine_bar_y_transparent', state)
      require('rosavim.plugins.ui.lualine.sections').reload()
    end,
  }):map '<leader>lqy'

  -- Rosagawa Gutter BG — OFF (default) keeps the characteristic grey gutter
  -- strip (LineNr/CursorLineNr/SignColumn/FoldColumn); ON flattens it to
  -- match the editor bg (dark bg in dark mode, transparent under
  -- transparency, light bg in light mode). The repaint itself lives in the
  -- rosagawa overrides; only reload live when rosagawa is the active theme.
  Snacks.toggle({
    name = 'Rosagawa Gutter BG',
    get = function()
      return toggles.get 'rosagawa_gutter_flat'
    end,
    set = function(state)
      toggles.set('rosagawa_gutter_flat', state)
      if vim.g.colors_name == 'rosagawa' then
        require('rosavim.config.appearance').reload()
      end
    end,
  }):map '<leader>lqu'

  -- Min Icons: Files (<leader>lqh) — flattens mini.icons' MiniIcons* palette
  -- to a single neutral grey, across every theme (not theme-specific). Read
  -- theme-side from each overrides.lua (rosavim.config.min_icons), same
  -- reason borderless/invert_bg can't just paint MiniIcons* centrally here —
  -- mini.icons' lazy load races a centralized ColorScheme autocmd. Highlight
  -- colours are looked up by name on every redraw, so reload() is enough —
  -- no separate cache to invalidate, unlike the folder glyphs below.
  Snacks.toggle({
    name = 'Min Icons: Files',
    get = function()
      return toggles.get 'min_icons_files'
    end,
    set = function(state)
      toggles.set('min_icons_files', state)
      require('rosavim.config.appearance').reload()
    end,
  }):map '<leader>lqh'

  -- Min Icons: Folders (<leader>lqj) — swaps the explorer's closed/open
  -- folder glyphs for the minimalist pair, independent of the Files toggle
  -- above (some people want plain folders but minimalist files, or vice
  -- versa). Folder glyph TEXT is baked into the picker's rendered buffer
  -- lines, so a config mutation alone is invisible to an already-open
  -- picker — refresh_open_pickers() forces those rows to reformat now.
  Snacks.toggle({
    name = 'Min Icons: Folders',
    get = function()
      return toggles.get 'min_icons_dir'
    end,
    set = function(state)
      toggles.set('min_icons_dir', state)
      local min_icons = require 'rosavim.config.min_icons'
      min_icons.apply_picker()
      min_icons.refresh_open_pickers()
    end,
  }):map '<leader>lqj'

  -- Lualine separator preset selector (rounded / bar / arrow / slant).
  -- Same vim.ui.select popup style as the rosaterm/rosaai theme pickers.
  vim.keymap.set('n', '<leader>lqg', function()
    local sections = require 'rosavim.plugins.ui.lualine.sections'
    local current = toggles.get 'lualine_separator'
    vim.ui.select(sections.presets, {
      prompt = 'Lualine · select separator',
      kind = 'lualine_separator',
      format_item = function(p)
        local marker = p.name == current and ' ●' or ''
        return p.icon .. '  ' .. p.label .. marker
      end,
    }, function(choice)
      if not choice then
        return
      end
      toggles.set('lualine_separator', choice.name)
      sections.reload()
      Snacks.notify.info('Lualine separator: ' .. choice.label)
    end)
  end, { desc = 'Lualine: Select Separator' })
end

local dashboard = require 'rosavim.plugins.ui.snacks.dashboard'
local picker = require 'rosavim.plugins.ui.snacks.picker'
local keys = require 'rosavim.plugins.ui.snacks.keys'

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = dashboard,
    explorer = {
      enabled = true,
      cycle = false,
      replace_netrw = false,
    },
    indent = {
      enabled = require('rosavim.config.toggles').get 'indent',
      char = '│',
      only_scope = false,
      only_current = false,
      animate = {
        enabled = false,
        style = 'out',
        easing = 'linear',
        duration = {
          step = 20,
          total = 500,
        },
      },
      width = 70,
      filter = function(buf)
        return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == '' and vim.fn.line '$' > 1
      end,
    },
    profiler = { enabled = true },
    input = {
      enabled = true,
      win = {
        row = 0.35,
        col = 0.35,
        border = 'rounded',
        width = 65,
        height = 2,
      },
    },
    terminal = { enabled = false },
    edgy = { enabled = true },
    picker = picker,
    quickfile = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    image = { enabled = false },
    icons = { enabled = true },
    animate = { enabled = true },
    words = { enabled = true },
    scroll = {
      enabled = false,
      animate = {
        duration = { step = 12, total = 100 },
      },
    },
    rename = { enabled = true },
    toggle = { enabled = true },
    lazygit = { enabled = true },
    git = {
      enabled = true,
      width = 0.6,
      height = 0.6,
      border = 'rounded',
      title = ' Git Blame ',
      title_pos = 'center',
      ft = 'git',
    },
    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 1, right = 1, bottom = 1 },
      padding = true,
      sort = { 'level', 'added' },
      level = vim.log.levels.TRACE,
      style = 'compact',
      top_down = true,
      date_format = '%R',
      more_format = ' ↓ %d lines ',
      refresh = 50,
    },
  },
  keys = keys,
  init = function()
    -- Register custom Rosavim startup section
    local ok, snacks_dashboard = pcall(require, 'snacks.dashboard')
    if ok and snacks_dashboard.sections then
      snacks_dashboard.sections.rosavim_startup = function(opts)
        local rosavim = require 'rosavim'
        local stats = require('lazy').stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        return {
          align = 'center',
          text = {
            -- ⚡
            { '󰧱 ' .. rosavim.name .. ' loaded ', hl = 'footer' },
            { stats.loaded .. '/' .. stats.count, hl = 'special' },
            { ' plugins in ', hl = 'footer' },
            { ms .. 'ms', hl = 'special' },
          },
        }
      end
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd

        local toggles = require 'rosavim.config.toggles'

        local function persist_toggle(snacks_toggle, key)
          local orig_toggle = snacks_toggle.toggle
          snacks_toggle.toggle = function(self)
            orig_toggle(self)
            toggles.set(key, self:get())
          end
          return snacks_toggle
        end

        persist_toggle(Snacks.toggle.option('wrap', { name = 'Wrap' }), 'wrap'):map '<leader>lw'
        persist_toggle(Snacks.toggle.option('relativenumber', { name = 'Relative Number' }), 'relativenumber'):map '<leader>lg'
        persist_toggle(Snacks.toggle.line_number(), 'linenumber'):map '<leader>ln'
        Snacks.toggle.zen():map '<leader>lz'
        persist_toggle(Snacks.toggle.indent(), 'indent'):map '<leader>li'
        persist_toggle(Snacks.toggle.dim(), 'dim'):map '<leader>lk'

        -- Restore persisted states
        if toggles.get 'indent' then
          Snacks.toggle.indent():set(true)
        end
        if toggles.get 'dim' then
          Snacks.toggle.dim():set(true)
        end
      end,
    })
  end,
}

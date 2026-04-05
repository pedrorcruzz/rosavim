return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  lazy = true,
  event = 'VeryLazy',
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup {
      preset = 'modern', --classic, modern, helix
      win = {
        border = 'single', -- none, single, double, shadow
        -- width = 60,
      },
    }

    -- Document existing key chains
    require('which-key').add {
      { '<leader>', group = ' 󰧱 ROSAVIM' }, --󰧵
      { '<leader>e', group = 'File Explorer', icon = '' },
      -- { "<leader>'", group = 'Wrap', icon = '󰭷' },
      { '<leader>ft', group = 'Todo Comments', icon = ' ' },
      { '<leader>z', group = 'Dropbar', icon = '󰳯' },
      { '<leader>,', group = 'Trouble Diagnostic', icon = '󰁨' },
      { '<leader>j', group = 'Windows', icon = '' },
      { '<leader>v', group = 'DBUI', icon = '' },
      { '<leader>b', group = 'BufferLine', icon = '' },
      { '<leader>x', group = 'Rosafile', icon = '' },

      { '<leader>n', group = 'Rosatest', icon = '󰙨' },
      { '<leader>m', group = 'Rosapick', icon = '' },

      { '<leader>y', group = 'Yazi', icon = '' },
      { '<leader>;', group = 'Dashboard', icon = '󰕮' },
      { '<leader>w', group = 'Save', icon = '' },
      { '<leader>W', group = 'Save Without Formatter', icon = '' },
      { '<leader>J', group = 'Previous Buffer', icon = '󰙣' },
      { '<leader>K', group = 'Next Buffer', icon = '󰙡' },
      { '<leader>h', group = 'No Highlight', icon = '󰸱' },
      { '<leader>ci', group = 'ToggleTerm', icon = ' ' },
      { '<leader>o', group = 'Rosapoon', icon = '󰛢' },
      { '<leader>k', group = 'Yeet Tmux', icon = ' ' },

      { '<leader>j', group = 'Obsidian', icon = '' },
      { '<leader>vb', group = 'Buffers', icon = '' },
      { '<leader>vt', group = 'Tabs', icon = '' },

      { '<leader>R', icon = '' },
      { '<leader>L', group = 'Lazy', icon = '󰒲 ' },

      { '<leader>l', group = 'Tools', icon = ' ' },
      { '<leader>lq', group = 'Theme', icon = '' },
      { '<leader>lp', group = 'Triforce', icon = '' },
      { '<leader>lx', group = 'Virtual Environment', icon = ' ' },
      { '<leader>le', group = 'GrugFar', icon = '󰛔' },

      { '<leader>lj', group = 'Spell', icon = '󰓆 ' },
      { '<leader>la', group = 'Autocmd Toggles', icon = '󰒓' },
      { '<leader>las', group = 'Snacks', icon = '󰡰' },
      { '<leader>lae', group = 'Editor', icon = '' },
      { '<leader>lal', group = 'LSP', icon = '' },
      { '<leader>lad', group = 'DBUI', icon = '󰆼' },

      -- Rosakit
      { '<leader>k', group = 'Rosakit', icon = ' ' },

      { '<leader>c', group = 'Window', icon = '󰶛' },
      { '<leader>t', group = 'Tabs', icon = '󱦞' },

      { '<leader>i', group = 'Copilot', icon = '' },
      { '<leader>u', group = 'Markdown', icon = '' },
      { '<leader>d', group = 'Debug' },
      { '<leader>f', group = 'Find' },
      { '<leader>g', group = 'Git', icon = { name = 'git', cat = 'filetype' } },
      { '<leader>r', group = 'Refactor' },
      { '<leader>s', group = 'Search' },
      { '<leader>1', group = 'Focus Left', icon = '󰛁' },
      { '<leader>2', group = 'Focus Right', icon = '󰛂' },
      { '<leader>3', group = 'Focus Down', icon = '󰛀' },
      { '<leader>4', group = 'Focus Up', icon = '󰛃' },

      { '<leader>R', group = 'Rosavim', icon = '󰧱' },
    }
  end,

  keys = {
    { '<leader>R', '<cmd>Rosavim<cr>', desc = 'Rosavim' },
    { '<leader>w', '<cmd>w!<cr>', desc = 'Save' },
    { '<leader>W', '<cmd>noa w<cr>', desc = 'Save Without Formatter' },
    { '<leader>h', '<cmd>nohlsearch<cr>', desc = 'No Highlight' },
    { '<leader>q', '<cmd>confirm q<cr>', desc = 'Exit' },
    -- TSContext toggle moved to snacks/toggles.lua
    { '<leader>lql', ToggleLualineTheme, desc = 'Toggle Lualine Theme (Auto/Default)' },
    { '<leader>fp', '<cmd>NeovimProjectDiscover<cr>', desc = 'Discover Projects' },

    --Spell
    {
      '<leader>ljp',
      function()
        local toggles = require 'rosavim.config.toggles'
        toggles.set('spelllang', 'pt')
        vim.cmd 'set spelllang=pt'
      end,
      desc = 'Set Spell Pt Br',
    },
    {
      '<leader>ljl',
      function()
        vim.api.nvim_feedkeys('z=', 'n', false)
      end,
      desc = 'Spell Suggestions',
    },
    {
      '<leader>lje',
      function()
        local toggles = require 'rosavim.config.toggles'
        toggles.set('spelllang', 'en')
        vim.cmd 'set spelllang=en'
      end,
      desc = 'Set Spell En Us',
    },

    --Lazy
    { '<leader>Ll', '<cmd>Lazy<cr>', desc = 'Lazy' },
    { '<leader>Lp', '<cmd>Lazy profile<cr>', desc = 'Profile' },
    { '<leader>Lh', '<cmd>LazyHealth<cr>', desc = 'Health' },
    { '<leader>LH', '<cmd>Lazy help<cr>', desc = 'Help' },
    { '<leader>Lb', '<cmd>Lazy build<cr>', desc = 'Build' },
    { '<leader>Lc', '<cmd>Lazy clean<cr>', desc = 'Clean' },
    { '<leader>LC', '<cmd>Lazy clear<cr>', desc = 'Clear' },
    { '<leader>Lu', '<cmd>Lazy update<cr>', desc = 'Update' },
    { '<leader>Ls', '<cmd>Lazy sync<cr>', desc = 'Sync' },

    --Wrap
    -- { "<leader>'", '<cmd>:set wrap<cr>', desc = 'Wrap' },

    --Bufers
    { '<leader>J', '<cmd>bprevious<cr>', desc = 'Previous' },
    { '<leader>K', '<cmd>bnext<cr>', desc = 'Next' },

    --Tabs
    { '<leader>tt', '<cmd>tabnew<cr>', desc = 'Tabs: New Tab' },
    { '<leader>tj', '<cmd>tabprevious<cr>', desc = 'Tabs: Previous' },
    { '<leader>tk', '<cmd>tabnext<cr>', desc = 'Tabs: Next' },
    { '<leader>tc', '<cmd>tabclose<cr>', desc = 'Tabs: Close' },
    { '<leader>tC', '<cmd>tabonly<cr>', desc = 'Tabs: Close other Tabs' },
    { '<leader>t1', '<cmd>tabn 1<cr>', desc = 'Tabs: 1' },
    { '<leader>t2', '<cmd>tabn 2<cr>', desc = 'Tabs: 2' },
    { '<leader>t3', '<cmd>tabn 3<cr>', desc = 'Tabs: 3' },
    { '<leader>t4', '<cmd>tabn 4<cr>', desc = 'Tabs: 4' },
    { '<leader>t5', '<cmd>tabn 5<cr>', desc = 'Tabs: 5' },
    { '<leader>t6', '<cmd>tabn 6<cr>', desc = 'Tabs: 6' },
    { '<leader>t7', '<cmd>tabn 7<cr>', desc = 'Tabs: 7' },
    { '<leader>t8', '<cmd>tabn 8ba<cr>', desc = 'Tabs: 8' },
    { '<leader>t9', '<cmd>tabn 9<cr>', desc = 'Tabs: 9' },
    { '<leader>t0', '<cmd>tabn 10<cr>', desc = 'Tabs: 10' },

    --Git
    -- { '<leader>gc', '<cmd>FzfLua git_commits<CR>', desc = 'Git: Commits' },
    { '<leader>gt', '<cmd>Gitsigns toggle_current_line_blame<CR>', desc = 'Git: Toggle Current Line Blame' },
    -- { '<leader>gb', '<cmd>FzfLua git_branches<CR>', desc = 'Git: Branches' },
    -- { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Git: Status' },
    -- { '<leader>gl', '<cmd>FzfLua git_blame<CR>', desc = 'Git: Blame' },
    -- { '<leader>gt', '<cmd>FzfLua git_stash<CR>', desc = 'Git: Stash' },

    --Window
    { '<leader>1', '<cmd>wincmd h<cr>', desc = 'Focus Left' },
    { '<leader>2', '<cmd>wincmd l<cr>', desc = 'Focus Right' },
    { '<leader>3', '<cmd>wincmd j<cr>', desc = 'Focus Down' },
    { '<leader>4', '<cmd>wincmd k<cr>', desc = 'Focus Up' },
    { '<leader>cq', '<cmd>vsplit<cr>', desc = 'Split Vertical' },
    { '<leader>ce', '<cmd>split<cr>', desc = 'Split Horizontal' },
    { '<leader>cC', '<cmd>only<cr>', desc = 'Close all Others' },
    { '<leader>cc', '<cmd>close<cr>', desc = 'Close Window' },
    { '<leader>ch', '<cmd>wincmd H<cr>', desc = 'Swap Left' },
    { '<leader>cl', '<cmd>wincmd L<cr>', desc = 'Swap Right' },
    { '<leader>ck', '<cmd>wincmd K<cr>', desc = 'Swap Up' },
    { '<leader>cj', '<cmd>wincmd J<cr>', desc = 'Swap Down' },
    {
      '<leader>c1',
      function()
        vim.cmd('vertical resize ' .. math.floor(vim.o.columns / 3))
      end,
      desc = 'Resize Left 1/3',
    },
    {
      '<leader>c2',
      function()
        vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 2 / 3))
      end,
      desc = 'Resize Right 2/3',
    },
    {
      '<leader>c3',
      function()
        vim.cmd('resize ' .. math.floor(vim.o.lines / 3))
      end,
      desc = 'Resize Up 1/3',
    },
    {
      '<leader>c4',
      function()
        vim.cmd('resize ' .. math.floor(vim.o.lines * 2 / 3))
      end,
      desc = 'Resize Down 2/3',
    },
    { '<leader>cr', '<cmd>resize | vertical resize | wincmd =<cr>', desc = 'Reset Window Sizes' },
  },
}

--- Rosaterm/RosaAI panels (pinned floats or splits) and sidebar tool windows
--- (Snacks explorer, Trouble, dbui, ...) must never move position or receive
--- a swapped-in buffer.
local function is_protected(buf)
  local ft = vim.bo[buf].filetype
  if ft:sub(1, 8) == 'rosaterm' or ft:sub(1, 6) == 'rosaai' then
    return true
  end
  return require('rosavim.helpers.win_equal').sidebar_filetypes[ft] == true
end

--- Swap BUFFERS (never window position) between the focused window and its
--- neighbour on `dir` ('h'/'j'/'k'/'l'). `wincmd H/L/K/J` reflows the whole
--- layout and drags pinned panels/sidebars along with it, so this trades
--- buffer content between the two windows instead - each window keeps its
--- place, and a Rosaterm/RosaAI panel or sidebar on either side is skipped.
local function swap(dir)
  return function()
    if is_protected(vim.api.nvim_get_current_buf()) then
      return
    end
    local cur_win = vim.api.nvim_get_current_win()
    local target_nr = vim.fn.winnr(dir)
    if target_nr == vim.fn.winnr() then
      return
    end
    local target_win = vim.fn.win_getid(target_nr)
    local target_buf = vim.api.nvim_win_get_buf(target_win)
    if is_protected(target_buf) then
      return
    end
    local cur_buf = vim.api.nvim_win_get_buf(cur_win)
    vim.api.nvim_win_set_buf(cur_win, target_buf)
    vim.api.nvim_win_set_buf(target_win, cur_buf)
  end
end

return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  lazy = true,
  event = 'VeryLazy',
  config = function() -- This is the function that runs, AFTER loading
    local toggles = require 'rosavim.config.toggles'
    require('which-key').setup {
      preset = toggles.get 'whichkey_preset',
      win = {
        border = toggles.get 'whichkey_border',
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
      { '<leader>v', group = 'DBUI', icon = '' },
      { '<leader>b', group = 'BufferLine', icon = '' },
      { '<leader>x', group = 'Rosafile', icon = '' },

      { '<leader>n', group = 'Rosatest', icon = '󰙨' },
      { '<leader>m', desc = 'Rosapick: Pick Window', icon = '' },
      { '<leader>S', desc = 'Rosapick: Swap Window', icon = '' },
      { '<leader>p', icon = '' },
      { '<leader>P', icon = '' },

      { '<leader>y', group = 'Yazi', icon = '' },
      { '<leader>;', group = 'Dashboard', icon = '󰕮' },
      { '<leader>w', group = 'Save', icon = '' },
      { '<leader>W', group = 'Save Without Formatter', icon = '' },
      { '<leader>J', group = 'Previous Buffer', icon = '󰙣' },
      { '<leader>K', group = 'Next Buffer', icon = '󰙡' },
      { '<leader>h', group = 'No Highlight', icon = '󰸱' },
      { '<leader>ci', group = 'Rosaterm', icon = ' ' },
      { '<leader>o', group = 'Rosapoon', icon = '󰛢' },

      { '<leader>j', group = 'Obsidian', icon = '' },

      { '<leader>L', group = 'Lazy', icon = '󰒲 ' },

      { '<leader>l', group = 'Tools', icon = ' ' },
      { '<leader>q', desc = 'Close Window', icon = '󰅖 ' },
      { '<leader>C', desc = 'Close Everything Else', icon = ' ' },
      { '<leader>lo', desc = 'Rosasnippets', icon = '󰷆 ' },
      { '<leader>lq', group = 'Theme', icon = '' },
      { '<leader>lqd', group = 'Dashboard', icon = '' },
      { '<leader>lqr', group = 'Rosaterm', icon = '' },
      { '<leader>lqa', group = 'RosaAI', icon = ' ' },
      { '<leader>lqi', group = 'Invert BG', icon = '󰓢' },
      { '<leader>lqn', group = 'Borderless', icon = '󰹞' },
      { '<leader>lqm', desc = 'Render Markdown: Select Theme', icon = '' },
      { '<leader>lqg', desc = 'Lualine: Select Separator' },
      { '<leader>lqy', desc = 'Lualine: Bar Y Transparent (toggle)' },
      { '<leader>lqu', desc = 'Rosagawa: Gutter BG (toggle)' },
      { '<leader>ly', desc = 'Toggle Cursor Shape (bar/block)' },
      { '<leader>lY', desc = 'Toggle Cursor Line' },
      { '<leader>lqc', group = 'TODO', icon = '󱩽 ' },
      { '<leader>lqf', group = 'Force Dark BG', icon = '󰖔 ' },
      { '<leader>lqs', desc = 'Select Theme' },
      { '<leader>lqp', desc = 'Picker Layout', icon = '󰠲' },
      { '<leader>lqw', desc = 'Which-Key Preset', icon = '󰌌' },
      { '<leader>lqb', desc = 'Which-Key Border', icon = '󰹞' },
      { '<leader>lp', desc = 'Rosadirs: Manage Dirs', icon = '' },
      { '<leader>lx', group = 'Virtual Environment', icon = ' ' },
      { '<leader>le', group = 'GrugFar', icon = '󰛔' },

      { '<leader>lj', group = 'Spell', icon = '󰓆 ' },
      { '<leader>la', group = 'Tools Toggles', icon = '󰒓' },
      { '<leader>lab', group = 'BufferLine', icon = '' },
      { '<leader>las', group = 'Snacks', icon = '󰡰' },
      { '<leader>lae', group = 'Editor', icon = '' },
      { '<leader>lal', group = 'LSP', icon = '' },
      { '<leader>lad', group = 'DBUI', icon = '󰆼' },
      { '<leader>lau', group = 'Dropbar', icon = '󰜢 ' },
      { '<leader>lam', group = 'Rosamaximize', icon = '󰊓 ' },
      { '<leader>lat', group = 'Rosatag', icon = '󰗀 ' },
      { '<leader>lar', group = 'Rosaterm', icon = '' },
      { '<leader>laa', group = 'RosaAI', icon = ' ' },

      -- Rosakit
      { '<leader>k', group = 'Rosakit', icon = ' ' },
      { '<leader>kv', group = 'Rosavisualmulti', icon = '󰆿 ' },
      { '<leader>kvv', desc = 'Rosavisualmulti: Menu', icon = '󰆿 ' },
      { '<leader>kva', desc = 'Rosavisualmulti: Select All Occurrences', icon = '󰦅 ' },
      { '<leader>kvr', desc = 'Rosavisualmulti: Rename Selection', icon = '󰳽 ' },

      { '<leader>c', group = 'Window', icon = '󰶛' },
      { '<leader>t', group = 'Tabs', icon = '󱦞' },

      { '<leader>i', group = 'Copilot', icon = '' },
      { '<leader>u', group = 'Markdown', icon = '' },
      { '<leader>d', group = 'Debug' },
      { '<leader>f', group = 'Find' },
      { '<leader>g', group = 'Git', icon = { name = 'git', cat = 'filetype' } },
      { '<leader>s', group = 'Search' },
      { '<leader>1', group = 'Focus Left', icon = '󰛁' },
      { '<leader>2', group = 'Focus Right', icon = '󰛂' },
      { '<leader>3', group = 'Focus Down', icon = '󰛀' },
      { '<leader>4', group = 'Focus Up', icon = '󰛃' },

      { '<leader>R', icon = '󰳽 ' },
      { '<leader>lR', desc = 'Rosavim', icon = '󰧱' },
    }
  end,

  keys = {
    { '<leader>lR', '<cmd>Rosavim<cr>', desc = 'Rosavim' },
    { '<leader>w', '<cmd>w!<cr>', desc = 'Save' },
    { '<leader>W', '<cmd>noa w<cr>', desc = 'Save Without Formatter' },
    { '<leader>h', '<cmd>nohlsearch<cr>', desc = 'No Highlight' },
    {
      '<leader>C',
      function()
        if require('rosavim.helpers.win_equal').only_all() > 0 then
          Snacks.notify.info 'Closed all windows'
        end
      end,
      desc = 'Close Everything Else',
    },
    {
      '<leader>Q',
      function()
        -- Quit the current window, but if it's the only *real* editing window
        -- (the rest are floats or rosazen padding spacers), quit Neovim instead
        -- of leaving the user stranded on the empty pads.
        local reals = 0
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_config(w).relative == '' then
            local buf = vim.api.nvim_win_get_buf(w)
            if vim.bo[buf].buftype == '' and vim.bo[buf].filetype ~= 'rosa_spacer' then
              reals = reals + 1
            end
          end
        end
        vim.cmd(reals <= 1 and 'confirm qall' or 'confirm q')
      end,
      desc = 'Exit',
    },
    -- TSContext, Lualine Theme toggles moved to snacks/toggles.lua
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
    { '<leader>Lh', '<cmd>checkhealth lazy<cr>', desc = 'Health' },
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
    -- leader gt is now a Snacks toggle (plugins.lua)
    -- { '<leader>gb', '<cmd>FzfLua git_branches<CR>', desc = 'Git: Branches' },
    -- { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Git: Status' },
    -- { '<leader>gl', '<cmd>FzfLua git_blame<CR>', desc = 'Git: Blame' },
    -- { '<leader>gt', '<cmd>FzfLua git_stash<CR>', desc = 'Git: Stash' },
    { '<leader>gw', function() Snacks.gitbrowse() end, desc = 'Browse Repo' },

    --Window
    -- Directional focus falls back to the RosaAI CLI float if there's no
    -- split in that direction (wincmd h/j/k/l skip floats by design).
    {
      '<leader>1',
      function()
        require('rosavim.config.focus').go 'h'
      end,
      desc = 'Focus Left',
    },
    {
      '<leader>2',
      function()
        require('rosavim.config.focus').go 'l'
      end,
      desc = 'Focus Right',
    },
    {
      '<leader>3',
      function()
        require('rosavim.config.focus').go 'j'
      end,
      desc = 'Focus Down',
    },
    {
      '<leader>4',
      function()
        require('rosavim.config.focus').go 'k'
      end,
      desc = 'Focus Up',
    },
    {
      '<leader>cq',
      function()
        require('rosavim.helpers.win_equal').split 'vsplit'
      end,
      desc = 'Split Vertical',
    },
    {
      '<leader>ce',
      function()
        require('rosavim.helpers.win_equal').split 'split'
      end,
      desc = 'Split Horizontal',
    },
    {
      '<leader>cC',
      function()
        require('rosavim.helpers.win_equal').only()
      end,
      desc = 'Close Other Editor Windows',
    },
    { '<leader>cc', '<cmd>close<cr>', desc = 'Close Window' },
    { '<leader>q', '<cmd>close<cr>', desc = 'Close Window' },
    { '<leader>ch', swap 'h', desc = 'Swap Left' },
    { '<leader>cl', swap 'l', desc = 'Swap Right' },
    { '<leader>ck', swap 'k', desc = 'Swap Up' },
    { '<leader>cj', swap 'j', desc = 'Swap Down' },
    {
      '<leader>cs',
      function()
        local cur = vim.api.nvim_get_current_win()
        if is_protected(vim.api.nvim_win_get_buf(cur)) then
          return
        end
        local win = require('rosavim.rosa_plugins.rosapick').select {
          single = true,
          filter = function(w, buf)
            return w ~= cur and not is_protected(buf)
          end,
        }
        if not win then
          return
        end
        local cur_buf = vim.api.nvim_win_get_buf(cur)
        local other_buf = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_win_set_buf(cur, other_buf)
        vim.api.nvim_win_set_buf(win, cur_buf)
      end,
      desc = 'Rosapick: Swap Buffer',
    },
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
    {
      '<leader>cr',
      function()
        require('rosavim.helpers.win_equal').reset_all()
      end,
      desc = 'Reset Window Sizes',
    },
  },
}

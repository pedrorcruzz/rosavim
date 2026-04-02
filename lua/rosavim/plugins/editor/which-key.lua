return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  lazy = true,
  event = 'VeryLazy',
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup {
      preset = 'modern', --classic, modern, helix
      win = {
        border = 'shadow', -- none, single, double, shadow
        -- width = 60,
      },
    }

    -- Document existing key chains
    require('which-key').add {
      { '<leader>', group = ' 󰠥 ROSAVIM' }, --󰧵
      { '<leader>e', group = 'File Explorer', icon = '' },
      -- { "<leader>'", group = 'Wrap', icon = '󰭷' },
      { '<leader>ft', group = 'Todo Comments', icon = ' ' },
      { '<leader>z', group = 'Dropbar', icon = '󰳯' },
      { '<leader>,', group = 'Trouble Diagnostic', icon = '󰁨' },
      { '<leader>j', group = 'Windows', icon = '' },
      { '<leader>v', group = 'DBUI', icon = '' },
      { '<leader>b', group = 'BufferLine', icon = '' },
      { '<leader>x', group = 'File Tools', icon = '' },

      { '<leader>n', group = 'Neotest', icon = '󰙨' },
      { '<leader>ng', group = 'Go Test', icon = '' },

      { '<leader>y', group = 'Yazi', icon = '' },
      { '<leader>;', group = 'Home', icon = '' },
      { '<leader>w', group = 'Save', icon = '' },
      { '<leader>W', group = 'Save Without Formatter', icon = '' },
      { '<leader>J', group = 'Previous Buffer', icon = '󰙣' },
      { '<leader>K', group = 'Next Buffer', icon = '󰙡' },
      { '<leader>h', group = 'No Highlight', icon = '󰸱' },
      { '<leader>ci', group = 'ToggleTerm', icon = ' ' },
      { '<leader>o', group = 'Grapple', icon = '󱝩' },
      { '<leader>k', group = 'Yeet Tmux', icon = ' ' },
      -- { '<leader>o', group = 'Harpoon', icon = '󱝩' },

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

      -- Languagens tools
      { '<leader>k', group = 'Languages Tools', icon = ' ' },
      { '<leader>kp', group = 'PHP Tools', icon = ' ' },
      { '<leader>kg', group = 'GO Tools', icon = ' ' },
      { '<leader>kj', group = 'Javascript Tools', icon = ' ' },
      { '<leader>ks', group = 'Spring Tools', icon = ' ' },

      { '<leader>kjc', group = 'Codi', icon = ' ' },
      { '<leader>kgd', group = 'Debug', icon = ' ' },
      { '<leader>kgt', group = 'Test', icon = '󰙨 ' },

      { '<leader>kl', group = 'Laravel Tools', icon = ' ' },
      { '<leader>klc', group = 'Composer', icon = ' ' },
      { '<leader>kln', group = 'Sail', icon = ' ' },
      { '<leader>kld', group = 'Diagrams', icon = ' ' },
      { '<leader>klx', group = 'Cache', icon = '󰃨 ' },
      { '<leader>klh', group = 'IDE Helper', icon = ' ' },

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

      { '<leader>R', group = 'Rosavim', icon = '' },
    }
  end,

  keys = {
    { '<leader>R', '<cmd>Rosavim<cr>', desc = 'Rosavim' },
    { '<leader>w', '<cmd>w!<cr>', desc = 'Save' },
    { '<leader>W', '<cmd>noa w<cr>', desc = 'Save Without Formatter' },
    -- { '<leader>c', '<cmd>close<cr>', desc = 'Close Window' },
    { '<leader>h', '<cmd>nohlsearch<cr>', desc = 'No Highlight' },
    { '<leader>q', '<cmd>confirm q<cr>', desc = 'Exit' },
    { '<leader>lt', '<cmd>TSContextToggle<cr>', desc = 'TSCOntext: Toggle' },
    { '<leader>fp', '<cmd>NeovimProjectDiscover<cr>', desc = 'Discover Projects' },

    --Spell
    {
      '<leader>ljj',
      function()
        vim.o.spell = not vim.o.spell
        if vim.o.spell then
          vim.notify('Spellcheck: On', vim.log.levels.INFO)
        else
          vim.notify('Spellcheck: Off', vim.log.levels.INFO)
        end
      end,
      desc = 'Toggle Spell',
    },
    { '<leader>ljp', '<cmd>set spelllang=pt<cr>', desc = 'Set Spell Pt Br' },
    {
      '<leader>ljl',
      function()
        vim.api.nvim_feedkeys('z=', 'n', false)
      end,
      desc = 'Spell Suggestions',
    },
    { '<leader>lje', '<cmd>set spelllang=en<cr>', desc = 'Set Spell En Us' },

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

    -- Delete and Create Files
    {
      '<leader>xa',
      function()
        local new_file_path = vim.fn.input('Create New File: ', vim.fn.expand '%:p:h' .. '/', 'file')
        if new_file_path ~= '' then
          local dir = vim.fn.fnamemodify(new_file_path, ':p:h')
          vim.fn.mkdir(dir, 'p')
          if vim.fn.filereadable(new_file_path) == 0 then
            vim.fn.writefile({}, new_file_path)
          end
          vim.cmd('edit ' .. new_file_path)
        end
      end,
      desc = 'New File: Create in Current Directory',
    },

    {
      '<leader>xe',
      function()
        local new_file_path = vim.fn.input('Enter File Path: ', '', 'file')
        if new_file_path ~= '' then
          local dir = vim.fn.fnamemodify(new_file_path, ':p:h')
          vim.fn.mkdir(dir, 'p')
          if vim.fn.filereadable(new_file_path) == 0 then
            vim.fn.writefile({}, new_file_path)
          end
          vim.cmd('edit ' .. new_file_path)
        end
      end,
      desc = 'New File: Create Anywhere',
    },

    {
      '<leader>xx',
      function()
        local project_root = vim.fn.getcwd() .. '/'
        local new_file_path = vim.fn.input('Create File at Project Root: ', project_root, 'file')
        if new_file_path ~= '' then
          local dir = vim.fn.fnamemodify(new_file_path, ':p:h')
          vim.fn.mkdir(dir, 'p')
          if vim.fn.filereadable(new_file_path) == 0 then
            vim.fn.writefile({}, new_file_path)
          end
          vim.cmd('edit ' .. new_file_path)
        end
      end,
      desc = 'New File: Create from Project Root',
    },

    {
      '<leader>xd',
      function()
        local refresh_snacks_explorer = true

        local file_name = vim.api.nvim_buf_get_name(0)
        if file_name == '' then
          vim.notify('No file to delete', vim.log.levels.WARN)
          return
        end

        if vim.fn.confirm('Are you sure you want to delete this file?', '&Yes\n&No', 2) == 1 then
          local dir = vim.fs.dirname(file_name)
          local current_bufnr = vim.api.nvim_get_current_buf()
          local current_win = vim.api.nvim_get_current_win()

          -- Get all windows and their buffers
          local buffers_in_windows = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            buffers_in_windows[vim.api.nvim_win_get_buf(win)] = true
          end

          -- Check if there are multiple windows (splits)

          -- Get alternative buffer (previous buffer)
          local alt_bufnr = vim.fn.bufnr '#'
          local alt_buf_is_valid = alt_bufnr > 0 and vim.api.nvim_buf_is_valid(alt_bufnr) and vim.bo[alt_bufnr].buflisted and alt_bufnr ~= current_bufnr

          -- Check if alternative buffer is already open in another window
          local alt_buf_in_other_window = alt_buf_is_valid and buffers_in_windows[alt_bufnr] and current_win ~= vim.fn.bufwinid(alt_bufnr)

          -- If we have multiple windows and the previous buffer is already in another split,
          -- just close the current window (which closes the split)
          if alt_buf_in_other_window then
            -- Close the window (split), then close the buffer
            vim.api.nvim_win_close(current_win, true)
            vim.cmd('bdelete! ' .. current_bufnr)
          else
            -- Otherwise, navigate to previous buffer if available
            local buffers = vim.tbl_filter(function(b)
              return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and b ~= current_bufnr
            end, vim.api.nvim_list_bufs())

            if #buffers > 0 then
              vim.cmd 'bprevious'
            end

            -- Close the buffer of the file being deleted
            vim.cmd('bdelete! ' .. current_bufnr)
          end

          -- Delete the file
          local ok, err = pcall(vim.fn.delete, file_name)
          if not ok then
            vim.notify('Failed to delete file: ' .. (err or 'unknown error'), vim.log.levels.ERROR)
            return
          end

          -- Refresh snacks explorer if enabled and available
          if refresh_snacks_explorer then
            vim.defer_fn(function()
              local snacks_ok, snacks = pcall(require, 'snacks')
              if snacks_ok and snacks then
                -- Try to refresh the tree using Tree:refresh
                local tree_ok, tree_module = pcall(function()
                  return require 'snacks.tree'
                end)
                if tree_ok and tree_module and type(tree_module.refresh) == 'function' then
                  tree_module.refresh(dir)
                end
              end
            end, 50)
          end

          vim.notify('File deleted: ' .. vim.fn.fnamemodify(file_name, ':t'), vim.log.levels.INFO)
        end
      end,
      desc = 'Delete File',
    },
  },
}

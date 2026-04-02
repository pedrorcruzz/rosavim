return {
  -- Top Pickers & Explorer
  { '<leader>fs', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
  { '<leader><cr>', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
  { '<leader><space>', function() Snacks.picker.files() end, desc = 'Find Files' },
  { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
  { '<leader>N', function() Snacks.picker.notifications() end, desc = 'Notification History' },
  { '<leader>e', function() Snacks.explorer() end, desc = 'File Explorer' },

  -- Find
  { '<leader>fc', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = 'Find Config File' },
  { '<leader>ff', function() Snacks.picker.files() end, desc = 'Find Files' },
  { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Find Buffers' },
  { '<leader>fg', function() Snacks.picker.git_files() end, desc = 'Find Git Files' },
  { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent' },

  -- Todo Comments
  { '<leader>ftt', function() Snacks.picker.todo_comments() end, desc = 'Todo Comments' },
  { '<leader>ftf', function() Snacks.picker.todo_comments { keywords = { 'FIX', 'FIXME' } } end, desc = 'Find Fix/Fixme' },
  { '<leader>fte', function() Snacks.picker.todo_comments { keywords = { 'TODO' } } end, desc = 'Find Todo' },
  { '<leader>ftn', function() Snacks.picker.todo_comments { keywords = { 'NOTE' } } end, desc = 'Find Note' },
  { '<leader>fti', function() Snacks.picker.todo_comments { keywords = { 'INFO' } } end, desc = 'Find Info' },
  { '<leader>fth', function() Snacks.picker.todo_comments { keywords = { 'HACK' } } end, desc = 'Find Hack' },
  { '<leader>ftw', function() Snacks.picker.todo_comments { keywords = { 'WARN' } } end, desc = 'Find Warn' },

  -- Git
  { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },
  { '<leader>gl', function() Snacks.git.blame_line() end, desc = 'Git Blame Line' },
  { '<leader>gc', function() Snacks.lazygit.log() end, desc = 'Git Log' },
  { '<leader>gL', function() Snacks.picker.git_log_line() end, desc = 'Git Log Line' },
  { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
  { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git Stash' },
  { '<leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git Diff (Hunks)' },
  { '<leader>gf', function() Snacks.picker.git_log_file() end, desc = 'Git Log File' },
  { '<leader>gg', function() Snacks.lazygit.open() end, desc = 'Lazygit' },

  -- Grep
  { '<leader>sb', function() Snacks.picker.grep_buffers() end, desc = 'Grep Buffers' },
  { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Grep' },
  { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Visual selection or word', mode = { 'n', 'x' } },

  -- Search
  { '<leader>s/', function() Snacks.picker.search_history() end, desc = 'Search History' },
  { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
  { '<leader>/', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
  { '<leader>sc', function() Snacks.picker.command_history() end, desc = 'Command History' },
  { '<leader>sC', function() Snacks.picker.commands() end, desc = 'Commands' },
  { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
  { '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, desc = 'Buffer Diagnostics' },
  { '<leader>sH', function() Snacks.picker.help() end, desc = 'Help Pages' },
  { '<leader>sh', function() Snacks.picker.highlights() end, desc = 'Highlights' },
  { '<leader>si', function() Snacks.picker.icons() end, desc = 'Icons' },
  { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
  { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
  { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
  { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
  { '<leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
  { '<leader>sp', function() Snacks.picker.lazy() end, desc = 'Search for Plugin Spec' },
  { '<leader>sR', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },
  { '<leader>sq', function() Snacks.picker.registers() end, desc = 'Search Registers' },
  { '<leader>su', function() Snacks.picker.undo() end, desc = 'Undo History' },
  -- LSP
  { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
  { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration' },
  { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
  { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
  { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition' },
  { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
  { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },

  -- Misc
  { '<leader>;', function() Snacks.dashboard() end, desc = 'Dashboard' },
  { '<leader>.', function() Snacks.notifier.hide() end, desc = 'Dimiss Notification' },
  { '<leader>lv', function() Snacks.rename.rename_file() end, desc = 'Snacks: Rename Current File' },
  { '<leader>lm', function() Snacks.image.hover() end, desc = 'Snacks: Image Preview' },
}

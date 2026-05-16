return {
  'folke/todo-comments.nvim',
  lazy = true,
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'TodoTrouble', 'TodoQuickFix', 'TodoLocList' },
  keys = {
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      desc = 'Next todo comment',
    },
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      desc = 'Previous todo comment',
    },
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function(_, opts)
    require('todo-comments').setup(opts)

    -- folders treated as third-party / generated code — TODOs inside them
    -- should not be highlighted in the editor nor appear in :TodoTrouble etc.
    local excluded_dirs = {
      'node_modules',
      'bower_components',
      '__pycache__',
      '%.venv',
      'venv',
      'env',
      'site%-packages',
      '%.tox',
      'vendor',
      'dist',
      'build',
      'out',
      'target',
      '%.next',
      '%.nuxt',
      '%.svelte%-kit',
      '%.turbo',
      '%.cache',
      '%.parcel%-cache',
      'coverage',
      '%.git',
      '%.idea',
      '%.gradle',
      '%.mvn',
      'Pods',
      'DerivedData',
    }

    local function is_excluded(path)
      if path == '' then
        return false
      end
      for _, dir in ipairs(excluded_dirs) do
        if path:match('/' .. dir .. '/') or path:match('/' .. dir .. '$') then
          return true
        end
      end
      return false
    end

    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
      group = vim.api.nvim_create_augroup('RosavimTodoCommentsExclude', { clear = true }),
      callback = function(args)
        if is_excluded(vim.api.nvim_buf_get_name(args.buf)) then
          pcall(function()
            require('todo-comments.highlight').detach(args.buf)
          end)
          vim.b[args.buf].todo_comments_disabled = true
        end
      end,
    })
  end,
  opts = {
    signs = true, -- show icons in the signs column
    sign_priority = 8, -- sign priority
    -- keywords recognized as todo comments
    keywords = {
      FIX = {
        icon = ' ', -- icon used for the sign, and in search results
        color = 'error', -- can be a hex color, or a named color (see below)
        alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
        -- signs = false, -- configure signs for some keywords individually
      },
      TODO = { icon = ' ', color = 'info' },
      HACK = { icon = ' ', color = 'warning' },
      WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
      PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
      NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
      TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
    },
    gui_style = {
      fg = 'NONE', -- The gui style to use for the fg highlight group.
      bg = 'BOLD', -- The gui style to use for the bg highlight group.
    },
    merge_keywords = true, -- when true, custom keywords will be merged with the defaults
    -- highlighting of the line containing the todo comment
    -- * before: highlights before the keyword (typically comment characters)
    -- * keyword: highlights of the keyword
    -- * after: highlights after the keyword (todo text)
    highlight = {
      multiline = true, -- enable multine todo comments
      multiline_pattern = '^.', -- lua pattern to match the next multiline from the start of the matched keyword
      multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
      before = '', -- "fg" or "bg" or empty
      keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
      after = 'fg', -- "fg" or "bg" or empty
      pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
      comments_only = false, -- also highlight in markdown/text files (not just code comments)
      max_line_len = 400, -- ignore lines longer than this
      exclude = {}, -- list of file types to exclude highlighting
    },
    -- list of named colors where we try to extract the guifg from the
    -- list of highlight groups or use the hex color if hl not found as a fallback
    colors = {
      error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
      warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
      info = { 'DiagnosticInfo', '#2563EB' },
      hint = { 'DiagnosticHint', '#10B981' },
      default = { 'Identifier', '#7C3AED' },
      test = { 'Identifier', '#FF00FF' },
    },
    search = {
      command = 'rg',
      args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        -- exclude third-party / generated code so TODOs from libs do not show up
        '--glob=!**/node_modules/**',
        '--glob=!**/bower_components/**',
        '--glob=!**/__pycache__/**',
        '--glob=!**/.venv/**',
        '--glob=!**/venv/**',
        '--glob=!**/env/**',
        '--glob=!**/site-packages/**',
        '--glob=!**/.tox/**',
        '--glob=!**/vendor/**',
        '--glob=!**/dist/**',
        '--glob=!**/build/**',
        '--glob=!**/out/**',
        '--glob=!**/target/**',
        '--glob=!**/.next/**',
        '--glob=!**/.nuxt/**',
        '--glob=!**/.svelte-kit/**',
        '--glob=!**/.turbo/**',
        '--glob=!**/.cache/**',
        '--glob=!**/.parcel-cache/**',
        '--glob=!**/coverage/**',
        '--glob=!**/.git/**',
        '--glob=!**/.idea/**',
        '--glob=!**/.gradle/**',
        '--glob=!**/.mvn/**',
        '--glob=!**/Pods/**',
        '--glob=!**/DerivedData/**',
      },
      -- regex that will be used to match keywords.
      -- don't replace the (KEYWORDS) placeholder
      pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
    },
  },
}

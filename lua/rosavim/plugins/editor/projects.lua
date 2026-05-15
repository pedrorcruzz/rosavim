return {
  {
    'coffebar/neovim-project',
    lazy = true,
    event = 'VeryLazy',
    opts = function()
      local ok, rosadirs = pcall(require, 'rosavim.rosa_plugins.rosadirs')
      local projects = ok and rosadirs.projects() or {}

      return {
        -- Project directories are managed dynamically via Rosadirs (<leader>lp)
        projects = projects,
        -- Path to store history and sessions
        datapath = vim.fn.stdpath 'data', -- ~/.local/share/nvim/
        -- Load the most recent session on startup if not in the project directory
        last_session_on_startup = false,
        -- Dashboard mode prevents session autoload on startup
        dashboard_mode = true,
        -- Timeout to trigger FileType autocmd after session load (for LSP attachment)
        filetype_autocmd_timeout = 200,
        -- Keymap to delete project from history in Telescope picker
        forget_project_keys = {
          i = '<C-d>',
          n = 'd',
        },
        -- Overwrite some of Session Manager options
        session_manager_opts = {
          autosave_ignore_dirs = {
            vim.fn.expand '~',
            '/tmp',
          },
          autosave_ignore_filetypes = {
            'ccc-ui',
            'gitcommit',
            'gitrebase',
            'qf',
            'toggleterm',
          },
        },
        -- Picker configuration
        picker = {
          type = 'snacks',
        },
      }
    end,
    init = function()
      -- Enable saving the state of plugins in the session
      vim.opt.sessionoptions:append 'globals'
    end,
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
      { 'Shatur/neovim-session-manager', lazy = true, cmd = { 'SessionManager' } },
    },
  },
}

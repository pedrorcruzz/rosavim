return {
  {
    'coffebar/neovim-project',
    lazy = true,
    event = 'VeryLazy', -- otimizado: carrega só quando o Neovim estiver ocioso
    -- lazy = false, -- removido para otimizar o ms
    -- priority = 100, -- removido para otimizar o ms
    opts = {
      projects = { -- define project roots
        '~/Developer/Projects/Garage/*',
        '~/Developer/Projects/Personal/*',
        '~/Developer/Projects/Sandbox/*',
        '~/Developer/Projects/Udemy/*',
        '~/Developer/Projects/algorithm-practice*',
        '~/Developer/Business/Seven/*',
        '~/Developer/Business/Guru/*',
        '~/Developer/Business/Freelas/*',
        '~/Developer/Cesmac/*',
      },
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
        i = '<C-d>', -- insert mode: Ctrl+d
        n = 'd', -- normal mode: d
      },
      -- Overwrite some of Session Manager options
      session_manager_opts = {
        autosave_ignore_dirs = {
          vim.fn.expand '~', -- don't create a session for $HOME/
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
        type = 'telescope', -- "telescope" or "fzf-lua"
      },
    },
    init = function()
      -- Enable saving the state of plugins in the session
      vim.opt.sessionoptions:append 'globals'
    end,
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
      { 'nvim-telescope/telescope.nvim', lazy = true }, -- optional picker
      -- { 'ibhagwan/fzf-lua', lazy = true }, -- optional picker
      { 'Shatur/neovim-session-manager', lazy = true },
    },
  },
}

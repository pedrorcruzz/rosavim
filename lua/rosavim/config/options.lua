require('rosavim.config.appearance').setup()

-- Enable loader (speed up startup time)
vim.loader.enable()

vim.opt.lazyredraw = false

vim.opt.fileencoding = 'utf-8'

-- Global floating window border (Neovim 0.12+)
vim.opt.winborder = 'rounded'

-- Auto root detection using vim.fs.root() (Neovim 0.12+)
local root_cache = {}

local set_root = function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    return
  end

  local root = root_cache[path]
  if root == nil then
    root = vim.fs.root(0, { '.git', 'Makefile', '.rn' })
    if root == nil then
      return
    end
    root_cache[path] = root
  end

  vim.fn.chdir(root)
end

-- Terminal toggle term
-- vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
-- vim.api.nvim_set_keymap('t', '<C-x>', [[<C-\><C-n>]], { noremap = true })
--Confirm before closing unsaved buffer
vim.opt.confirm = true

local root_augroup = vim.api.nvim_create_augroup('MyAutoRoot', {})
vim.api.nvim_create_autocmd('BufEnter', { group = root_augroup, callback = set_root })

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Disables netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Line numbers are set via toggles persistence (end of file)

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'
vim.opt.mousemoveevent = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Enable line wrap
-- Wrap is set via toggles persistence (end of file)
-- Set the line wrap to be at 100 characters
vim.opt.textwidth = 100
vim.opt.formatoptions:append 't'

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 500

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true
vim.opt.cursorcolumn = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Status line
vim.o.laststatus = 3 -- or 3,  if u want global bar even hidden or 0 if u want to disable it

local toggles = require 'rosavim.config.toggles'
vim.opt.spell = toggles.get 'spell'
vim.opt.spelllang = toggles.get 'spelllang'
vim.opt.wrap = toggles.get 'wrap'
vim.opt.relativenumber = toggles.get 'relativenumber'
vim.opt.number = toggles.get 'linenumber'

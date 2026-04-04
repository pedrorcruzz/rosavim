-- Disable background colors for LSP document colors (Tailwind CSS, etc.)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    vim.lsp.document_color.enable(false)
  end,
})

-- Trigger the Snacks picker if Neovim is started with a single directory as an argument
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local arg = vim.fn.argv(0)
    if vim.fn.argc() == 1 and vim.fn.isdirectory(arg) == 1 then
      Snacks.picker.smart()
    end
  end,
})

local toggles = require 'rosavim.config.toggles'

--last cursor position
local grp_lastpos = vim.api.nvim_create_augroup('LastCursorPos', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  group = grp_lastpos,
  callback = function(event)
    if not toggles.get 'lastpos' then
      return
    end

    local buf = event.buf
    local exclude = { 'gitcommit', 'gitrebase' }

    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_cursor_restored then
      return
    end

    vim.b[buf].last_cursor_restored = true

    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local line_count = vim.api.nvim_buf_line_count(buf)

    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Initialize spell checking on buffer read
local spell_group = vim.api.nvim_create_augroup('SpellByDefault', { clear = true })

vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
  group = spell_group,
  pattern = { 'markdown', '*.md', 'text' },
  callback = function()
    vim.opt_local.spell = toggles.get 'spell'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dashboard',
  command = 'setlocal nolist',
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Syntax highlighting for dotenv files
local dotenv_ft = vim.api.nvim_create_augroup('dotenv_ft', { clear = true })

vim.api.nvim_create_autocmd('BufRead', {
  group = dotenv_ft,
  pattern = { '.env*', '.env' },
  callback = function()
    if toggles.get 'dotenv_syntax' then
      vim.bo.filetype = 'dosini'
    end
  end,
})

-- Disable auto comment continuation on new lines
local no_auto_comment = vim.api.nvim_create_augroup('no_auto_comment', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = no_auto_comment,
  callback = function()
    if toggles.get 'no_auto_comment' then
      vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
    end
  end,
})

--Auto Save (FocusLost/BufLeave)
local autosave_group = vim.api.nvim_create_augroup('kickstart-autosave', { clear = true })

vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
  group = autosave_group,
  callback = function()
    if toggles.get 'autosave_focuslost' then
      vim.cmd 'silent! update'
    end
  end,
})

-- ToggleTerm
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*toggleterm#*',
  callback = set_terminal_keymaps,
})

-- Snacks Explorer
local function focus_buffer_after_snacks(bufnr)
  local attempts = 0
  local function try_focus()
    if vim.api.nvim_buf_is_valid(bufnr) then
      local current_buf = vim.api.nvim_get_current_buf()
      if current_buf ~= bufnr then
        vim.api.nvim_set_current_buf(bufnr)
      end
    end
    attempts = attempts + 1
    if attempts < 10 then
      vim.defer_fn(try_focus, 15)
    end
  end
  try_focus()
end

local function open_snacks_explorer()
  local ok, snacks = pcall(require, 'snacks')
  if not ok or not snacks or not snacks.explorer then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  snacks.explorer()
  if not toggles.get 'snacks_explorer_focus' then
    focus_buffer_after_snacks(bufnr)
  end
end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if not toggles.get 'snacks_explorer' then
      return
    end

    -- Skip when dashboard is shown (no args)
    if vim.fn.argc() == 0 then
      return
    end

    open_snacks_explorer()
  end,
})

-- Open explorer when navigating away from dashboard to a file
vim.api.nvim_create_autocmd('BufReadPost', {
  once = true,
  callback = function(args)
    if not toggles.get 'snacks_explorer' then
      return
    end

    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == '' or bufname:match 'snacks_picker_input' or bufname:match 'NvimTree_' or bufname:match '^%[.*%]$' then
      return
    end

    open_snacks_explorer()
  end,
})

-- Highlight LSP references
local my_highlights = vim.api.nvim_create_augroup('MyHighlights', { clear = true })

vim.api.nvim_create_autocmd('ColorScheme', {
  group = my_highlights,
  pattern = '*',
  callback = function()
    if toggles.get 'lsp_ref_highlights' then
      local highlight_style = { bold = true, bg = 'none', fg = '#FFFFFF' }

      vim.api.nvim_set_hl(0, 'LspReferenceRead', highlight_style)
      vim.api.nvim_set_hl(0, 'LspReferenceWrite', highlight_style)
      vim.api.nvim_set_hl(0, 'LspReferenceText', highlight_style)
    end
  end,
})

-- DBUI NO FOLDING
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dbout',
  callback = function()
    if toggles.get 'dbout_no_folding' then
      vim.cmd 'normal! zR'
    end
  end,
})

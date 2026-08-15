-- Disable background colors for LSP document colors (Tailwind CSS, etc.)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    vim.lsp.document_color.enable(false)
  end,
})

local toggles = require 'rosavim.config.toggles'

-- Trigger the Snacks picker if Neovim is started with a single directory as an argument
local opened_with_dir = false
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local arg = vim.fn.argv(0)
    if vim.fn.argc() == 1 and vim.fn.isdirectory(arg) == 1 then
      opened_with_dir = true
      Snacks.picker.smart()
    end
  end,
})

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

-- Auto-reload buffers changed on disk (RosaAI, git, external edits)
local autoread_group = vim.api.nvim_create_augroup('kickstart-autoread', { clear = true })

--- Re-stat the file buffers currently ON SCREEN and reload the ones that
--- changed on disk.
---
--- Bare `:checktime` stats EVERY loaded buffer, so an afternoon in a monorepo
--- turns each idle tick into hundreds of stat() calls. Only what you can see
--- has to be polled: a hidden buffer is checked by the BufEnter below the
--- instant you switch to it, so nothing is missed — and a file the RosaAI CLI
--- writes to while it sits in a visible split still refreshes live.
local function checktime_visible()
  local seen = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not seen[buf] and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= '' then
      seen[buf] = true
      pcall(vim.cmd, 'silent! checktime ' .. buf)
    end
  end
end

-- CursorHoldI is deliberately absent: doing this mid-typing (every `updatetime`
-- pause in insert mode) buys nothing — the file cannot have changed under you
-- while you type into it, and CursorHold covers the moment you stop.
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'WinEnter', 'CursorHold', 'TermLeave' }, {
  group = autoread_group,
  callback = function()
    if not toggles.get 'autoread' then
      return
    end
    -- Skip special buffers (terminals, prompts, non-file buffers)
    if vim.bo.buftype ~= '' or vim.fn.mode() == 'c' then
      return
    end
    checktime_visible()
  end,
})

-- Live reload while parked in a terminal (e.g. the RosaAI CLI): the event autocmd
-- above already covers normal editing via CursorHold, but CursorHold never fires
-- while focused on a terminal buffer, so a visible file split wouldn't refresh as
-- the CLI writes to disk. This timer fills only that gap.
-- `checktime` just stats files and never touches buffers with unsaved changes.
local autoread_interval = 1000 -- ms
local autoread_timer = vim.uv.new_timer()
if autoread_timer then
  autoread_timer:start(
    autoread_interval,
    autoread_interval,
    vim.schedule_wrap(function()
      if not toggles.get 'autoread' then
        return
      end
      -- Only act while focused on a non-file buffer (terminal/prompt). When you're
      -- in a normal buffer, CursorHold already reloads all buffers on idle.
      if vim.bo.buftype == '' then
        return
      end
      -- Same visible-only scan: it is the on-screen split that has to refresh
      -- while the CLI writes, and it already skips the work when nothing is up.
      checktime_visible()
    end)
  )

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = autoread_group,
    callback = function()
      if autoread_timer and not autoread_timer:is_closing() then
        autoread_timer:stop()
        autoread_timer:close()
      end
    end,
  })
end

-- Rosaterm
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

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rosaterm',
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

local explorer_auto_opened = false

local function open_snacks_explorer()
  if explorer_auto_opened then
    return
  end
  explorer_auto_opened = true

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

    -- Skip when opened with a directory (nvim .) — picker handles that
    if opened_with_dir then
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

    -- Change cwd to the file's directory (or its git root) so the explorer opens in the right place
    local file_dir = vim.fn.fnamemodify(bufname, ':p:h')
    local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(file_dir) .. ' rev-parse --show-toplevel')[1]
    if vim.v.shell_error == 0 and git_root and git_root ~= '' then
      vim.cmd('cd ' .. vim.fn.fnameescape(git_root))
    else
      vim.cmd('cd ' .. vim.fn.fnameescape(file_dir))
    end

    open_snacks_explorer()
  end,
})

local my_highlights = vim.api.nvim_create_augroup('MyHighlights', { clear = true })

local function on_colorscheme(fn)
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = my_highlights,
    pattern = '*',
    callback = fn,
  })
  vim.api.nvim_create_autocmd('VimEnter', {
    group = my_highlights,
    callback = function()
      vim.schedule(fn)
    end,
  })
end

local function lsp_reference_highlights()
  if not toggles.get 'lsp_ref_highlights' then
    return
  end

  local fg = vim.o.background == 'light' and '#000000' or '#FFFFFF'
  local highlight_style = { bold = true, bg = 'none', fg = fg }

  vim.api.nvim_set_hl(0, 'LspReferenceRead', highlight_style)
  vim.api.nvim_set_hl(0, 'LspReferenceWrite', highlight_style)
  vim.api.nvim_set_hl(0, 'LspReferenceText', highlight_style)
end

local function bg_only_match_highlights()
  local function bg_of(name)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    return ok and hl.bg or nil
  end

  local bg = bg_of 'MatchParen' or bg_of 'Visual'
  if not bg then
    return
  end

  for _, group in ipairs { 'MatchWord', 'MatchWordCur', 'MatchParenCur' } do
    vim.api.nvim_set_hl(0, group, { bg = bg })
  end
end

on_colorscheme(lsp_reference_highlights)
on_colorscheme(bg_only_match_highlights)

-- Re-apply lualine state after colorscheme change
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.schedule(function()
      local ok, lualine = pcall(require, 'lualine')
      if not ok then
        return
      end
      local lualine_enabled = toggles.get 'lualine'
      if lualine_enabled then
        -- Refresh lualine to pick up new theme colors
        local theme_ok, theme = pcall(require, 'rosavim.plugins.ui.lualine.theme')
        local sections = require 'rosavim.plugins.ui.lualine.sections'
        local sep = sections.get_sep()
        local use_custom = toggles.get 'lualine_theme'
        lualine.setup {
          options = {
            theme = (use_custom and theme_ok) and theme.create() or 'auto',
            section_separators = sep.section,
            component_separators = sep.component,
            globalstatus = true,
          },
          sections = sections.build(sep),
          inactive_sections = sections.inactive_sections,
        }
        lualine.hide { unhide = true }
      else
        lualine.hide { unhide = false }
        -- hide() can't restore once a re-setup reset lualine's cache; wipe
        -- any leftover rendered bar (see sections.clear_stale)
        require('rosavim.plugins.ui.lualine.sections').clear_stale()
        -- Ensure native statusline stays visible when lualine is off
        vim.defer_fn(function()
          vim.o.laststatus = 3
        end, 50)
      end
    end)
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

-- Rosaterm: a thin bar cursor while typing (insert/terminal), and a
-- hidden cursor in normal mode, plus no full-width CursorLine, so the
-- terminal stays clean instead of showing a heavy block on the current line.
do
  local bar_fts = { rosaterm = true }
  local saved
  local grp = vim.api.nvim_create_augroup('rosaterm_bar_cursor', { clear = true })
  local function set_hidden_hl()
    vim.api.nvim_set_hl(0, 'RosatermHiddenCursor', { blend = 100, nocombine = true })
  end
  set_hidden_hl()
  vim.api.nvim_create_autocmd('ColorScheme', { group = grp, callback = set_hidden_hl })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = grp,
    callback = function(ev)
      if bar_fts[vim.bo[ev.buf].filetype] then
        if not saved then
          saved = vim.o.guicursor
        end
        set_hidden_hl()
        vim.o.guicursor = 'a:ver25,n-v-c:block-RosatermHiddenCursor/RosatermHiddenCursor'
        vim.wo.cursorline = false
      elseif saved then
        vim.o.guicursor = saved
        saved = nil
      end
    end,
  })
end

vim.api.nvim_create_autocmd('ModeChanged', {
  group = vim.api.nvim_create_augroup('rosavim_snippet_stop', { clear = true }),
  pattern = '*:n',
  callback = function()
    if not vim.snippet.active() then
      return
    end
    vim.defer_fn(function()
      if vim.snippet.active() and vim.fn.mode() == 'n' then
        vim.snippet.stop()
      end
    end, 60)
  end,
})

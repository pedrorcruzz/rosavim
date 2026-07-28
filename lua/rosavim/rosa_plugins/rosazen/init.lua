--- Rosazen - Distraction-free mode for Rosavim
--- Unlike Snacks zen (a single centered float over a backdrop), Rosazen keeps
--- a real window: it maximizes the current window (via rosamaximize, without the
--- badge) and strips the UI chrome. Floating tools (rosaterm, rosaai, yazi,
--- lazygit) still open on top without leaving zen, since it's a mode, not a
--- window that closes on focus change.
local M = {}

local active = false
local saved = nil

-- Global options stripped while zen is active. laststatus is set AFTER
-- lualine.hide() (which stops lualine's refresh timer/autocmd), otherwise
-- lualine would re-force it back on the next event.
local GLOBAL_OPTS = {
  laststatus = 0, -- hides the statusline row
  showtabline = 0, -- hides bufferline
}

-- Window-local options stripped on the zen window.
local WIN_OPTS = {
  number = false,
  relativenumber = false,
  signcolumn = 'no',
  foldcolumn = '0',
  cursorline = false,
  winbar = '', -- hides dropbar
  statuscolumn = '',
  -- Blank statusline (Normal highlight, no text). laststatus=0 only hides the
  -- LAST window's statusline; windows stacked above a split (e.g. rosaterm)
  -- still get a separator statusline, so we make it invisible.
  statusline = '%#Normal#',
}

-- Target width of the centered editing window.
local TARGET_WIDTH = 140

local augroup = nil

--- Create an empty padding window on one side (`topleft` / `botright`) so the
--- editing window is centered. Returns the padding window handle.
local function make_pad(where, width)
  vim.cmd(where .. ' ' .. width .. 'vsplit')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  -- Same marker the panel_reserve spacers use, so rosapick (window picker)
  -- skips these padding windows.
  vim.bo[buf].filetype = 'rosa_spacer'
  vim.api.nvim_win_set_buf(win, buf)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].foldcolumn = '0'
  vim.wo[win].cursorline = false
  vim.wo[win].winbar = ''
  vim.wo[win].statuscolumn = ''
  vim.wo[win].statusline = '%#Normal#'
  vim.wo[win].list = false
  vim.wo[win].fillchars = 'eob: '
  vim.wo[win].winfixwidth = true
  return win
end

--- Add left/right padding windows to center the main window at TARGET_WIDTH.
--- Returns the list of padding window handles (empty if the screen is too narrow).
local function add_padding(main)
  local cols = vim.o.columns
  if cols <= TARGET_WIDTH + 8 then
    return {}
  end
  local pad = math.floor((cols - TARGET_WIDTH) / 2)
  local pads = { make_pad('topleft', pad), make_pad('botright', pad) }
  if vim.api.nvim_win_is_valid(main) then
    vim.api.nvim_set_current_win(main)
  end
  return pads
end

--- A normal editing window (real file buffer, not a floating tool window).
local function is_editing_win(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  if vim.api.nvim_win_get_config(win).relative ~= '' then
    return false -- floating window (rosaterm, rosaai, yazi, lazygit)
  end
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].buftype == ''
end

--- Center the editing window with side padding, but ONLY when a single real
--- file window is focused. Skips the dashboard and other special/non-file
--- buffers (they center themselves) and split layouts. Runs on enter and on
--- buffer changes, so opening a file from the dashboard gets centered too.
local function ensure_padding()
  if not active or not saved then
    return
  end
  if saved.pads then
    for _, w in ipairs(saved.pads) do
      if vim.api.nvim_win_is_valid(w) then
        return -- already padded
      end
    end
  end
  local win = vim.api.nvim_get_current_win()
  if not is_editing_win(win) then
    return
  end
  local reals = 0
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(w).relative == '' then
      reals = reals + 1
    end
  end
  if reals ~= 1 then
    return -- a split layout is open; don't force centering
  end
  saved.pads = add_padding(win)
end

--- Hide lualine using its own API so it stops redrawing the statusline.
local function hide_lualine()
  local ok, lualine = pcall(require, 'lualine')
  if ok then
    pcall(lualine.hide)
  end
end

--- Re-assert the zen chrome. Opening rosaterm/rosaai/yazi/lazygit (or any split)
--- makes lualine/bufferline re-force laststatus/showtabline and dropbar re-attach
--- the winbar. This runs on every window event, so it only does the expensive
--- work (lualine.hide) when something actually changed.
local function clamp()
  if not active then
    return
  end
  if vim.o.laststatus ~= 0 then
    -- lualine came back; re-hide it, then force laststatus=0 (hide restores
    -- laststatus to its saved value, so the 0 must come after).
    hide_lualine()
    vim.o.laststatus = 0
  end
  if vim.o.showtabline ~= 0 then
    vim.o.showtabline = 0
  end
  local win = vim.api.nvim_get_current_win()
  if is_editing_win(win) then
    if vim.wo[win].winbar ~= '' then
      pcall(function()
        vim.wo[win].winbar = ''
      end)
    end
    if vim.wo[win].statusline ~= '%#Normal#' then
      pcall(function()
        vim.wo[win].statusline = '%#Normal#'
      end)
    end
  end
end

--- Never let the cursor rest on a padding window (e.g. closing rosaterm drops
--- focus onto an edge pad). Bounce back to the main editing window.
local function is_pad(win)
  if not (saved and saved.pads) then
    return false
  end
  for _, w in ipairs(saved.pads) do
    if w == win then
      return true
    end
  end
  return false
end

local function bounce_off_pad()
  if not active then
    return
  end
  if not is_pad(vim.api.nvim_get_current_win()) then
    return
  end
  local target = (saved.win and vim.api.nvim_win_is_valid(saved.win)) and saved.win or nil
  if not target then
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if is_editing_win(w) then
        target = w
        break
      end
    end
  end
  if target and vim.api.nvim_win_is_valid(target) then
    pcall(vim.api.nvim_set_current_win, target)
  end
end

-- Coalesce a burst of window events into a single deferred pass.
local pending = false
local function on_event()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    clamp()
    ensure_padding()
    bounce_off_pad()
  end)
end

local function watch()
  augroup = vim.api.nvim_create_augroup('Rosazen', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'WinNew', 'TermOpen' }, {
    group = augroup,
    callback = on_event,
  })
  -- Some tools (rosaterm, etc.) re-set laststatus/showtabline AFTER their open
  -- event, so the event-based clamp above misses it. Watch the options directly
  -- and force them back to 0 whenever anything raises them during zen.
  vim.api.nvim_create_autocmd('OptionSet', {
    group = augroup,
    pattern = { 'laststatus', 'showtabline' },
    callback = on_event,
  })
end

--- Persist the zen state so it survives across sessions.
local function persist(state)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if ok then
    toggles.set('rosazen', state)
  end
end

function M.is_active()
  return active
end

function M.on()
  if active then
    return
  end

  saved = { globals = {}, win_opts = {}, incline = nil }

  -- Hide lualine FIRST so it stops re-forcing laststatus, then strip globals
  hide_lualine()
  for opt, val in pairs(GLOBAL_OPTS) do
    saved.globals[opt] = vim.o[opt]
    vim.o[opt] = val
  end

  -- Maximize the current window without the rosamaximize badge
  pcall(function()
    require('rosavim.rosa_plugins.rosamaximize').maximize { indicator = false }
  end)

  -- Snapshot + strip window-local options on the (now single) zen window
  local win = vim.api.nvim_get_current_win()
  saved.win = win
  for opt, val in pairs(WIN_OPTS) do
    local ok, cur = pcall(function()
      return vim.wo[win][opt]
    end)
    if ok then
      saved.win_opts[opt] = cur
      pcall(function()
        vim.wo[win][opt] = val
      end)
    end
  end

  -- Hide the floating filename indicator
  local ok_incline, incline = pcall(require, 'incline')
  if ok_incline then
    saved.incline = incline.is_enabled()
    if saved.incline then
      pcall(incline.disable)
    end
  end

  -- Mark active BEFORE centering — ensure_padding() bails out when inactive
  active = true

  -- Center the editing window with side padding (skipped on the dashboard;
  -- re-applied automatically when you open a real file)
  ensure_padding()

  watch()
  persist(true)
end

function M.off()
  if not active then
    return
  end

  local s = saved
  saved = nil
  active = false
  persist(false)

  if augroup then
    pcall(vim.api.nvim_del_augroup_by_id, augroup)
    augroup = nil
  end

  -- Close the side padding windows
  if s.pads then
    for _, w in ipairs(s.pads) do
      if vim.api.nvim_win_is_valid(w) then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end
  end

  -- Focus back the editing window before restoring options/layout
  if s.win and vim.api.nvim_win_is_valid(s.win) then
    pcall(vim.api.nvim_set_current_win, s.win)
  end

  -- Restore window-local options (the zen window is still current here)
  if s.win and vim.api.nvim_win_is_valid(s.win) then
    for opt, val in pairs(s.win_opts) do
      pcall(function()
        vim.wo[s.win][opt] = val
      end)
    end
  end

  -- Restore global options
  for opt, val in pairs(s.globals) do
    vim.o[opt] = val
  end

  -- Restore lualine to its persisted visibility
  local ok_ll, lualine = pcall(require, 'lualine')
  if ok_ll then
    local visible = true
    local ok_t, toggles = pcall(require, 'rosavim.config.toggles')
    if ok_t then
      visible = toggles.get 'lualine' ~= false
    end
    pcall(function()
      lualine.hide { unhide = visible }
    end)
  end

  -- Restore incline if it was enabled before
  if s.incline then
    local ok, incline = pcall(require, 'incline')
    if ok then
      pcall(incline.enable)
    end
  end

  -- Rebuild the original layout (reopens explorer/rosaai if they were open)
  pcall(function()
    require('rosavim.rosa_plugins.rosamaximize').restore()
  end)
end

function M.toggle()
  if active then
    M.off()
  else
    M.on()
  end
end

return M

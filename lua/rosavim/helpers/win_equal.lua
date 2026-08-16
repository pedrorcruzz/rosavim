local M = {}

M.sidebar_filetypes = {
  ['snacks_explorer'] = true,
  ['snacks_picker_list'] = true,
  ['snacks_picker_input'] = true,
  ['snacks_layout_box'] = true,
  ['neo-tree'] = true,
  ['NvimTree'] = true,
  ['oil'] = true,
  ['Outline'] = true,
  ['aerial'] = true,
  ['dbui'] = true,
  ['Trouble'] = true,
  ['trouble'] = true,
  ['undotree'] = true,
  ['rosa_spacer'] = true,
}

--- Native (non-float) windows whose filetype passes `match`.
local function wins_matching(match)
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if match(ft) then
        table.insert(wins, win)
      end
    end
  end
  return wins
end

local function sidebars()
  return wins_matching(function(ft)
    return M.sidebar_filetypes[ft] == true
  end)
end

--- Windows an equalize must never resize: sidebars plus the fixed-size tool
--- panels, whose size is a user setting, not a share of the screen.
local function pinnable()
  return wins_matching(function(ft)
    return M.sidebar_filetypes[ft] == true or ft == 'rosaterm' or ft:sub(1, 6) == 'rosaai'
  end)
end

--- Run `fn` with every pinnable window fixed on both axes, restoring the
--- previous flags afterwards.
local function with_sidebars_pinned(fn)
  local saved = {}
  for _, win in ipairs(pinnable()) do
    saved[win] = { vim.wo[win].winfixwidth, vim.wo[win].winfixheight }
    vim.wo[win].winfixwidth = true
    vim.wo[win].winfixheight = true
  end
  local ok, err = pcall(fn)
  for win, prev in pairs(saved) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winfixwidth = prev[1]
      vim.wo[win].winfixheight = prev[2]
    end
  end
  if not ok then
    error(err)
  end
end

function M.equalize()
  with_sidebars_pinned(function()
    pcall(vim.cmd, 'wincmd =')
  end)
end

--- Equalize the editor windows AND put the pinned panels back to their preset
--- size. equalize() alone can't: they're floats, and it deliberately pins them.
function M.reset_all()
  M.equalize()
  for _, mod in ipairs { 'rosavim.rosa_plugins.rosaterm', 'rosavim.rosa_plugins.rosaai' } do
    local ok, panel = pcall(require, mod)
    if ok and panel.reset_sizes then
      pcall(panel.reset_sizes)
    end
  end
end

--- The split itself has to run pinned too: with `equalalways` on, `:vsplit`
--- equalizes every window in the tabpage, so an unpinned explorer/spacer is
--- already resized by the time equalize() runs.
function M.split(cmd)
  with_sidebars_pinned(function()
    vim.cmd(cmd)
    pcall(vim.cmd, 'wincmd =')
  end)
  vim.schedule(M.equalize)
end

--- `:only` minus the sidebars: closes the editor windows and re-equalizes,
--- leaving the explorer and the invisible spacers in place.
function M.only()
  local cur = vim.api.nvim_get_current_win()
  local keep = {}
  local cur_is_sidebar = false
  for _, win in ipairs(sidebars()) do
    keep[win] = true
    cur_is_sidebar = cur_is_sidebar or win == cur
  end
  keep[cur] = true
  -- Focused ON a sidebar: keep one editor window, or nothing is left but
  -- panels.
  if cur_is_sidebar then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if not keep[win] and vim.api.nvim_win_get_config(win).relative == '' then
        keep[win] = true
        break
      end
    end
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not keep[win] and vim.api.nvim_win_get_config(win).relative == '' then
      pcall(vim.api.nvim_win_close, win, false)
    end
  end
  M.equalize()
end

--- The Snacks explorer is not one window and none of its windows carries a
--- `snacks_explorer` filetype: it's a native `snacks_layout_box` column
--- framing the picker's list and input, which are floats. Ask Snacks whether
--- an explorer is actually up, then spare every window of that shape.
local EXPLORER_FILETYPES = {
  ['snacks_layout_box'] = true,
  ['snacks_picker_list'] = true,
  ['snacks_picker_input'] = true,
  ['snacks_explorer'] = true,
}

local function explorer_wins()
  local keep = {}
  local ok, pickers = pcall(function()
    return Snacks.picker.get { source = 'explorer' }
  end)
  -- No explorer up: a plain picker's windows are fair game. If the query
  -- itself failed, spare them — losing the explorer is the worse outcome.
  if ok and (not pickers or #pickers == 0) then
    return keep
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if EXPLORER_FILETYPES[vim.bo[vim.api.nvim_win_get_buf(win)].filetype] then
      keep[win] = true
    end
  end
  return keep
end

--- Everything `only()` spares, gone too: the other sidebars, the stray floats
--- and the Rosaterm / RosaAI panels, leaving just the focused window. The
--- panels go through their own close path so the session and the space they
--- reserved are released; their spacers disappear with them. Neovim keeps one
--- native window alive, so focusing a float leaves an editor pane behind by
--- design.
---
--- The Snacks explorer is the one exception: it survives wherever the cursor
--- is, along with the layout box that frames it.
function M.only_all()
  local api = vim.api
  local cur = api.nvim_get_current_win()
  local closed = 0

  local keep = explorer_wins()

  for _, mod in ipairs { 'rosavim.rosa_plugins.rosaterm', 'rosavim.rosa_plugins.rosaai' } do
    local ok, panel = pcall(require, mod)
    if ok and panel.close_win then
      for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        if win ~= cur and not keep[win] and api.nvim_win_is_valid(win) then
          local pok, hit = pcall(panel.close_win, win)
          if pok and hit then
            closed = closed + 1
          end
        end
      end
    end
  end

  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if win ~= cur and not keep[win] and api.nvim_win_is_valid(win) then
      local ft = vim.bo[api.nvim_win_get_buf(win)].filetype
      if ft ~= 'rosa_spacer' and pcall(api.nvim_win_close, win, false) then
        closed = closed + 1
      end
    end
  end

  M.equalize()
  return closed
end

--- A sidebar takes its width from ONE editor pane, leaving an existing split
--- lopsided. Re-equalize when one opens or closes.
function M.watch_sidebars()
  local group = vim.api.nvim_create_augroup('RosavimWinEqualSidebars', { clear = true })
  local patterns = {}
  for ft in pairs(M.sidebar_filetypes) do
    -- Spacers are layout plumbing, not panels the user opened.
    if ft ~= 'rosa_spacer' then
      table.insert(patterns, ft)
    end
  end
  -- Snacks sizes its layout box a few ticks after the FileType that announces
  -- it, so an immediate `wincmd =` equalizes the old layout and gets undone.
  -- Debounce: each event restarts the timer, the equalize runs once settled.
  local timer = nil
  local function later()
    if timer then
      pcall(function()
        timer:stop()
        timer:close()
      end)
    end
    timer = vim.uv.new_timer()
    timer:start(
      60,
      0,
      vim.schedule_wrap(function()
        timer = nil
        M.equalize()
      end)
    )
  end
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = patterns,
    callback = later,
  })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(args)
      local win = tonumber(args.match)
      if not win or not vim.api.nvim_win_is_valid(win) then
        return
      end
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        return
      end
      local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if M.sidebar_filetypes[ft] and ft ~= 'rosa_spacer' then
        later()
      end
    end,
  })
end

return M

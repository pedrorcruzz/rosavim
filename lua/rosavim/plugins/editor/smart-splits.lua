--- The explorer lives in a `winfixwidth` layout box and the cursor sits in a
--- float inside it, so smart-splits can't touch either. Drive the box directly
--- and keep the layout's own width in sync.
local function resize_explorer(dir)
  if dir ~= 'left' and dir ~= 'right' then
    return false
  end
  local ok, snacks = pcall(function()
    return Snacks
  end)
  if not ok or not snacks or not snacks.picker then
    return false
  end
  local picker = (snacks.picker.get() or {})[1]
  local layout = picker and picker.layout
  local box = layout and layout.root and layout.root.win
  if not box or not vim.api.nvim_win_is_valid(box) then
    return false
  end
  -- Only when the cursor is inside this explorer.
  local cur = vim.api.nvim_get_current_win()
  local inside = cur == box
  for _, w in pairs(layout.wins or {}) do
    inside = inside or (w.win == cur)
  end
  if not inside then
    return false
  end
  local on_left = vim.api.nvim_win_get_position(box)[2] < vim.o.columns / 2
  local grow = (dir == 'right') == on_left
  local width = vim.api.nvim_win_get_width(box) + (grow and 1 or -1)
  if width < 15 or width > vim.o.columns - 20 then
    return false
  end
  local fixed = vim.wo[box].winfixwidth
  vim.wo[box].winfixwidth = false
  pcall(vim.api.nvim_win_set_width, box, width)
  vim.wo[box].winfixwidth = fixed
  if layout.opts and layout.opts.layout then
    layout.opts.layout.width = width
  end
  return true
end

--- Windows the arrows must never disturb from elsewhere: the sidebars and the
--- invisible panel spacers. `winfixwidth` isn't enough — Vim shrinks a pinned
--- window anyway when it's the only neighbour left, so an editor pane sitting
--- alone next to the explorer would drag it along.
local function protected_sizes()
  local sidebars = require('rosavim.helpers.win_equal').sidebar_filetypes
  local cur = vim.api.nvim_get_current_win()
  local out = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= cur and vim.api.nvim_win_get_config(win).relative == '' then
      if sidebars[vim.bo[vim.api.nvim_win_get_buf(win)].filetype] then
        out[win] = { vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win) }
      end
    end
  end
  return out
end

local function restore_protected(before)
  for win, size in pairs(before) do
    if vim.api.nvim_win_is_valid(win) then
      if vim.api.nvim_win_get_width(win) ~= size[1] then
        pcall(vim.api.nvim_win_set_width, win, size[1])
      end
      if vim.api.nvim_win_get_height(win) ~= size[2] then
        pcall(vim.api.nvim_win_set_height, win, size[2])
      end
    end
  end
end

--- Arrow-key resize, always on the FOCUSED window: rosaterm/RosaAI float first
--- (smart-splits can't see floats), then the explorer, then the native split.
local function resize(dir)
  for _, mod in ipairs { 'rosavim.rosa_plugins.rosaterm', 'rosavim.rosa_plugins.rosaai' } do
    local ok, panel = pcall(require, mod)
    if ok and panel.resize_arrow(dir) then
      return
    end
  end
  if resize_explorer(dir) then
    return
  end

  local before = protected_sizes()
  require('smart-splits')['resize_' .. dir]()
  restore_protected(before)
end

return {
  'mrjones2014/smart-splits.nvim',
  lazy = true,
  keys = {
    {
      '<C-h>',
      function()
        require('smart-splits').move_cursor_left()
      end,
      desc = 'Move to left split',
    },
    {
      '<C-j>',
      function()
        require('smart-splits').move_cursor_down()
      end,
      desc = 'Move to below split',
    },
    {
      '<C-k>',
      function()
        require('smart-splits').move_cursor_up()
      end,
      desc = 'Move to above split',
    },
    {
      '<C-l>',
      function()
        require('smart-splits').move_cursor_right()
      end,
      desc = 'Move to right split',
    },
    {
      '<C-\\>',
      function()
        require('smart-splits').move_cursor_previous()
      end,
      desc = 'Move to previous split',
    },
    {
      '<left>',
      function()
        resize 'left'
      end,
      desc = 'Resize left',
    },
    {
      '<down>',
      function()
        resize 'down'
      end,
      desc = 'Resize down',
    },
    {
      '<up>',
      function()
        resize 'up'
      end,
      desc = 'Resize up',
    },
    {
      '<right>',
      function()
        resize 'right'
      end,
      desc = 'Resize right',
    },
  },
}

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

local function sidebars()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if M.sidebar_filetypes[ft] then
        table.insert(wins, win)
      end
    end
  end
  return wins
end

--- Run `fn` with every sidebar pinned on both axes, restoring the previous
--- flags afterwards.
local function with_sidebars_pinned(fn)
  local saved = {}
  for _, win in ipairs(sidebars()) do
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

return M

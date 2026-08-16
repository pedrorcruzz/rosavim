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

function M.equalize()
  local saved = {}
  for _, win in ipairs(sidebars()) do
    saved[win] = { vim.wo[win].winfixwidth, vim.wo[win].winfixheight }
    vim.wo[win].winfixwidth = true
    vim.wo[win].winfixheight = true
  end
  pcall(vim.cmd, 'wincmd =')
  for win, prev in pairs(saved) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winfixwidth = prev[1]
      vim.wo[win].winfixheight = prev[2]
    end
  end
end

function M.split(cmd)
  vim.cmd(cmd)
  M.equalize()
  vim.schedule(M.equalize)
end

return M

vim.keymap.set('i', 'kj', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('x', '<C-j>', ":move '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('x', '<C-k>', ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('n', '<A-Down>', [[:m .+1<CR>==]], { noremap = true, silent = true })
vim.keymap.set('n', '<A-Up>', [[:m .-2<CR>==]], { noremap = true, silent = true })

-- Emmet
vim.g.user_emmet_leader_key = '<C-y>'

-- Window navigation handled by smart-splits.nvim

vim.keymap.set('n', '<BS>', '<c-6>', { desc = 'Switch to last buffer' })

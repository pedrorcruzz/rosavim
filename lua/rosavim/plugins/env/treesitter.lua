-- Native treesitter configuration (Neovim 0.12+)
-- No plugin needed — uses built-in vim.treesitter API

vim.filetype.add {
  pattern = {
    ['.*%.blade%.php'] = 'blade',
    ['.*%.html'] = 'htmldjango',
    ['.*%.html%.jinja'] = 'htmldjango',
    ['.*%.html%.jinja2'] = 'htmldjango',
    ['.*%.html%.j2'] = 'htmldjango',
  },
}

local group = vim.api.nvim_create_augroup('RosavimTreesitter', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if ok then
      vim.bo[args.buf].indentexpr = "v:lua.require'vim.treesitter'.indentexpr()"
    end
  end,
})

return {}

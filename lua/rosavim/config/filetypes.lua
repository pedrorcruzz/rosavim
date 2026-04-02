vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.html',
  callback = function()
    local manage_py = vim.fn.findfile('manage.py', vim.fn.getcwd() .. ';')
    if manage_py ~= '' then
      vim.bo.filetype = 'htmldjango'
    else
      vim.bo.filetype = 'html'
    end
  end,
})

return {
  cmd = { 'superhtml', 'lsp' },
  filetypes = { 'html', 'htmldjango', 'shtml', 'xml' },
  root_markers = { '.git' },
  get_language_id = function()
    return 'html'
  end,
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('<leader>lr', vim.lsp.buf.rename, 'Rename')
    map('<leader>la', vim.lsp.buf.code_action, 'Code Action')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

local severity = vim.diagnostic.severity
vim.diagnostic.config {
  virtual_text = { current_line = true },
  signs = {
    text = {
      [severity.ERROR] = ' ',
      [severity.WARN] = ' ',
      [severity.HINT] = '󱠇 ',
      [severity.INFO] = ' ',
    },
  },
  underline = true,
  update_in_insert = true,
  severity_sort = true,
}

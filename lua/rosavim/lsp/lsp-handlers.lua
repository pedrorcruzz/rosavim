local toggles = require 'rosavim.config.toggles'

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('<leader>lr', vim.lsp.buf.rename, 'Rename')
    map('<leader>la', vim.lsp.buf.code_action, 'Code Action')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight') then
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
  virtual_text = { current_line = toggles.get 'virtual_text_current_line' },
  signs = {
    text = {
      [severity.ERROR] = ' ',
      [severity.WARN] = ' ',
      [severity.HINT] = '󱠇 ',
      [severity.INFO] = ' ',
    },
  },
  underline = true,
  -- Neovim's default (false) on purpose: with this on, every keystroke in
  -- insert mode re-publishes diagnostics, which re-lays out all virtual text,
  -- re-renders the bufferline (diagnostics = 'nvim_lsp') and redraws the
  -- statusline. On a big TS file that is the single biggest source of typing
  -- lag. Diagnostics still refresh on InsertLeave and on every LSP publish.
  update_in_insert = false,
  severity_sort = true,
}

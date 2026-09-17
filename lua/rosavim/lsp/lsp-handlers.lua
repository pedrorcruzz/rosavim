local toggles = require 'rosavim.config.toggles'

local lsp_group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })

-- Document highlight is handled by snacks.words (one request stream, plus
-- ]]/[[ reference navigation); no manual CursorHold pipeline here.
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_group,
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('<leader>r', vim.lsp.buf.rename, 'Rename')
    map('<leader>la', vim.lsp.buf.code_action, 'Code Action')
  end,
})

-- superhtml exits with code 1 on malformed HTML; keep that noise out of the
-- notifier. Wrapped here (after snacks owns vim.notify) via lazy scheduling.
vim.schedule(function()
  local orig_notify = vim.notify
  vim.notify = function(msg, ...)
    if type(msg) == 'string' and msg:find('Client superhtml quit', 1, true) then
      return
    end
    return orig_notify(msg, ...)
  end
end)

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

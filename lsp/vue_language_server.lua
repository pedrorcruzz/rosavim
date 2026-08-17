-- This server STAYS long term, but the on_init block below is temporary: it
-- only exists to forward TypeScript work to vtsls. See lsp/vtsls.lua for the
-- reason and the removal checklist.

local warned = false

return {
  cmd = { 'vue-language-server', '--stdio' },
  filetypes = { 'vue' },
  root_markers = { 'nuxt.config.ts', 'vite.config.ts', 'package.json', '.git' },
  on_init = function(client)
    client.handlers['tsserver/request'] = function(_, result, context)
      local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'vtsls' })[1] or vim.lsp.get_clients({ bufnr = context.bufnr, name = 'ts_ls' })[1]
      if not ts_client then
        if not warned then
          warned = true
          vim.notify('vue_language_server needs vtsls (or ts_ls) for TypeScript features in .vue files', vim.log.levels.WARN)
        end
        return
      end
      local id, command, payload = result[1][1], result[1][2], result[1][3]
      ts_client:exec_cmd({
        title = 'vue_tsserver_request',
        command = 'typescript.tsserverRequest',
        arguments = { command, payload },
      }, { bufnr = context.bufnr }, function(_, response)
        client:notify('tsserver/response', { { id, response and response.body } })
      end)
    end
  end,
}

return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
  on_attach = function(client)
    local config = client.config
    config.settings.json = config.settings.json or {}
    config.settings.json.schemas = config.settings.json.schemas or {}
    vim.list_extend(config.settings.json.schemas, require('schemastore').json.schemas())
    client:notify('workspace/didChangeConfiguration', { settings = config.settings })
  end,
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
    },
  },
}

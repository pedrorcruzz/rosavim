--WARN: TEMPORARY: root_dir is a gate instead of root_markers so vtsls can own Vue
-- projects. Removal checklist and the reason live in lsp/vtsls.lua.

local vue = require 'rosavim.helpers.vue_project'

return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_dir = vue.gate(false),
}

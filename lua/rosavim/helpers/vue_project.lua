--- Vue project detection - decides whether vtsls or tsc owns a TypeScript buffer
--- TEMPORARY: this whole file is deleted once Volar supports TypeScript 7.
--- Removal checklist and the reason live in lsp/vtsls.lua.
local M = {}

M.mason_vue = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules'

local cache = {}

local ts_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' }
local vue_markers = { 'nuxt.config.ts', 'nuxt.config.js', 'vue.config.js' }

--- Nearest ancestor of `path` containing one of `markers`
--- @param path string
--- @param markers string[]
--- @return string|nil
function M.root(path, markers)
  local found = vim.fs.find(markers, { path = path, upward = true })[1]
  if found then
    return vim.fs.dirname(found)
  end
  return nil
end

local function reads_as_vue(root_dir)
  for _, marker in ipairs(vue_markers) do
    if vim.uv.fs_stat(root_dir .. '/' .. marker) then
      return true
    end
  end

  local manifest = root_dir .. '/package.json'
  if not vim.uv.fs_stat(manifest) then
    return false
  end

  local ok, lines = pcall(vim.fn.readfile, manifest)
  if not ok then
    return false
  end

  local decoded, pkg = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not decoded or type(pkg) ~= 'table' then
    return false
  end

  for _, field in ipairs { 'dependencies', 'devDependencies', 'peerDependencies' } do
    local deps = pkg[field]
    if type(deps) == 'table' and (deps.vue or deps.nuxt or deps['@vue/runtime-core']) then
      return true
    end
  end

  return false
end

--- Is `root_dir` a Vue project? Cached per root.
--- @param root_dir string|nil
--- @return boolean
function M.is_vue(root_dir)
  if not root_dir then
    return false
  end
  if cache[root_dir] == nil then
    cache[root_dir] = reads_as_vue(root_dir)
  end
  return cache[root_dir]
end

--- Resolve the project root for a buffer, then hand it to `on_dir` only when
--- `want_vue` matches whether that root is a Vue project. Not calling `on_dir`
--- keeps the server from attaching, which is how vtsls and tsc stay exclusive.
--- @param want_vue boolean
--- @return fun(bufnr: integer, on_dir: fun(dir: string))
function M.gate(want_vue)
  return function(bufnr, on_dir)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == '' then
      return
    end

    local root_dir = M.root(name, ts_markers)
    if not root_dir then
      return
    end

    if M.is_vue(root_dir) == want_vue then
      on_dir(root_dir)
    end
  end
end

--- Forget cached answers so a freshly added Vue dependency is picked up
function M.clear_cache()
  cache = {}
end

return M

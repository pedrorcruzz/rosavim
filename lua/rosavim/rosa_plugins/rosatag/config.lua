--- Rosatag - filetypes it attaches to and the persisted toggle state
local M = {}

M.filetypes = {
  'html',
  'htmldjango',
  'xml',
  'svg',
  'php',
  'blade',
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'vue',
  'svelte',
  'astro',
  'templ',
  'eruby',
  'handlebars',
  'twig',
}

local supported = {}
for _, ft in ipairs(M.filetypes) do
  supported[ft] = true
end

--- @param ft string|nil
--- @return boolean
function M.supported(ft)
  return ft ~= nil and supported[ft] == true
end

local function get(key, default)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return default
  end
  local v = toggles.get(key)
  if v == nil then
    return default
  end
  return v
end

function M.enabled()
  return get('rosatag', true)
end

function M.close_enabled()
  return get('rosatag_close', true)
end

function M.rename_enabled()
  return get('rosatag_rename', true)
end

return M

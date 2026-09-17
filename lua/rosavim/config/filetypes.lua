-- Django template detection at filetype-resolution time (once per buffer
-- load), with the manage.py lookup cached per directory - the old BufEnter
-- handler walked the filesystem on every re-entry and re-fired FileType.
local django_root_cache = {}

local function is_django(path)
  local dir = vim.fs.dirname(path)
  local cached = django_root_cache[dir]
  if cached == nil then
    cached = vim.fs.root(dir, 'manage.py') ~= nil
    django_root_cache[dir] = cached
  end
  return cached
end

vim.filetype.add {
  pattern = {
    ['.*%.html'] = function(path)
      return is_django(path) and 'htmldjango' or 'html'
    end,
  },
}

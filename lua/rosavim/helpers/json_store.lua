--- JSON Store - Tiny shared read/write layer for plugin state files
---
--- Every rosa plugin that persists state keeps one JSON file on disk. This
--- module owns the read-decode / encode-write dance (pcall-guarded and
--- nil-safe) so plugins only deal with their own data shape.
local M = {}

--- Load and decode a JSON state file.
--- Returns `defaults` when the file is missing, unreadable or not valid JSON.
--- @param path string
--- @param defaults any
--- @return any
function M.load(path, defaults)
  local ok, content = pcall(vim.fn.readfile, path)
  if ok and content and #content > 0 then
    local decode_ok, decoded = pcall(vim.json.decode, table.concat(content, '\n'))
    if decode_ok and type(decoded) == 'table' then
      return decoded
    end
  end
  return defaults
end

--- Encode and write data to a JSON state file (single line, like vim.json.encode emits).
--- @param path string
--- @param data any
--- @return boolean ok, string|nil err
function M.save(path, data)
  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    return false, 'failed to encode'
  end
  local ok2, err = pcall(vim.fn.writefile, { encoded }, path)
  if not ok2 then
    return false, err
  end
  return true
end

return M

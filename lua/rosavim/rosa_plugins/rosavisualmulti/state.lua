local M = {}

local api = vim.api

M.ns_pos = api.nvim_create_namespace 'rosavm_pos'
M.ns_hl = api.nvim_create_namespace 'rosavm_hl'

local s = nil

function M.session()
  if s and api.nvim_buf_is_valid(s.buf) then
    return s
  end
  s = nil
  return nil
end

function M.active()
  local cur = M.session()
  return cur ~= nil and cur.buf == api.nvim_get_current_buf()
end

function M.start()
  local buf = api.nvim_get_current_buf()
  if s and s.buf ~= buf then
    M.stop()
  end
  if not s then
    s = { buf = buf, regions = {}, index = 0, pattern = nil, whole_word = false }
  end
  return s
end

function M.stop()
  local cur = M.session()
  if cur then
    api.nvim_buf_clear_namespace(cur.buf, M.ns_pos, 0, -1)
    api.nvim_buf_clear_namespace(cur.buf, M.ns_hl, 0, -1)
    vim.b[cur.buf].rosavisualmulti = nil
  end
  s = nil
end

function M.range(region)
  local cur = M.session()
  if not cur then
    return nil
  end
  local m = api.nvim_buf_get_extmark_by_id(cur.buf, M.ns_pos, region.id, { details = true })
  if not m or not m[1] then
    return nil
  end
  local d = m[3] or {}
  return m[1], m[2], d.end_row or m[1], d.end_col or m[2]
end

local function line_len(buf, row)
  local l = api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  return l and #l or 0
end

function M.clamp(buf, row, col)
  local total = api.nvim_buf_line_count(buf)
  row = math.max(0, math.min(row, total - 1))
  return row, math.max(0, math.min(col, line_len(buf, row)))
end

function M.add(srow, scol, erow, ecol)
  local cur = M.start()
  srow, scol = M.clamp(cur.buf, srow, scol)
  erow, ecol = M.clamp(cur.buf, erow or srow, ecol or scol)
  for _, r in ipairs(cur.regions) do
    local rs, rc = M.range(r)
    if rs == srow and rc == scol then
      return nil
    end
  end
  local id = api.nvim_buf_set_extmark(cur.buf, M.ns_pos, srow, scol, {
    end_row = erow,
    end_col = ecol,
    right_gravity = false,
    end_right_gravity = true,
  })
  local region = { id = id }
  table.insert(cur.regions, region)
  M.sort()
  cur.index = M.index_of(region) or #cur.regions
  return region
end

function M.add_many(list)
  local cur = M.start()
  local taken = {}
  for _, r in ipairs(cur.regions) do
    local row, col = M.range(r)
    if row then
      taken[row .. ':' .. col] = true
    end
  end
  for _, item in ipairs(list) do
    local srow, scol = M.clamp(cur.buf, item.srow, item.scol)
    local key = srow .. ':' .. scol
    if not taken[key] then
      taken[key] = true
      local erow, ecol = M.clamp(cur.buf, item.erow or srow, item.ecol or scol)
      local id = api.nvim_buf_set_extmark(cur.buf, M.ns_pos, srow, scol, {
        end_row = erow,
        end_col = ecol,
        right_gravity = false,
        end_right_gravity = true,
      })
      table.insert(cur.regions, { id = id })
    end
  end
  M.sort()
  if cur.index == 0 then
    cur.index = 1
  end
end

function M.index_of(region)
  local cur = M.session()
  if not cur then
    return nil
  end
  for i, r in ipairs(cur.regions) do
    if r.id == region.id then
      return i
    end
  end
  return nil
end

function M.sort()
  local cur = M.session()
  if not cur then
    return
  end
  local keyed = {}
  for _, r in ipairs(cur.regions) do
    local row, col = M.range(r)
    if row then
      table.insert(keyed, { r = r, row = row, col = col })
    end
  end
  table.sort(keyed, function(a, b)
    if a.row ~= b.row then
      return a.row < b.row
    end
    return a.col < b.col
  end)
  cur.regions = {}
  for _, k in ipairs(keyed) do
    table.insert(cur.regions, k.r)
  end
end

function M.remove(i)
  local cur = M.session()
  if not cur or not cur.regions[i] then
    return
  end
  api.nvim_buf_del_extmark(cur.buf, M.ns_pos, cur.regions[i].id)
  table.remove(cur.regions, i)
  if #cur.regions == 0 then
    M.stop()
    return
  end
  if cur.index > #cur.regions then
    cur.index = #cur.regions
  end
end

function M.mark()
  local cur = M.session()
  if cur then
    vim.b[cur.buf].rosavisualmulti = #cur.regions
    pcall(vim.cmd, 'redrawstatus')
  end
end

function M.count()
  local cur = M.session()
  return cur and #cur.regions or 0
end

function M.main()
  local cur = M.session()
  if not cur then
    return nil
  end
  return cur.regions[cur.index]
end

return M

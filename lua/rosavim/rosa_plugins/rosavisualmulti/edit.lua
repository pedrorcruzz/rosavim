local M = {}

local api = vim.api
local state = require 'rosavim.rosa_plugins.rosavisualmulti.state'

function M.atomic(fn)
  local first = true
  local join = function()
    if first then
      first = false
      return
    end
    pcall(vim.cmd, 'silent! undojoin')
  end
  fn(join)
end

function M.snapshot()
  local cur = state.session()
  if not cur then
    return {}
  end
  state.sort()
  local out = {}
  for i, region in ipairs(cur.regions) do
    local srow, scol, erow, ecol = state.range(region)
    if srow then
      table.insert(out, { region = region, index = i, srow = srow, scol = scol, erow = erow, ecol = ecol })
    end
  end
  table.sort(out, function(a, b)
    if a.srow ~= b.srow then
      return a.srow > b.srow
    end
    return a.scol > b.scol
  end)
  return out
end

function M.text_of(item)
  local cur = state.session()
  if not cur then
    return ''
  end
  local ok, lines = pcall(api.nvim_buf_get_text, cur.buf, item.srow, item.scol, item.erow, item.ecol, {})
  if not ok then
    return ''
  end
  return table.concat(lines, '\n')
end

local function set_region(item, srow, scol, erow, ecol)
  local cur = state.session()
  if not cur then
    return
  end
  api.nvim_buf_set_extmark(cur.buf, state.ns_pos, srow, scol, {
    id = item.region.id,
    end_row = erow,
    end_col = ecol,
    right_gravity = false,
    end_right_gravity = true,
  })
end

function M.replace(replace)
  local cur = state.session()
  if not cur then
    return
  end
  local items = M.snapshot()
  M.atomic(function(join)
    for _, item in ipairs(items) do
      local text = M.text_of(item)
      local new = replace(item, text)
      if new ~= nil then
        join()
        local repl = vim.split(new, '\n', { plain = true })
        pcall(api.nvim_buf_set_text, cur.buf, item.srow, item.scol, item.erow, item.ecol, repl)
        local erow = item.srow + #repl - 1
        local ecol = #repl == 1 and (item.scol + #repl[1]) or #repl[#repl]
        set_region(item, item.srow, item.scol, erow, ecol)
      end
    end
  end)
end

function M.collapse(where)
  local cur = state.session()
  if not cur then
    return
  end
  for _, item in ipairs(M.snapshot()) do
    if where == 'end' then
      set_region(item, item.erow, item.ecol, item.erow, item.ecol)
    else
      set_region(item, item.srow, item.scol, item.srow, item.scol)
    end
  end
end

function M.yank()
  local parts = {}
  local items = M.snapshot()
  for i = #items, 1, -1 do
    table.insert(parts, M.text_of(items[i]))
  end
  if #parts == 0 then
    return
  end
  vim.fn.setreg(vim.v.register or '"', table.concat(parts, '\n'), 'v')
end

function M.delete()
  M.yank()
  M.replace(function()
    return ''
  end)
  M.collapse 'start'
end

function M.delete_lines()
  local cur = state.session()
  if not cur then
    return
  end
  local rows, seen = {}, {}
  for _, item in ipairs(M.snapshot()) do
    for row = item.srow, item.erow do
      if not seen[row] then
        seen[row] = true
        table.insert(rows, row)
      end
    end
  end
  table.sort(rows, function(a, b)
    return a > b
  end)
  M.atomic(function(join)
    for _, row in ipairs(rows) do
      join()
      pcall(api.nvim_buf_set_lines, cur.buf, row, row + 1, false, {})
    end
  end)
end

function M.paste(before)
  local reg = vim.fn.getreg(vim.v.register or '"')
  if reg == '' then
    return
  end
  M.replace(function(_, text)
    if text ~= '' then
      return reg
    end
    return before and reg or nil
  end)
  local cur = state.session()
  if not cur then
    return
  end
  if not before then
    local items = M.snapshot()
    M.atomic(function(join)
      for _, item in ipairs(items) do
        if item.srow == item.erow and item.scol == item.ecol then
          join()
          local col = math.min(item.scol + 1, #(api.nvim_buf_get_lines(cur.buf, item.srow, item.srow + 1, false)[1] or ''))
          pcall(api.nvim_buf_set_text, cur.buf, item.srow, col, item.srow, col, vim.split(reg, '\n', { plain = true }))
        end
      end
    end)
  end
end

function M.run_normal(cmd)
  local cur = state.session()
  if not cur or cmd == '' then
    return
  end
  local items = M.snapshot()
  M.atomic(function(join)
    for _, item in ipairs(items) do
      local row, col = state.clamp(cur.buf, item.srow, item.scol)
      if pcall(api.nvim_win_set_cursor, 0, { row + 1, col }) then
        join()
        pcall(vim.cmd, 'noautocmd silent! normal! ' .. cmd)
        local nrow, ncol = unpack(api.nvim_win_get_cursor(0))
        nrow, ncol = state.clamp(cur.buf, nrow - 1, ncol)
        api.nvim_buf_set_extmark(cur.buf, state.ns_pos, nrow, ncol, {
          id = item.region.id,
          end_row = nrow,
          end_col = ncol,
          right_gravity = false,
          end_right_gravity = true,
        })
      end
    end
  end)
  state.sort()
end

function M.run_macro(register)
  M.run_normal('@' .. register)
end

local function pad_at(cur, row, col, amount)
  api.nvim_buf_set_text(cur.buf, row, col, row, col, { string.rep(' ', amount) })
end

function M.align()
  local cur = state.session()
  if not cur then
    return
  end
  local items = M.snapshot()
  local target = 0
  for _, item in ipairs(items) do
    if item.scol > target then
      target = item.scol
    end
  end
  M.atomic(function(join)
    for _, item in ipairs(items) do
      local gap = target - item.scol
      if gap > 0 then
        join()
        pcall(pad_at, cur, item.srow, item.scol, gap)
      end
    end
  end)
  state.sort()
end

function M.align_char(ch)
  local cur = state.session()
  if not cur or ch == '' then
    return
  end
  local items = M.snapshot()
  local spots = {}
  local target = 0
  for _, item in ipairs(items) do
    local text = api.nvim_buf_get_lines(cur.buf, item.srow, item.srow + 1, false)[1] or ''
    local at = text:find(ch, item.scol + 1, true)
    if at then
      local col = at - 1
      spots[#spots + 1] = { row = item.srow, col = col }
      if col > target then
        target = col
      end
    end
  end
  table.sort(spots, function(a, b)
    if a.row ~= b.row then
      return a.row > b.row
    end
    return a.col > b.col
  end)
  M.atomic(function(join)
    for _, spot in ipairs(spots) do
      local gap = target - spot.col
      if gap > 0 then
        join()
        pcall(pad_at, cur, spot.row, spot.col, gap)
      end
    end
  end)
  state.sort()
end

function M.transform(fn)
  M.replace(function(_, text)
    if text == '' then
      return nil
    end
    return fn(text)
  end)
end

return M

local M = {}

local api = vim.api
local state = require 'rosavim.rosa_plugins.rosavisualmulti.state'
local edit = require 'rosavim.rosa_plugins.rosavisualmulti.edit'
local render = require 'rosavim.rosa_plugins.rosavisualmulti.render'

local pending = nil

local function line_len(buf, row)
  local l = api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  return l and #l or 0
end

local function entry_pos(item, key)
  if key == 'i' then
    return item.srow, item.scol
  end
  if key == 'a' then
    return item.erow, item.ecol
  end
  if key == 'I' then
    return item.srow, 0
  end
  return item.erow, nil
end

function M.begin(key)
  local cur = state.session()
  if not cur or #cur.regions == 0 then
    return
  end

  if key == 'c' then
    edit.replace(function()
      return ''
    end)
    edit.collapse 'start'
    key = 'i'
  end

  local items = edit.snapshot()
  local anchors = {}
  for _, item in ipairs(items) do
    local row, col = entry_pos(item, key)
    if col == nil then
      col = line_len(cur.buf, row)
    end
    row, col = state.clamp(cur.buf, row, col)
    api.nvim_buf_set_extmark(cur.buf, state.ns_pos, row, col, {
      id = item.region.id,
      end_row = row,
      end_col = col,
      right_gravity = false,
      end_right_gravity = false,
    })
    table.insert(anchors, { region = item.region, index = item.index, row = row, col = col })
  end

  local main = state.main()
  local mrow, mcol = state.range(main)
  if not mrow then
    return
  end

  pending = { buf = cur.buf, anchors = anchors, main_id = main.id, row = mrow, col = mcol }
  render.draw_pending(main.id)
  pcall(api.nvim_win_set_cursor, 0, { mrow + 1, mcol })
  vim.cmd 'startinsert'
end

local function capture(p)
  if not p or not api.nvim_buf_is_valid(p.buf) then
    return nil
  end
  local m = api.nvim_buf_get_extmark_by_id(p.buf, state.ns_pos, p.main_id, {})
  if not m or not m[1] then
    return nil
  end
  local arow, acol = m[1], m[2]
  local crow, ccol = unpack(api.nvim_win_get_cursor(0))
  crow = crow - 1
  local deleted = 0
  if arow == p.row and acol < p.col then
    deleted = p.col - acol
  end
  if crow < arow or (crow == arow and ccol < acol) then
    return { deleted = deleted, text = '' }
  end
  local ok, lines = pcall(api.nvim_buf_get_text, p.buf, arow, acol, crow, ccol, {})
  if not ok then
    return nil
  end
  return { deleted = deleted, text = table.concat(lines, '\n') }
end

function M.finish()
  local p = pending
  pending = nil
  if not p then
    return
  end
  local cur = state.session()
  if not cur or cur.buf ~= p.buf then
    return
  end
  local diff = capture(p)
  if not diff or (diff.deleted == 0 and diff.text == '') then
    render.draw()
    state.mark()
    return
  end

  local repl = vim.split(diff.text, '\n', { plain = true })
  local targets = {}
  for _, a in ipairs(p.anchors) do
    if a.region.id ~= p.main_id then
      local row, col = state.range(a.region)
      if row then
        table.insert(targets, { region = a.region, row = row, col = col })
      end
    end
  end
  table.sort(targets, function(x, y)
    if x.row ~= y.row then
      return x.row > y.row
    end
    return x.col > y.col
  end)

  edit.atomic(function(join)
    for _, t in ipairs(targets) do
      local row, col = t.row, t.col
      if diff.deleted > 0 then
        local from = math.max(0, col - diff.deleted)
        join()
        pcall(api.nvim_buf_set_text, p.buf, row, from, row, col, { '' })
        col = from
      end
      if diff.text ~= '' then
        join()
        pcall(api.nvim_buf_set_text, p.buf, row, col, row, col, repl)
      end
      local erow = row + #repl - 1
      local ecol = #repl == 1 and (col + #repl[1]) or #repl[#repl]
      api.nvim_buf_set_extmark(p.buf, state.ns_pos, erow, ecol, {
        id = t.region.id,
        end_row = erow,
        end_col = ecol,
        right_gravity = false,
        end_right_gravity = true,
      })
    end
  end)

  local crow, ccol = unpack(api.nvim_win_get_cursor(0))
  crow, ccol = state.clamp(p.buf, crow - 1, ccol)
  api.nvim_buf_set_extmark(p.buf, state.ns_pos, crow, ccol, {
    id = p.main_id,
    end_row = crow,
    end_col = ccol,
    right_gravity = false,
    end_right_gravity = true,
  })

  state.sort()
  render.draw()
  state.mark()
end

function M.pending()
  return pending ~= nil
end

function M.cancel()
  pending = nil
end

return M

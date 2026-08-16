local M = {}

local api = vim.api
local state = require 'rosavim.rosa_plugins.rosavisualmulti.state'

M.groups = {
  RosavmRegion = 'Visual',
  RosavmCursor = 'Cursor',
  RosavmMain = 'IncSearch',
}

function M.define()
  for group, link in pairs(M.groups) do
    if vim.tbl_isempty(api.nvim_get_hl(0, { name = group })) then
      api.nvim_set_hl(0, group, { link = link })
    end
  end
end

local function line_len(buf, row)
  local l = api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  return l and #l or 0
end

function M.clear()
  local cur = state.session()
  if cur and api.nvim_buf_is_valid(cur.buf) then
    api.nvim_buf_clear_namespace(cur.buf, state.ns_hl, 0, -1)
  end
end

function M.draw()
  local cur = state.session()
  if not cur then
    return
  end
  M.define()
  M.clear()
  for i, region in ipairs(cur.regions) do
    local srow, scol, erow, ecol = state.range(region)
    if srow then
      if srow ~= erow or scol ~= ecol then
        pcall(api.nvim_buf_set_extmark, cur.buf, state.ns_hl, srow, scol, {
          end_row = erow,
          end_col = ecol,
          hl_group = 'RosavmRegion',
          priority = 150,
        })
      end
      local hl = i == cur.index and 'RosavmMain' or 'RosavmCursor'
      local head_col = (srow == erow and scol == ecol) and scol or math.max(scol, ecol - 1)
      if head_col < line_len(cur.buf, erow) then
        pcall(api.nvim_buf_set_extmark, cur.buf, state.ns_hl, erow, head_col, {
          end_col = head_col + 1,
          hl_group = hl,
          priority = 200,
        })
      else
        pcall(api.nvim_buf_set_extmark, cur.buf, state.ns_hl, erow, head_col, {
          virt_text = { { ' ', hl } },
          virt_text_pos = 'overlay',
          priority = 200,
        })
      end
    end
  end
end

function M.draw_pending(skip_id)
  local cur = state.session()
  if not cur then
    return
  end
  M.define()
  M.clear()
  for _, region in ipairs(cur.regions) do
    if region.id ~= skip_id then
      local srow, scol, erow, ecol = state.range(region)
      if srow then
        local col = scol
        if col < line_len(cur.buf, srow) then
          pcall(api.nvim_buf_set_extmark, cur.buf, state.ns_hl, srow, col, {
            end_col = col + 1,
            hl_group = 'RosavmCursor',
            priority = 200,
          })
        else
          pcall(api.nvim_buf_set_extmark, cur.buf, state.ns_hl, srow, col, {
            virt_text = { { ' ', 'RosavmCursor' } },
            virt_text_pos = 'overlay',
            priority = 200,
          })
        end
      end
    end
  end
end

function M.status()
  local cur = state.session()
  if not cur then
    return ''
  end
  return ('%d/%d'):format(cur.index, #cur.regions)
end

return M

--- Rosatag - auto close and live rename html/jsx tags, part of Rosakit.
--- Text scanning only, no treesitter parser needed.
local M = {}

local api = vim.api
local config = require 'rosavim.rosa_plugins.rosatag.config'
local scan = require 'rosavim.rosa_plugins.rosatag.scan'

local NS = api.nvim_create_namespace 'rosatag'
local attached = {}
local marks = {}

M.filetypes = config.filetypes
M.supported = config.supported

local function in_macro()
  return vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= ''
end

local function editable(buf)
  return api.nvim_buf_is_valid(buf) and vim.bo[buf].modifiable and not vim.bo[buf].readonly
end

local function close_tag(buf)
  if not editable(buf) or buf ~= api.nvim_get_current_buf() then
    return
  end

  local cursor = api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  if col == 0 or api.nvim_get_current_line():sub(col, col) ~= '>' then
    return
  end

  local name = scan.tag_to_close(buf, row, col - 1)
  if not name then
    return
  end

  api.nvim_buf_set_text(buf, row, col, row, col, { '</' .. name .. '>' })
  api.nvim_win_set_cursor(0, { row + 1, col })
end

local function clear_marks(buf)
  if marks[buf] then
    marks[buf] = nil
    pcall(api.nvim_buf_clear_namespace, buf, NS, 0, -1)
  end
end

local function set_mark(buf, id, row, start_col, end_col)
  return api.nvim_buf_set_extmark(buf, NS, row, start_col, {
    id = id,
    end_row = row,
    end_col = end_col,
    right_gravity = false,
    end_right_gravity = true,
  })
end

local function get_mark(buf, id)
  local m = api.nvim_buf_get_extmark_by_id(buf, NS, id, { details = true })
  if not m or not m[1] or not m[3] or m[3].invalid or m[3].end_row ~= m[1] then
    return nil
  end
  return { row = m[1], start_col = m[2], end_col = m[3].end_col }
end

local function mark_text(buf, m)
  local ok, lines = pcall(api.nvim_buf_get_text, buf, m.row, m.start_col, m.row, m.end_col, {})
  if not ok then
    return nil
  end
  return lines[1]
end

local function cursor_inside(m, row, col)
  return m ~= nil and row == m.row and col >= m.start_col and col <= m.end_col
end

local function update_marks(buf)
  if buf ~= api.nvim_get_current_buf() then
    return
  end

  local cursor = api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local tag = scan.name_at(api.nvim_get_current_line(), col)
  if not tag or tag.name == '' then
    return clear_marks(buf)
  end

  tag.row = row
  local other = scan.pair_of(buf, tag)
  if not other then
    return clear_marks(buf)
  end

  clear_marks(buf)
  marks[buf] = {
    a = set_mark(buf, nil, tag.row, tag.start_col, tag.end_col),
    b = set_mark(buf, nil, other.row, other.start_col, other.end_col),
  }
end

local function refresh_marks(buf)
  local ids = marks[buf]
  if ids then
    local cursor = api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]
    if cursor_inside(get_mark(buf, ids.a), row, col) or cursor_inside(get_mark(buf, ids.b), row, col) then
      return
    end
  end
  update_marks(buf)
end

local function sync_marks(buf)
  local ids = marks[buf]
  if not ids or not editable(buf) then
    return
  end

  local a, b = get_mark(buf, ids.a), get_mark(buf, ids.b)
  if not a or not b then
    return clear_marks(buf)
  end

  local cursor = api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local src_id, src, dst
  if cursor_inside(a, row, col) then
    src_id, src, dst = ids.a, a, b
  elseif cursor_inside(b, row, col) then
    src_id, src, dst = ids.b, b, a
  else
    return
  end

  local text = mark_text(buf, src)
  if text == nil then
    return clear_marks(buf)
  end

  -- A space starts the attribute list: keep the name, drop the rest.
  local name = text:match '^[%w_%-%.:]*'
  if name ~= text then
    if name == '' or not text:sub(#name + 1, #name + 1):match '%s' then
      return clear_marks(buf)
    end
    set_mark(buf, src_id, src.row, src.start_col, src.start_col + #name)
    text = name
  end

  if mark_text(buf, dst) ~= text then
    pcall(api.nvim_buf_set_text, buf, dst.row, dst.start_col, dst.row, dst.end_col, { text })
  end
end

--- @return boolean success
function M.rename()
  local buf = api.nvim_get_current_buf()
  if not editable(buf) then
    return false
  end

  local cursor = api.nvim_win_get_cursor(0)
  local tag = scan.name_at(api.nvim_get_current_line(), cursor[2])
  if not tag or tag.name == '' then
    Snacks.notify.warn 'Rosatag: no tag under the cursor'
    return false
  end

  tag.row = cursor[1] - 1
  local other = scan.pair_of(buf, tag, scan.PAIR_LINES_MANUAL)
  clear_marks(buf)

  vim.ui.input({ prompt = 'Tag: ', default = tag.name }, function(input)
    if not input or input == '' or input == tag.name then
      return
    end
    if not input:match '^[%w_%-%.:]+$' then
      Snacks.notify.warn 'Rosatag: invalid tag name'
      return
    end
    if not editable(buf) then
      return
    end

    local first, second = tag, other
    if other and (other.row > tag.row or (other.row == tag.row and other.start_col > tag.start_col)) then
      first, second = other, tag
    end

    pcall(api.nvim_buf_set_text, buf, first.row, first.start_col, first.row, first.end_col, { input })
    if second then
      pcall(api.nvim_buf_set_text, buf, second.row, second.start_col, second.row, second.end_col, { input })
    end
  end)

  return true
end

function M.attach(buf)
  if not api.nvim_buf_is_valid(buf) then
    return
  end
  attached[buf] = true

  local group = api.nvim_create_augroup('rosatag_buf_' .. buf, { clear = true })

  vim.keymap.set('n', '<leader>kr', M.rename, { buffer = buf, desc = 'Rosakit: Rename Tag' })

  if config.close_enabled() then
    api.nvim_create_autocmd('InsertCharPre', {
      group = group,
      buffer = buf,
      callback = function()
        if vim.v.char ~= '>' or in_macro() then
          return
        end
        vim.schedule(function()
          close_tag(buf)
        end)
      end,
    })
  end

  if config.rename_enabled() then
    api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      group = group,
      buffer = buf,
      callback = vim.schedule_wrap(function()
        if api.nvim_buf_is_valid(buf) and buf == api.nvim_get_current_buf() and not in_macro() then
          refresh_marks(buf)
        end
      end),
    })
    api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
      group = group,
      buffer = buf,
      callback = function()
        if not in_macro() then
          sync_marks(buf)
        end
      end,
    })
  else
    clear_marks(buf)
  end

  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = buf,
    callback = function()
      attached[buf] = nil
      marks[buf] = nil
      vim.schedule(function()
        pcall(api.nvim_del_augroup_by_name, 'rosatag_buf_' .. buf)
      end)
    end,
  })
end

function M.refresh()
  for buf in pairs(attached) do
    if api.nvim_buf_is_valid(buf) then
      M.attach(buf)
    else
      attached[buf] = nil
      marks[buf] = nil
    end
  end
end

function M.setup()
  local group = api.nvim_create_augroup('rosatag', { clear = true })

  api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = config.filetypes,
    callback = function(ev)
      M.attach(ev.buf)
    end,
  })

  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and config.supported(vim.bo[buf].filetype) then
      M.attach(buf)
    end
  end
end

return M

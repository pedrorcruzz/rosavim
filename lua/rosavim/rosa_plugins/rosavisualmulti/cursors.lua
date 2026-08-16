local M = {}

local api = vim.api
local state = require 'rosavim.rosa_plugins.rosavisualmulti.state'
local render = require 'rosavim.rosa_plugins.rosavisualmulti.render'

local function line(buf, row)
  return api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''
end

local function word_under_cursor()
  local buf = api.nvim_get_current_buf()
  local row, col = unpack(api.nvim_win_get_cursor(0))
  row = row - 1
  local text = line(buf, row)
  if text == '' then
    return nil
  end
  local s, e = nil, nil
  local i = col + 1
  if not text:sub(i, i):match '[%w_]' then
    while i <= #text and not text:sub(i, i):match '[%w_]' do
      i = i + 1
    end
    if i > #text then
      return nil
    end
  end
  s = i
  while s > 1 and text:sub(s - 1, s - 1):match '[%w_]' do
    s = s - 1
  end
  e = i
  while e < #text and text:sub(e + 1, e + 1):match '[%w_]' do
    e = e + 1
  end
  return row, s - 1, e, text:sub(s, e)
end

local function escape(word)
  return word:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%1')
end

local function regex_matches(cur)
  local out = {}
  local ok, re = pcall(vim.regex, cur.pattern)
  if not ok then
    return out
  end
  local total = api.nvim_buf_line_count(cur.buf)
  for row = 0, total - 1 do
    local text = line(cur.buf, row)
    local init = 0
    while init <= #text do
      local s, e = re:match_str(text:sub(init + 1))
      if not s then
        break
      end
      local scol, ecol = init + s, init + e
      if ecol <= scol then
        init = scol + 1
      else
        table.insert(out, { row = row, scol = scol, ecol = ecol })
        init = ecol
      end
    end
  end
  return out
end

local function matches(cur)
  local out = {}
  if not cur.pattern then
    return out
  end
  if cur.regex then
    return regex_matches(cur)
  end
  local pat = escape(cur.pattern)
  if cur.whole_word then
    pat = '%f[%w_]' .. pat .. '%f[^%w_]'
  end
  local lines = api.nvim_buf_get_lines(cur.buf, 0, -1, false)
  for row, text in ipairs(lines) do
    local init = 1
    while true do
      local s, e = text:find(pat, init)
      if not s then
        break
      end
      table.insert(out, { row = row - 1, scol = s - 1, ecol = e })
      init = e + 1
      if e < s then
        init = s + 1
      end
    end
  end
  return out
end

local function focus(region)
  local srow, scol, erow, ecol = state.range(region)
  if not srow then
    return
  end
  local head = (srow == erow and scol == ecol) and scol or math.max(scol, ecol - 1)
  pcall(api.nvim_win_set_cursor, 0, { erow + 1, head })
end

function M.sync()
  state.sort()
  render.draw()
  state.mark()
  local main = state.main()
  if main then
    focus(main)
  end
end

function M.find_under()
  local cur = state.session()
  if not cur or not cur.pattern then
    local row, scol, ecol, word = word_under_cursor()
    if not word then
      return
    end
    cur = state.start()
    cur.pattern = word
    cur.whole_word = true
    cur.regex = false
    state.add(row, scol, row, ecol)
    M.sync()
    return
  end
  M.next_occurrence()
end

function M.next_occurrence()
  local cur = state.session()
  if not cur or not cur.pattern then
    return
  end
  local taken = {}
  for _, r in ipairs(cur.regions) do
    local row, col = state.range(r)
    if row then
      taken[row .. ':' .. col] = true
    end
  end
  local main = state.main()
  local from_row, from_col = 0, 0
  if main then
    local r, c = state.range(main)
    from_row, from_col = r or 0, c or 0
  end
  local all = matches(cur)
  local pick = nil
  for _, m in ipairs(all) do
    if not taken[m.row .. ':' .. m.scol] and (m.row > from_row or (m.row == from_row and m.scol > from_col)) then
      pick = m
      break
    end
  end
  if not pick then
    for _, m in ipairs(all) do
      if not taken[m.row .. ':' .. m.scol] then
        pick = m
        break
      end
    end
  end
  if not pick then
    return
  end
  state.add(pick.row, pick.scol, pick.row, pick.ecol)
  M.sync()
end

function M.prev_occurrence()
  local cur = state.session()
  if not cur or not cur.pattern then
    return
  end
  local taken = {}
  for _, r in ipairs(cur.regions) do
    local row, col = state.range(r)
    if row then
      taken[row .. ':' .. col] = true
    end
  end
  local main = state.main()
  local from_row, from_col = 0, 0
  if main then
    local r, c = state.range(main)
    from_row, from_col = r or 0, c or 0
  end
  local all = matches(cur)
  local pick = nil
  for _, m in ipairs(all) do
    if not taken[m.row .. ':' .. m.scol] and (m.row < from_row or (m.row == from_row and m.scol < from_col)) then
      pick = m
    end
  end
  if not pick then
    for i = #all, 1, -1 do
      if not taken[all[i].row .. ':' .. all[i].scol] then
        pick = all[i]
        break
      end
    end
  end
  if not pick then
    return
  end
  state.add(pick.row, pick.scol, pick.row, pick.ecol)
  M.sync()
end

function M.select_all()
  local cur = state.session()
  if not cur or not cur.pattern then
    local row, scol, ecol, word = word_under_cursor()
    if not word then
      return
    end
    cur = state.start()
    cur.pattern = word
    cur.whole_word = true
    cur.regex = false
    state.add(row, scol, row, ecol)
  end
  local batch = {}
  for _, m in ipairs(matches(cur)) do
    table.insert(batch, { srow = m.row, scol = m.scol, erow = m.row, ecol = m.ecol })
  end
  state.add_many(batch)
  M.sync()
end

function M.from_regex(pattern)
  if not pattern or pattern == '' then
    return
  end
  local cur = state.start()
  cur.pattern = pattern
  cur.regex = true
  cur.whole_word = false
  local batch = {}
  for _, m in ipairs(matches(cur)) do
    table.insert(batch, { srow = m.row, scol = m.scol, erow = m.row, ecol = m.ecol })
  end
  if #batch == 0 then
    if #cur.regions == 0 then
      state.stop()
    end
    return
  end
  state.add_many(batch)
  M.sync()
end

local function vertical(step)
  local buf = api.nvim_get_current_buf()
  local row, col = unpack(api.nvim_win_get_cursor(0))
  row = row - 1
  local cur = state.session()
  if not cur or #cur.regions == 0 then
    cur = state.start()
    state.add(row, col, row, col)
  end
  local edge = nil
  for _, r in ipairs(cur.regions) do
    local rrow = state.range(r)
    if rrow and (edge == nil or (step > 0 and rrow > edge) or (step < 0 and rrow < edge)) then
      edge = rrow
    end
  end
  local target = (edge or row) + step
  if target < 0 or target >= api.nvim_buf_line_count(buf) then
    return
  end
  local trow, tcol = state.clamp(buf, target, col)
  state.add(trow, tcol, trow, tcol)
  M.sync()
end

function M.add_down()
  vertical(1)
end

function M.add_up()
  vertical(-1)
end

function M.from_visual()
  local srow = vim.fn.line 'v' - 1
  local erow = vim.fn.line '.' - 1
  local scol = vim.fn.col 'v' - 1
  local ecol = vim.fn.col '.' - 1
  api.nvim_feedkeys(api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
  if srow > erow then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end
  local buf = api.nvim_get_current_buf()
  state.start()
  if srow == erow then
    local a, b = math.min(scol, ecol), math.max(scol, ecol) + 1
    state.add(srow, a, srow, b)
  else
    local col = math.min(scol, ecol)
    local batch = {}
    for row = srow, erow do
      local r, c = state.clamp(buf, row, col)
      table.insert(batch, { srow = r, scol = c, erow = r, ecol = c })
    end
    state.add_many(batch)
  end
  M.sync()
end

function M.goto_next()
  local cur = state.session()
  if not cur or #cur.regions == 0 then
    return
  end
  cur.index = cur.index % #cur.regions + 1
  M.sync()
end

function M.goto_prev()
  local cur = state.session()
  if not cur or #cur.regions == 0 then
    return
  end
  cur.index = (cur.index - 2) % #cur.regions + 1
  M.sync()
end

function M.skip()
  local cur = state.session()
  if not cur or #cur.regions == 0 then
    return
  end
  local victim = cur.regions[cur.index]
  local before = #cur.regions
  M.next_occurrence()
  cur = state.session()
  if not cur or #cur.regions <= before then
    return
  end
  local idx = state.index_of(victim)
  if idx then
    state.remove(idx)
    M.sync()
  end
end

function M.remove_current()
  local cur = state.session()
  if not cur or #cur.regions == 0 then
    return
  end
  state.remove(cur.index)
  if state.session() then
    M.sync()
  end
end

return M

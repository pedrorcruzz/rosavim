--- Rosatag scanner - plain-text tag lookup
local M = {}

local api = vim.api

--- @class Rosatag.Tag
--- @field name string
--- @field row integer 0-indexed
--- @field start_col integer 0-indexed, first byte of the name
--- @field end_col integer 0-indexed, one past the last byte of the name
--- @field closing boolean

local NAME = '^([%w_%-%.:]*)'
local TAG_LINES = 30

--- The live path runs on cursor moves, so it reads less than a manual rename.
M.PAIR_LINES = 400
M.PAIR_LINES_MANUAL = 5000

local VOID = {
  area = true,
  base = true,
  br = true,
  col = true,
  embed = true,
  hr = true,
  img = true,
  input = true,
  link = true,
  meta = true,
  param = true,
  source = true,
  track = true,
  wbr = true,
}

--- Tag the `>` at (row, col) just finished, when it needs a closing partner.
--- Bails on closing/self-closing/void/doctype and on anything ambiguous
--- (a stray `<` or `>` inside an attribute value).
--- @return string|nil
function M.tag_to_close(buf, row, col)
  local first = math.max(0, row - TAG_LINES)
  local lines = api.nvim_buf_get_lines(buf, first, row + 1, false)
  if #lines == 0 then
    return nil
  end
  lines[#lines] = lines[#lines]:sub(1, col + 1)

  local inner = table.concat(lines, '\n'):match '<([^<>]*)>$'
  if not inner or inner == '' or inner:sub(-1) == '/' then
    return nil
  end

  local name = inner:match(NAME)
  if not name or name == '' or VOID[name:lower()] then
    return nil
  end
  return name
end

--- Tag name the cursor sits in. A name never spans lines.
--- @return Rosatag.Tag|nil
function M.name_at(line, col)
  local init = 1
  while true do
    local s = line:find('<', init, true)
    if not s then
      return nil
    end
    local closing = line:sub(s + 1, s + 1) == '/'
    local ns = s + (closing and 2 or 1)
    local name = line:sub(ns):match(NAME)
    local start_col, end_col = ns - 1, ns - 1 + #name
    if col >= start_col and col <= end_col then
      return { name = name, start_col = start_col, end_col = end_col, closing = closing }
    end
    init = s + 1
  end
end

--- Every `<name` / `</name` on the line, left to right.
local function occurrences(line, name)
  local out = {}
  local init = 1
  while true do
    local s = line:find('<', init, true)
    if not s then
      return out
    end
    local closing = line:sub(s + 1, s + 1) == '/'
    local ns = s + (closing and 2 or 1)
    if line:sub(ns):match(NAME) == name then
      local after = line:sub(ns + #name, ns + #name)
      if after == '' or after:match '[%s/>]' then
        out[#out + 1] = { col = s - 1, start_col = ns - 1, closing = closing }
      end
    end
    init = s + 1
  end
end

--- Whether the tag opening at (row, col) ends in `/>`.
--- `win` (optional): lines already fetched by the caller, starting at
--- 0-indexed row `win.base` - reused so each occurrence does not cost an
--- extra API read. Falls back to reading when the range is not covered.
local function self_closing(buf, row, col, win)
  local stop = math.min(api.nvim_buf_line_count(buf), row + 1 + TAG_LINES)
  local lines, first_idx
  if win and row >= win.base and stop <= win.base + #win.lines then
    lines, first_idx = win.lines, row - win.base + 1
  else
    lines, first_idx = api.nvim_buf_get_lines(buf, row, stop, false), 1
  end
  for i = first_idx, first_idx + (stop - row) - 1 do
    local line = lines[i]
    if not line then
      break
    end
    local s = line:find('>', i == first_idx and col + 1 or 1, true)
    if s then
      return line:sub(s - 1, s - 1) == '/'
    end
  end
  return false
end

--- Matching partner of `tag`, skipping self-closed and nested same-name tags.
--- @param tag Rosatag.Tag
--- @param limit integer|nil lines to read in each direction
--- @return Rosatag.Tag|nil
function M.pair_of(buf, tag, limit)
  if tag.name == '' then
    return nil
  end
  local depth = 0
  local PAIR_LINES = limit or M.PAIR_LINES

  if not tag.closing then
    local stop = math.min(api.nvim_buf_line_count(buf), tag.row + 1 + PAIR_LINES)
    local lines = api.nvim_buf_get_lines(buf, tag.row, stop, false)
    local win = { base = tag.row, lines = lines }
    for i, line in ipairs(lines) do
      local row = tag.row + i - 1
      for _, occ in ipairs(occurrences(line, tag.name)) do
        if row ~= tag.row or occ.start_col > tag.start_col then
          if occ.closing then
            if depth == 0 then
              return {
                name = tag.name,
                row = row,
                start_col = occ.start_col,
                end_col = occ.start_col + #tag.name,
                closing = true,
              }
            end
            depth = depth - 1
          elseif not self_closing(buf, row, occ.col, win) then
            depth = depth + 1
          end
        end
      end
    end
    return nil
  end

  local first = math.max(0, tag.row - PAIR_LINES)
  local lines = api.nvim_buf_get_lines(buf, first, tag.row + 1, false)
  local win = { base = first, lines = lines }
  for i = #lines, 1, -1 do
    local row = first + i - 1
    local occs = occurrences(lines[i], tag.name)
    for j = #occs, 1, -1 do
      local occ = occs[j]
      if row ~= tag.row or occ.start_col < tag.start_col then
        if occ.closing then
          depth = depth + 1
        elseif not self_closing(buf, row, occ.col, win) then
          if depth == 0 then
            return {
              name = tag.name,
              row = row,
              start_col = occ.start_col,
              end_col = occ.start_col + #tag.name,
              closing = false,
            }
          end
          depth = depth - 1
        end
      end
    end
  end
  return nil
end

return M

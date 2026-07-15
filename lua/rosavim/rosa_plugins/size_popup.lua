--- Shared rosa-style size popup for rosaterm & rosaai.
---
--- Mirrors the dashboard-gif config popup (<leader>lqdc): a small centered
--- float that STAYS OPEN while you tweak values. Instead of one global size,
--- each display mode is configured independently:
---   f  cycle Float size       (compact → default → wide → …)
---   v  cycle Vertical size
---   h  cycle Horizontal size
---   a  cycle All three at once
--- Every keypress cycles the preset in place and applies it live (real-time),
--- so e.g. the vertical split can be Compact while the float stays Wide.
---
--- Driven by a spec so both plugins reuse it:
---   { title, name, list, get(mode), set(mode, presetName), apply(mode) }
--- where `mode` is 'float' | 'vertical' | 'horizontal' (or 'all' for apply()).
local M = {}

local api = vim.api
local ns = api.nvim_create_namespace 'rosasizepopup'

local MODES = { 'float', 'vertical', 'horizontal' }
local ROW_LABELS = { float = 'Float', vertical = 'Vertical', horizontal = 'Horizontal' }

local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  api.nvim_set_hl(0, 'RosaSizeTitle', { fg = p.title, bold = true })
  api.nvim_set_hl(0, 'RosaSizeBorder', { fg = p.border })
  api.nvim_set_hl(0, 'RosaSizeKey', { fg = p.key, bold = true })
  api.nvim_set_hl(0, 'RosaSizeAction', { fg = p.text })
  api.nvim_set_hl(0, 'RosaSizeValue', { fg = p.pink, bold = true })
  api.nvim_set_hl(0, 'RosaSizeDim', { fg = p.dim })
end

local function create_float(opts)
  local width = opts.width or 52
  local height = opts.height or 14
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = api.nvim_create_buf(false, true)
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = opts.title,
    title_pos = 'center',
    footer = opts.footer,
    footer_pos = opts.footer and 'center' or nil,
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosaSizeBorder,FloatTitle:RosaSizeTitle,FloatFooter:RosaSizeDim'
  vim.bo[buf].bufhidden = 'wipe'
  return buf, win
end

--- Resolve a preset's display label from its name.
local function label_of(list, name)
  for _, s in ipairs(list) do
    if s.name == name then
      return (s.icon or '') .. s.label
    end
  end
  return name or '?'
end

--- Next preset name after `name` in the list (wraps around).
local function next_name(list, name)
  local idx = 1
  for i, s in ipairs(list) do
    if s.name == name then
      idx = i
      break
    end
  end
  return list[(idx % #list) + 1].name
end

--- The common preset across all modes, or nil when they differ ("mixed").
local function combined(spec)
  local first = spec.get 'float'
  for _, mode in ipairs(MODES) do
    if spec.get(mode) ~= first then
      return nil
    end
  end
  return first
end

function M.open(spec)
  setup_highlights()

  local pad = '   '
  local gap = '  '
  local label_w = 13

  local buf, win

  local function render()
    local lines, hls, ln = {}, {}, 0
    local function add(text)
      table.insert(lines, text)
      ln = ln + 1
    end
    local function hl(group, col_s, col_e)
      table.insert(hls, { group, ln - 1, col_s, col_e })
    end

    add ''
    add(pad .. string.rep('─', 34))
    hl('RosaSizeDim', #pad, -1)

    -- One row per mode: label + current preset value
    for _, mode in ipairs(MODES) do
      local label = ROW_LABELS[mode]
      local value = label_of(spec.list, spec.get(mode))
      add(pad .. label .. string.rep(' ', label_w - #label) .. value)
      hl('RosaSizeAction', #pad, #pad + label_w)
      hl('RosaSizeValue', #pad + label_w, -1)
    end

    add(pad .. string.rep('─', 34))
    hl('RosaSizeDim', #pad, -1)

    -- "All" summary row (shows the shared preset or "mixed")
    local all = combined(spec)
    local all_val = all and label_of(spec.list, all) or '— mixed'
    add(pad .. 'All' .. string.rep(' ', label_w - #'All') .. all_val)
    hl('RosaSizeAction', #pad, #pad + label_w)
    hl(all and 'RosaSizeValue' or 'RosaSizeDim', #pad + label_w, -1)

    add(pad .. string.rep('─', 34))
    hl('RosaSizeDim', #pad, -1)

    add ''

    local actions = {
      { key = 'f', label = 'cycle float' },
      { key = 'v', label = 'cycle vertical' },
      { key = 'h', label = 'cycle horizontal' },
      { key = 'a', label = 'cycle all' },
    }
    for _, a in ipairs(actions) do
      add(pad .. a.key .. gap .. a.label)
      hl('RosaSizeKey', #pad, #pad + #a.key)
      hl('RosaSizeAction', #pad + #a.key + #gap, -1)
    end

    add ''

    vim.bo[buf].modifiable = true
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for _, h in ipairs(hls) do
      api.nvim_buf_add_highlight(buf, ns, h[1], h[2], h[3] or 0, h[4] or -1)
    end
  end

  buf, win = create_float {
    title = spec.title,
    footer = ' q: close ',
    width = 52,
    height = 15,
  }
  render()

  local kopts = { buffer = buf, silent = true, nowait = true }
  local function close()
    if api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set('n', 'q', close, kopts)
  vim.keymap.set('n', '<Esc>', close, kopts)

  local function cycle_mode(mode)
    local nxt = next_name(spec.list, spec.get(mode))
    spec.set(mode, nxt)
    spec.apply(mode)
    render()
  end

  vim.keymap.set('n', 'f', function()
    cycle_mode 'float'
  end, kopts)
  vim.keymap.set('n', 'v', function()
    cycle_mode 'vertical'
  end, kopts)
  vim.keymap.set('n', 'h', function()
    cycle_mode 'horizontal'
  end, kopts)
  vim.keymap.set('n', 'a', function()
    -- Base the cycle on the shared value (or 'default' when modes differ),
    -- then set every mode to the next preset.
    local base = combined(spec) or 'default'
    local nxt = next_name(spec.list, base)
    for _, mode in ipairs(MODES) do
      spec.set(mode, nxt)
    end
    spec.apply 'all'
    render()
  end, kopts)
end

return M

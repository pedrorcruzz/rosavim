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

local menu = require 'rosavim.helpers.rosa_menu'

local MODES = { 'float', 'vertical', 'horizontal' }
local ROW_LABELS = { float = 'Float', vertical = 'Vertical', horizontal = 'Horizontal' }

local function setup_highlights()
  require('rosavim.helpers.palette').define('RosaSize', function(p)
    return {
      Title = { fg = p.title, bold = true },
      Border = { fg = p.border },
      Key = { fg = p.key, bold = true },
      Action = { fg = p.text },
      Value = { fg = p.pink, bold = true },
      Dim = { fg = p.dim },
    }
  end)
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

  local buf

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

    menu.set_content(buf, lines, hls)
  end

  local function cycle_mode(mode)
    local nxt = next_name(spec.list, spec.get(mode))
    spec.set(mode, nxt)
    spec.apply(mode)
    render()
  end

  local ctx = menu.open {
    title = spec.title,
    footer = ' q: close ',
    width = 52,
    height = 15,
    hl_prefix = 'RosaSize',
    keys = {
      {
        'n',
        'f',
        function()
          cycle_mode 'float'
        end,
      },
      {
        'n',
        'v',
        function()
          cycle_mode 'vertical'
        end,
      },
      {
        'n',
        'h',
        function()
          cycle_mode 'horizontal'
        end,
      },
      {
        'n',
        'a',
        function()
          -- Base the cycle on the shared value (or 'default' when modes differ),
          -- then set every mode to the next preset.
          local base = combined(spec) or 'default'
          local nxt = next_name(spec.list, base)
          for _, mode in ipairs(MODES) do
            spec.set(mode, nxt)
          end
          spec.apply 'all'
          render()
        end,
      },
    },
  }
  buf = ctx.buf
  render()
end

return M

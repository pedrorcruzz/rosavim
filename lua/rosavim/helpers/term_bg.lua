local M = {}

local api = vim.api

--- One entry per tool that can be pinned to a black surface. `refresh` is the
--- extra work a tool needs to pick the new bg up live, beyond redefining its
--- highlight group (yazi needs none — define() covers it).
M.tools = {
  rosaterm = {
    key = 'rosaterm_dark_bg',
    name = 'Rosaterm',
    default_on = true,
    group = 'RosatermNormal',
    base = 'Normal',
    refresh = function()
      local ok, rosaterm = pcall(require, 'rosavim.rosa_plugins.rosaterm')
      if ok then
        rosaterm.refresh_bg()
      end
    end,
  },
  rosaai = {
    key = 'rosaai_dark_bg',
    name = 'RosaAI',
    default_on = true,
    group = 'RosaaiNormal',
    base = 'Normal',
    refresh = function()
      local ok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if ok then
        rosaai.relayout()
      end
    end,
  },
  yazi = { key = 'yazi_dark_bg', name = 'Yazi', default_on = true, group = 'YaziFloat', base = 'Normal' },
  lazygit = {
    key = 'lazygit_dark_bg',
    name = 'Lazygit',
    default_on = true,
    group = 'RosaLazygitNormal',
    base = function()
      return vim.g.colors_name == 'rosanight' and 'Normal' or 'NormalFloat'
    end,
    refresh = function()
      require('rosavim.helpers.lazygit_theme').refresh()
    end,
  },
}

--- Fixed order for the All toggles, so they always walk the tools the same way.
M.order = { 'rosaterm', 'rosaai', 'yazi', 'lazygit' }

--- Persisted toggle key for a tool in `mode` ('light' | 'dark'). The dark-mode
--- switch is the light one with a `_dm` suffix.
function M.key(tool, mode)
  local spec = M.tools[tool]
  if not spec then
    return nil
  end
  return spec.key .. (mode == 'dark' and '_dm' or '')
end

--- Re-paint one tool after its toggle flipped: the highlight group, plus the
--- tool's own live-refresh step.
function M.refresh_tool(tool)
  local spec = M.tools[tool]
  if not spec then
    return
  end
  M.define(tool)
  if spec.refresh then
    spec.refresh()
  end
end

--- Whether every tool is forced black in `mode` (backs the All toggles, so they
--- read as on only once the last tool is on).
function M.all_enabled(mode)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return false
  end
  for _, tool in ipairs(M.order) do
    if toggles.get(M.key(tool, mode)) ~= true then
      return false
    end
  end
  return true
end

--- Flip every tool at once for `mode`, then repaint them all.
function M.set_all(mode, state)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return
  end
  for _, tool in ipairs(M.order) do
    toggles.set(M.key(tool, mode), state)
  end
  for _, tool in ipairs(M.order) do
    M.refresh_tool(tool)
  end
end

function M.is_black(tool)
  local spec = M.tools[tool]
  if not spec then
    return false
  end
  local light_on = spec.default_on
  local dark_on = false
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if ok then
    local lv = toggles.get(spec.key)
    if lv ~= nil then
      light_on = lv
    end
    local dv = toggles.get(spec.key .. '_dm')
    if dv ~= nil then
      dark_on = dv
    end
  end
  if vim.o.background == 'light' then
    return light_on
  end
  return dark_on
end

M.CHIP_HL = 'RosaChipNormal'

M.BORDER_HL = { rosaterm = 'RosatermFloatBorder', rosaai = 'RosaaiFloatBorder' }

local function link_if_unset(group, target)
  if vim.tbl_isempty(api.nvim_get_hl(0, { name = group })) then
    api.nvim_set_hl(0, group, { link = target })
  end
end

function M.define(tool)
  local spec = M.tools[tool]
  if not spec then
    return
  end
  if M.is_black(tool) then
    api.nvim_set_hl(0, spec.group, { bg = '#000000', fg = '#d4d0c8' })
  else
    api.nvim_set_hl(0, spec.group, { link = type(spec.base) == 'function' and spec.base() or spec.base })
  end
end

function M.refresh()
  for tool in pairs(M.tools) do
    M.define(tool)
  end
  link_if_unset(M.CHIP_HL, 'Normal')
end

function M.winhl(tool, extra)
  M.define(tool)
  return 'Normal:' .. M.tools[tool].group .. (extra or '')
end

function M.float_winhl(tool)
  M.define(tool)
  local group = M.tools[tool].group
  return ('Normal:%s,NormalFloat:%s,FloatBorder:FloatBorder'):format(group, group)
end

function M.border_hl(tool)
  local group = M.BORDER_HL[tool]
  if not group then
    return 'FloatBorder'
  end
  link_if_unset(group, 'FloatBorder')
  return group
end

function M.chip_winhl(tool)
  link_if_unset(M.CHIP_HL, 'Normal')
  return 'Normal:' .. M.CHIP_HL .. ',FloatBorder:' .. M.border_hl(tool)
end

return M

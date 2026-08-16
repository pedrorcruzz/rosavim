local M = {}

local api = vim.api

M.tools = {
  rosaterm = { key = 'rosaterm_dark_bg', default_on = true, group = 'RosatermNormal', base = 'Normal' },
  rosaai = { key = 'rosaai_dark_bg', default_on = true, group = 'RosaaiNormal', base = 'Normal' },
  yazi = { key = 'yazi_dark_bg', default_on = true, group = 'YaziFloat', base = 'Normal' },
  lazygit = {
    key = 'lazygit_dark_bg',
    default_on = true,
    group = 'RosaLazygitNormal',
    base = function()
      return vim.g.colors_name == 'rosanight' and 'Normal' or 'NormalFloat'
    end,
  },
}

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

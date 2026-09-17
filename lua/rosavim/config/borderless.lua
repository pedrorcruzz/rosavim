--- Borderless (<leader>lqn) - paint a tool's borders in its own bg so they
--- blend in. One persisted toggle per tool, plus All (<leader>lqna). Called
--- from the ColorScheme autocmd and from each theme's set_groups (lualine's
--- 'auto' re-sources a theme without firing ColorScheme). Must run after the
--- pass in colorscheme.lua that pins the BlinkCmp*Border colours.
local M = {}

--- Border groups per tool + the surfaces each one may sit on, most specific
--- first. `fallback` groups have no theme colour of their own, so turning the
--- toggle off has to link them back instead of leaving the blend behind.
--- `surface_first` groups wrap a window whose interior is a known group, so
--- that surface wins over whatever colour the border itself carries.
M.tools = {
  {
    key = 'borderless_whichkey',
    name = 'Which-Key',
    map = '<leader>lqnw',
    borders = { { 'WhichKeyBorder', { 'WhichKeyNormal', 'NormalFloat' } } },
  },
  {
    key = 'borderless_snacks',
    name = 'Snacks Picker',
    map = '<leader>lqns',
    borders = {
      { 'SnacksPickerBorder', { 'SnacksPicker', 'NormalFloat' } },
      { 'SnacksPickerInputBorder', { 'SnacksPickerInput', 'SnacksPicker', 'NormalFloat' }, surface_first = true },
      { 'SnacksPickerListBorder', { 'SnacksPickerList', 'SnacksPicker', 'NormalFloat' }, surface_first = true },
      { 'SnacksPickerPreviewBorder', { 'SnacksPickerPreview', 'SnacksPicker', 'NormalFloat' }, surface_first = true },
      { 'SnacksPickerBoxBorder', { 'SnacksPickerBox', 'SnacksPicker', 'NormalFloat' }, surface_first = true },
    },
  },
  {
    key = 'borderless_rosapick',
    name = 'Rosapick',
    map = '<leader>lqnp',
    borders = { { 'RosapickBorder', { 'Normal' } } },
  },
  {
    key = 'borderless_blink',
    name = 'Blink.cmp',
    map = '<leader>lqnb',
    borders = {
      { 'BlinkCmpMenuBorder', { 'BlinkCmpMenu', 'Pmenu', 'NormalFloat' } },
      { 'BlinkCmpDocBorder', { 'BlinkCmpDoc', 'Pmenu', 'NormalFloat' } },
      { 'BlinkCmpSignatureHelpBorder', { 'BlinkCmpSignatureHelp', 'Pmenu', 'NormalFloat' } },
    },
  },
  {
    key = 'borderless_rosaterm',
    name = 'Rosaterm',
    map = '<leader>lqnr',
    borders = { { 'RosatermFloatBorder', { 'RosatermNormal', 'Normal' }, fallback = 'FloatBorder' } },
  },
  {
    key = 'borderless_rosaai',
    name = 'RosaAI',
    map = '<leader>lqni',
    borders = { { 'RosaaiFloatBorder', { 'RosaaiNormal', 'Normal' }, fallback = 'FloatBorder' } },
  },
  {
    key = 'borderless_notify',
    name = 'Notify',
    map = '<leader>lqnn',
    borders = {
      { 'SnacksNotifierBorderInfo', { 'SnacksNotifierInfo', 'Normal' }, surface_first = true },
      { 'SnacksNotifierBorderWarn', { 'SnacksNotifierWarn', 'Normal' }, surface_first = true },
      { 'SnacksNotifierBorderError', { 'SnacksNotifierError', 'Normal' }, surface_first = true },
      { 'SnacksNotifierBorderDebug', { 'SnacksNotifierDebug', 'Normal' }, surface_first = true },
      { 'SnacksNotifierBorderTrace', { 'SnacksNotifierTrace', 'Normal' }, surface_first = true },
    },
  },
}

local function hl_of(group)
  return vim.api.nvim_get_hl(0, { name = group, link = false })
end

local function blend_bg(border, surfaces, surface_first)
  local bg
  if not surface_first then
    bg = hl_of(border).bg
    if bg then
      return bg
    end
  end
  for _, surface in ipairs(surfaces) do
    bg = hl_of(surface).bg
    if bg then
      return bg
    end
  end
end

--- @return boolean
function M.enabled(key)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  return ok and toggles.get(key) == true
end

--- Whether every tool is blended (backs the All toggle).
function M.all_enabled()
  for _, tool in ipairs(M.tools) do
    if not M.enabled(tool.key) then
      return false
    end
  end
  return true
end

function M.set_all(state)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return
  end
  local values = {}
  for _, tool in ipairs(M.tools) do
    values[tool.key] = state
  end
  toggles.set_many(values)
end

function M.apply()
  -- Transparent mode has no bg to blend into: approximate the terminal backdrop
  -- and leave the group bg-less, painting one would draw the frame back.
  local fallback_fg = hl_of('Normal').bg or (vim.o.background == 'light' and 0xffffff or 0x000000)

  for _, tool in ipairs(M.tools) do
    local on = M.enabled(tool.key)
    for _, spec in ipairs(tool.borders) do
      local group, surfaces = spec[1], spec[2]
      if on then
        local bg = blend_bg(group, surfaces, spec.surface_first)
        vim.api.nvim_set_hl(0, group, bg and { fg = bg, bg = bg } or { fg = fallback_fg })
      elseif spec.fallback then
        vim.api.nvim_set_hl(0, group, { link = spec.fallback })
      end
    end
  end
end

return M

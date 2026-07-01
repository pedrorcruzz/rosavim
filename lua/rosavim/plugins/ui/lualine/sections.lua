local M = {}

M.sep = {
  section = { left = '', right = '' },
  component = { left = '', right = '' },
  -- mode = { left = '', right = '' },
  -- location = { left = '', right = '' },
}
--- Lualine separator presets. `rounded` reuses the original M.sep default;
--- the active preset is persisted as `lualine_separator` (rosavim.config
--- .toggles) and chosen via <leader>lqg. Each `sep` feeds options
--- .section_separators / component_separators and the per-component
--- separators in M.build (mode / location stay unset). Glyphs are built
--- from nerd-font powerline codepoints via nr2char so the source stays
--- ASCII. `icon` is just the pair shown in the selector popup.
local function g(...)
  local out = {}
  for _, cp in ipairs { ... } do
    out[#out + 1] = vim.fn.nr2char(cp)
  end
  return table.concat(out)
end

M.presets = {
  { name = 'rounded', label = 'Rounded', icon = g(0xE0B6, 0xE0B4), sep = M.sep },
  {
    name = 'bar',
    label = 'Bar',
    icon = '| |',
    sep = { section = { left = '', right = '' }, component = { left = '|', right = '|' } },
  },
  {
    name = 'arrow',
    label = 'Arrow',
    icon = g(0xE0B0, 0xE0B2),
    sep = { section = { left = g(0xE0B0), right = g(0xE0B2) }, component = { left = g(0xE0B1), right = g(0xE0B3) } },
  },
  {
    name = 'slant',
    label = 'Slant',
    icon = g(0xE0BC, 0xE0BA),
    sep = { section = { left = g(0xE0BC), right = g(0xE0BA) }, component = { left = g(0xE0BD), right = g(0xE0BB) } },
  },
}

--- Return the sep table for the persisted preset (defaults to rounded).
function M.get_sep()
  local name = 'rounded'
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if ok then
    name = toggles.get 'lualine_separator' or name
  end
  for _, p in ipairs(M.presets) do
    if p.name == name then
      return p.sep
    end
  end
  return M.sep
end

function M.build(sep)
  return {
    lualine_a = {
      {
        'mode',
        fmt = function(mode)
          -- When focused on a RosaAI CLI terminal, brand the mode block
          -- instead of showing NORMAL/INSERT/TERMINAL.
          if vim.b.rosaai_cli then
            return '  ROSAAI'
          end
          return '󰧱 ' .. mode
        end,
        separator = sep.mode,
        -- separator = { left = '', right = '' },
        -- separator = { left = '', right = '' },
        right_padding = 10,
        color = { gui = 'bold' },
      },
    },
    lualine_b = { 'branch' },
    lualine_c = {
      {
        'diff',
        symbols = {
          added = ' ',
          modified = ' ',
          removed = ' ',
          untracked = '󰝤',
        },
        diff_color = {
          added = { fg = '#a6e3a1' },
          modified = { fg = '#89b4fa' },
          removed = { fg = '#f38ba8' },
        },
      },
    },
    lualine_x = {
      {
        'diagnostics',
        symbols = {
          error = ' ',
          warn = ' ',
          info = ' ',
          hint = ' ',
        },
      },
    },
    lualine_y = {
      'copilot',
      {
        'lsp_status',
        icon = ' ',
        symbols = {
          spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
          done = '✓',
          separator = ' ',
        },
        ignore_lsp = { 'copilot', 'tailwindcss' },
      },
      'progress',
      { 'filename', symbols = { modified = '●', readonly = '' } },
      'filetype',
      {
        function()
          local venv = os.getenv 'VIRTUAL_ENV'
          return venv and venv:match '([^/]+)$' and (' ' .. venv:match '([^/]+)$') or ''
        end,
        color = { fg = '#ffffff', gui = 'bold' },
        left_padding = 2,
      },
    },
    lualine_z = {
      { 'location', separator = sep.location, left_padding = 2 },
      -- { 'location', separator = { left = '', right = '' }, left_padding = 2 },
      -- { 'location', separator = { left = '', right = '' }, left_padding = 2 },
    },
  }
end

M.inactive_sections = {
  lualine_a = { 'filename' },
  lualine_b = {},
  lualine_c = {},
  lualine_x = {},
  lualine_y = {},
  lualine_z = { 'location' },
}

--- Re-apply the full lualine config live: current theme toggle + active
--- separator preset. Used by the separator selector (<leader>lqg) so a new
--- preset takes effect without restarting.
function M.reload()
  local ok, lualine = pcall(require, 'lualine')
  if not ok then
    return
  end
  local toggles = require 'rosavim.config.toggles'
  local theme = require 'rosavim.plugins.ui.lualine.theme'
  local sep = M.get_sep()
  lualine.setup {
    options = {
      theme = toggles.get 'lualine_theme' and theme.create() or 'auto',
      section_separators = sep.section,
      component_separators = sep.component,
      globalstatus = true,
    },
    sections = M.build(sep),
    inactive_sections = M.inactive_sections,
  }
  lualine.hide { unhide = toggles.get 'lualine' }
end

return M

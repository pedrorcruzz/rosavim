local M = {}

function M.build(sep)
  return {
    lualine_a = {
      {
        'mode',
        fmt = function(mode)
          return '󰅶 ' .. mode
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

return M

return {
  'brenoprata10/nvim-highlight-colors',
  event = 'BufReadPost',
  config = function()
    require('nvim-highlight-colors').setup {
      render = 'virtual', --foreground or background or virtual
      virtual_symbol = '■', -- ■ 
      virtual_symbol_prefix = '',
      virtual_symbol_suffix = ' ',
      virtual_symbol_position = 'inline', -- inline or eow (end of word) or eol (end of line)
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_ansi = true,
      enable_hsl_without_function = true,
      enable_var_usage = true,
      enable_named_colors = false,
      enable_tailwind = false,
      custom_colors = {
        { label = '%-%-theme%-primary%-color', color = '#0f1219' },
        { label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
      },
      exclude_filetypes = {},
      exclude_buftypes = {},
      exclude_buffer = function(bufnr)
        return false
      end,
    }
  end,
}

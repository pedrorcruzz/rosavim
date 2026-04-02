return {
  'mistricky/codesnap.nvim',
  lazy = true,
  build = 'make build_generator',
  keys = {
    { '<leader>lP', '<cmd>CodeSnap<cr>', mode = 'x', desc = 'Codesnap: Save on clipboard' },
    { '<leader>lp', '<cmd>CodeSnapSave<cr>', mode = 'x', desc = 'Codesnap: Save in photos' },
    { '<leader>lH', '<cmd>CodeSnapHighlight<cr>', mode = 'x', desc = 'Codesnap: Highlight on clipboard' },
    { '<leader>lh', '<cmd>CodeSnapSaveHighlight<cr>', mode = 'x', desc = 'Codesnap: Save Highlight in photos' },
    { '<leader>la', '<cmd>CodeSnapASCII<cr>', mode = 'x', desc = 'Codesnap: Save ASCII on clipboard' },
  },
  opts = {
    save_path = '~/Pictures/Codesnap',
    bg_theme = 'grape',
    bg_color = '#535c68',
    watermark = '',
    has_line_number = true,
    has_breadcrumbs = false,
    show_workspace = true,
  },
}

return {
  'MeanderingProgrammer/render-markdown.nvim',
  lazy = true,
  ft = { 'markdown' },
  cmd = { 'RenderMarkdown' },
  dependencies = { 'echasnovski/mini.icons' },
  opts = function()
    return { preset = require('rosavim.config.toggles').get 'render_markdown_theme' }
  end,
}

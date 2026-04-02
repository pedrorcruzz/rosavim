return {
  'iamcco/markdown-preview.nvim',
  lazy = true,
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'cd app && npm install',
  init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
  end,
  ft = { 'markdown' },
  keys = {
    -- { '<leader>ua', '<cmd>MarkdownPreview<cr>', desc = 'Markdown Preview: Open' },
    { '<leader>ua', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview: Toggle' },
    -- { '<leader>us', '<cmd>MarkdownPreviewStop<cr>', desc = 'Markdown Preview: Stop' },
  },
}

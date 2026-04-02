package.loaded['lazyvim.config.keymaps'] = true
require 'rosavim'
require 'rosavim.config.keybinds'
require 'rosavim.config.autocmds'
require 'rosavim.config.options'
require 'rosavim.config.filetypes'
require 'rosavim.lsp.lsp-handlers'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- nvim-treesitter is archived and its query_predicates crash on Neovim 0.12
-- (nil node:range() in get_node_text during markdown injection parsing).
-- We patch get_node_text to handle this gracefully before plugins load.
do
  local original = vim.treesitter.get_node_text
  vim.treesitter.get_node_text = function(node, source, opts)
    local ok, result = pcall(original, node, source, opts)
    if ok then
      return result
    end
    return ''
  end
end

require('lazy').setup({

  { import = 'rosavim.plugins.env.lsp' },
  { import = 'rosavim.plugins.env' },
  { import = 'rosavim.plugins.language' },
  { import = 'rosavim.plugins.ui' },
  { import = 'rosavim.plugins.ui.colorschemes' },
  { import = 'rosavim.plugins.coding' },
  { import = 'rosavim.plugins.editor' },
  { import = 'rosavim.plugins.ai' },
  { import = 'rosavim.plugins.test' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

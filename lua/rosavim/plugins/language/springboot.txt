return {
  'elmcgill/springboot-nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-jdtls',
  },
  config = function()
    local springboot_nvim = require 'springboot-nvim'
    springboot_nvim.setup {}
  end,
  keys = {
    {
      '<leader>psr',
      function()
        require('springboot-nvim').boot_run()
      end,
      desc = 'Spring Boot Run Project',
    },
    {
      '<leader>psc',
      function()
        require('springboot-nvim').generate_class()
      end,
      desc = 'Java Create Class',
    },
    {
      '<leader>psi',
      function()
        require('springboot-nvim').generate_interface()
      end,
      desc = 'Java Create Interface',
    },
    {
      '<leader>pse',
      function()
        require('springboot-nvim').generate_enum()
      end,
      desc = 'Java Create Enum',
    },
    { '<leader>psn', '<cmd>SpringBootNewProject<CR>', desc = 'Spring Boot New Project' },
  },
}

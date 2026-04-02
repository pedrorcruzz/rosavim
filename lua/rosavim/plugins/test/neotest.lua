return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',

      -- Adapters
      'fredrikaverpil/neotest-golang',
      'nvim-neotest/neotest-jest',
      'nvim-neotest/neotest-python',
      'V13Axel/neotest-pest',
      'rcasia/neotest-java',
      'marilari88/neotest-vitest',
    },
    keys = {
      {
        '<leader>nn',
        function()
          require('neotest').run.run()
        end,
        desc = 'Neotest: Run Nearest',
      },
      {
        '<leader>nf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = 'Neotest: Run File',
      },
      {
        '<leader>nl',
        function()
          require('neotest').run.run_last()
        end,
        desc = 'Neotest: Run Last',
      },
      {
        '<leader>ns',
        function()
          require('neotest').run.stop()
        end,
        desc = 'Neotest: Stop',
      },
      {
        '<leader>no',
        function()
          require('neotest').output.open { enter = true }
        end,
        desc = 'Neotest: Output',
      },
      {
        '<leader>np',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = 'Neotest: Output Panel',
      },
      {
        '<leader>nt',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Neotest: Summary',
      },
      {
        '<leader>nw',
        function()
          require('neotest').watch.toggle(vim.fn.expand '%')
        end,
        desc = 'Neotest: Watch File',
      },

      -- Go
      { '<leader>nga', '<cmd>GoAddTest<cr>', desc = 'Go Add Test' },
      { '<leader>ngA', '<cmd>GoAddAllTest<cr>', desc = 'Go Add All Test' },
    },
    config = function()
      local neotest_ns = vim.api.nvim_create_namespace 'neotest'
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
            return message
          end,
        },
      }, neotest_ns)

      require('neotest').setup {
        adapters = {
          require('neotest-golang')({
            runner = 'gotestsum',
          }),
          require('neotest-jest')({
            jestCommand = 'npx jest',
            jestConfigFile = function(file)
              local cwd = vim.fn.getcwd()
              if vim.fn.filereadable(cwd .. '/jest.config.ts') == 1 then
                return cwd .. '/jest.config.ts'
              elseif vim.fn.filereadable(cwd .. '/jest.config.js') == 1 then
                return cwd .. '/jest.config.js'
              end
              return cwd .. '/jest.config.ts'
            end,
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
          require('neotest-vitest')({}),
          require('neotest-python')({
            dap = { justMyCode = false },
            runner = 'pytest',
            python = '.venv/bin/python',
            pytest_discover_instances = true,
          }),
          require('neotest-pest')({
            ignore_dirs = { 'vendor', 'node_modules' },
            test_file_suffixes = { 'Test.php', '_test.php', 'PestTest.php' },
            pest_cmd = 'vendor/bin/pest',
          }),
          require('neotest-java')({}),
        },
      }
    end,
  },

  {
    'rcasia/neotest-java',
    ft = 'java',
    dependencies = {
      'mfussenegger/nvim-jdtls',
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
  },
}

vim.fn.sign_define('DapBreakpoint', { text = '󰃤', texthl = 'DiagnosticError', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '', texthl = 'DiagnosticInfo', linehl = 'Visual', numhl = '' })
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',

      -- Python
      {
        'mfussenegger/nvim-dap-python',
        ft = 'python',
        dependencies = {
          'mfussenegger/nvim-dap',
          'rcarriga/nvim-dap-ui',
        },
        config = function()
          local path = vim.fn.expand '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
          require('dap-python').setup(path)
        end,
      },

      'nvim-neotest/nvim-nio',

      -- Virtual text DAP
      {
        'theHamsta/nvim-dap-virtual-text',
        config = function()
          require('nvim-dap-virtual-text').setup()
        end,
      },

      {
        'williamboman/mason.nvim',
        opts = function(_, opts)
          opts.ensure_installed = {
            'debugpy',
            'delve',
            'php-debug-adapter',
            'java-debug-adapter',
          }
        end,
      },

      'jay-babu/mason-nvim-dap.nvim',
      'leoluz/nvim-dap-go',
    },

    opts = function()
      local dap = require 'dap'

      -- Python DAP config
      if not dap.adapters.python then
        dap.adapters.python = {
          type = 'server',
          host = 'localhost',
          port = 5678,
          executable = {
            command = 'python',
            args = { '-m', 'debugpy.adapter' },
          },
        }
      end

      dap.configurations.python = dap.configurations.python
        or {
          {
            type = 'python',
            request = 'launch',
            name = 'Launch Django server',
            program = '${workspaceFolder}/manage.py',
            args = { 'runserver', '127.0.0.1:8000' },
            pythonPath = function()
              return vim.fn.input('Python path: ', (vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. '/bin/python') or 'python', 'file')
            end,
          },
          {
            type = 'python',
            request = 'launch',
            name = 'Launch Django shell',
            program = '${workspaceFolder}/manage.py',
            args = { 'shell' },
            pythonPath = function()
              return vim.fn.input('Python path: ', (vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. '/bin/python') or 'python', 'file')
            end,
          },
          {
            type = 'python',
            request = 'attach',
            name = 'Attach to Django process',
            processId = require('dap.utils').pick_process,
          },
        }

      -- Go DAP config (delve)
      if not dap.adapters.go then
        dap.adapters.go = {
          type = 'server',
          port = '${port}',
          executable = {
            command = 'dlv',
            args = { 'dap', '-l', '127.0.0.1:${port}' },
          },
        }
      end

      dap.configurations.go = dap.configurations.go
        or {
          {
            type = 'go',
            name = 'Debug',
            request = 'launch',
            program = '${file}',
          },
          {
            type = 'go',
            name = 'Debug (test file)',
            request = 'launch',
            mode = 'test',
            -- program = '${file}',
            program = '${fileDirname}',
          },
          {
            type = 'go',
            name = 'Attach',
            request = 'attach',
            processId = require('dap.utils').pick_process,
            program = '${file}',
          },
        }

      -- PHP DAP config
      if not dap.adapters.php then
        dap.adapters.php = {
          type = 'executable',
          command = 'php-debug-adapter',
          args = {},
        }
      end

      dap.configurations.php = dap.configurations.php
        or {
          {
            type = 'php',
            request = 'launch',
            name = 'Listen for Xdebug',
            port = 9003,
            pathMappings = {
              ['/var/www/html'] = '${workspaceFolder}',
            },
          },
        }

      -- Java DAP config
      if not dap.adapters.java then
        dap.adapters.java = {
          type = 'server',
          host = '127.0.0.1',
          port = 5005,
        }
      end

      dap.configurations.java = dap.configurations.java
        or {
          {
            type = 'java',
            request = 'attach',
            name = 'Attach to remote',
            hostName = '127.0.0.1',
            port = 5005,
          },
        }
    end,

    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      require('dap-go').setup()
    end,

    keys = {
      { '<leader>ds', '<cmd>DapContinue<cr>', desc = 'Debug: Start/Continue' },
      { '<leader>dq', '<cmd>DapTerminate<cr>', desc = 'Debug: Terminate' },
      { '<leader>db', '<cmd>DapToggleBreakpoint<cr>', desc = 'Debug: Breakpoint' },
      { '<leader>dt', '<cmd>DapUiToggle<cr>', desc = 'Debug: Ui Toggle' },
      { '<leader>df', '<cmd>DapUiFloat<cr>', desc = 'Debug: Ui Float' },
      { '<leader>dd', '<cmd>DapStepOver<cr>', desc = 'Debug: Step Over' },
      { '<leader>di', '<cmd>DapStepInto<cr>', desc = 'Debug: Step Into' },
      { '<leader>do', '<cmd>DapStepOut<cr>', desc = 'Debug: Step Out' },
      { '<leader>dp', '<cmd>DapPause<cr>', desc = 'Debug: Pause' },
      { '<leader>dc', '<cmd>DapClearBreakpoint<cr>', desc = 'Debug: Clear Breakpoint' },
      { '<leader>dD', '<cmd>DapDisconnect<cr>', desc = 'Debug: Disconnect' },
      { '<leader>dr', '<cmd>DapRerun<cr>', desc = 'Debug: Rerun' },
      { '<leader>dR', '<cmd>DapRestartFrame<cr>', desc = 'Debug: Restart Frame' },
      { '<leader>dn', '<cmd>DapNew<cr>', desc = 'Debug: New' },
      { '<leader>de', '<cmd>DapEval<cr>', desc = 'Debug: Eval' },
    },
  },
}

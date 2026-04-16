local toggles = require 'rosavim.config.toggles'

local function get_layout()
  return toggles.get 'sidekick_right' and 'right' or 'left'
end

local function toggle_with_layout(toggle_opts)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { ' [v] vertical  [h] horizontal ' })
  local width = 32
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - 3) / 2) - 1,
    col = math.floor((vim.o.columns - width - 2) / 2),
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    title = ' Layout ',
    title_pos = 'center',
  })
  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  local function apply(layout)
    close()
    local State = require 'sidekick.cli.state'
    local filter = {}
    if toggle_opts and toggle_opts.name then
      filter.name = toggle_opts.name
    end
    State.with(function(state, attached)
      if not state.terminal then
        return
      end
      if state.terminal:is_open() then
        state.terminal:hide()
      end
      state.terminal.opts.layout = layout
      state.terminal:show()
      if toggles.get 'sidekick_auto_focus' then
        state.terminal:focus()
      end
    end, { attach = true, filter = filter })
  end

  vim.keymap.set('n', 'v', function()
    apply(get_layout())
  end, { buffer = buf, nowait = true })
  vim.keymap.set('n', 'h', function()
    apply 'bottom'
  end, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<esc>', close, { buffer = buf, nowait = true })
  vim.keymap.set('n', 'q', close, { buffer = buf, nowait = true })
end

return {
  {
    'folke/sidekick.nvim',
    event = 'VeryLazy',
    opts = {
      cli = {
        tools = {
          openclaude = {
            cmd = { 'openclaude' },
            is_proc = '\\<openclaude\\>',
            resume = { '--resume' },
            continue = { '--continue' },
          },
          ['claude-yolo'] = {
            cmd = { 'claude', '--dangerously-skip-permissions' },
            is_proc = '\\<claude\\>',
            resume = { '--resume' },
            continue = { '--continue' },
          },
        },
        win = {
          split = {
            width = 70,
            height = 20,
          },
        },
      },
    },
    keys = {
      {
        '<tab>',
        function()
          if not require('sidekick').nes_jump_or_apply() then
            return '<Tab>'
          end
        end,
        expr = true,
        desc = 'Goto/Apply Next Edit Suggestion',
      },
      { '<leader>a', '', desc = '+ai', mode = { 'n', 'v' } },
      {
        '<c-.>',
        function()
          require('sidekick.cli').focus()
        end,
        desc = 'Sidekick Focus',
        mode = { 'n', 't', 'i', 'x' },
      },
      {
        '<leader>aa',
        function()
          toggle_with_layout()
        end,
        desc = 'Sidekick Toggle CLI',
      },
      {
        '<leader>aa',
        function()
          -- Capture selection range before leaving visual mode
          local start_line = vim.fn.line 'v'
          local end_line = vim.fn.line '.'
          if start_line > end_line then
            start_line, end_line = end_line, start_line
          end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)

          Snacks.input({ prompt = '  Ask AI' }, function(input)
            if not input or input == '' then
              return
            end
            local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')
            local ref = '@' .. file .. ':' .. start_line .. '-' .. end_line
            require('sidekick.cli').send {
              msg = ref .. ' ' .. input,
              show = true,
              focus = true,
            }
          end)
        end,
        mode = 'x',
        desc = 'Ask AI (selection + prompt)',
      },
      {
        '<leader>as',
        function()
          require('sidekick.cli').select()
        end,
        desc = 'Select CLI',
      },
      {
        '<leader>ad',
        function()
          require('sidekick.cli').close()
        end,
        desc = 'Detach a CLI Session',
      },
      {
        '<leader>at',
        function()
          require('sidekick.cli').send { msg = '{this}' }
        end,
        mode = { 'x', 'n' },
        desc = 'Send This',
      },
      {
        '<leader>af',
        function()
          require('sidekick.cli').send { msg = '{file}' }
        end,
        desc = 'Send File',
      },
      {
        '<leader>av',
        function()
          require('sidekick.cli').send { msg = '{selection}' }
        end,
        mode = { 'x' },
        desc = 'Send Visual Selection',
      },
      {
        '<leader>ap',
        function()
          require('sidekick.cli').prompt()
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Select Prompt',
      },
      {
        '<leader>ac',
        function()
          toggle_with_layout { name = 'claude', focus = true }
        end,
        desc = 'Sidekick Toggle Claude',
      },
      {
        '<leader>aC',
        function()
          toggle_with_layout { name = 'claude-yolo', focus = true }
        end,
        desc = 'Sidekick Toggle Claude (Skip Permissions)',
      },
      {
        '<leader>av',
        function()
          toggle_with_layout { name = 'cursor', focus = true }
        end,
        desc = 'Sidekick Toggle Cursor',
      },
      {
        '<leader>ao',
        function()
          toggle_with_layout { name = 'openclaude', focus = true }
        end,
        desc = 'Toggle OpenClaude CLI',
      },
    },
    config = function(_, opts)
      require('sidekick').setup(opts)
      vim.api.nvim_create_autocmd('TermOpen', {
        callback = function(ev)
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(ev.buf) then
              return
            end
            if not vim.b[ev.buf].sidekick_cli then
              return
            end
            local bopts = { buffer = ev.buf }
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], bopts)
          end)
        end,
      })
    end,
  },
}

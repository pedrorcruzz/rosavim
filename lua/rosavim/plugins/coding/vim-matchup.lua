return {
  'andymass/vim-matchup',
  event = 'BufReadPost',
  init = function()
    vim.g.matchup_treesitter_stopline = 500
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_matchparen_deferred_show_delay = 50
    vim.g.matchup_matchparen_deferred_hide_delay = 300
    vim.g.matchup_matchparen_timeout = 100
    vim.g.matchup_matchparen_insert_timeout = 30
  end,
  config = function()
    require('match-up').setup {
      treesitter = {
        stopline = 500,
      },
    }

    local ns = vim.api.nvim_create_namespace 'vim-matchup'

    local function drop_stale_highlight()
      if vim.g.matchup_matchparen_enabled == 0 then
        return
      end

      local buf = vim.api.nvim_get_current_buf()
      local ok, marks = pcall(vim.api.nvim_buf_get_extmarks, buf, ns, 0, -1, { details = true })
      if not ok or #marks == 0 then
        return
      end

      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1] - 1, cursor[2]
      for _, mark in ipairs(marks) do
        local details = mark[4] or {}
        if mark[2] == row and col >= mark[3] - 1 and col <= (details.end_col or mark[3]) + 1 then
          return
        end
      end

      pcall(vim.fn['matchup#matchparen#update'])
    end

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'TextChangedI' }, {
      group = vim.api.nvim_create_augroup('rosavim_matchup_stale', { clear = true }),
      callback = drop_stale_highlight,
    })
  end,
}

local toggles = require 'rosavim.config.toggles'

--- Delete a buffer without collapsing the window layout (replaces
--- mini.bufremove): every window showing it switches to the alternate or
--- another listed buffer first — a fresh scratch one when it was the last —
--- so a plain :bdelete never takes the split with it. Prompts to save
--- unsaved changes instead of erroring out.
local function delete_buf_keep_layout(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].modified then
    local choice = vim.fn.confirm(('Save changes to %q?'):format(vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')), '&Yes\n&No\n&Cancel')
    if choice == 1 then
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd 'write'
      end)
    elseif choice ~= 2 then
      return
    end
  end
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr '#'
      if alt > 0 and alt ~= bufnr and vim.bo[alt].buflisted then
        vim.api.nvim_win_set_buf(win, alt)
        return
      end
      local listed = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted and b ~= bufnr
      end, vim.api.nvim_list_bufs())
      vim.api.nvim_win_set_buf(win, listed[1] or vim.api.nvim_create_buf(true, false))
    end)
  end
  pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

return {
  'akinsho/bufferline.nvim',
  dependencies = {
    { 'echasnovski/mini.icons', lazy = true },
  },
  lazy = true,
  event = 'VeryLazy',
  opts = {
    options = {
      show_bufferline = toggles.get 'bufferline',
      close_command = delete_buf_keep_layout,
      right_mouse_command = delete_buf_keep_layout,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(_, _, diagnostics)
        local symbols = {
          error = { icon = '', hl = 'DiagnosticError' },
          warning = { icon = '', hl = 'DiagnosticWarn' },
          info = { icon = '', hl = 'DiagnosticInfo' },
          hint = { icon = '', hl = 'DiagnosticHint' },
        }
        local result = {}
        for name, count in pairs(diagnostics) do
          local sym = symbols[name]
          if sym and count > 0 then
            table.insert(result, string.format('%%#%s#%s%%*%d', sym.hl, sym.icon, count))
          end
        end
        return table.concat(result, ' ')
      end,

      offsets = {
        {
          filetype = 'snacks_picker_list',
          text = 'Snacks Explorer',
          highlight = 'BufferLineOffset',
          text_align = 'left',
          separator = true,
        },
        {
          filetype = 'snacks_layout_box',
          text = '',
          highlight = 'BufferLineOffset',
          text_align = 'left',
          separator = true,
        },
      },
    },
  },

  config = function(_, opts)
    require('bufferline').setup(opts)
    local active = toggles.get 'bufferline'
    vim.opt.showtabline = active and 2 or 0

    -- bufferline builds the BufferLineDevIcon* groups from its own internal
    -- highlight tables, whose bg is derived from the editor's Normal bg instead
    -- of the theme's bar bg — so the icon square renders lighter than the bar.
    -- It recreates those groups on render and caches them, which beats any
    -- after-the-fact override (the fix loses the race against the redraw).
    -- Wrap the icon-highlight builder to force each icon's bg to the bar bg at
    -- the source, on every call, so the icon square always matches the bar
    -- (icon == tab == fill), race-free and surviving redraws/colorscheme swaps.
    local bl_hl = require 'bufferline.highlights'
    local original_set_icon = bl_hl.set_icon_highlight
    bl_hl.set_icon_highlight = function(state, hls, base_hl)
      local name = original_set_icon(state, hls, base_hl)
      local fill = vim.api.nvim_get_hl(0, { name = 'BufferLineFill' })
      if name and fill.bg then
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        if hl.bg ~= fill.bg then
          hl.bg = fill.bg
          -- bufferline sets its highlights as `default` (themable); re-setting
          -- with default=true is a no-op once the group exists, so drop it to
          -- make the override actually stick.
          hl.default = nil
          vim.api.nvim_set_hl(0, name, hl)
        end
      end
      return name
    end
  end,

  keys = {
    { '<leader>bb', '<cmd>BufferLinePick<cr>', desc = 'Pick Buffer' },
    {
      '<leader>bf',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Find Buffers',
    },
    { '<leader>bp', '<cmd>BufferLinePickClose<cr>', desc = 'Pick Close Buffer' },
    { '<leader>bh', '<cmd>BufferLineCloseLeft<cr>', desc = 'Close Left' },
    { '<leader>bl', '<cmd>BufferLineCloseRight<cr>', desc = 'Close Right' },
    { '<leader>bC', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close Others' },
    { '<leader>bj', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<leader>bk', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '<leader>bq', '<cmd>BufferLineSortByDirectory<cr>', desc = 'Sort Directory' },
    { '<leader>be', '<cmd>BufferLineSortByExtension<cr>', desc = 'Sort Extension' },
    { '<leader>br', '<cmd>BufferLineSortByRelativeDirectory<cr>', desc = 'Sort Relative Directory' },
  },
}

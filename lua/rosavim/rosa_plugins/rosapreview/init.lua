--- Rosapreview - LSP preview in floating windows for Rosavim
local M = {}

local preview_wins = {}

local defaults = {
  width = 130,
  height = 30,
  border = 'rounded',
}

local config = {}

--- Setup highlights
local function setup_highlights()
  vim.api.nvim_set_hl(0, 'RosapreviewBorder', { fg = '#6c7086' })
  vim.api.nvim_set_hl(0, 'RosapreviewTitle', { fg = '#cba6f7', bold = true })
  vim.api.nvim_set_hl(0, 'RosapreviewFooter', { fg = '#6c7086', italic = true })
  vim.api.nvim_set_hl(0, 'RosapreviewFooterKey', { fg = '#89b4fa', bold = true })
end

--- Build styled footer with highlighted keys
local function build_footer()
  return {
    { ' ', 'RosapreviewFooter' },
    { 'q', 'RosapreviewFooterKey' },
    { ' close  ', 'RosapreviewFooter' },
    { '󰍉 Q', 'RosapreviewFooterKey' },
    { ' vsplit  ', 'RosapreviewFooter' },
    { '󰍉 M', 'RosapreviewFooterKey' },
    { ' replace ', 'RosapreviewFooter' },
  }
end

--- Set a keymap on a buffer that auto-cleans when the float closes
local function float_keymap(bufnr, win, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, nowait = true, desc = desc })
  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(win),
    once = true,
    callback = function()
      pcall(vim.keymap.del, mode, lhs, { buffer = bufnr })
    end,
  })
end

--- Open a floating window showing the given URI at the given range
local function open_float(uri, range)
  setup_highlights()

  local bufnr = vim.uri_to_bufnr(uri)
  vim.fn.bufload(bufnr)

  local width = math.min(config.width, vim.o.columns - 4)
  local height = math.min(config.height, vim.o.lines - 6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local filename = vim.fn.fnamemodify(vim.uri_to_fname(uri), ':~:.')
  local lnum = range and ((range.start.line or 0) + 1) or nil
  local title_text = filename .. (lnum and (':' .. lnum) or '')

  local win = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    border = config.border,
    title = {
      { ' 󰍉 ', 'RosapreviewTitle' },
      { title_text .. ' ', 'RosapreviewTitle' },
    },
    title_pos = 'center',
    footer = build_footer(),
    footer_pos = 'center',
    zindex = 50,
  })

  vim.wo[win].cursorline = true
  vim.wo[win].number = true
  vim.wo[win].relativenumber = true
  vim.wo[win].wrap = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosapreviewBorder,FloatTitle:RosapreviewTitle,FloatFooter:RosapreviewFooter'

  -- Jump to position
  if range then
    local ccol = range.start.character or 0
    pcall(vim.api.nvim_win_set_cursor, win, { lnum, ccol })
    vim.cmd 'normal! zz'
  end

  table.insert(preview_wins, win)

  -- q / Esc to close
  float_keymap(bufnr, win, 'n', 'q', function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 'Rosapreview: Close')

  float_keymap(bufnr, win, 'n', '<Esc>', function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 'Rosapreview: Close')

  -- <leader>Q to expand to vsplit
  float_keymap(bufnr, win, 'n', '<leader>Q', function()
    vim.api.nvim_win_close(win, true)
    vim.cmd('vsplit | buffer ' .. bufnr)
    if range then
      pcall(vim.api.nvim_win_set_cursor, 0, { (range.start.line or 0) + 1, range.start.character or 0 })
    end
  end, 'Rosapreview: Expand Vsplit')

  -- <leader>M to replace current window
  float_keymap(bufnr, win, 'n', '<leader>M', function()
    vim.api.nvim_win_close(win, true)
    vim.cmd('buffer ' .. bufnr)
    if range then
      pcall(vim.api.nvim_win_set_cursor, 0, { (range.start.line or 0) + 1, range.start.character or 0 })
    end
  end, 'Rosapreview: Replace Window')

  -- Clean up tracking on close
  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(win),
    once = true,
    callback = function()
      for i, w in ipairs(preview_wins) do
        if w == win then
          table.remove(preview_wins, i)
          break
        end
      end
    end,
  })
end

--- Make an LSP request and open the result in a float
local function lsp_preview(method)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then
    Snacks.notify.warn('Rosapreview: no LSP client attached')
    return
  end
  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)

  -- references needs context
  if method == 'textDocument/references' then
    params.context = { includeDeclaration = true }
  end

  vim.lsp.buf_request(0, method, params, function(err, result)
    if err then
      Snacks.notify.error('Rosapreview: ' .. (err.message or 'LSP error'))
      return
    end
    if not result or (type(result) == 'table' and vim.tbl_isempty(result)) then
      Snacks.notify.info('Rosapreview: no results')
      return
    end

    local target = vim.islist(result) and result[1] or result
    local uri = target.uri or target.targetUri
    local range = target.range or target.targetSelectionRange

    if uri and range then
      vim.schedule(function()
        open_float(uri, range)
      end)
    end
  end)
end

function M.definition()
  lsp_preview 'textDocument/definition'
end

function M.type_definition()
  lsp_preview 'textDocument/typeDefinition'
end

function M.implementation()
  lsp_preview 'textDocument/implementation'
end

function M.declaration()
  lsp_preview 'textDocument/declaration'
end

function M.references()
  lsp_preview 'textDocument/references'
end

function M.close_all()
  for _, win in ipairs(preview_wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  preview_wins = {}
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', defaults, opts or {})
end

M.setup {}

return M

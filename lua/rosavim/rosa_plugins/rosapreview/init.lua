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
  local p = require('rosavim.rosa_plugins.palette').get()
  vim.api.nvim_set_hl(0, 'RosapreviewBorder', { fg = p.border })
  vim.api.nvim_set_hl(0, 'RosapreviewTitle', { fg = p.title, bold = true })
  vim.api.nvim_set_hl(0, 'RosapreviewFooter', { fg = p.dim, italic = true })
  vim.api.nvim_set_hl(0, 'RosapreviewFooterKey', { fg = p.key, bold = true })
end

--- Build styled footer with highlighted keys. When `close_only` is set the
--- footer shows just `q close` (vsplit/replace omitted).
local function build_footer(close_only)
  if close_only then
    return {
      { ' ', 'RosapreviewFooter' },
      { 'q', 'RosapreviewFooterKey' },
      { ' close ', 'RosapreviewFooter' },
    }
  end
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

--- Open a floating window showing the given URI at the given range. `geom`
--- optionally overrides the placement/size ({ row, col, width, height }) so a
--- caller can dock the float somewhere specific (e.g. beside another panel);
--- when omitted the float is centered at the configured size, as before.
local function open_float(uri, range, geom, opts)
  opts = opts or {}
  setup_highlights()

  local bufnr = vim.uri_to_bufnr(uri)
  vim.fn.bufload(bufnr)

  local width = (geom and geom.width) or math.min(config.width, vim.o.columns - 4)
  local height = (geom and geom.height) or math.min(config.height, vim.o.lines - 6)
  local row = (geom and geom.row) or math.floor((vim.o.lines - height) / 2)
  local col = (geom and geom.col) or math.floor((vim.o.columns - width) / 2)

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
    footer = build_footer(opts.close_only),
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

  if not opts.close_only then
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
  end

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

  return win
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

--- Open the styled preview float directly for a file path, optionally jumped to
--- a 1-based line. Reuses the same float as the LSP previews, so callers (e.g.
--- RosaAI review's `p`) get identical look, keymaps (q close, expand, replace)
--- and any highlights already attached to the file's buffer (like gitsigns).
--- `geom` optionally docks the float ({ row, col, width, height }).
function M.file(path, line, geom, opts)
  if not path or path == '' then
    return
  end
  local uri = vim.uri_from_fname(path)
  local range
  if line and line > 0 then
    range = { start = { line = line - 1, character = 0 } }
  end
  return open_float(uri, range, geom, opts)
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

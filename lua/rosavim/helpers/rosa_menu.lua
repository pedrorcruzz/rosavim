--- Rosa Menu - Shared centered floating menu for rosa plugin popups
---
--- Every rosa plugin menu follows the same shape: build lines plus highlight
--- spans, open a centered rounded float with a title/footer, replay the spans
--- as extmarks and wire q/<Esc> to close. This module owns that shape; each
--- plugin only supplies content, sizing and its bespoke keys.
local M = {}

local ns = vim.api.nvim_create_namespace 'rosa_menu'

--- Line/highlight accumulator used while composing menu content.
--- `add(text, hl)` appends a line (hl, when given, covers the whole line);
--- `add_hl(hl, line, col_start, col_end)` attaches a span to an existing
--- 0-based line (col_end -1 or nil means end of line); `line()` is the
--- 0-based index of the last added line.
function M.builder()
  local b = { lines = {}, highlights = {} }
  local ln = 0
  function b.add(text, hl)
    table.insert(b.lines, text)
    if hl then
      table.insert(b.highlights, { hl, ln })
    end
    ln = ln + 1
  end
  function b.add_hl(hl_name, line_nr, col_start, col_end)
    table.insert(b.highlights, { hl_name, line_nr, col_start, col_end })
  end
  function b.line()
    return ln - 1
  end
  return b
end

--- Replay { hl_group, line, col_start|nil, col_end|nil } spans as extmarks.
--- A nil or -1 col_end highlights through the end of the line.
function M.apply_highlights(buf, highlights)
  for _, hl in ipairs(highlights) do
    local col_end = hl[4] or -1
    vim.api.nvim_buf_set_extmark(buf, ns, hl[2], hl[3] or 0, {
      end_row = col_end == -1 and hl[2] + 1 or hl[2],
      end_col = col_end == -1 and 0 or col_end,
      hl_group = hl[1],
    })
  end
end

--- Replace a menu buffer's content and highlights in place (for re-renders).
function M.set_content(buf, lines, highlights)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  M.apply_highlights(buf, highlights or {})
end

--- Open a centered menu float.
---
--- `title` and `footer` are used verbatim (callers keep their own padding and
--- icons). Highlight groups are derived from `hl_prefix`: the window links
--- FloatBorder to <prefix>Border, FloatTitle to <prefix>Title and FloatFooter
--- to <prefix>Dim. q and <Esc> close the menu by default; entries in `keys`
--- ({ mode, lhs, fn }) may override them. Each fn receives a ctx table with
--- `buf`, `win` and `close()`.
---
--- @param opts { title: string, footer: string|nil, width: number|nil, height: number|nil, lines: string[], highlights: table[]|nil, hl_prefix: string, filetype: string|nil, cursorline: boolean|nil, keys: table[]|nil }
--- @return { buf: number, win: number, close: function }
function M.open(opts)
  local lines = opts.lines or {}
  local width = opts.width or 56
  local height = opts.height or #lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  if opts.filetype then
    vim.bo[buf].filetype = opts.filetype
  end

  local win_opts = {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = opts.title,
    title_pos = 'center',
    zindex = 50,
  }
  if opts.footer then
    win_opts.footer = opts.footer
    win_opts.footer_pos = 'center'
  end

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  local p = opts.hl_prefix
  vim.wo[win].winhl = ('Normal:Normal,FloatBorder:%sBorder,FloatTitle:%sTitle,FloatFooter:%sDim'):format(p, p, p)
  vim.wo[win].cursorline = opts.cursorline or false
  vim.wo[win].wrap = false

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  M.apply_highlights(buf, opts.highlights or {})

  local ctx = { buf = buf, win = win }
  function ctx.close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local kopts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set('n', 'q', ctx.close, kopts)
  vim.keymap.set('n', '<Esc>', ctx.close, kopts)
  for _, key in ipairs(opts.keys or {}) do
    local mode, lhs, fn = key[1], key[2], key[3]
    vim.keymap.set(mode, lhs, function()
      fn(ctx)
    end, kopts)
  end

  return ctx
end

return M

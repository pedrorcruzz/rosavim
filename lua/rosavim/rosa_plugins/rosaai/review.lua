--- RosaAI review - keep/reject per-hunk review of AI changes
---
--- A native, Cursor/VSCode-style review layer for changes an AI CLI made to
--- the working tree. It pairs two dependencies that do the heavy lifting:
---   * `snapshot` captures a git baseline (the "before" state) and lists the
---     files the AI touched.
---   * `gitsigns` provides the hunk mechanics (diff against the baseline via
---     `change_base`, green/red line highlights, hunk navigation, and
---     per-hunk / whole-buffer resets).
---
--- The UI is "both combined": a floating overview panel that lists each
--- changed file with a resolved/total progress, plus inline green (added) /
--- red (removed) highlights in the source buffers and a small status chip.
---
--- Review flow: open() sets the diff base to the snapshot SHA, turns on the
--- line highlights, and walks every touched buffer. Each hunk is resolved by
--- KEEP (leave the AI change in place) or REJECT (revert that hunk to the
--- baseline via gitsigns). When every hunk is resolved the review tears down
--- automatically and clears the baseline so the next session starts fresh.
---
--- Public API (frozen — teammates wire to these):
---   M.open()            full flow (no-op with a notify when there is nothing
---                       to review)
---   M.close()           full teardown
---   M.toggle()          open if closed, else close
---   M.is_open()         boolean
---   M.keep_all()        accept everything, teardown
---   M.reject_all()      revert every touched buffer to baseline, teardown
---   M.notify_ai_edit()  debounced auto-open hook (gated by a toggle)
local M = {}

local api = vim.api
local fn = vim.fn

local snapshot = require 'rosavim.rosa_plugins.rosaai.snapshot'

local panel_ns = api.nvim_create_namespace 'rosareview_panel'
local chip_ns = api.nvim_create_namespace 'rosareview_chip'

--- Active review state, or nil when the review is closed. Shape:
---   { files = { { file, bufnr, total, resolved = { [sig] = 'keep'|'reject' } } },
---     source_win, chip = { buf, win }, panel = { buf, win, sel }, au }
local S = nil

--- Guard so a second open() while the async first one is still setting up
--- does not spin up a duplicate review.
local opening = false

--- True while close()'s async `change_base(nil)` (base reset) is still in
--- flight. A fast reopen waits for it to land before setting its own base, so
--- the late reset can't clobber the new baseline (turning the diff back to
--- HEAD and leaking already-accepted hunks into the next review).
local base_reset_pending = false

--- Previous definitions of the gitsigns line-hl groups we override, so they
--- can be restored on teardown.
local saved_hl = {}

--- Debounce timer for notify_ai_edit (reset on each call).
local debounce_timer = nil

-- Forward declarations (defined further down, referenced earlier).
local update_chip, close_chip, open_panel, close_panel, render_panel
local after_action, finalize, install_buffer_keymaps, remove_buffer_keymaps

-- ---------------------------------------------------------------------------
-- Dependencies / small utilities
-- ---------------------------------------------------------------------------

--- Safe gitsigns handle, or nil when the plugin is not installed.
local function gitsigns()
  local ok, gs = pcall(require, 'gitsigns')
  if not ok then
    return nil
  end
  return gs
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

--- Whether the whole Review feature is enabled (master `rosaai_review` toggle,
--- default true). When off, entry points no-op and the indicator is hidden.
local function review_enabled()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return true
  end
  local v = toggles.get 'rosaai_review'
  if v == nil then
    return true
  end
  return v
end

--- Public accessor for the master toggle (used by cli.lua / bar.lua).
function M.enabled()
  return review_enabled()
end

--- Convert a decimal color to a `#rrggbb` string (nil-safe).
local function hexcolor(n)
  if not n then
    return nil
  end
  return string.format('#%06x', n)
end

local function parse_hex(h)
  h = h:gsub('#', '')
  return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
end

--- Blend `fg` over `bg` with alpha `a` (0..1) → `#rrggbb`. Used to derive the
--- subtle green/red line fills so text stays readable.
local function blend(fg, bg, a)
  local fr, fgc, fb = parse_hex(fg)
  local br, bgc, bb = parse_hex(bg)
  local function mix(x, y)
    return math.floor(x * a + y * (1 - a) + 0.5)
  end
  return string.format('#%02x%02x%02x', mix(fr, br), mix(fgc, bgc), mix(fb, bb))
end

--- Current editor background as `#rrggbb`, with a sane fallback when Normal
--- has a transparent (nil) bg.
local function normal_bg()
  local normal = api.nvim_get_hl(0, { name = 'Normal' })
  return hexcolor(normal.bg) or (vim.o.background == 'light' and '#ffffff' or '#1e1e2e')
end

-- ---------------------------------------------------------------------------
-- Highlights
-- ---------------------------------------------------------------------------

--- Register the Rosa review highlight groups from the shared palette.
local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  api.nvim_set_hl(0, 'RosaReviewAdd', { fg = p.green })
  api.nvim_set_hl(0, 'RosaReviewDel', { fg = p.red })
  api.nvim_set_hl(0, 'RosaReviewTitle', { fg = p.title, bold = true })
  api.nvim_set_hl(0, 'RosaReviewBorder', { fg = p.border })
  api.nvim_set_hl(0, 'RosaReviewKey', { fg = p.key, bold = true })
  api.nvim_set_hl(0, 'RosaReviewDim', { fg = p.dim })
  api.nvim_set_hl(0, 'RosaReviewText', { fg = p.text })
  api.nvim_set_hl(0, 'RosaReviewKept', { fg = p.green, bold = true })
  api.nvim_set_hl(0, 'RosaReviewReject', { fg = p.red, bold = true })
end

--- Give the gitsigns whole-line groups the Cursor-style green/red fill.
--- Captures each group's previous definition once so it can be restored on
--- teardown.
local function restyle_gitsigns()
  local p = require('rosavim.rosa_plugins.palette').get()
  local bg = normal_bg()
  local add_bg = blend(p.green, bg, 0.16)
  local del_bg = blend(p.red, bg, 0.18)

  local overrides = {
    GitSignsAddLn = { bg = add_bg },
    GitSignsChangeLn = { bg = add_bg },
    GitSignsDeleteLn = { bg = del_bg },
    GitSignsDeleteVirtLn = { bg = del_bg, fg = p.red },
  }
  for group, def in pairs(overrides) do
    if saved_hl[group] == nil then
      saved_hl[group] = api.nvim_get_hl(0, { name = group, link = false }) or {}
    end
    pcall(api.nvim_set_hl, 0, group, def)
  end
end

--- Restore the gitsigns groups we overrode to their captured definitions.
local function restore_gitsigns()
  for group, def in pairs(saved_hl) do
    pcall(api.nvim_set_hl, 0, group, def)
  end
  saved_hl = {}
end

-- Keep the Rosa groups (and the gitsigns restyle while active) in sync with
-- colorscheme changes.
api.nvim_create_autocmd('ColorScheme', {
  group = api.nvim_create_augroup('RosaReviewHl', { clear = true }),
  callback = function()
    setup_highlights()
    if S then
      restyle_gitsigns()
    end
  end,
})

-- ---------------------------------------------------------------------------
-- Hunk helpers
-- ---------------------------------------------------------------------------

--- Content-based hunk signature. The added/removed patch lines are invariant
--- to line-number shifts caused by resetting *other* hunks, so this is a
--- stable identity for tracking a hunk as "kept" or "rejected".
local function hunk_sig(h)
  if h.lines and #h.lines > 0 then
    return table.concat(h.lines, '\n')
  end
  return (h.head or '') .. '#' .. tostring(h.added and h.added.start or '?')
end

--- The 1-based line range a hunk occupies in the current buffer. For a pure
--- deletion (added.count == 0) both ends collapse to the removed anchor.
local function hunk_range(h)
  local a = h.added or {}
  local start = a.start or (h.removed and h.removed.start) or 1
  local count = a.count or 0
  local finish = count > 0 and (start + count - 1) or start
  return start, finish
end

local function hunk_contains(h, line)
  local s, e = hunk_range(h)
  return line >= s and line <= e
end

--- All hunks gitsigns currently reports for `bufnr` (against the review base).
local function get_hunks_of(bufnr)
  local gs = gitsigns()
  if not gs then
    return {}
  end
  local ok, hunks = pcall(gs.get_hunks, bufnr)
  if ok and hunks then
    return hunks
  end
  return {}
end

--- Hunks in a file that have not yet been kept or rejected.
local function unresolved_of(entry)
  local out = {}
  for _, h in ipairs(get_hunks_of(entry.bufnr)) do
    if not entry.resolved[hunk_sig(h)] then
      out[#out + 1] = h
    end
  end
  return out
end

--- Number of resolved (kept OR rejected) hunks in a file, capped at total.
--- A new file is a single whole-file decision (resolved key `__file__`).
local function resolved_count(entry)
  if entry.is_new then
    return entry.resolved.__file__ and 1 or 0
  end
  local n = 0
  for _ in pairs(entry.resolved) do
    n = n + 1
  end
  if entry.total > 0 then
    return math.min(n, entry.total)
  end
  return n
end

--- Whether every file is fully reviewed: new files need a whole-file decision,
--- tracked files need no unresolved hunks left.
local function all_resolved()
  if not S then
    return false
  end
  for _, e in ipairs(S.files) do
    if e.is_new then
      if not e.resolved.__file__ then
        return false
      end
    elseif #unresolved_of(e) > 0 then
      return false
    end
  end
  return true
end

--- The review entry backing a given buffer, or nil.
local function entry_for_buf(bufnr)
  if not S then
    return nil
  end
  for _, e in ipairs(S.files) do
    if e.bufnr == bufnr then
      return e
    end
  end
  return nil
end

--- Navigate to the next/prev hunk using whichever gitsigns API exists.
local function nav(dir)
  local gs = gitsigns()
  if not gs then
    return
  end
  if gs.nav_hunk then
    pcall(gs.nav_hunk, dir)
  elseif dir == 'next' and gs.next_hunk then
    pcall(gs.next_hunk)
  elseif dir == 'prev' and gs.prev_hunk then
    pcall(gs.prev_hunk)
  end
end

--- Pick a normal (non-floating) window to show a source buffer in, creating a
--- split when only floats are open.
local function pick_main_win()
  local function is_normal(w)
    if not api.nvim_win_is_valid(w) then
      return false
    end
    local cfg = api.nvim_win_get_config(w)
    return not cfg.relative or cfg.relative == ''
  end
  local cur = api.nvim_get_current_win()
  if is_normal(cur) then
    return cur
  end
  for _, w in ipairs(api.nvim_list_wins()) do
    if is_normal(w) then
      return w
    end
  end
  vim.cmd 'botright split'
  return api.nvim_get_current_win()
end

--- The hunk under the cursor in `win`, or the file's first unresolved hunk.
local function find_hunk_under_cursor(entry, win)
  local ok, pos = pcall(api.nvim_win_get_cursor, win)
  local line = ok and pos[1] or 1
  for _, h in ipairs(get_hunks_of(entry.bufnr)) do
    if hunk_contains(h, line) then
      return h
    end
  end
  return unresolved_of(entry)[1]
end

-- ---------------------------------------------------------------------------
-- Status chip
-- ---------------------------------------------------------------------------

close_chip = function()
  if S and S.chip and S.chip.win and api.nvim_win_is_valid(S.chip.win) then
    pcall(api.nvim_win_close, S.chip.win, true)
  end
  if S and S.chip then
    S.chip.win = nil
  end
end

--- Recompute and (re)draw the floating status chip over the source window.
update_chip = function()
  if not S then
    return
  end
  -- Anchor the chip to the window showing the reviewed buffer. If the cursor
  -- is in a float (e.g. the panel), fall back to the tracked source window.
  local win = api.nvim_get_current_win()
  local cfg = api.nvim_win_get_config(win)
  if cfg.relative and cfg.relative ~= '' then
    win = S.source_win
  end
  if not win or not api.nvim_win_is_valid(win) then
    close_chip()
    return
  end
  local buf = api.nvim_win_get_buf(win)
  local entry = entry_for_buf(buf)
  if not entry then
    close_chip()
    return
  end
  S.source_win = win

  local hunks = get_hunks_of(buf)
  local total = #hunks
  local cur = api.nvim_win_get_cursor(win)[1]
  local idx = 0
  for i, h in ipairs(hunks) do
    if hunk_contains(h, cur) then
      idx = i
      break
    end
    local s = hunk_range(h)
    if idx == 0 and s >= cur then
      idx = i
    end
  end
  if idx == 0 then
    idx = total
  end

  -- Global kept / rejected counters.
  local kept, rej = 0, 0
  for _, e in ipairs(S.files) do
    for _, v in pairs(e.resolved) do
      if v == 'keep' then
        kept = kept + 1
      else
        rej = rej + 1
      end
    end
  end

  local segs = {
    { ' RosaAI Review · hunk ', 'RosaReviewDim' },
    { string.format('%d/%d', idx, total), 'RosaReviewText' },
    { ' · kept ', 'RosaReviewDim' },
    { tostring(kept), 'RosaReviewKept' },
    { ' · rejected ', 'RosaReviewDim' },
    { tostring(rej), 'RosaReviewReject' },
    { ' ', 'RosaReviewDim' },
  }
  local text = ''
  for _, s in ipairs(segs) do
    text = text .. s[1]
  end
  local width = api.nvim_strwidth(text)

  local chip = S.chip
  if not chip.buf or not api.nvim_buf_is_valid(chip.buf) then
    chip.buf = api.nvim_create_buf(false, true)
    vim.bo[chip.buf].bufhidden = 'hide'
  end
  vim.bo[chip.buf].modifiable = true
  api.nvim_buf_set_lines(chip.buf, 0, -1, false, { text })
  vim.bo[chip.buf].modifiable = false
  api.nvim_buf_clear_namespace(chip.buf, chip_ns, 0, -1)
  local col = 0
  for _, s in ipairs(segs) do
    local ec = col + #s[1]
    pcall(api.nvim_buf_set_extmark, chip.buf, chip_ns, 0, col, {
      end_row = 0,
      end_col = ec,
      hl_group = s[2],
    })
    col = ec
  end

  local win_w = api.nvim_win_get_width(win)
  local place_col = math.max(0, math.floor((win_w - width) / 2))
  if chip.win and api.nvim_win_is_valid(chip.win) then
    pcall(api.nvim_win_set_config, chip.win, {
      relative = 'win',
      win = win,
      row = 0,
      col = place_col,
      width = width,
      height = 1,
    })
  else
    local ok, cwin = pcall(api.nvim_open_win, chip.buf, false, {
      relative = 'win',
      win = win,
      row = 0,
      col = place_col,
      width = width,
      height = 1,
      style = 'minimal',
      border = 'none',
      focusable = false,
      zindex = 60,
      noautocmd = true,
    })
    if ok then
      chip.win = cwin
      vim.wo[cwin].winhl = 'Normal:Normal'
    end
  end
end

-- ---------------------------------------------------------------------------
-- Keep / reject a single hunk (buffer-local commands)
-- ---------------------------------------------------------------------------

--- Persist a rejected buffer to disk. gitsigns reset only changes the in-memory
--- buffer, but the AI already wrote the file, so without this the rejection
--- would not survive on disk (reopening would show the AI version again).
--- `noautocmd` avoids triggering formatters/LSP/autosave on a mechanical
--- revert; only real, modifiable file buffers are written.
local function write_buf(bufnr)
  if not (bufnr and api.nvim_buf_is_valid(bufnr)) then
    return
  end
  if api.nvim_buf_get_name(bufnr) == '' then
    return
  end
  if not vim.bo[bufnr].modifiable or vim.bo[bufnr].buftype ~= '' then
    return
  end
  pcall(api.nvim_buf_call, bufnr, function()
    vim.cmd 'silent noautocmd write'
  end)
end

--- Discard a rejected NEW (untracked) file: wipe its buffer and delete it from
--- disk. A brand-new file has no baseline version to reset to, so rejecting it
--- means removing it entirely.
local function delete_new_file(entry)
  local name = api.nvim_buf_get_name(entry.bufnr)
  if api.nvim_buf_is_valid(entry.bufnr) then
    pcall(api.nvim_buf_delete, entry.bufnr, { force = true })
  end
  if name ~= '' then
    pcall(vim.fn.delete, name)
  end
end

--- Keep the hunk under the cursor: mark resolved, advance. The AI change stays.
local function keep_current()
  if not S then
    return
  end
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  local entry = entry_for_buf(buf)
  if not entry then
    return
  end
  if entry.is_new then
    entry.resolved.__file__ = 'keep'
    after_action()
    return
  end
  local h = find_hunk_under_cursor(entry, win)
  if h then
    entry.resolved[hunk_sig(h)] = 'keep'
  end
  nav 'next'
  after_action()
end

--- Reject the hunk under the cursor: reset it to the baseline, mark resolved,
--- advance. reset_hunk is async, so the follow-up runs in its callback.
local function reject_current()
  if not S then
    return
  end
  local gs = gitsigns()
  if not gs then
    return
  end
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  local entry = entry_for_buf(buf)
  if not entry then
    return
  end
  if entry.is_new then
    delete_new_file(entry)
    entry.resolved.__file__ = 'reject'
    notify 'RosaAI: discarded new file'
    after_action()
    return
  end
  local h = find_hunk_under_cursor(entry, win)
  if not h then
    return
  end
  local sig = hunk_sig(h)
  local s, e = hunk_range(h)
  -- Position at the hunk so gitsigns resolves the right one from the range.
  local last = api.nvim_buf_line_count(buf)
  pcall(api.nvim_win_set_cursor, win, { math.min(s, last), 0 })
  local ok = pcall(gs.reset_hunk, { s, e }, nil, vim.schedule_wrap(function()
    if S and entry then
      entry.resolved[sig] = 'reject'
    end
    write_buf(buf)
    nav 'next'
    after_action()
  end))
  if not ok then
    notify('RosaAI: could not reject hunk', vim.log.levels.WARN)
  end
end

-- ---------------------------------------------------------------------------
-- Whole-file keep / reject (panel commands)
-- ---------------------------------------------------------------------------

--- Keep every remaining hunk in a file (mark them all resolved as kept).
local function keep_file(i)
  local e = S and S.files[i]
  if not e then
    return
  end
  if e.is_new then
    e.resolved.__file__ = 'keep'
    after_action()
    render_panel()
    return
  end
  for _, h in ipairs(unresolved_of(e)) do
    e.resolved[hunk_sig(h)] = 'keep'
  end
  after_action()
  render_panel()
end

--- Reject a whole file: delete it if new, else reset the buffer to baseline.
local function reject_file(i)
  local e = S and S.files[i]
  if not e then
    return
  end
  if e.is_new then
    delete_new_file(e)
    e.resolved.__file__ = 'reject'
    after_action()
    render_panel()
    return
  end
  local gs = gitsigns()
  if not gs or not api.nvim_buf_is_valid(e.bufnr) then
    return
  end
  -- Capture sigs before the reset removes the hunks, then mark them rejected.
  local hunks = get_hunks_of(e.bufnr)
  -- reset_buffer is synchronous and operates on the current buffer; run it
  -- with the target buffer current without leaving the panel.
  pcall(api.nvim_buf_call, e.bufnr, function()
    gs.reset_buffer()
  end)
  write_buf(e.bufnr)
  for _, h in ipairs(hunks) do
    e.resolved[hunk_sig(h)] = 'reject'
  end
  after_action()
  render_panel()
end

-- ---------------------------------------------------------------------------
-- Completion
-- ---------------------------------------------------------------------------

--- Refresh the chip and, when nothing is left to review, notify + teardown.
after_action = function()
  if not S then
    return
  end
  update_chip()
  if all_resolved() then
    vim.schedule(function()
      if S and all_resolved() then
        notify 'RosaAI: review complete'
        M.close()
      end
    end)
  end
end

-- ---------------------------------------------------------------------------
-- Overview panel
-- ---------------------------------------------------------------------------

close_panel = function()
  if S and S.panel and S.panel.win and api.nvim_win_is_valid(S.panel.win) then
    pcall(api.nvim_win_close, S.panel.win, true)
  end
  if S and S.panel then
    S.panel.win = nil
  end
end

render_panel = function()
  if not S or not S.panel then
    return
  end
  local buf = S.panel.buf
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end
  local sel = S.panel.sel or 1
  local pad = '  '
  local lines, hls = {}, {}

  local function add(line)
    table.insert(lines, line)
    return #lines - 1
  end

  add ''
  for i, e in ipairs(S.files) do
    local name = fn.fnamemodify(e.file, ':t')
    local total = math.max(e.total, resolved_count(e))
    local done = resolved_count(e)
    local marker = (i == sel) and '▸ ' or '  '
    local name_col = name .. string.rep(' ', math.max(1, 20 - #name))
    local hunks_txt = e.is_new and 'new file' or string.format('%d hunk%s', total, total == 1 and '' or 's')
    local prog = string.format('(%d/%d)', done, total)
    local line = pad .. marker .. name_col .. hunks_txt .. '   ' .. prog
    local row = add(line)
    local name_start = #pad + #marker
    table.insert(hls, { (i == sel) and 'RosaReviewTitle' or 'RosaReviewText', row, name_start, name_start + #name })
    local complete = total > 0 and done >= total
    table.insert(hls, { complete and 'RosaReviewKept' or 'RosaReviewDim', row, #line - #prog, -1 })
  end
  add ''

  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  api.nvim_buf_clear_namespace(buf, panel_ns, 0, -1)
  for _, h in ipairs(hls) do
    pcall(api.nvim_buf_add_highlight, buf, panel_ns, h[1], h[2], h[3], h[4])
  end
end

--- Jump to a file's first unresolved hunk in a normal window; close the panel
--- but keep the review active.
local function jump_to(i)
  local e = S and S.files[i]
  if not e then
    return
  end
  local target = unresolved_of(e)[1] or get_hunks_of(e.bufnr)[1]
  close_panel()
  local win = pick_main_win()
  pcall(api.nvim_win_set_buf, win, e.bufnr)
  api.nvim_set_current_win(win)
  S.source_win = win
  if target then
    local s = hunk_range(target)
    local last = api.nvim_buf_line_count(e.bufnr)
    pcall(api.nvim_win_set_cursor, win, { math.min(s, last), 0 })
  end
  update_chip()
end

--- Open (or refocus) the floating overview panel listing every changed file.
open_panel = function()
  if not S then
    return
  end
  S.panel = S.panel or {}
  if S.panel.win and api.nvim_win_is_valid(S.panel.win) then
    api.nvim_set_current_win(S.panel.win)
    render_panel()
    return
  end
  S.panel.sel = S.panel.sel or 1

  local width = 56
  local height = math.max(4, math.min(#S.files + 2, vim.o.lines - 4))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'

  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  local win_border = ok and themes.current().window or 'rounded'
  if not win_border or win_border == 'none' then
    win_border = 'rounded'
  end

  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = win_border,
    title = { { '  RosaAI Review ', 'Title' } },
    title_pos = 'center',
    footer = ' ↵ jump · a keep · r reject · A/R all · q close ',
    footer_pos = 'center',
    zindex = 50,
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosaReviewBorder,FloatTitle:RosaReviewTitle,FloatFooter:RosaReviewDim'
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].cursorline = false

  S.panel.buf = buf
  S.panel.win = win

  local kopts = { buffer = buf, silent = true, nowait = true }
  local function move(delta)
    S.panel.sel = math.max(1, math.min(#S.files, (S.panel.sel or 1) + delta))
    render_panel()
  end
  vim.keymap.set('n', 'j', function()
    move(1)
  end, kopts)
  vim.keymap.set('n', 'k', function()
    move(-1)
  end, kopts)
  vim.keymap.set('n', '<Down>', function()
    move(1)
  end, kopts)
  vim.keymap.set('n', '<Up>', function()
    move(-1)
  end, kopts)
  vim.keymap.set('n', '<CR>', function()
    jump_to(S.panel.sel or 1)
  end, kopts)
  vim.keymap.set('n', 'a', function()
    keep_file(S.panel.sel or 1)
  end, kopts)
  vim.keymap.set('n', 'r', function()
    reject_file(S.panel.sel or 1)
  end, kopts)
  vim.keymap.set('n', 'A', function()
    M.keep_all()
  end, kopts)
  vim.keymap.set('n', 'R', function()
    M.reject_all()
  end, kopts)
  vim.keymap.set('n', 'q', close_panel, kopts)
  vim.keymap.set('n', '<Esc>', close_panel, kopts)

  render_panel()
end

-- ---------------------------------------------------------------------------
-- Buffer-local review keymaps
-- ---------------------------------------------------------------------------

--- lhs list installed in every reviewed source buffer (removed on teardown).
--- Each entry is { lhs, rhs, desc } — the desc is what which-key shows, so
--- every key reads distinctly instead of a generic "RosaAI review".
local BUFFER_MAPS = {
  {
    ']h',
    function()
      nav 'next'
      update_chip()
    end,
    'RosaAI: Next Hunk',
  },
  {
    '[h',
    function()
      nav 'prev'
      update_chip()
    end,
    'RosaAI: Prev Hunk',
  },
  { '<leader>ak', keep_current, 'RosaAI: Keep Hunk' },
  { '<leader>ax', reject_current, 'RosaAI: Reject Hunk' },
  {
    '<leader>aK',
    function()
      M.keep_all()
    end,
    'RosaAI: Keep All Hunks',
  },
  {
    '<leader>aX',
    function()
      M.reject_all()
    end,
    'RosaAI: Reject All Hunks',
  },
  {
    '<leader>ar',
    function()
      open_panel()
    end,
    'RosaAI: Review Panel',
  },
}

install_buffer_keymaps = function(bufnr)
  for _, m in ipairs(BUFFER_MAPS) do
    pcall(vim.keymap.set, 'n', m[1], m[2], {
      buffer = bufnr,
      silent = true,
      nowait = true,
      desc = m[3] or 'RosaAI review',
    })
  end
end

remove_buffer_keymaps = function(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  for _, m in ipairs(BUFFER_MAPS) do
    pcall(vim.keymap.del, 'n', m[1], { buffer = bufnr })
  end
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Finalize an open() once hunks are available: build state, wire keymaps and
--- autocmds, and show the overview panel.
finalize = function(entries)
  local total = 0
  for _, e in ipairs(entries) do
    total = total + e.total
  end
  if total == 0 then
    -- Nothing diffable against the baseline — tear down what we set up.
    local gs = gitsigns()
    if gs then
      pcall(gs.change_base, nil, true)
      pcall(gs.toggle_linehl, false)
      pcall(gs.toggle_deleted, false)
    end
    restore_gitsigns()
    opening = false
    notify 'RosaAI: no AI changes to review'
    return
  end

  S = {
    files = entries,
    source_win = nil,
    chip = {},
    panel = {},
    au = api.nvim_create_augroup('RosaReviewSession', { clear = true }),
  }
  opening = false

  for _, e in ipairs(entries) do
    install_buffer_keymaps(e.bufnr)
  end

  -- Keep the chip in sync as the cursor moves through reviewed buffers.
  api.nvim_create_autocmd('CursorMoved', {
    group = S.au,
    callback = function()
      if not S then
        return
      end
      if entry_for_buf(api.nvim_get_current_buf()) then
        update_chip()
      end
    end,
  })

  open_panel()
end

--- Centered popup shown when the review is invoked OUTSIDE a git repository.
--- The review diffs against git, so without a repo it cannot run. Git is
--- opt-in here: this only informs — it never creates a repo for the user.
local function needs_git_popup()
  setup_highlights()
  local ns = api.nvim_create_namespace 'rosareview_gitwarn'
  local lines = {
    '',
    "  This folder isn't a git repository.",
    '',
    '  RosaAI Review compares your files against git',
    '  to show what the AI changed, so it needs a repo.',
    '',
    '  Optional: run  git init  here to enable it.',
    '',
  }
  local width = 52
  local height = #lines
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local ok, themes = pcall(require, 'rosavim.rosa_plugins.rosaai.themes')
  local border = ok and themes.current().window or 'rounded'
  if not border or border == 'none' then
    border = 'rounded'
  end

  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = border,
    title = { { ' RosaAI Review · needs Git ', 'RosaReviewTitle' } },
    title_pos = 'center',
    footer = ' q · close ',
    footer_pos = 'center',
    zindex = 60,
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosaReviewBorder,FloatTitle:RosaReviewTitle,FloatFooter:RosaReviewDim'
  vim.wo[win].cursorline = false

  api.nvim_buf_add_highlight(buf, ns, 'RosaReviewText', 1, 0, -1)
  api.nvim_buf_add_highlight(buf, ns, 'RosaReviewDim', 3, 0, -1)
  api.nvim_buf_add_highlight(buf, ns, 'RosaReviewDim', 4, 0, -1)
  api.nvim_buf_add_highlight(buf, ns, 'RosaReviewKey', 6, 0, -1)

  local function close()
    if api.nvim_win_is_valid(win) then
      pcall(api.nvim_win_close, win, true)
    end
  end
  for _, k in ipairs { 'q', '<Esc>' } do
    vim.keymap.set('n', k, close, { buffer = buf, nowait = true, silent = true })
  end
end

--- Full review flow. No-op (with a friendly notify/popup) when there is no
--- git repo, no baseline, or nothing changed.
function M.open()
  if S or opening then
    return
  end
  if not review_enabled() then
    return
  end
  local gs = gitsigns()
  if not gs then
    notify('RosaAI: gitsigns is not installed', vim.log.levels.WARN)
    return
  end
  -- The review is git-based. Outside a repo there is nothing to diff, so show
  -- a clear popup (git stays opt-in — we never init a repo for the user).
  if not snapshot.has_git() then
    needs_git_popup()
    return
  end
  local sha = snapshot.current()
  if not sha then
    notify 'RosaAI: no review baseline yet (open a CLI first)'
    return
  end

  opening = true
  snapshot.changed_files(function(files)
    if not files or #files == 0 then
      opening = false
      notify 'RosaAI: no AI changes to review'
      return
    end

    setup_highlights()
    restyle_gitsigns()

    -- Point gitsigns at the baseline FIRST, then (inside the callback) load,
    -- reload, and re-attach each touched buffer so it attaches FRESH with the
    -- baseline as its diff base. gitsigns.change_base only affects buffers that
    -- attach AFTER it — it does not re-diff already-attached ones — so a plain
    -- attach on a buffer left over from a previous review would keep the old
    -- (HEAD) base and leak non-AI changes. detach→attach + refresh guarantees a
    -- clean re-diff against the snapshot.
    local function apply_base()
      -- Wait for a prior close()'s async base reset to land first, so it can't
      -- clobber the baseline we set here on a fast reopen.
      if base_reset_pending then
        vim.defer_fn(apply_base, 30)
        return
      end
      local ok = pcall(gs.change_base, sha, true, function()
      local entries = {}
      -- gitsigns only diffs a buffer that is shown in a window; a purely
      -- bufadd'd (hidden) buffer attaches but never computes hunks. So each
      -- changed buffer is briefly displayed in a tiny off-side, non-focusable
      -- float to prime the diff. The hunks persist after the float closes, so
      -- the panel counts, highlights and keep/reject all work afterwards.
      local prime_wins = {}
      for _, f in ipairs(files) do
        local path = f.path
        local b = fn.bufadd(path)
        pcall(fn.bufload, b)
        -- Reload unmodified buffers that were already open before the AI edited
        -- them (a stale buffer would otherwise diff against the wrong content).
        pcall(api.nvim_buf_call, b, function()
          if not vim.bo.modified then
            vim.cmd 'silent! edit'
          end
        end)
        -- Untracked new files can't be hunk-diffed by gitsigns; they are
        -- reviewed whole-file, so they need no priming.
        if not f.new then
          pcall(function()
            gs.detach(b)
          end)
          local pok, pw = pcall(api.nvim_open_win, b, false, {
            relative = 'editor',
            row = 0,
            col = 0,
            width = 1,
            height = 1,
            focusable = false,
            style = 'minimal',
            zindex = 1,
          })
          if pok then
            prime_wins[#prime_wins + 1] = pw
          end
          pcall(function()
            gs.attach(b)
          end)
        end
        entries[#entries + 1] = { file = path, bufnr = b, total = 0, resolved = {}, is_new = f.new or false }
      end

      pcall(gs.toggle_linehl, true)
      pcall(gs.toggle_deleted, true)
      pcall(gs.refresh)

      local function close_prime()
        for _, w in ipairs(prime_wins) do
          if api.nvim_win_is_valid(w) then
            pcall(api.nvim_win_close, w, true)
          end
        end
        prime_wins = {}
      end

      -- Poll (while the priming floats keep the buffers diffed) until the total
      -- hunk count is non-zero AND stable across several reads, so we never
      -- capture a transient count before the baseline re-diff has settled.
      local tries, stable, last = 0, 0, -1
      local function ready()
        if not opening then
          close_prime()
          return
        end
        tries = tries + 1
        local total = 0
        for _, e in ipairs(entries) do
          if e.is_new then
            e.total = 1 -- a new file is one whole-file decision
          else
            e.total = #get_hunks_of(e.bufnr)
          end
          total = total + e.total
        end
        if total > 0 and total == last then
          stable = stable + 1
        else
          stable = 0
        end
        last = total
        if (total > 0 and stable >= 3) or tries >= 30 then
          close_prime()
          finalize(entries)
        else
          vim.defer_fn(ready, 150)
        end
      end
      vim.defer_fn(ready, 150)
    end)

      if not ok then
        opening = false
        restore_gitsigns()
        notify('RosaAI: failed to set diff base', vim.log.levels.WARN)
      end
    end
    apply_base()
  end)
end

--- Full teardown: revert the diff base, turn highlights off, remove keymaps
--- and windows, clear state, and RE-ARM the baseline to the now-current
--- (accepted or reverted) state — so a later AI edit on the same files is
--- reviewable again within the same CLI session.
function M.close()
  local gs = gitsigns()
  -- Gate any fast reopen until this teardown's git activity has fully settled:
  -- both the base reset AND the re-baseline's `git stash create` write, which
  -- pokes the .git dir and makes gitsigns' gitdir watcher re-diff the buffers
  -- against HEAD — clobbering the next review's baseline if it opens too soon.
  base_reset_pending = true
  if gs then
    pcall(gs.change_base, nil, true)
    pcall(gs.toggle_linehl, false)
    pcall(gs.toggle_deleted, false)
  end

  close_chip()
  close_panel()

  if S then
    for _, e in ipairs(S.files) do
      remove_buffer_keymaps(e.bufnr)
      -- Detach gitsigns so no stale attachment (still pinned to the old base)
      -- survives into the next review; the next open re-attaches these buffers
      -- fresh against the new baseline.
      if gs then
        pcall(gs.detach, e.bufnr)
      end
    end
    if S.au then
      pcall(api.nvim_clear_autocmds, { group = S.au })
    end
  end

  restore_gitsigns()
  S = nil
  opening = false
  -- Re-baseline to the current state so the next AI turn on these files is
  -- reviewable again (previously this dropped the baseline, which made a
  -- second edit to a just-kept file show up as "no baseline yet"). Clear the
  -- reopen gate only after the stash-create write has landed and gitsigns'
  -- watcher has had a moment to process it.
  snapshot.mark(function()
    vim.defer_fn(function()
      base_reset_pending = false
      -- Recompute the pending badge now that the baseline moved (usually 0).
      M.refresh_pending()
    end, 400)
  end)
  -- Safety net so the gate never sticks if the callback never fires.
  vim.defer_fn(function()
    base_reset_pending = false
  end, 3000)
end

--- Open if closed, else close.
function M.toggle()
  if S then
    M.close()
  else
    M.open()
  end
end

--- Whether a review is currently active.
function M.is_open()
  return S ~= nil
end

--- Accept every AI change and tear down (nothing is reverted).
function M.keep_all()
  if not S then
    return
  end
  notify 'RosaAI: kept all AI changes'
  M.close()
end

--- Revert every touched buffer to the baseline, then tear down.
function M.reject_all()
  if not S then
    return
  end
  local gs = gitsigns()
  local n = 0
  for _, e in ipairs(S.files) do
    if e.is_new then
      delete_new_file(e)
      n = n + 1
    elseif gs and api.nvim_buf_is_valid(e.bufnr) then
      pcall(api.nvim_buf_call, e.bufnr, function()
        gs.reset_buffer()
      end)
      write_buf(e.bufnr)
      n = n + 1
    end
  end
  notify(string.format('RosaAI: discarded %d file%s', n, n == 1 and '' or 's'))
  M.close()
end

-- ---------------------------------------------------------------------------
-- Pending-review indicator
-- ---------------------------------------------------------------------------

--- Cached count of files changed vs the baseline but not yet reviewed, shown
--- as a small badge on the CLI chip so accumulated AI edits stay visible.
local pending = 0

--- The cached number of AI-changed files awaiting review (0 when none, no
--- baseline, or not a git repo). Read synchronously by the chip renderer.
function M.pending_count()
  return pending
end

--- Recompute the pending-review count (async) and refresh the CLI chips when
--- it changes. Cheap (one git diff); safe to call on show / focus-out / timer.
function M.refresh_pending()
  if not review_enabled() then
    -- Feature off: clear the badge if it was showing.
    if pending ~= 0 then
      pending = 0
      local rok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
      if rok and rosaai.refresh_chips then
        rosaai.refresh_chips()
      end
    end
    return
  end
  return pcall(function()
    snapshot.changed_files(function(files)
      local n = files and #files or 0
      if n ~= pending then
        pending = n
        local rok, rosaai = pcall(require, 'rosavim.rosa_plugins.rosaai')
        if rok and rosaai.refresh_chips then
          rosaai.refresh_chips()
        end
      end
    end)
  end)
end

--- Debounced auto-open hook. Gated by the `rosaai_auto_review` toggle and the
--- presence of a baseline; opens the review ~800ms after edits settle when
--- there is something to review and one is not already open.
function M.notify_ai_edit()
  if not review_enabled() then
    return
  end
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok or not toggles.get 'rosaai_auto_review' then
    return
  end
  if not snapshot.current() then
    return
  end

  if debounce_timer then
    pcall(function()
      debounce_timer:stop()
    end)
  end
  debounce_timer = debounce_timer or (vim.uv or vim.loop).new_timer()
  debounce_timer:start(
    800,
    0,
    vim.schedule_wrap(function()
      if S or not snapshot.current() then
        return
      end
      snapshot.changed_files(function(files)
        if files and #files > 0 and not S then
          M.open()
        end
      end)
    end)
  )
end

return M

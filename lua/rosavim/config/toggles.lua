local M = {}

local cache_file = vim.fn.stdpath 'cache' .. '/rosavim-toggles'

local defaults = {
  lualine = true,
  lualine_theme = true,
  lualine_separator = 'rounded', -- rounded | bar | arrow | slant
  lualine_bar_y_transparent = true, -- true (default) = y/centre bar transparent, blends with theme bg; false = original solid #1a1a1a bar
  -- Borderless: paint a tool's borders the same colour as its bg, in every
  -- rosa theme. One per tool, All flips them together. See
  -- rosavim.config.borderless.
  borderless_whichkey = false,
  borderless_snacks = false,
  borderless_rosapick = false,
  borderless_blink = false,
  borderless_rosaterm = false,
  borderless_rosaai = false,
  borderless_notify = false,
  -- Invert Backgrounds: swap a theme's editor surface with its explorer/tab
  -- chrome surface. One per theme, see
  -- rosavim.config.invert_bg.
  rosajet_invert = false,
  rosamin_invert = false,
  rosavintage_invert = false,
  -- Rosagawa Gutter BG (<leader>lqu): rosagawa's LineNr/CursorLineNr/
  -- SignColumn/FoldColumn paint a grey gutter strip distinct from the editor
  -- bg by design. false (default) keeps that characteristic look; true
  -- flattens the gutter to match the editor bg instead. See the overrides in
  -- rosavim.plugins.ui.colorschemes.rosagawa.overrides.
  rosagawa_gutter_flat = false,
  dropbar = true,
  autosave = false,
  virtual_text_current_line = false,
  spell = false,
  spelllang = 'en',
  relativenumber = true,
  linenumber = true,
  indent = true,
  scroll = true,
  dim = false,
  wrap = false,
  cursor_block = true,
  cursorline = true,
  -- Autocmd toggles
  lastpos = false,
  autoread = true, -- reload buffers changed on disk (RosaAI, git, etc.) on focus/idle
  dotenv_syntax = true,
  no_auto_comment = true,
  autosave_focuslost = true,
  snacks_explorer = false,
  snacks_explorer_focus = false,
  lsp_ref_highlights = true,
  dbout_no_folding = true,
  copilot = false,
  copilot_lualine = true, -- show the copilot icon on lualine
  incline = true,
  bufferline = true,
  picker_hidden = false,
  picker_ignored = true,
  picker_layout = 'default',
  picker_preview = true,
  picker_border = 'rounded',
  whichkey_preset = 'modern',
  whichkey_border = 'single',
  explorer_right = false,
  explorer_preview = false,
  -- RosaAI
  rosaai_position = 'right',
  rosaai_size = 'default',
  rosaai_theme = 'garland',
  rosaai_title = true,
  rosaai_time = true,
  rosaai_autoinsert = true,
  rosaai_auto_focus = true,
  rosaai_vertical_border = true,
  rosaai_horizontal_border = true,
  rosaai_dark_bg = true, -- light mode: force #000
  rosaai_dark_bg_dm = false, -- dark mode: force #000
  rosaai_review = true, -- master switch for the Review feature
  rosaai_auto_review = false, -- auto-open the AI-changes review
  rosaai_review_badge = true, -- show the pending-review count on the chip
  -- Rosamaximize
  rosamaximize_lualine = true, -- show the zoom indicator on lualine
  rosamaximize_badge = true, -- show the floating zoom badge on the buffer
  rosamaximize_name = true, -- show the "max" text (true) or icon only (false)
  rosamaximize_border = 'rounded', -- badge border: none | rounded | single
  -- Rosazen (distraction-free mode) — persisted across sessions
  rosazen = false,
  git_blame = true,
  render_markdown = true,
  render_markdown_theme = 'none', -- none | lazy | obsidian
  image_preview = false,
  -- Todo Comments
  todo_comments = true,
  todo_comments_bg = true,
  todo_comments_fg = false,
  -- Rosaterm
  rosaterm_title = true,
  rosaterm_time = true,
  rosaterm_theme = 'garland',
  rosaterm_size = 'default',
  rosaterm_autoinsert = true, -- insert mode when a terminal opens
  rosaterm_focus_insert = true, -- insert mode when focus lands on it
  rosaterm_vertical_border = false,
  rosaterm_horizontal_border = false,
  rosaterm_name_full = true,
  rosaterm_icon_visible = true,
  rosaterm_icon_style = 'terminal', -- 'rosa' | 'terminal'
  rosaterm_dark_bg = true, -- light mode: force #000
  rosaterm_dark_bg_dm = false, -- dark mode: force #000
  -- Rosatag
  rosatag = true, -- master switch: off disables the whole plugin
  rosatag_close = true, -- auto close tag
  rosatag_rename = true, -- auto live rename tag
  -- Yazi / Lazygit background overrides (force #000, same light+dark scheme)
  yazi_dark_bg = true, -- light mode: force #000
  yazi_dark_bg_dm = false, -- dark mode: force #000
  lazygit_dark_bg = true, -- light mode: force #000
  lazygit_dark_bg_dm = false, -- dark mode: force #000
  -- Dropbar
  dropbar_compact = false, -- false = full path (16 segments), true = parent + filename only
  dropbar_path_preview = true,
  -- Dashboard gif (chafa)
  dashboard_gif = false,
  dashboard_gif_name = 'gopher.gif',
  dashboard_gif_height = 8,
  dashboard_gif_width = 20,
  dashboard_gif_indent = 50,
}

M._state = nil

--- The single Borderless toggle became one per tool: carry its state over once
--- and drop the old key from the cache.
function M._migrate_borderless()
  if M._state.theme_borderless == nil then
    return
  end
  local on = M._state.theme_borderless == true
  M._state.theme_borderless = nil
  if on then
    for key in pairs(defaults) do
      if key:sub(1, 11) == 'borderless_' then
        M._state[key] = true
      end
    end
  end
  M._save()
end

function M._load()
  if M._state then
    return M._state
  end
  local ok, content = pcall(vim.fn.readfile, cache_file)
  if ok and content[1] then
    local decoded = vim.json.decode(content[1])
    if decoded then
      M._state = vim.tbl_deep_extend('force', vim.deepcopy(defaults), decoded)
      M._migrate_borderless()
      return M._state
    end
  end
  M._state = vim.deepcopy(defaults)
  return M._state
end

function M._save()
  local json = vim.json.encode(M._state)
  vim.fn.writefile({ json }, cache_file)
end

function M.get(key)
  local state = M._load()
  return state[key]
end

function M.set(key, value)
  local state = M._load()
  state[key] = value
  M._save()
end

--- Like get(), but with a fallback when the module may not be loaded yet or
--- the key is unset. Lets callers drop the pcall(require) + nil-check dance.
function M.get_or(key, default)
  local value = M.get(key)
  if value == nil then
    return default
  end
  return value
end

--- Set several keys with a single disk write (set() writes the whole JSON
--- file per call, so batch updates like "force dark bg: all" should not pay
--- one write per key).
function M.set_many(values)
  local state = M._load()
  for key, value in pairs(values) do
    state[key] = value
  end
  M._save()
end

function M.toggle(key)
  local state = M._load()
  state[key] = not state[key]
  M._save()
  return state[key]
end

return M

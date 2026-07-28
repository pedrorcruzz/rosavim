--- Rosamaximize - Window maximizer for Rosavim
--- No mksession — manually saves and restores window layout to avoid
--- buggy behavior with special buffers (snacks explorer, rosaai).
local M = {}

local state = nil
local indicator = nil

local function opt(key)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return true
  end
  return toggles.get(key)
end

local function hide_indicator()
  if indicator then
    if indicator.win and vim.api.nvim_win_is_valid(indicator.win) then
      vim.api.nvim_win_close(indicator.win, true)
    end
    if indicator.buf and vim.api.nvim_buf_is_valid(indicator.buf) then
      vim.api.nvim_buf_delete(indicator.buf, { force = true })
    end
    indicator = nil
  end
end

local function show_indicator()
  hide_indicator()
  if opt 'rosamaximize_badge' == false then
    return
  end
  local fg = vim.o.background == 'light' and '#000000' or '#A3AAB8'
  vim.api.nvim_set_hl(0, 'RosamaximizeZoom', { fg = fg })
  local text = opt 'rosamaximize_name' == false and '▍ 󰊓  ' or '▍ max  󰊓  '
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  local border = opt 'rosamaximize_border' or 'rounded'
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    anchor = 'NE',
    row = 1,
    col = vim.o.columns,
    width = vim.api.nvim_strwidth(text),
    height = 1,
    focusable = false,
    style = 'minimal',
    border = border,
    noautocmd = true,
    zindex = 50,
  })
  vim.wo[win].winhighlight = 'NormalFloat:RosamaximizeZoom,FloatBorder:RosamaximizeZoom'
  indicator = { win = win, buf = buf }
end

local function refresh_statusline()
  pcall(function()
    require('lualine').refresh()
  end)
end

-- #TODO: This is a bit hacky but it works for now. The main issue is that mksession doesn't handle the snacks explorer or rosaai windows well — they end up taking up space in the layout and causing weirdness when restored. To work around this, we manually snapshot and restore the layout, filtering out any special windows. This way we can maximize just the "real" buffers and then restore everything else afterward.

local function is_special_buf(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return true
  end
  return vim.bo[buf].filetype == 'snacks_explorer' or vim.b[buf].rosaai_cli ~= nil
end

local function explorer_is_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'snacks_explorer' then
      return true
    end
  end
  return false
end

local function rosaai_is_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.b[vim.api.nvim_win_get_buf(win)].rosaai_cli then
      return true
    end
  end
  return false
end

--- Save the layout tree, filtering out special windows
local function snapshot(layout)
  if layout[1] == 'leaf' then
    local win = layout[2]
    local buf = vim.api.nvim_win_get_buf(win)
    if is_special_buf(buf) then
      return nil
    end
    return {
      type = 'leaf',
      buf = buf,
      width = vim.api.nvim_win_get_width(win),
      height = vim.api.nvim_win_get_height(win),
      cursor = vim.api.nvim_win_get_cursor(win),
      is_current = (win == vim.api.nvim_get_current_win()),
    }
  end

  local children = {}
  for _, child in ipairs(layout[2]) do
    local node = snapshot(child)
    if node then
      children[#children + 1] = node
    end
  end

  if #children == 0 then
    return nil
  end
  if #children == 1 then
    return children[1]
  end
  return { type = layout[1], children = children }
end

--- Recreate the layout tree in the given window
local function rebuild(node, win)
  if node.type == 'leaf' then
    if vim.api.nvim_buf_is_valid(node.buf) then
      vim.api.nvim_win_set_buf(win, node.buf)
    end
    return { { win = win, width = node.width, height = node.height, cursor = node.cursor, is_current = node.is_current } }
  end

  local is_vertical = (node.type == 'row')
  local all = {}
  local prev_win = win

  for i, child in ipairs(node.children) do
    local target
    if i == 1 then
      target = win
    else
      vim.api.nvim_set_current_win(prev_win)
      vim.cmd(is_vertical and 'rightbelow vsplit' or 'rightbelow split')
      target = vim.api.nvim_get_current_win()
    end
    local wins = rebuild(child, target)
    prev_win = wins[#wins].win
    vim.list_extend(all, wins)
  end

  return all
end

function M.is_maximized()
  return state ~= nil
end

function M.maximize(opts)
  if state then
    return
  end

  opts = opts or {}
  local had_explorer = explorer_is_open()
  local had_rosaai = rosaai_is_open()

  -- Close special windows FIRST so they don't occupy layout space
  if had_rosaai then
    pcall(function()
      require('rosavim.rosa_plugins.rosaai').hide()
    end)
  end
  if had_explorer then
    pcall(function()
      Snacks.explorer()
    end)
  end

  -- Snapshot AFTER closing — layout now only has real buffer windows
  local tree = snapshot(vim.fn.winlayout())
  if not tree then
    return
  end

  state = {
    tree = tree,
    had_explorer = had_explorer,
    had_rosaai = had_rosaai,
    indicator = opts.indicator ~= false,
  }

  vim.cmd 'silent! only'

  if state.indicator then
    show_indicator()
    refresh_statusline()
  end
end

function M.restore()
  if not state then
    return
  end

  hide_indicator()

  local s = state
  state = nil

  -- Rebuild the saved layout
  local win = vim.api.nvim_get_current_win()
  local wins = rebuild(s.tree, win)

  -- Restore sizes (two passes for accuracy)
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w.win) then
      vim.api.nvim_win_set_width(w.win, w.width)
    end
  end
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w.win) then
      vim.api.nvim_win_set_height(w.win, w.height)
    end
  end

  -- Restore cursors and find the original focused window
  local focus_win = nil
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w.win) then
      pcall(vim.api.nvim_win_set_cursor, w.win, w.cursor)
      if w.is_current then
        focus_win = w.win
      end
    end
  end

  -- Focus the original window BEFORE reopening specials
  if focus_win and vim.api.nvim_win_is_valid(focus_win) then
    vim.api.nvim_set_current_win(focus_win)
  end

  -- Kill any stale explorer picker instance so the toggle opens fresh
  if s.had_explorer then
    pcall(function()
      local existing = Snacks.picker.get { source = 'explorer' }
      for _, p in ipairs(existing) do
        p:close()
      end
      Snacks.explorer()
    end)
  end
  if s.had_rosaai then
    pcall(function()
      require('rosavim.rosa_plugins.rosaai').show()
    end)
  end

  -- Ensure focus stays on the buffer, not on explorer/rosaai
  if focus_win and vim.api.nvim_win_is_valid(focus_win) then
    vim.api.nvim_set_current_win(focus_win)
  end

  refresh_statusline()
end

function M.toggle()
  if M.is_maximized() then
    M.restore()
  else
    M.maximize()
  end
end

--- Text shown on the lualine indicator, honoring the name/icon toggle.
function M.lualine_label()
  return opt 'rosamaximize_name' == false and '󰊓' or '󰊓 max'
end

--- Whether the lualine indicator should render right now.
function M.lualine_visible()
  return M.is_maximized() and opt 'rosamaximize_lualine' ~= false
end

--- Re-render the badge and statusline to reflect the current toggle states.
function M.refresh()
  if M.is_maximized() then
    show_indicator()
  else
    hide_indicator()
  end
  refresh_statusline()
end

return M

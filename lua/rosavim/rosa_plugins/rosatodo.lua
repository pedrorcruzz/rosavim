local M = {}

local toggles = require 'rosavim.config.toggles'

local KEYWORDS = { 'TODO', 'FIX', 'HACK', 'WARN', 'PERF', 'NOTE', 'TEST' }

function M.ensure_loaded()
  if not package.loaded['todo-comments'] then
    require('lazy').load { plugins = { 'todo-comments.nvim' } }
  end
end

function M.force_fg()
  for _, kw in ipairs(KEYWORDS) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = 'TodoBg' .. kw })
    if ok and hl.bg then
      vim.api.nvim_set_hl(0, 'TodoBg' .. kw, { bg = hl.bg, fg = '#111111', bold = true })
    end
  end
end

function M.apply_style()
  local ok, cfg = pcall(require, 'todo-comments.config')
  if not ok or not cfg.options or not cfg.options.highlight then
    return
  end
  local bg = toggles.get 'todo_comments_bg'
  local fg = toggles.get 'todo_comments_fg'
  cfg.options.highlight.keyword = bg and 'wide' or (fg and 'fg' or '')
  cfg.options.highlight.after = (bg or fg) and 'fg' or ''
  cfg.options.signs = (bg or fg) and true or false
  M.force_fg()
  if toggles.get 'todo_comments' then
    local hl = require 'todo-comments.highlight'
    hl.stop()
    hl.start()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_is_valid(buf) then
          hl.attach(win)
          hl.invalidate(buf, 0, -1)
        end
      end
    end
  end
end

local function ready()
  local ok, cfg = pcall(require, 'todo-comments.config')
  return ok and cfg.options and cfg.options.highlight ~= nil
end

function M.restore()
  local function try(attempt)
    if ready() then
      M.apply_style()
      if not toggles.get 'todo_comments' then
        require('todo-comments').disable()
      end
    elseif attempt < 100 then
      vim.defer_fn(function()
        try(attempt + 1)
      end, 20)
    end
  end
  try(0)
end

function M.set_enabled(state)
  M.ensure_loaded()
  toggles.set('todo_comments', state)
  if state then
    M.apply_style()
  else
    require('todo-comments').disable()
  end
end

function M.set_bg(state)
  M.ensure_loaded()
  toggles.set('todo_comments_bg', state)
  if state then
    toggles.set('todo_comments_fg', false)
  end
  M.apply_style()
end

function M.set_fg(state)
  M.ensure_loaded()
  toggles.set('todo_comments_fg', state)
  if state then
    toggles.set('todo_comments_bg', false)
  end
  M.apply_style()
end

return M

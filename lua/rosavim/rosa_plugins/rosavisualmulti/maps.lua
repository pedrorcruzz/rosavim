local M = {}

local state = require 'rosavim.rosa_plugins.rosavisualmulti.state'
local cursors = require 'rosavim.rosa_plugins.rosavisualmulti.cursors'
local edit = require 'rosavim.rosa_plugins.rosavisualmulti.edit'
local insert = require 'rosavim.rosa_plugins.rosavisualmulti.insert'

local active_buf = nil

M.keys = {
  { 'n', 'next occurrence', cursors.next_occurrence },
  { 'N', 'previous occurrence', cursors.prev_occurrence },
  { ']', 'next cursor', cursors.goto_next },
  { '[', 'previous cursor', cursors.goto_prev },
  { 'q', 'skip and take next', cursors.skip },
  { 'Q', 'remove cursor', cursors.remove_current },
  {
    'i',
    'insert before',
    function()
      insert.begin 'i'
    end,
  },
  {
    'a',
    'insert after',
    function()
      insert.begin 'a'
    end,
  },
  {
    'I',
    'insert at line start',
    function()
      insert.begin 'I'
    end,
  },
  {
    'A',
    'insert at line end',
    function()
      insert.begin 'A'
    end,
  },
  {
    'c',
    'change selection',
    function()
      insert.begin 'c'
    end,
  },
  { 'd', 'delete selection', edit.delete },
  { 'x', 'delete selection', edit.delete },
  {
    'D',
    'delete lines',
    function()
      edit.delete_lines()
      require('rosavim.rosa_plugins.rosavisualmulti').stop()
    end,
  },
  { 'y', 'yank selection', edit.yank },
  {
    'p',
    'paste after',
    function()
      edit.paste(false)
    end,
  },
  {
    'P',
    'paste before',
    function()
      edit.paste(true)
    end,
  },
  {
    'gu',
    'lowercase',
    function()
      edit.transform(string.lower)
    end,
  },
  {
    'gU',
    'uppercase',
    function()
      edit.transform(string.upper)
    end,
  },
  {
    '~',
    'toggle case',
    function()
      edit.transform(function(t)
        return (t:gsub('%a', function(c)
          return c:match '%l' and c:upper() or c:lower()
        end))
      end)
    end,
  },
  {
    '.',
    'run normal command',
    function()
      require('rosavim.rosa_plugins.rosavisualmulti.ui').run_normal()
    end,
  },
  {
    '@',
    'run macro',
    function()
      require('rosavim.rosa_plugins.rosavisualmulti.ui').run_macro()
    end,
  },
  { '<C-Down>', 'cursor down', cursors.add_down },
  { '<C-Up>', 'cursor up', cursors.add_up },
  { '<C-n>', 'add next occurrence', cursors.find_under },
  {
    '<Esc>',
    'exit',
    function()
      require('rosavim.rosa_plugins.rosavisualmulti').stop()
    end,
  },
}

local function wrap(fn)
  return function()
    if not state.active() then
      return
    end
    fn()
    if state.session() then
      cursors.sync()
    end
  end
end

function M.attach()
  local buf = vim.api.nvim_get_current_buf()
  if active_buf == buf then
    return
  end
  M.detach()
  active_buf = buf
  for _, k in ipairs(M.keys) do
    vim.keymap.set('n', k[1], wrap(k[3]), { buffer = buf, nowait = true, desc = 'Rosavisualmulti: ' .. k[2] })
  end
end

function M.detach()
  if not active_buf or not vim.api.nvim_buf_is_valid(active_buf) then
    active_buf = nil
    return
  end
  for _, k in ipairs(M.keys) do
    pcall(vim.keymap.del, 'n', k[1], { buffer = active_buf })
  end
  active_buf = nil
end

return M

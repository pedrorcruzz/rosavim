local M = {}

local api = vim.api
local state = require 'rosavim.rosa_plugins.rosavisualmulti.state'
local cursors = require 'rosavim.rosa_plugins.rosavisualmulti.cursors'
local render = require 'rosavim.rosa_plugins.rosavisualmulti.render'
local insert = require 'rosavim.rosa_plugins.rosavisualmulti.insert'
local maps = require 'rosavim.rosa_plugins.rosavisualmulti.maps'

local function refresh()
  if state.session() and state.count() > 0 then
    maps.attach()
    vim.b[state.session().buf].rosavisualmulti = state.count()
    pcall(vim.cmd, 'redrawstatus')
  else
    M.stop()
  end
end

function M.stop()
  maps.detach()
  insert.cancel()
  state.stop()
  pcall(vim.cmd, 'redrawstatus')
end

function M.active()
  return state.active() and state.count() > 0
end

function M.count()
  return state.count()
end

function M.status()
  if not M.active() then
    return ''
  end
  return render.status()
end

local function action(fn)
  return function()
    fn()
    refresh()
  end
end

M.find_under = action(cursors.find_under)
M.select_all = action(cursors.select_all)
M.add_down = action(cursors.add_down)
M.add_up = action(cursors.add_up)
M.from_visual = action(cursors.from_visual)

function M.menu()
  require('rosavim.rosa_plugins.rosavisualmulti.ui').menu()
end

function M.rename()
  require('rosavim.rosa_plugins.rosavisualmulti.ui').rename()
end

function M.setup()
  local group = api.nvim_create_augroup('Rosavisualmulti', { clear = true })

  api.nvim_create_autocmd('InsertLeavePre', {
    group = group,
    callback = function()
      if insert.pending() then
        insert.finish()
        refresh()
      end
    end,
  })

  api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function(ev)
      local cur = state.session()
      if not cur or insert.pending() then
        return
      end
      if ev.buf == cur.buf or vim.bo[ev.buf].buftype ~= '' then
        return
      end
      M.stop()
    end,
  })

  api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      for name in pairs(render.groups) do
        pcall(api.nvim_set_hl, 0, name, {})
      end
      render.define()
      if state.session() then
        render.draw()
      end
    end,
  })
end

return M

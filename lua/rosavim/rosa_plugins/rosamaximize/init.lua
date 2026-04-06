--- Rosamaximize - Window maximizer for Rosavim
local M = {}

local saved_session = nil

function M.is_maximized()
  return saved_session ~= nil
end

function M.maximize()
  if saved_session then
    return
  end
  saved_session = vim.fn.tempname()
  vim.cmd('mksession! ' .. vim.fn.fnameescape(saved_session))
  vim.cmd 'only'
end

function M.restore()
  if not saved_session then
    return
  end
  vim.cmd('silent! source ' .. vim.fn.fnameescape(saved_session))
  vim.fn.delete(saved_session)
  saved_session = nil
end

function M.toggle()
  if M.is_maximized() then
    M.restore()
  else
    M.maximize()
  end
end

return M

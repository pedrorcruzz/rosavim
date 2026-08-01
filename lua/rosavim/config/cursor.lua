local M = {}

local toggles = require 'rosavim.config.toggles'

local BAR = 'a:ver25'

M._default_guicursor = nil

local function default_guicursor()
  if M._default_guicursor == nil then
    M._default_guicursor = vim.o.guicursor
  end
  return M._default_guicursor
end

function M.set_shape(block)
  vim.o.guicursor = block and default_guicursor() or BAR
end

function M.set_line(on)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    pcall(vim.api.nvim_set_option_value, 'cursorline', on, { win = win })
  end
end

function M.setup()
  default_guicursor()
  M.set_shape(toggles.get 'cursor_block')
  M.set_line(toggles.get 'cursorline')
end

return M

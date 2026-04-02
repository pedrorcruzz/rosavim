local M = {}

local bg_cache = vim.fn.stdpath 'cache' .. '/rosavim-background'
local cs_cache = vim.fn.stdpath 'cache' .. '/rosavim-colorscheme'
local tp_cache = vim.fn.stdpath 'cache' .. '/rosavim-transparent'

M._reloader = nil
M._transparent = false

function M.get_mode()
  return vim.o.background
end

function M.get_colorscheme()
  local ok, content = pcall(vim.fn.readfile, cs_cache)
  return ok and content[1] or nil
end

function M.get_transparent()
  return M._transparent
end

function M.toggle_transparent()
  M._transparent = not M._transparent
  vim.fn.writefile({ M._transparent and 'true' or 'false' }, tp_cache)

  if M._reloader then
    M._reloader()
  else
    local name = vim.g.colors_name
    if name then
      vim.cmd('colorscheme ' .. name)
    end
  end

  vim.notify('Transparent: ' .. (M._transparent and 'on' or 'off'), vim.log.levels.INFO)
end

function M.setup()
  local ok, content = pcall(vim.fn.readfile, bg_cache)
  local mode = (ok and content[1] == 'light') and 'light' or 'dark'
  vim.o.background = mode

  local tp_ok, tp_content = pcall(vim.fn.readfile, tp_cache)
  M._transparent = tp_ok and tp_content[1] == 'true' or false

  -- Persist colorscheme on change
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
      local name = vim.g.colors_name
      if name then
        vim.fn.writefile({ name }, cs_cache)
      end
    end,
  })
end

function M.register_reloader(fn)
  M._reloader = fn
end

function M.toggle()
  local new_mode = vim.o.background == 'dark' and 'light' or 'dark'
  vim.o.background = new_mode
  vim.fn.writefile({ new_mode }, bg_cache)

  if M._reloader then
    M._reloader()
  else
    local name = vim.g.colors_name
    if name then
      vim.cmd('colorscheme ' .. name)
    end
  end

  vim.notify('Background: ' .. new_mode, vim.log.levels.INFO)
end

return M

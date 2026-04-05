--- Rosasave - Automatic file saving for Rosavim
local M = {}

local enabled = false
local augroup = vim.api.nvim_create_augroup('Rosasave', { clear = true })
local defer_timer = nil

local defaults = {
  debounce_delay = 600,
  write_all_buffers = false,
  immediate_save = { 'BufLeave', 'FocusLost', 'QuitPre', 'VimSuspend' },
  defer_save = { 'InsertLeave', 'TextChanged' },
  cancel_deferred_save = { 'InsertEnter' },
}

local config = {}

local function is_saveable(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if vim.bo[bufnr].buftype ~= '' then
    return false
  end
  if not vim.bo[bufnr].modified then
    return false
  end
  if vim.bo[bufnr].readonly then
    return false
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return false
  end
  return true
end

local function save(bufnr)
  if config.write_all_buffers then
    vim.cmd 'silent! wall'
  else
    if is_saveable(bufnr) then
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd 'silent! write'
      end)
    end
  end
end

local function cancel_defer()
  if defer_timer and not defer_timer:is_closing() then
    defer_timer:stop()
  end
end

local function deferred_save(bufnr)
  cancel_defer()
  if not defer_timer then
    defer_timer = vim.uv.new_timer()
  end
  defer_timer:start(
    config.debounce_delay,
    0,
    vim.schedule_wrap(function()
      save(bufnr)
    end)
  )
end

local function create_autocmds()
  vim.api.nvim_clear_autocmds { group = augroup }

  if #config.immediate_save > 0 then
    vim.api.nvim_create_autocmd(config.immediate_save, {
      group = augroup,
      callback = function(ev)
        save(ev.buf)
      end,
    })
  end

  if #config.defer_save > 0 then
    vim.api.nvim_create_autocmd(config.defer_save, {
      group = augroup,
      callback = function(ev)
        deferred_save(ev.buf)
      end,
    })
  end

  if #config.cancel_deferred_save > 0 then
    vim.api.nvim_create_autocmd(config.cancel_deferred_save, {
      group = augroup,
      callback = function()
        cancel_defer()
      end,
    })
  end
end

function M.enable()
  enabled = true
  create_autocmds()
end

function M.disable()
  enabled = false
  cancel_defer()
  vim.api.nvim_clear_autocmds { group = augroup }
end

function M.toggle()
  if enabled then
    M.disable()
  else
    M.enable()
  end
  return enabled
end

function M.is_enabled()
  return enabled
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', defaults, opts or {})

  local toggles = require 'rosavim.config.toggles'
  if toggles.get 'autosave' then
    M.enable()
  end
end

return M

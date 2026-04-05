--- Rosasweep - Automatic buffer retirement for Rosavim
--- Closes inactive buffers after a configurable period of inactivity.
local M = {}

local timer = nil

local defaults = {
  retirement_mins = 20,
  check_interval_secs = 30,
  minimum_buffers = 1,
  ignore_special_buftypes = true,
  ignore_alt_file = true,
  ignore_unsaved = true,
  ignore_visible = true,
  ignored_filetypes = {},
}

local config = {}

local function is_ignored(bufnr)
  local ft = vim.bo[bufnr].filetype
  for _, ignored in ipairs(config.ignored_filetypes) do
    if ft == ignored then
      return true
    end
  end

  if config.ignore_special_buftypes and vim.bo[bufnr].buftype ~= '' then
    return true
  end

  if config.ignore_unsaved and vim.bo[bufnr].modified then
    return true
  end

  if config.ignore_alt_file then
    local alt = vim.fn.bufnr '#'
    if bufnr == alt then
      return true
    end
  end

  return false
end

local function retire_buffers()
  local bufs = vim.fn.getbufinfo { buflisted = 1 }
  if #bufs <= config.minimum_buffers then
    return
  end

  local now = os.time()
  local max_age = config.retirement_mins * 60

  for _, buf in ipairs(bufs) do
    local bufnr = buf.bufnr

    if config.ignore_visible and buf.hidden == 0 then
      goto continue
    end

    if buf.lastused == 0 then
      goto continue
    end

    if (now - buf.lastused) < max_age then
      goto continue
    end

    if is_ignored(bufnr) then
      goto continue
    end

    pcall(vim.api.nvim_buf_delete, bufnr, { force = false, unload = false })

    ::continue::
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', defaults, opts or {})

  if timer then
    timer:stop()
    timer:close()
  end

  timer = vim.uv.new_timer()
  local interval_ms = config.check_interval_secs * 1000
  local initial_ms = config.retirement_mins * 60 * 1000

  timer:start(initial_ms, interval_ms, vim.schedule_wrap(retire_buffers))
end

function M.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

return M

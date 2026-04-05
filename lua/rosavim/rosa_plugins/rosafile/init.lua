--- Rosafile - File operations plugin for Rosavim
local M = {}

local ui = require 'rosavim.rosa_plugins.rosafile.ui'

--- Create a new file in the current file's directory
function M.create_here()
  local dir = vim.fn.expand '%:p:h'
  local rel = vim.fn.fnamemodify(dir, ':~:.')
  ui.input_popup {
    title = rel .. '/',
    default = '',
    completion = 'file',
    on_confirm = function(input)
      M._create_file(dir .. '/' .. input)
    end,
  }
end

--- Create a new file from project root
function M.create_root()
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ':t')
  ui.input_popup {
    title = project_name .. '/',
    default = '',
    completion = 'file',
    on_confirm = function(input)
      M._create_file(cwd .. '/' .. input)
    end,
  }
end


--- Rename the current file
function M.rename()
  local current = vim.api.nvim_buf_get_name(0)
  if current == '' then
    Snacks.notify.warn('Rosafile: no file to rename')
    return
  end

  local dir = vim.fn.fnamemodify(current, ':h')
  local name = vim.fn.fnamemodify(current, ':t')
  local name_no_ext = vim.fn.fnamemodify(current, ':t:r')
  local ext = vim.fn.fnamemodify(current, ':e')

  ui.input_popup {
    title = 'Rename file',
    default = name,
    -- Place cursor before the extension so user can just type the new name
    cursor_before_ext = ext ~= '' and #name_no_ext or nil,
    on_confirm = function(new_name)
      if new_name == '' or new_name == name then
        return
      end

      local new_path = dir .. '/' .. new_name

      -- Move the file on disk
      local ok, err = vim.uv.fs_rename(current, new_path)
      if not ok then
        Snacks.notify.error('Rosafile: failed to rename: ' .. (err or 'unknown'))
        return
      end

      -- Point the current buffer to the new file path without saving
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(bufnr, new_path)
      vim.bo[bufnr].modified = false

      -- Clear the old buffer name from the buffer list
      vim.cmd 'silent! bwipeout #'

      M._refresh_explorer(dir)
      Snacks.notify.info('Renamed to: ' .. new_name)
    end,
  }
end

--- Copy the current file
function M.copy()
  local current = vim.api.nvim_buf_get_name(0)
  if current == '' then
    Snacks.notify.warn('Rosafile: no file to copy')
    return
  end

  local dir = vim.fn.fnamemodify(current, ':h')
  local name = vim.fn.fnamemodify(current, ':t:r')
  local ext = vim.fn.fnamemodify(current, ':e')
  local default_name = dir .. '/' .. name .. '_copy'
  if ext ~= '' then
    default_name = default_name .. '.' .. ext
  end

  ui.input_popup {
    title = 'Duplicate file',
    default = default_name,
    completion = 'file',
    on_confirm = function(new_path)
      if new_path == '' or new_path == current then
        return
      end

      local dest_dir = vim.fn.fnamemodify(new_path, ':p:h')
      vim.fn.mkdir(dest_dir, 'p')

      local ok = vim.fn.writefile(vim.fn.readfile(current, 'b'), new_path, 'b')
      if ok ~= 0 then
        Snacks.notify.error('Rosafile: failed to copy file')
        return
      end

      vim.cmd('edit ' .. vim.fn.fnameescape(new_path))
      M._refresh_explorer(dest_dir)
      Snacks.notify.info('Copied to: ' .. vim.fn.fnamemodify(new_path, ':t'))
    end,
  }
end

--- Delete the current file
function M.delete()
  local file_name = vim.api.nvim_buf_get_name(0)
  if file_name == '' then
    Snacks.notify.warn('Rosafile: no file to delete')
    return
  end

  local short_name = vim.fn.fnamemodify(file_name, ':t')

  ui.confirm_popup {
    title = ' Delete File',
    message = 'Delete "' .. short_name .. '"?',
    detail = vim.fn.fnamemodify(file_name, ':~:.'),
    on_confirm = function()
      local dir = vim.fs.dirname(file_name)
      local current_bufnr = vim.api.nvim_get_current_buf()
      local current_win = vim.api.nvim_get_current_win()

      -- Get all windows and their buffers
      local buffers_in_windows = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        buffers_in_windows[vim.api.nvim_win_get_buf(win)] = true
      end

      -- Get alternative buffer
      local alt_bufnr = vim.fn.bufnr '#'
      local alt_buf_is_valid = alt_bufnr > 0
        and vim.api.nvim_buf_is_valid(alt_bufnr)
        and vim.bo[alt_bufnr].buflisted
        and alt_bufnr ~= current_bufnr

      local alt_buf_in_other_window = alt_buf_is_valid
        and buffers_in_windows[alt_bufnr]
        and current_win ~= vim.fn.bufwinid(alt_bufnr)

      if alt_buf_in_other_window then
        vim.api.nvim_win_close(current_win, true)
        vim.cmd('bdelete! ' .. current_bufnr)
      else
        local buffers = vim.tbl_filter(function(b)
          return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and b ~= current_bufnr
        end, vim.api.nvim_list_bufs())

        if #buffers > 0 then
          vim.cmd 'bprevious'
        end

        vim.cmd('bdelete! ' .. current_bufnr)
      end

      local ok, err = pcall(vim.fn.delete, file_name)
      if not ok then
        Snacks.notify.error('Rosafile: failed to delete: ' .. (err or 'unknown'))
        return
      end

      M._refresh_explorer(dir)
      Snacks.notify.info('Deleted: ' .. short_name)
    end,
  }
end

--- Show the main Rosafile actions popup
function M.open()
  ui.actions_popup()
end

--- Show file info popup
function M.info()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    Snacks.notify.warn('Rosafile: no file open')
    return
  end
  ui.info_popup(file)
end

--- Internal: create a file and open it
function M._create_file(path)
  if path == '' then
    return
  end

  local dir = vim.fn.fnamemodify(path, ':p:h')
  vim.fn.mkdir(dir, 'p')

  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({}, path)
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  M._refresh_explorer(dir)
  Snacks.notify.info('Created: ' .. vim.fn.fnamemodify(path, ':t'))
end

--- Internal: refresh snacks explorer
function M._refresh_explorer(dir)
  vim.defer_fn(function()
    local ok, _ = pcall(require, 'snacks')
    if ok then
      local tree_ok, tree_module = pcall(function()
        return require 'snacks.tree'
      end)
      if tree_ok and tree_module and type(tree_module.refresh) == 'function' then
        tree_module.refresh(dir)
      end
    end
  end, 50)
end

return M

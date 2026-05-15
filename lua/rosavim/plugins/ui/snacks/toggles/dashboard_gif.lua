--- Dashboard gif toggles — manage the chafa-rendered animation on the dashboard.
---
--- Keys registered (under <leader>lqd):
---   <leader>lqdt  toggle gif on/off (persisted, no restart needed)
---   <leader>lqde  pick an image/gif from dashboard_img/ (persisted)
---   <leader>lqdc  configure height/width/indent for the current gif (persisted)
---
--- Selection and dimensions are read at dashboard load. After lqde/lqdc
--- restart Neovim (or run :Lazy reload snacks.nvim) so the new values
--- take effect; lqdt re-renders on the next dashboard open.
local toggles = require 'rosavim.config.toggles'

local dashboard_dir = vim.fn.stdpath 'config' .. '/lua/rosavim/plugins/ui/dashboard_img'

local IMG_EXTS = {
  ['.gif'] = true,
  ['.png'] = true,
  ['.jpg'] = true,
  ['.jpeg'] = true,
  ['.webp'] = true,
  ['.bmp'] = true,
}

local function list_images()
  if vim.fn.isdirectory(dashboard_dir) == 0 then
    return {}
  end
  local entries = vim.fn.readdir(dashboard_dir)
  local images = {}
  for _, name in ipairs(entries) do
    local ext = name:match '^.+(%..+)$'
    if ext and IMG_EXTS[ext:lower()] then
      table.insert(images, name)
    end
  end
  table.sort(images)
  return images
end

local function notify_restart()
  Snacks.notify.info 'Dashboard gif: restart Neovim (or :Lazy reload snacks.nvim) to apply'
end

local function pick_gif()
  local images = list_images()
  if #images == 0 then
    Snacks.notify.warn('Dashboard gif: no images found in ' .. dashboard_dir)
    return
  end

  local current = toggles.get 'dashboard_gif_name'
  local items = {}
  for _, name in ipairs(images) do
    local label = name == current and (name .. '  (current)') or name
    table.insert(items, { text = label, file = name })
  end

  Snacks.picker {
    title = ' Dashboard gif',
    items = items,
    format = 'text',
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      toggles.set('dashboard_gif_name', item.file)
      Snacks.notify.info('Dashboard gif: selected ' .. item.file)
      notify_restart()
    end,
  }
end

local function prompt_number(prompt, default, on_confirm)
  vim.ui.input({
    prompt = prompt,
    default = tostring(default),
  }, function(input)
    if not input or input == '' then
      return
    end
    local n = tonumber(input)
    if not n then
      Snacks.notify.warn('Dashboard gif: invalid number "' .. input .. '"')
      return
    end
    on_confirm(n)
  end)
end

local function config_gif()
  local current_name = toggles.get 'dashboard_gif_name'
  local h = toggles.get 'dashboard_gif_height'
  local w = toggles.get 'dashboard_gif_width'
  local i = toggles.get 'dashboard_gif_indent'

  prompt_number('Height for ' .. current_name .. ' (current ' .. h .. '): ', h, function(new_h)
    toggles.set('dashboard_gif_height', new_h)
    prompt_number('Width for ' .. current_name .. ' (current ' .. w .. '): ', w, function(new_w)
      toggles.set('dashboard_gif_width', new_w)
      prompt_number('Indent for ' .. current_name .. ' (current ' .. i .. '): ', i, function(new_i)
        toggles.set('dashboard_gif_indent', new_i)
        Snacks.notify.info(string.format('Dashboard gif: h=%d w=%d indent=%d', new_h, new_w, new_i))
        notify_restart()
      end)
    end)
  end)
end

return function()
  -- Toggle on/off (re-renders on next dashboard open)
  Snacks.toggle({
    name = 'Dashboard Gif',
    get = function()
      return toggles.get 'dashboard_gif'
    end,
    set = function(state)
      toggles.set('dashboard_gif', state)
    end,
  }):map '<leader>lqdt'

  vim.keymap.set('n', '<leader>lqde', pick_gif, { desc = 'Dashboard gif: Select image' })
  vim.keymap.set('n', '<leader>lqdc', config_gif, { desc = 'Dashboard gif: Configure height/width/indent' })
end

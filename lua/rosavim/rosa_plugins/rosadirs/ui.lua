--- Rosadirs UI - Floating popups for the directory manager
local M = {}

local menu = require 'rosavim.helpers.rosa_menu'

local SECTION_LABEL = {
  projects = 'Projects',
  obsidian = 'Obsidian',
}

local function setup_highlights()
  require('rosavim.helpers.palette').define('Rosadirs', function(p)
    return {
      Title = { fg = p.title, bold = true },
      Border = { fg = p.border },
      Key = { fg = p.key, bold = true },
      Action = { fg = p.text },
      Create = { fg = p.green },
      Danger = { fg = p.red, bold = true },
      Dim = { fg = p.dim },
      Info = { fg = p.teal },
      Warn = { fg = p.yellow, bold = true },
      Count = { fg = p.pink, bold = true },
    }
  end)
end

--- Open a centered rosadirs menu (adds this plugin's title/footer padding)
local function open_menu(opts)
  opts.title = ' ' .. (opts.title or 'Rosadirs') .. ' '
  if opts.footer then
    opts.footer = ' ' .. opts.footer .. ' '
  end
  opts.hl_prefix = 'Rosadirs'
  opts.filetype = 'rosadirs'
  return menu.open(opts)
end

--- Apply changes to live plugins and emit a friendly notification.
--- @param section 'projects' | 'obsidian' | nil
local function apply_and_notify(section)
  local status = require('rosavim.rosa_plugins.rosadirs').apply()

  -- Only mention obsidian state if the change affected obsidian
  local mentions_obsidian = section == 'obsidian' or section == nil
  if mentions_obsidian and status.obsidian == 'pending_restart' then
    Snacks.notify.info 'Rosadirs: changes applied. Restart Neovim to (re)load Obsidian.'
  else
    Snacks.notify.info 'Rosadirs: changes applied'
  end
end

--- Prompt the user for a directory path
--- @param section 'projects' | 'obsidian'
local function prompt_add(section)
  local prompt = section == 'projects' and 'Project path (use /* for subfolders): ' or 'Obsidian vault path: '

  vim.ui.input({
    prompt = prompt,
    default = '~/',
    completion = 'dir',
  }, function(input)
    if not input or input == '' or input == '~/' then
      return
    end

    -- Strip trailing whitespace
    input = input:gsub('%s+$', '')

    local ok, reason = require('rosavim.rosa_plugins.rosadirs').add(section, input)
    if not ok then
      Snacks.notify.warn('Rosadirs: ' .. (reason or 'failed to add'))
      return
    end
    Snacks.notify.info('Rosadirs: added to ' .. SECTION_LABEL[section] .. ' — ' .. input)
    apply_and_notify(section)
  end)
end

--- Show a snacks picker listing dirs in a section so the user can remove one
--- @param section 'projects' | 'obsidian'
local function pick_remove(section)
  local rosadirs = require 'rosavim.rosa_plugins.rosadirs'
  local list = rosadirs.list(section)

  if #list == 0 then
    Snacks.notify.info('Rosadirs: no ' .. SECTION_LABEL[section] .. ' directories')
    return
  end

  local items = {}
  for _, dir in ipairs(list) do
    table.insert(items, { text = dir, dir = dir })
  end

  Snacks.picker {
    title = ' Remove ' .. SECTION_LABEL[section] .. ' directory',
    items = items,
    format = 'text',
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      if rosadirs.remove(section, item.dir) then
        Snacks.notify.info('Rosadirs: removed ' .. item.dir)
        apply_and_notify(section)
      end
    end,
  }
end

--- Confirm + clear a section (or everything when section == nil)
--- @param section 'projects' | 'obsidian' | nil
local function confirm_clear(section)
  local rosadirs = require 'rosavim.rosa_plugins.rosadirs'

  local title, message, detail
  if section then
    local count = #rosadirs.list(section)
    if count == 0 then
      Snacks.notify.info('Rosadirs: no ' .. SECTION_LABEL[section] .. ' directories')
      return
    end
    title = ' Clear ' .. SECTION_LABEL[section]
    message = 'Remove all ' .. count .. ' ' .. SECTION_LABEL[section] .. ' directories?'
    detail = 'This cannot be undone.'
  else
    local total = #rosadirs.list 'projects' + #rosadirs.list 'obsidian'
    if total == 0 then
      Snacks.notify.info 'Rosadirs: nothing to clear'
      return
    end
    title = ' Clear EVERYTHING'
    message = 'Remove ALL ' .. total .. ' directories (projects + obsidian)?'
    detail = 'This cannot be undone.'
  end

  M.confirm_popup {
    title = title,
    message = message,
    detail = detail,
    on_confirm = function()
      if section then
        rosadirs.clear(section)
        Snacks.notify.info('Rosadirs: cleared ' .. SECTION_LABEL[section])
      else
        rosadirs.clear_all()
        Snacks.notify.info 'Rosadirs: cleared everything'
      end
      apply_and_notify(section)
    end,
  }
end

--- Main menu
function M.main_menu()
  setup_highlights()

  local rosadirs = require 'rosavim.rosa_plugins.rosadirs'
  local projects = rosadirs.list 'projects'
  local obsidian = rosadirs.list 'obsidian'

  local actions = {
    { key = 'a', label = 'Add project', action = 'add_project', hl = 'RosadirsCreate' },
    { key = 'd', label = 'Remove project', action = 'remove_project', hl = 'RosadirsInfo' },
    { key = 'c', label = 'Clear projects', action = 'clear_projects', hl = 'RosadirsDanger' },
    { sep = true },
    { key = 'A', label = 'Add obsidian vault', action = 'add_obsidian', hl = 'RosadirsCreate' },
    { key = 'D', label = 'Remove obsidian vault', action = 'remove_obsidian', hl = 'RosadirsInfo' },
    { key = 'C', label = 'Clear obsidian vaults', action = 'clear_obsidian', hl = 'RosadirsDanger' },
    { sep = true },
    { key = 'X', label = 'Clear EVERYTHING', action = 'clear_all', hl = 'RosadirsDanger' },
  }

  local pad = '       '
  local gap = '    '

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl

  -- Section counts
  local label_w = 12
  local function counts_row(label, count)
    return pad .. label .. string.rep(' ', label_w - #label) .. count
  end

  add(counts_row('Projects', tostring(#projects)))
  add_hl('RosadirsAction', b.line(), #pad, #pad + label_w)
  add_hl('RosadirsCount', b.line(), #pad + label_w, -1)

  add(counts_row('Obsidian', tostring(#obsidian)))
  add_hl('RosadirsAction', b.line(), #pad, #pad + label_w)
  add_hl('RosadirsCount', b.line(), #pad + label_w, -1)

  add(pad .. string.rep('─', 38), 'RosadirsDim')
  add ''

  for _, a in ipairs(actions) do
    if a.sep then
      add ''
    else
      local line = pad .. a.key .. gap .. a.label
      local key_start = #pad
      local key_end = key_start + #a.key
      local label_start = key_end + #gap
      local label_end = label_start + #a.label

      add(line)
      add_hl('RosadirsKey', b.line(), key_start, key_end)
      add_hl(a.hl, b.line(), label_start, label_end)
    end
  end

  add ''

  local action_handlers = {
    add_project = function()
      prompt_add 'projects'
    end,
    remove_project = function()
      pick_remove 'projects'
    end,
    clear_projects = function()
      confirm_clear 'projects'
    end,
    add_obsidian = function()
      prompt_add 'obsidian'
    end,
    remove_obsidian = function()
      pick_remove 'obsidian'
    end,
    clear_obsidian = function()
      confirm_clear 'obsidian'
    end,
    clear_all = function()
      confirm_clear(nil)
    end,
  }

  local keys = {}
  for _, a in ipairs(actions) do
    if not a.sep then
      table.insert(keys, {
        'n',
        a.key,
        function(ctx)
          ctx.close()
          vim.schedule(function()
            local handler = action_handlers[a.action]
            if handler then
              handler()
            end
          end)
        end,
      })
    end
  end

  open_menu {
    title = ' Rosadirs',
    footer = 'q: close',
    width = 56,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    keys = keys,
  }
end

--- Confirm popup for destructive actions
--- @param opts { title: string, message: string, detail: string|nil, on_confirm: function }
function M.confirm_popup(opts)
  setup_highlights()

  local pad = '       '

  local b = menu.builder()
  local add, add_hl = b.add, b.add_hl

  add ''
  add(pad .. opts.message, 'RosadirsWarn')
  add ''

  if opts.detail then
    add(pad .. opts.detail, 'RosadirsDim')
    add ''
  end

  add(pad .. string.rep('─', 30), 'RosadirsDim')
  add ''

  add(pad .. 'y    Confirm          n    Cancel')
  local y_start = #pad
  add_hl('RosadirsDanger', b.line(), y_start, y_start + 1)
  add_hl('RosadirsAction', b.line(), y_start + 4, y_start + 11)
  local n_start = y_start + 22
  add_hl('RosadirsKey', b.line(), n_start, n_start + 1)
  add_hl('RosadirsAction', b.line(), n_start + 4, n_start + 10)
  add ''

  local keys = {
    {
      'n',
      'n',
      function(ctx)
        ctx.close()
      end,
    },
    {
      'n',
      'y',
      function(ctx)
        ctx.close()
        vim.schedule(function()
          opts.on_confirm()
        end)
      end,
    },
  }

  open_menu {
    title = opts.title or ' Confirm',
    width = 52,
    height = #b.lines,
    lines = b.lines,
    highlights = b.highlights,
    keys = keys,
  }
end

return M

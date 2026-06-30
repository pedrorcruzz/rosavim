--- RosaAI ui - Pickers for theme / position / size / border
--- All four use vim.ui.select so they inherit the snacks picker layout
--- the user has configured globally (<leader>lasl, <leader>lasb).
local M = {}

--- Render an item label with a marker dot when it is the current value
local function fmt(item, current)
  local icon = item.icon or ''
  local label = item.label or item.name
  local marker = item.name == current and ' ●' or ''
  return icon .. label .. marker
end

local function pick(opts)
  vim.ui.select(opts.items, {
    prompt = opts.prompt,
    format_item = function(item)
      return fmt(item, opts.current())
    end,
    kind = opts.kind,
  }, function(choice)
    if not choice then
      return
    end
    opts.on_select(choice)
  end)
end

function M.pick_theme()
  local themes = require 'rosavim.rosa_plugins.rosaai.themes'
  local items = {}
  for _, t in ipairs(themes.list) do
    table.insert(items, { name = t.name, label = t.label, icon = t.icon .. ' ' })
  end
  pick {
    prompt = 'RosaAI · select theme',
    kind = 'rosaai_theme',
    items = items,
    current = function()
      return themes.current().name
    end,
    on_select = function(item)
      themes.set(item.name)
      Snacks.notify.info('RosaAI theme: ' .. item.name)
    end,
  }
end

function M.pick_position()
  local layout = require 'rosavim.rosa_plugins.rosaai.layout'
  pick {
    prompt = 'RosaAI · select position',
    kind = 'rosaai_position',
    items = layout.positions,
    current = function()
      return layout.current_position()
    end,
    on_select = function(item)
      require('rosavim.config.toggles').set('rosaai_position', item.name)
      Snacks.notify.info('RosaAI position: ' .. item.name)
      require('rosavim.rosa_plugins.rosaai').relayout()
    end,
  }
end

function M.pick_size()
  local layout = require 'rosavim.rosa_plugins.rosaai.layout'
  pick {
    prompt = 'RosaAI · select size',
    kind = 'rosaai_size',
    items = layout.sizes,
    current = function()
      return layout.current_size()
    end,
    on_select = function(item)
      require('rosavim.config.toggles').set('rosaai_size', item.name)
      -- Picking a named preset resets any interactive arrow-resize override.
      layout.clear_overrides()
      Snacks.notify.info('RosaAI size: ' .. item.name)
      require('rosavim.rosa_plugins.rosaai').relayout()
    end,
  }
end

return M

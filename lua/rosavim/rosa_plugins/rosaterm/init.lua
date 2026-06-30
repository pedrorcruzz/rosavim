--- Rosaterm - Native terminal plugin for Rosavim
--- Float window cycles through multiple terminals via <C-j>/<C-k>;
--- splits are persistent and toggle visibility. Both modes show a
--- top winbar with terminal name, buffer size and time.
local M = {}

local float = require 'rosavim.rosa_plugins.rosaterm.float'
local split = require 'rosavim.rosa_plugins.rosaterm.split'

function M.toggle_float()
  float.toggle()
end

function M.float_new()
  float.new()
end

function M.float_cycle(direction)
  float.cycle(direction)
end

function M.toggle_horizontal(id, size, name)
  split.toggle(id or 'h_main', 'horizontal', size or 16, name)
end

function M.toggle_vertical(id, size, name)
  split.toggle(id or 'v_main', 'vertical', size or 70, name)
end

--- Re-evaluate chip visibility on float and all splits (called by toggles)
function M.refresh_chips()
  float.refresh()
  split.refresh_all()
end

--- Size picker (compact / default / wide) — mirrors RosaAI's <leader>laaz.
--- Applies the chosen preset to every open split and the float live.
function M.pick_size()
  local sizes = require 'rosavim.rosa_plugins.rosaterm.sizes'
  local current = sizes.current().name
  vim.ui.select(sizes.list, {
    prompt = 'Rosaterm · select size',
    kind = 'rosaterm_size',
    format_item = function(s)
      local marker = s.name == current and ' ●' or ''
      return s.icon .. s.label .. marker
    end,
  }, function(choice)
    if not choice then
      return
    end
    require('rosavim.config.toggles').set('rosaterm_size', choice.name)
    split.apply_size()
    float.apply_geom()
    if _G.Snacks and Snacks.notify then
      Snacks.notify.info('Rosaterm size: ' .. choice.label)
    end
  end)
end

--- Forward resize_arrow to the split module so smart-splits can fall
--- through to the rosaterm float when no native split changed.
function M.resize_arrow(dir)
  return split.resize_arrow(dir)
end

--- Reload open splits to apply a border-mode change. Pass 'vertical' or
--- 'horizontal' to limit; nil reloads both.
function M.reload_splits(direction)
  split.reload_all(direction)
end

--- Re-apply the terminal bg on the open float + all splits (called when the
--- rosaterm_dark_bg toggle <leader>latd flips).
function M.refresh_bg()
  float.refresh_bg()
  split.reload_all()
end

return M

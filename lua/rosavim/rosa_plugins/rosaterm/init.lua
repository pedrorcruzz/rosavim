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
  split.toggle(id or 'v_main', 'vertical', size or 80, name)
end

--- Re-evaluate chip visibility on float and all splits (called by toggles)
function M.refresh_chips()
  float.refresh()
  split.refresh_all()
end

return M

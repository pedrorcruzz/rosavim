--- RosaAI - Native AI CLI integration for Rosavim
--- One persistent terminal per supported CLI tool (claude, cursor-agent,
--- openclaude, gemini, ...). Layout/theme are configurable through the
--- shared toggles store and mirror the look-and-feel of rosaterm.
local M = {}

local cli = require 'rosavim.rosa_plugins.rosaai.cli'

function M.toggle(name)
  cli.toggle(name)
end

function M.toggle_with_picker(name)
  cli.toggle_with_picker(name)
end

function M.show_in(position, name)
  cli.show_in(position, name)
end

function M.open_in_layout(position)
  cli.open_in_layout(position)
end

function M.show(name)
  cli.show(name)
end

function M.hide()
  cli.hide()
end

function M.close()
  cli.close()
end

--- Pick one of the running CLIs and kill it (window + process + history).
function M.close_pick()
  cli.close_pick()
end

--- Kill every running CLI.
function M.close_all()
  cli.close_all()
end

--- Visual-pick a CLI window and minimize (hide) it, keeping its session alive.
function M.minimize_pick()
  cli.minimize_pick()
end

function M.focus()
  cli.focus()
end

function M.select()
  cli.select()
end

function M.send(opts)
  cli.send(opts)
end

function M.prompt()
  cli.prompt()
end

function M.ask_with_selection()
  cli.ask_with_selection()
end

function M.ask_with_preview()
  cli.ask_with_preview()
end

function M.refresh_chips()
  cli.refresh_chips()
end

function M.relayout()
  cli.relayout()
end

--- Resize the active CLI float in an arrow direction ('up'/'down'/'left'/
--- 'right'). Returns true if it handled the resize (used by smart-splits).
function M.resize_arrow(dir)
  return cli.resize_arrow(dir)
end

--- Whether any CLI buffer is currently visible (used by rosamaximize)
function M.is_open()
  local state = require 'rosavim.rosa_plugins.rosaai.state'
  return state.any_visible()
end

return M

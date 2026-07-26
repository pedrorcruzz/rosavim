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

function M.send_ref(opts)
  cli.send_ref(opts)
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

--- Open/toggle the review of pending AI changes (keep/reject per hunk, diffed
--- against the session baseline snapshot).
function M.review()
  require('rosavim.rosa_plugins.rosaai.review').toggle()
end

--- Manually (re)mark the review baseline — the "before" snapshot the review
--- diffs against. Normally captured automatically when a CLI opens.
function M.mark_baseline()
  require('rosavim.rosa_plugins.rosaai.snapshot').mark(function(sha)
    if sha then
      vim.notify('RosaAI: review baseline marked', vim.log.levels.INFO)
    else
      vim.notify('RosaAI: could not mark baseline (not a git repo?)', vim.log.levels.WARN)
    end
  end)
end

--- Create or remove the global review keybinds (<leader>ar / <leader>ab) based
--- on the master `rosaai_review` toggle, so they disappear from which-key when
--- the feature is off. Called at startup and whenever the toggle flips.
function M.apply_review_keymaps()
  local toggles = require 'rosavim.config.toggles'
  local on = toggles.get 'rosaai_review'
  if on == nil then
    on = true
  end
  if on then
    vim.keymap.set('n', '<leader>ar', function()
      require('rosavim.rosa_plugins.rosaai').review()
    end, { desc = 'RosaAI: Review AI Changes' })
    vim.keymap.set('n', '<leader>ab', function()
      require('rosavim.rosa_plugins.rosaai').mark_baseline()
    end, { desc = 'RosaAI: Mark Review Baseline' })
  else
    pcall(vim.keymap.del, 'n', '<leader>ar')
    pcall(vim.keymap.del, 'n', '<leader>ab')
  end
end

return M

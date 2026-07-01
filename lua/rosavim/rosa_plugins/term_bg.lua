--- Shared light-mode terminal background helper for rosaterm + rosaai.
--- In light mode the shell prompt assumes a dark terminal, so a light bg
--- makes light-on-light prompts unreadable. Each plugin owns a persistent
--- toggle deciding whether to force a black bg in light mode:
---   - rosaterm → rosaterm_dark_bg (default on,  <leader>latd)
---   - rosaai   → rosaai_dark_bg   (default on,  <leader>laad)
--- Dark mode always follows the theme's Normal bg (already dark), so the
--- toggle only has an effect while `background == 'light'`.
local M = {}

local api = vim.api

--- Whether to force a black terminal bg right now: the per-plugin toggle is
--- on (falls back to `default_on` when unset) AND we're in light mode.
function M.is_black(toggle_key, default_on)
  local on = default_on
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if ok then
    local v = toggles.get(toggle_key)
    if v ~= nil then
      on = v
    end
  end
  return on and vim.o.background == 'light'
end

--- Build a winhl string mapping Normal for a terminal window. When black-bg
--- is active, defines `hl_group` (#000 bg / dim fg) and maps Normal to it;
--- otherwise maps Normal:Normal. `extra` (e.g. ',FloatBorder:FloatBorder')
--- is appended verbatim.
function M.winhl(toggle_key, default_on, hl_group, extra)
  extra = extra or ''
  if M.is_black(toggle_key, default_on) then
    api.nvim_set_hl(0, hl_group, { bg = '#000000', fg = '#d4d0c8' })
    return 'Normal:' .. hl_group .. extra
  end
  return 'Normal:Normal' .. extra
end

return M

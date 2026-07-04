--- Shared terminal/float background helper for rosaterm, rosaai, yazi and
--- lazygit. In light mode the shell prompt assumes a dark terminal, so a
--- light bg makes light-on-light prompts unreadable — hence a "force black
--- bg" override. Each consumer owns TWO persistent toggles:
---   - <key>      → force #000 in LIGHT mode (default on)
---   - <key>_dm   → force #000 in DARK  mode (default off)
--- so users can opt the dark themes (rosamin dark, rosaesthetic dark) into a
--- pure-black bg too, independently from light mode.
---   - rosaterm → rosaterm_dark_bg / rosaterm_dark_bg_dm (<leader>latd / <leader>latD)
---   - rosaai   → rosaai_dark_bg   / rosaai_dark_bg_dm   (<leader>laad / <leader>laaD)
---   - yazi     → yazi_dark_bg     / yazi_dark_bg_dm     (<leader>layd / <leader>layD)
---   - lazygit  → lazygit_dark_bg  / lazygit_dark_bg_dm  (<leader>lagd / <leader>lagD)
local M = {}

local api = vim.api

--- Whether to force a black bg right now. Picks the light-mode toggle while
--- `background == 'light'` (falls back to `default_on` when unset) and the
--- dark-mode sibling `<key>_dm` (default off) while `background == 'dark'`.
function M.is_black(toggle_key, default_on)
  local light_on = default_on
  local dark_on = false
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if ok then
    local lv = toggles.get(toggle_key)
    if lv ~= nil then
      light_on = lv
    end
    local dv = toggles.get(toggle_key .. '_dm')
    if dv ~= nil then
      dark_on = dv
    end
  end
  if vim.o.background == 'light' then
    return light_on
  end
  return dark_on
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

--- Full winhighlight for a floating window (yazi, lazygit): maps Normal AND
--- NormalFloat to a forced-black group when active, otherwise back to their
--- defaults. Kept separate from `winhl` because floats also render through
--- NormalFloat, which must be remapped in lockstep.
function M.float_winhl(toggle_key, default_on, hl_group)
  if M.is_black(toggle_key, default_on) then
    api.nvim_set_hl(0, hl_group, { bg = '#000000', fg = '#d4d0c8' })
    return ('Normal:%s,NormalFloat:%s,FloatBorder:FloatBorder'):format(hl_group, hl_group)
  end
  return 'Normal:Normal,NormalFloat:NormalFloat,FloatBorder:FloatBorder'
end

return M

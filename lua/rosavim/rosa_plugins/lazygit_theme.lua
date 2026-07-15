--- Canonical lazygit theme for Rosavim.
---
--- Snacks derives the lazygit theme from Neovim highlight groups (MatchParen,
--- FloatBorder, Function, Identifier, Special, Visual, DiagnosticError, ...).
--- Those groups are *syntax* colors, so they differ between rosamin and
--- rosaesthetic — which made lazygit look inconsistent (rosaesthetic dark used
--- red/gold accents and a light-blue selection instead of rosamin's neutral
--- look). Overriding them per-theme would wreck code highlighting in the editor.
---
--- Instead we point Snacks' lazygit theme at dedicated `RosaLg*` groups defined
--- here, so lazygit renders IDENTICALLY across colorschemes. Values mirror the
--- rosamin look (the canonical reference), background-aware for dark/light.
local M = {}

local api = vim.api

-- Dark palette (from rosamin dark).
local dark = {
  c241 = '#bbbbbb', -- Special/symbol — lazygit uses color 241 heavily
  active = '#abb2bf', -- active/searching border (MatchParen)
  cherryBg = '#c1c1c1', -- cherry-picked commit bg marker (Identifier)
  cherryFg = '#b392f0', -- cherry-picked commit fg (Function)
  default = '#c1c1c1', -- default text (Normal fg)
  inactive = '#4c4c4c', -- inactive border (FloatBorder)
  options = '#b392f0', -- options/help text (Function)
  selected = '#4c4c4c', -- selected line bg (Visual)
  unstaged = '#FF7A84', -- unstaged changes (DiagnosticError)
}

-- Light palette (from rosamin light).
local light = {
  c241 = '#a1a1a1',
  active = '#383A42',
  cherryBg = '#616161',
  cherryFg = '#9966cc',
  default = '#383A42',
  inactive = '#C0C0C0',
  options = '#9966cc',
  selected = '#D6E4F0',
  unstaged = '#d6656a',
}

--- Snacks lazygit `theme` table — points every entry at a RosaLg* group so the
--- generated lazygit-theme.yml is theme-independent.
M.theme = {
  [241] = { fg = 'RosaLg241' },
  activeBorderColor = { fg = 'RosaLgActive', bold = true },
  cherryPickedCommitBgColor = { fg = 'RosaLgCherryBg' },
  cherryPickedCommitFgColor = { fg = 'RosaLgCherryFg' },
  defaultFgColor = { fg = 'RosaLgDefault' },
  inactiveBorderColor = { fg = 'RosaLgInactive' },
  optionsTextColor = { fg = 'RosaLgOptions' },
  searchingActiveBorderColor = { fg = 'RosaLgActive', bold = true },
  selectedLineBgColor = { bg = 'RosaLgSelected' },
  unstagedChangesColor = { fg = 'RosaLgUnstaged' },
}

--- (Re)define the RosaLg* highlight groups for the current background. Called on
--- setup and whenever the colorscheme/background changes, so Snacks reads fresh
--- colors when it regenerates the theme file (it does so on ColorScheme).
function M.apply()
  local p = vim.o.background == 'light' and light or dark
  api.nvim_set_hl(0, 'RosaLg241', { fg = p.c241 })
  api.nvim_set_hl(0, 'RosaLgActive', { fg = p.active, bold = true })
  api.nvim_set_hl(0, 'RosaLgCherryBg', { fg = p.cherryBg })
  api.nvim_set_hl(0, 'RosaLgCherryFg', { fg = p.cherryFg })
  api.nvim_set_hl(0, 'RosaLgDefault', { fg = p.default })
  api.nvim_set_hl(0, 'RosaLgInactive', { fg = p.inactive })
  api.nvim_set_hl(0, 'RosaLgOptions', { fg = p.options })
  api.nvim_set_hl(0, 'RosaLgSelected', { bg = p.selected })
  api.nvim_set_hl(0, 'RosaLgUnstaged', { fg = p.unstaged })
end

function M.setup()
  M.apply()
  api.nvim_create_autocmd({ 'ColorScheme', 'OptionSet' }, {
    group = api.nvim_create_augroup('RosavimLazygitTheme', { clear = true }),
    callback = function(ev)
      if ev.event == 'OptionSet' and ev.match ~= 'background' then
        return
      end
      M.apply()
    end,
  })
end

return M

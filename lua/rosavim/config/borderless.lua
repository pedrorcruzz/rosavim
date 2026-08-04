--- Borderless Theme (<leader>lqn) — repaint the which-key / snacks picker /
--- rosapick borders the same colour as their own bg so they blend in, in
--- every rosa theme. Called from the ColorScheme autocmd (plugins/ui/colorscheme.lua)
--- AND from each rosa theme's set_groups: lualine's 'auto' theme re-sources
--- the colors file without firing ColorScheme, so the themes must re-apply
--- this themselves or a restart would lose the borderless look.
local M = {}

function M.apply()
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not (ok and toggles.get 'theme_borderless') then
    return
  end
  for _, group in ipairs { 'WhichKeyBorder', 'SnacksPickerBorder', 'RosapickBorder' } do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    -- Themes that don't style a group leave it undefined — skip it rather than
    -- invent a black border (rosapick falls back to bg-on-bg on its own).
    if not vim.tbl_isempty(hl) then
      -- Transparent mode has no solid bg to blend into; black glyphs nearly
      -- vanish over the dark backdrop.
      vim.api.nvim_set_hl(0, group, { fg = hl.bg or 0x000000, bg = hl.bg })
    end
  end
end

return M

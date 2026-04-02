local M = {}

function M.create()
  local custom_only_bg_min = true
  local custom_only_bg_catpuccin = false
  local colors = {}

  if custom_only_bg_min then
    colors = {
      min_fg_branch = '#a9a9a9',
      min_bg_branch = '#2d2d2d',
      min_bar_bg = nil,
      min_git = '#FFFFFF',
      min_y_bg = '#2d2d2d',
      min_y_fg = '#a9a9a9',
      min_uni_fg_color = '#FEFEFE',
      min_uni_bg_color = '#1a1a1a',
      min_uni_bg_color_z = nil,
    }
  elseif custom_only_bg_catpuccin then
    colors = {
      multiple_min_fg_branch = '#7DB6FF',
      multiple_min_bg_branch = '#313245',
      catpuccin_bar_bg = nil,
      catpuccin_git = '#ECEFF4',
      catpuccin_y_bg = '#313245',
      catpuccin_y_fg = '#7DB6FF',
      catpuccin_uni_fg_color = '#181826',
      catpuccin_uni_bg_color = '#7DB6FF',
      catpuccin_uni_bg_color_z = '#3B4252',
    }
  else
    colors = {
      default_branch_fg = '#abb2bf',
      default_branch_bg = nil,
      default_fg_color = '#1A1A1A',
      default_y_bg = nil,
      default_bar_bg = nil,
      default_y_fg = '#a9a9a9',
      default_normal = '#64BAFF',
      default_insert = '#FF7081',
      default_visual = '#B990F7',
      default_replace = '#ffa066',
      default_command = '#75bf63',
      default_location_fg = '#FFFFFF',
      default_location_bg = nil,
    }
  end

  local function section_b()
    return {
      fg = colors.min_fg_branch or colors.multiple_min_fg_branch or colors.default_branch_fg,
      bg = colors.min_bg_branch or colors.multiple_min_bg_branch or colors.default_branch_bg,
      gui = 'bold',
    }
  end

  local function section_c()
    return {
      fg = colors.min_git or colors.catpuccin_git,
      bg = colors.min_bar_bg or colors.catpuccin_bar_bg or colors.default_bar_bg,
    }
  end

  local function section_y()
    return {
      fg = colors.min_y_fg or colors.catpuccin_y_fg or colors.default_y_fg,
      bg = colors.min_y_bg or colors.catpuccin_y_bg or colors.default_y_bg,
      gui = 'bold',
    }
  end

  local function mode_section(mode_color)
    local bg = colors.min_uni_bg_color or colors.catpuccin_uni_bg_color or mode_color
    local fg = colors.min_uni_fg_color or colors.catpuccin_uni_fg_color or colors.default_fg_color
    return {
      a = { fg = fg, bg = bg, gui = 'bold' },
      b = section_b(),
      c = section_c(),
      y = section_y(),
      z = { fg = fg, bg = bg, gui = 'bold' },
    }
  end

  return {
    normal = mode_section(colors.default_normal),
    insert = mode_section(colors.default_insert),
    visual = mode_section(colors.default_visual),
    replace = mode_section(colors.default_replace),
    command = mode_section(colors.default_command),
  }
end

return M

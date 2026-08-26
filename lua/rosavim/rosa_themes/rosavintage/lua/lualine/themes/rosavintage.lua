local colors = require 'rosavintage.colors'
local config = require 'rosavintage.config'
local M = {}

local bg = config.transparent and 'NONE' or colors.bg
-- The mode chip (a — and the location, which falls back to it) is painted in an
-- accent colour and takes the editor background as its TEXT colour. Transparent
-- mode turns colors.bg into 'NONE', which would leave that text with no
-- foreground at all: it then falls back to StatusLine's muted grey and reads
-- washed out on the accent chip. Keep an opaque dark shade for foregrounds.
local fg_on_accent = config.transparent and colors.bgDark or colors.bg

M.normal = {
  a = { bg = colors.blue, fg = fg_on_accent, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
  c = { bg = bg, fg = fg_on_accent },
}

M.insert = {
  a = { bg = colors.red, fg = fg_on_accent, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.terminal = {
  a = { bg = colors.green, fg = fg_on_accent, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.command = {
  a = { bg = colors.green, fg = fg_on_accent, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.visual = {
  a = { bg = colors.magenta, fg = fg_on_accent, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.replace = {
  a = { bg = colors.gold, fg = fg_on_accent, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.inactive = {
  a = { bg = colors.comment, fg = fg_on_accent },
  b = { bg = bg, fg = colors.gold, gui = 'bold' },
  c = { bg = bg, fg = colors.gold },
}

return M

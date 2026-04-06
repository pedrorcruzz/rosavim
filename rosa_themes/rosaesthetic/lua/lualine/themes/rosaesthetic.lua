local colors = require 'rosaesthetic.colors'
local config = require 'rosaesthetic.config'
local M = {}

local bg = config.transparent and 'NONE' or colors.bg

M.normal = {
  a = { bg = colors.blue, fg = colors.bg, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
  c = { bg = bg, fg = colors.bg },
}

M.insert = {
  a = { bg = colors.red, fg = colors.bg, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.terminal = {
  a = { bg = colors.green, fg = colors.bg, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.command = {
  a = { bg = colors.green, fg = colors.bg, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.visual = {
  a = { bg = colors.magenta, fg = colors.bg, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.replace = {
  a = { bg = colors.gold, fg = colors.bg, gui = 'bold' },
  b = { bg = bg, fg = colors.comment },
}

M.inactive = {
  a = { bg = colors.comment, fg = colors.bg },
  b = { bg = bg, fg = colors.gold, gui = 'bold' },
  c = { bg = bg, fg = colors.gold },
}

return M

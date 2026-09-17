local colors = require("rosamin.colors")
local config = require("rosamin.config")
local min = {}

-- Spelled "None" on purpose: lualine caches this string raw and its no-colour
-- check is case-sensitive. "NONE" slips through as a real colour, so next to a
-- non-empty diff the branch->diff transitional separator gets created with no
-- usable foreground and draws a grey cap with StatusLine's fallback fg.
local bg = config.transparent and "None" or colors.bg
-- The mode chip (a — and the location, which falls back to it) is painted in an
-- accent colour and takes the editor background as its TEXT colour. Transparent
-- mode turns colors.bg into "NONE", which would leave that text with no
-- foreground at all: it then falls back to StatusLine's muted grey and reads
-- washed out on the accent chip. Keep an opaque dark shade for foregrounds.
local fg_on_accent = config.transparent and colors.bgDark or colors.bg

min.normal = {
	a = { bg = colors.blue, fg = fg_on_accent, gui = "bold" },
	b = { bg = bg, fg = colors.comment },
	c = { bg = bg, fg = fg_on_accent },
}

min.insert = {
	a = { bg = colors.red, fg = fg_on_accent, gui = "bold" },
	b = { bg = bg, fg = colors.comment },
}

min.terminal = {
	a = { bg = colors.green, fg = fg_on_accent, gui = "bold" },
	b = { bg = bg, fg = colors.comment },
}

min.command = {
	a = { bg = colors.green, fg = fg_on_accent, gui = "bold" },
	b = { bg = bg, fg = colors.comment },
}

min.visual = {
	a = { bg = colors.purple, fg = fg_on_accent, gui = "bold" },
	b = { bg = bg, fg = colors.comment },
}

min.replace = {
	a = { bg = colors.orange, fg = fg_on_accent, gui = "bold" },
	b = { bg = bg, fg = colors.comment },
}

min.inactive = {
	a = { bg = colors.comment, fg = fg_on_accent },
	b = { bg = bg, fg = colors.orange, gui = "bold" },
	c = { bg = bg, fg = colors.orange },
}

return min

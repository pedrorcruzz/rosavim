-- Clear module caches to ensure fresh evaluation
package.loaded["rosamin"] = nil
package.loaded["rosamin.colors"] = nil
package.loaded["rosamin.config"] = nil

local ok, appearance = pcall(require, "rosavim.config.appearance")
if ok then
	local overrides = require("rosavim.plugins.ui.colorschemes.rosamin.overrides")
	local mode = appearance.get_mode()
	local transparent = appearance.get_transparent()
	local rosamin = require("rosamin")
	rosamin.setup {
		transparent = transparent,
		bold = true,
		strikethrough = true,
		italics = {
			comments = true,
			keywords = true,
			functions = true,
			strings = true,
			variables = true,
		},
		overrides = overrides.get(mode, transparent),
	}
	rosamin.colorscheme()
else
	require("rosamin").colorscheme()
end

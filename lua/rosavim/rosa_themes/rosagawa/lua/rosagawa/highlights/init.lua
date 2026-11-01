local M = {}

---@param highlights table
---@param termcolors table
function M.highlight(highlights, termcolors)
    for hl, spec in pairs(highlights) do
        vim.api.nvim_set_hl(0, hl, spec)
    end
    for i, tcolor in ipairs(termcolors) do
        vim.g["terminal_color_" .. i - 1] = tcolor
    end
end

---@param colors RosagawaColors
---@param config? RosagawaConfig
function M.setup(colors, config)
    config = config or require("rosagawa").config

    local highlights = {}
    for _, highlight in ipairs({ "editor", "syntax", "treesitter", "lsp", "plugins" }) do
        local mod = require("rosagawa.highlights." .. highlight)
        for hl, spec in pairs(mod.setup(colors, config)) do
            highlights[hl] = spec
        end
    end

    for hl, spec in pairs(config.overrides(colors)) do
        if spec.link then
            -- A link override fully replaces the group: merging it onto a
            -- base entry that carried its own fg/bg (e.g. DiagnosticSignWarn)
            -- would leave those stale attrs sitting next to `link`, and
            -- nvim_set_hl renders the explicit attrs instead of following
            -- the link (confirmed via nvim_get_hl(..., {link=false})).
            highlights[hl] = spec
        else
            if highlights[hl] and next(spec) then
                highlights[hl].link = nil
            end
            highlights[hl] = vim.tbl_extend("force", highlights[hl] or {}, spec)
        end
    end

    return highlights
end

return M

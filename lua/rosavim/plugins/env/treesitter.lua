-- Native treesitter configuration (Neovim 0.12+)
-- No plugin needed — uses built-in vim.treesitter API

vim.filetype.add {
  pattern = {
    ['.*%.blade%.php'] = 'blade',
    ['.*%.html'] = 'htmldjango',
    ['.*%.html%.jinja'] = 'htmldjango',
    ['.*%.html%.jinja2'] = 'htmldjango',
    ['.*%.html%.j2'] = 'htmldjango',
  },
}

local group = vim.api.nvim_create_augroup('RosavimTreesitter', { clear = true })

-- Parsing and, above all, the treesitter indentexpr get very expensive on large
-- files (a single `==` or paste re-indents through the tree). Skip both past
-- this size and fall back to the regex syntax, which is what Neovim would do
-- anyway; 512 KB clears every normal source file.
local MAX_FILESIZE = 512 * 1024

local function too_big(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return false
  end
  local ok, stats = pcall(vim.uv.fs_stat, name)
  return ok and stats and stats.size > MAX_FILESIZE or false
end

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function(args)
    if too_big(args.buf) then
      return
    end
    local ok = pcall(vim.treesitter.start, args.buf)
    if ok then
      vim.bo[args.buf].indentexpr = "v:lua.require'vim.treesitter'.indentexpr()"
    end
  end,
})

return {}

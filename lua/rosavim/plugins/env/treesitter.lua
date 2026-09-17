vim.filetype.add {
  pattern = {
    ['.*%.blade%.php'] = 'blade',
    ['.*%.html%.jinja'] = 'htmldjango',
    ['.*%.html%.jinja2'] = 'htmldjango',
    ['.*%.html%.j2'] = 'htmldjango',
  },
}

local group = vim.api.nvim_create_augroup('RosavimTreesitter', { clear = true })

-- Both runtimepath scans run at spec-collection time, before plugin dirs join
-- the rtp, so these tables see ONLY the parsers/queries bundled with Neovim.
-- That is the point: the distro policy is native treesitter with the bundled
-- parsers only, and freezing the tables here enforces it for the session.
local has_parser = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file('parser/*', true)) do
  has_parser[vim.fn.fnamemodify(path, ':t:r')] = true
end

local has_folds = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file('queries/*/folds.scm', true)) do
  has_folds[vim.fn.fnamemodify(path, ':h:t')] = true
end

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
    local buf = args.buf
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang or not has_parser[lang] or too_big(buf) then
      return
    end

    if not pcall(vim.treesitter.start, buf, lang) then
      return
    end

    if has_folds[lang] and vim.api.nvim_get_current_buf() == buf then
      vim.wo[0][0].foldmethod = 'expr'
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldlevel = 99
    end
  end,
})

return {}

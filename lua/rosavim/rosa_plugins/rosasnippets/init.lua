--- Rosasnippets - Browse, create and edit snippets interactively
--- Snippets live in <config>/snippets/<filetype>.json (VSCode format), read
--- by blink.cmp's built-in source and expanded by native vim.snippet. The UI
--- mirrors the RosaAI review panel: a centered container with the list on
--- top and a bordered live-filter search box at the bottom, plus a preview
--- that docks beside the panel. Every change is written to the JSON
--- immediately and blink's caches are refreshed in place — no restart.
local M = {}

local api = vim.api
local list_ns = api.nvim_create_namespace 'rosasnippets_list'
local prompt_ns = api.nvim_create_namespace 'rosasnippets_prompt'

--- Live session (nil when closed): container/list/prompt windows, the query,
--- the flat match list and the selected index.
local S = nil

-- --- Data ------------------------------------------------------------------

local function snippets_dir()
  return vim.fn.stdpath 'config' .. '/snippets'
end

local function file_path(ft)
  return snippets_dir() .. '/' .. ft .. '.json'
end

local function list_filetypes()
  local fts = {}
  for name, kind in vim.fs.dir(snippets_dir()) do
    local ft = kind == 'file' and name:match '^(.+)%.json$'
    if ft then
      fts[#fts + 1] = ft
    end
  end
  table.sort(fts)
  return fts
end

local function load_file(ft)
  local ok, lines = pcall(vim.fn.readfile, file_path(ft))
  if not ok then
    return {}
  end
  local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, '\n'))
  return decoded_ok and decoded or {}
end

--- Rebuild blink's live snippets source so saved changes complete instantly.
--- Provider methods run with the override wrapper as `self`, so swapping
--- registry/cache on it takes effect for every later completion. The resolved
--- config already contains the friendly-snippets paths, so re-append is
--- disabled to avoid duplicates. Silently no-ops if blink isn't loaded.
local function refresh_blink()
  if not package.loaded['blink.cmp'] then
    return
  end
  pcall(function()
    local lib = require 'blink.cmp.sources.lib'
    local provider = lib.get_provider_by_id and lib.get_provider_by_id 'snippets'
    local src = provider and provider.module
    if not (src and src.registry) then
      return
    end
    local cfg = vim.deepcopy(src.registry.config)
    cfg.friendly_snippets = false
    src.registry = require('blink.cmp.sources.snippets.default.registry').new(cfg)
    src.cache = {}
  end)
end

local function save_file(ft, data)
  vim.fn.mkdir(snippets_dir(), 'p')
  if vim.tbl_isempty(data) then
    vim.fn.delete(file_path(ft))
  else
    local ok, encoded = pcall(vim.json.encode, data, { indent = '  ', sort_keys = true })
    if not ok then
      encoded = vim.json.encode(data)
    end
    vim.fn.writefile(vim.split(encoded, '\n'), file_path(ft))
  end
  refresh_blink()
end

--- Body arrays may come as a plain string in hand-written files.
local function body_lines(body)
  if type(body) == 'string' then
    return vim.split(body, '\n')
  end
  return vim.deepcopy(body or { '$0' })
end

--- Every snippet across every file: { ft, name, prefix }.
local function all_snippets()
  local items = {}
  for _, ft in ipairs(list_filetypes()) do
    local data = load_file(ft)
    local names = vim.tbl_keys(data)
    table.sort(names)
    for _, name in ipairs(names) do
      items[#items + 1] = { ft = ft, name = name, prefix = data[name].prefix or '?' }
    end
  end
  return items
end

--- Starter bodies offered by the creation wizard, per language family, so
--- writing a body never starts from a blank page. `\t` re-indents to local
--- settings on expansion; `$0` is the final cursor stop. Personal presets
--- live in <config>/rosasnippets/templates.json (see templates_for).
local TEMPLATE_FAMILY = {
  javascript = { 'js' },
  typescript = { 'js' },
  javascriptreact = { 'js', 'react' },
  typescriptreact = { 'js', 'react' },
  vue = { 'js' },
  svelte = { 'js' },
  python = { 'python' },
  django = { 'python' },
  htmldjango = { 'html' },
  lua = { 'lua' },
  go = { 'go' },
  php = { 'php' },
  blade = { 'php', 'html' },
  sh = { 'sh' },
  bash = { 'sh' },
  zsh = { 'sh' },
  java = { 'java' },
  sql = { 'sql' },
  mysql = { 'sql' },
  plsql = { 'sql' },
  html = { 'html' },
  css = { 'css' },
  scss = { 'css' },
  less = { 'css' },
  markdown = { 'markdown' },
}

local TEMPLATES = {
  js = {
    { label = 'Function', body = { 'function ${1:name}(${2:args}) {', '\t${3:// code}', '}' } },
    { label = 'Arrow function', body = { 'const ${1:name} = (${2:args}) => {', '\t${3:// code}', '}' } },
    { label = 'Async function', body = { 'async function ${1:name}(${2:args}) {', '\t${3:// code}', '}' } },
    { label = 'Async arrow', body = { 'const ${1:name} = async (${2:args}) => {', '\t${3:// code}', '}' } },
    { label = 'Class', body = { 'class ${1:Name} {', '\tconstructor(${2:args}) {', '\t\t${3:// code}', '\t}', '}' } },
    { label = 'Try / Catch', body = { 'try {', '\t${1:// code}', '} catch (error) {', '\tconsole.error(error)', '}' } },
    { label = 'If / Else', body = { 'if (${1:condition}) {', '\t${2:// code}', '} else {', '\t${3:// code}', '}' } },
    { label = 'For loop', body = { 'for (let ${1:i} = 0; ${1:i} < ${2:n}; ${1:i}++) {', '\t${3:// code}', '}' } },
    { label = 'Switch', body = { 'switch (${1:value}) {', '\tcase ${2:match}:', '\t\t${3:// code}', '\t\tbreak', '\tdefault:', '\t\t$0', '}' } },
    { label = 'Promise', body = { 'new Promise((resolve, reject) => {', '\t${1:// code}', '})' } },
    { label = 'Fetch', body = { "const ${1:res} = await fetch('${2:url}')", 'const ${3:data} = await ${1:res}.json()$0' } },
    { label = 'Import', body = { "import ${1:module} from '${2:package}'$0" } },
    { label = 'Console log', body = { 'console.log(${1:value})$0' } },
  },
  react = {
    { label = 'React · Component (export default)', body = { 'export default function ${1:Component}(${2:props}) {', '\treturn (', '\t\t<div>', '\t\t\t$0', '\t\t</div>', '\t)', '}' } },
    { label = 'React · Arrow component', body = { 'const ${1:Component} = (${2:props}) => {', '\treturn (', '\t\t<div>', '\t\t\t$0', '\t\t</div>', '\t)', '}', '', 'export default ${1:Component}' } },
    { label = 'React · useState', body = { 'const [${1:state}, set${2:State}] = useState(${3:initial})$0' } },
    { label = 'React · useEffect', body = { 'useEffect(() => {', '\t${1:// effect}', '\treturn () => {', '\t\t${2:// cleanup}', '\t}', '}, [${3:deps}])' } },
    { label = 'React · Props type (TS)', body = { 'type ${1:Component}Props = {', '\t${2:prop}: ${3:string}', '}' } },
  },
  python = {
    { label = 'Function', body = { 'def ${1:name}(${2:args}):', '\t${3:pass}' } },
    { label = 'Async function', body = { 'async def ${1:name}(${2:args}):', '\t${3:pass}' } },
    { label = 'Class', body = { 'class ${1:Name}:', '\tdef __init__(self${2:, args}):', '\t\t${3:pass}' } },
    { label = 'Dataclass', body = { '@dataclass', 'class ${1:Name}:', '\t${2:field}: ${3:str}' } },
    { label = 'Try / Except', body = { 'try:', '\t${1:pass}', 'except ${2:Exception} as e:', '\t${3:print(e)}' } },
    { label = 'If / Else', body = { 'if ${1:condition}:', '\t${2:pass}', 'else:', '\t${3:pass}' } },
    { label = 'For loop', body = { 'for ${1:item} in ${2:items}:', '\t${3:pass}' } },
    { label = 'List comprehension', body = { '${1:result} = [${2:x} for ${2:x} in ${3:items} if ${4:condition}]$0' } },
    { label = 'With open', body = { 'with open(${1:path}) as ${2:f}:', '\t${3:pass}' } },
    { label = 'Main guard', body = { "if __name__ == '__main__':", '\t${1:main()}' } },
    { label = 'Pytest test', body = { 'def test_${1:name}():', '\t${2:result} = ${3:call()}', '\tassert ${2:result} == ${4:expected}' } },
  },
  lua = {
    { label = 'Function', body = { 'local function ${1:name}(${2:args})', '\t${3:-- code}', 'end' } },
    { label = 'Module', body = { 'local M = {}', '', 'function M.${1:name}(${2:args})', '\t${3:-- code}', 'end', '', 'return M' } },
    { label = 'If / Else', body = { 'if ${1:condition} then', '\t${2:-- code}', 'else', '\t${3:-- code}', 'end' } },
    { label = 'For loop', body = { 'for ${1:i} = 1, ${2:n} do', '\t${3:-- code}', 'end' } },
    { label = 'For pairs', body = { 'for ${1:k}, ${2:v} in pairs(${3:tbl}) do', '\t${4:-- code}', 'end' } },
    { label = 'Pcall', body = { 'local ok, ${1:result} = pcall(${2:fn})', 'if not ok then', '\t${3:-- handle error}', 'end' } },
    { label = 'Keymap', body = { "vim.keymap.set('${1:n}', '${2:lhs}', ${3:rhs}, { desc = '${4:description}' })$0" } },
  },
  go = {
    { label = 'Function', body = { 'func ${1:name}(${2:args}) ${3:error} {', '\t${4:// code}', '}' } },
    { label = 'Struct', body = { 'type ${1:Name} struct {', '\t${2:Field} ${3:string}', '}' } },
    { label = 'Interface', body = { 'type ${1:Name} interface {', '\t${2:Method}(${3:args}) ${4:error}', '}' } },
    { label = 'Method', body = { 'func (${1:r} *${2:Type}) ${3:Name}(${4:args}) ${5:error} {', '\t${6:// code}', '}' } },
    { label = 'If err', body = { 'if err != nil {', '\treturn ${1:err}', '}' } },
    { label = 'For loop', body = { 'for ${1:i} := 0; ${1:i} < ${2:n}; ${1:i}++ {', '\t${3:// code}', '}' } },
    { label = 'For range', body = { 'for ${1:i}, ${2:v} := range ${3:items} {', '\t${4:// code}', '}' } },
    { label = 'Goroutine', body = { 'go func() {', '\t${1:// code}', '}()' } },
    { label = 'Test func', body = { 'func Test${1:Name}(t *testing.T) {', '\t${2:// arrange}', '\tif ${3:got} != ${4:want} {', '\t\tt.Errorf("got %v, want %v", ${3:got}, ${4:want})', '\t}', '}' } },
  },
  php = {
    { label = 'Function', body = { 'function ${1:name}(${2:args})', '{', '\t${3:// code}', '}' } },
    { label = 'Class', body = { 'class ${1:Name}', '{', '\tpublic function __construct(${2:args})', '\t{', '\t\t${3:// code}', '\t}', '}' } },
    { label = 'Method', body = { 'public function ${1:name}(${2:args})', '{', '\t${3:// code}', '}' } },
    { label = 'Foreach', body = { 'foreach (${1:\\$items} as ${2:\\$item}) {', '\t${3:// code}', '}' } },
    { label = 'Foreach key/value', body = { 'foreach (${1:\\$items} as ${2:\\$key} => ${3:\\$value}) {', '\t${4:// code}', '}' } },
    { label = 'Try / Catch', body = { 'try {', '\t${1:// code}', '} catch (\\Exception ${2:\\$e}) {', '\t${3:// handle}', '}' } },
    { label = 'If / Else', body = { 'if (${1:condition}) {', '\t${2:// code}', '} else {', '\t${3:// code}', '}' } },
  },
  sh = {
    { label = 'Function', body = { '${1:name}() {', '\t${2:# code}', '}' } },
    { label = 'If', body = { 'if [[ ${1:condition} ]]; then', '\t${2:# code}', 'fi' } },
    { label = 'For loop', body = { 'for ${1:item} in ${2:items}; do', '\t${3:# code}', 'done' } },
    { label = 'Case', body = { 'case ${1:\\$var} in', '\t${2:pattern})', '\t\t${3:# code}', '\t\t;;', '\t*)', '\t\t$0', '\t\t;;', 'esac' } },
    { label = 'While', body = { 'while ${1:condition}; do', '\t${2:# code}', 'done' } },
  },
  java = {
    { label = 'Class', body = { 'public class ${1:Name} {', '\t${2:// code}', '}' } },
    { label = 'Method', body = { 'public ${1:void} ${2:name}(${3:args}) {', '\t${4:// code}', '}' } },
    { label = 'Main', body = { 'public static void main(String[] args) {', '\t${1:// code}', '}' } },
    { label = 'Try / Catch', body = { 'try {', '\t${1:// code}', '} catch (${2:Exception} e) {', '\t${3:e.printStackTrace();}', '}' } },
    { label = 'For loop', body = { 'for (int ${1:i} = 0; ${1:i} < ${2:n}; ${1:i}++) {', '\t${3:// code}', '}' } },
    { label = 'For each', body = { 'for (${1:Type} ${2:item} : ${3:items}) {', '\t${4:// code}', '}' } },
  },
  sql = {
    { label = 'Select', body = { 'SELECT ${1:columns}', 'FROM ${2:table}', 'WHERE ${3:condition};' } },
    { label = 'Insert', body = { 'INSERT INTO ${1:table} (${2:columns})', 'VALUES (${3:values});' } },
    { label = 'Update', body = { 'UPDATE ${1:table}', 'SET ${2:column} = ${3:value}', 'WHERE ${4:condition};' } },
    { label = 'Create table', body = { 'CREATE TABLE ${1:name} (', '\tid SERIAL PRIMARY KEY,', '\t${2:column} ${3:VARCHAR(255)}', ');' } },
    { label = 'Join', body = { 'SELECT ${1:columns}', 'FROM ${2:a}', 'JOIN ${3:b} ON ${2:a}.${4:id} = ${3:b}.${5:a_id}', 'WHERE ${6:condition};' } },
  },
  html = {
    { label = 'HTML5 boilerplate', body = { '<!doctype html>', '<html lang="${1:en}">', '\t<head>', '\t\t<meta charset="utf-8" />', '\t\t<title>${2:Title}</title>', '\t</head>', '\t<body>', '\t\t$0', '\t</body>', '</html>' } },
    { label = 'Tag', body = { '<${1:div} class="${2:class}">', '\t$0', '</${1:div}>' } },
    { label = 'Form', body = { '<form action="${1:/submit}" method="${2:post}">', '\t$0', '</form>' } },
  },
  css = {
    { label = 'Rule', body = { '${1:.selector} {', '\t${2:property}: ${3:value};', '}' } },
    { label = 'Flex center', body = { '${1:.selector} {', '\tdisplay: flex;', '\talign-items: center;', '\tjustify-content: center;', '}' } },
    { label = 'Media query', body = { '@media (max-width: ${1:768px}) {', '\t${2:.selector} {', '\t\t${3:property}: ${4:value};', '\t}', '}' } },
  },
  markdown = {
    { label = 'Code block', body = { '```${1:lang}', '$0', '```' } },
    { label = 'Link', body = { '[${1:text}](${2:url})$0' } },
    { label = 'Table', body = { '| ${1:Col} | ${2:Col} |', '|---|---|', '| ${3:cell} | ${4:cell} |' } },
    { label = 'Frontmatter', body = { '---', 'title: ${1:Title}', 'date: ${2:2026-01-01}', '---', '', '$0' } },
  },
}

--- Personal presets file: { ["<filetype-or-family>"] = { { label, body }, … } }.
--- Keys can be an exact filetype (typescriptreact) or a family name (js) to
--- cover the whole family. Lives OUTSIDE the nvim config on purpose: personal
--- presets belong to the user's dotfiles, never to the Rosavim distro itself
--- (and blink never scans there either).
local function user_templates_path()
  return vim.fs.dirname(vim.fn.stdpath 'config') .. '/rosasnippets/templates.json'
end

local function read_user_templates()
  local ok, lines = pcall(vim.fn.readfile, user_templates_path())
  if not ok then
    return {}
  end
  local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, '\n'))
  return decoded_ok and decoded or {}
end

local function write_user_templates(user)
  local path = user_templates_path()
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  local ok, encoded = pcall(vim.json.encode, user, { indent = '  ', sort_keys = true })
  if not ok then
    encoded = vim.json.encode(user)
  end
  vim.fn.writefile(vim.split(encoded, '\n'), path)
end

--- Template choices for a filetype: Empty first, personal presets (★) next,
--- then the built-in starters from the filetype's families.
local function templates_for(ft)
  local list = { { label = 'Empty — write from scratch', body = { '$0' } } }
  local families = TEMPLATE_FAMILY[ft] or {}
  local user = read_user_templates()
  local seen_user = {}
  local function add_user(key)
    for _, t in ipairs(user[key] or {}) do
      if not seen_user[t.label] then
        seen_user[t.label] = true
        list[#list + 1] = { label = '★ ' .. (t.label or '?'), body = body_lines(t.body) }
      end
    end
  end
  add_user(ft)
  for _, fam in ipairs(families) do
    add_user(fam)
  end
  for _, fam in ipairs(families) do
    vim.list_extend(list, TEMPLATES[fam] or {})
  end
  return list
end

-- --- UI helpers ------------------------------------------------------------

local function setup_highlights()
  local p = require('rosavim.rosa_plugins.palette').get()
  api.nvim_set_hl(0, 'RosasnippetsBorder', { fg = p.border })
  api.nvim_set_hl(0, 'RosasnippetsTitle', { fg = p.title, bold = true })
  api.nvim_set_hl(0, 'RosasnippetsKey', { fg = p.key, bold = true })
  api.nvim_set_hl(0, 'RosasnippetsDim', { fg = p.dim, italic = true })
  api.nvim_set_hl(0, 'RosasnippetsFiletype', { fg = p.title, bold = true })
  api.nvim_set_hl(0, 'RosasnippetsPrefix', { fg = p.key, bold = true })
end

local function session_open()
  return S ~= nil and S.list and api.nvim_win_is_valid(S.list.win)
end

local function close_panel()
  if not S then
    return
  end
  local wins = { S.prompt and S.prompt.win, S.list and S.list.win, S.container and S.container.win }
  S = nil
  pcall(vim.cmd, 'stopinsert')
  for _, win in ipairs(wins) do
    if win and api.nvim_win_is_valid(win) then
      pcall(api.nvim_win_close, win, true)
    end
  end
end

local function current_item()
  return S and S.matches and S.matches[S.sel or 1] or nil
end

--- Rebuild the match list from the query and repaint the list window.
--- Empty query → grouped by filetype with header rows; a query → flat
--- fuzzy-matched rows that show the filetype inline.
local function render()
  if not session_open() then
    return
  end
  local items = all_snippets()
  if S.ft_filter then
    items = vim.tbl_filter(function(i)
      return i.ft == S.ft_filter
    end, items)
  end
  local rows, matches = {}, {}

  if (S.query or '') == '' then
    local last_ft = nil
    for _, item in ipairs(items) do
      if item.ft ~= last_ft then
        if last_ft then
          rows[#rows + 1] = { text = '', kind = 'blank' }
        end
        rows[#rows + 1] = { text = '  ' .. item.ft, kind = 'header' }
        last_ft = item.ft
      end
      matches[#matches + 1] = item
      rows[#rows + 1] = { text = string.format('    %-14s %s', item.prefix, item.name), kind = 'item', match = #matches }
    end
  else
    local haystack = vim.tbl_map(function(i)
      return i.prefix .. ' ' .. i.name .. ' ' .. i.ft
    end, items)
    local ok, found = pcall(vim.fn.matchfuzzy, haystack, S.query)
    local picked = {}
    if ok then
      -- matchfuzzy gives ranked matched strings; map back to items by text.
      local by_text = {}
      for idx, text in ipairs(haystack) do
        by_text[text] = by_text[text] or idx
      end
      for _, text in ipairs(found) do
        local idx = by_text[text]
        if idx then
          picked[#picked + 1] = items[idx]
        end
      end
    end
    for _, item in ipairs(picked) do
      matches[#matches + 1] = item
      rows[#rows + 1] = { text = string.format('    %-14s %-30s %s', item.prefix, item.name, item.ft), kind = 'item', match = #matches }
    end
    if #rows == 0 then
      rows[#rows + 1] = { text = '    no matches', kind = 'blank' }
    end
  end

  if #items == 0 then
    rows = { { text = '', kind = 'blank' }, { text = '    No snippets yet — press a to create the first one', kind = 'blank' } }
  end

  S.matches = matches
  S.sel = math.max(1, math.min(S.sel or 1, math.max(#matches, 1)))

  local lines = {}
  local sel_row = nil
  for i, row in ipairs(rows) do
    lines[i] = row.text
    if row.kind == 'item' and row.match == S.sel then
      sel_row = i
      lines[i] = '  ❯' .. row.text:sub(4)
    end
  end

  local buf = S.list.buf
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  api.nvim_buf_clear_namespace(buf, list_ns, 0, -1)
  for i, row in ipairs(rows) do
    if row.kind == 'header' then
      api.nvim_buf_set_extmark(buf, list_ns, i - 1, 0, { end_col = #lines[i], hl_group = 'RosasnippetsFiletype' })
    elseif row.kind == 'item' then
      api.nvim_buf_set_extmark(buf, list_ns, i - 1, 4, { end_col = math.min(18, #lines[i]), hl_group = 'RosasnippetsPrefix' })
      if row.match == S.sel then
        api.nvim_buf_set_extmark(buf, list_ns, i - 1, 0, { end_row = i, hl_eol = true, hl_group = 'Visual' })
      end
    end
  end

  -- Keep the selection scrolled into view even while focus is on the prompt.
  if sel_row then
    pcall(api.nvim_win_set_cursor, S.list.win, { sel_row, 0 })
  end
end

local function move(delta)
  if not S or #(S.matches or {}) == 0 then
    return
  end
  S.sel = math.max(1, math.min(#S.matches, (S.sel or 1) + delta))
  render()
end

--- Reposition the panel to a new left column (children are relative='win'
--- floats that do not follow the container automatically). Used to slide the
--- panel aside while the preview docks on the right.
local function place_panel(ccol)
  if not S then
    return
  end
  pcall(api.nvim_win_set_config, S.container.win, {
    relative = 'editor',
    row = S.row,
    col = ccol,
    width = S.width,
    height = S.inner_h,
  })
  pcall(api.nvim_win_set_config, S.list.win, {
    relative = 'win',
    win = S.container.win,
    row = 0,
    col = 0,
    width = S.width,
    height = S.list_h,
  })
  pcall(api.nvim_win_set_config, S.prompt.win, {
    relative = 'win',
    win = S.container.win,
    row = S.list_h,
    col = 3,
    width = S.width - 6,
    height = 1,
  })
end

-- --- Actions ---------------------------------------------------------------

--- Body editor: a float with the snippet body as real buffer lines.
--- Autosaves (debounced) on every change — hot reload while typing.
function M.edit_body(item)
  local data = load_file(item.ft)
  local snip = data[item.name]
  if not snip then
    return
  end

  setup_highlights()
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  api.nvim_buf_set_lines(buf, 0, -1, false, body_lines(snip.body))
  -- Syntax via treesitter directly: setting 'filetype' would fire FileType
  -- autocmds (nvim-lint, LSP attach) which choke on ${1:} placeholders.
  local ts_ok = pcall(vim.treesitter.start, buf, vim.treesitter.language.get_lang(item.ft) or item.ft)
  if not ts_ok then
    pcall(function()
      vim.bo[buf].syntax = item.ft
    end)
  end
  pcall(vim.diagnostic.enable, false, { bufnr = buf })

  local width = math.min(100, vim.o.columns - 8)
  local height = math.min(math.max(api.nvim_buf_line_count(buf) + 2, 10), 26)
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = { { ' 󰩫 ' .. (snip.prefix or '?') .. ' · body ', 'RosasnippetsTitle' } },
    title_pos = 'center',
    footer = {
      { ' ${1:placeholder} tabstops · $0 end · ', 'RosasnippetsDim' },
      { '<C-t>', 'RosasnippetsKey' },
      { ' next tabstop · autosaves · ', 'RosasnippetsDim' },
      { 'q', 'RosasnippetsKey' },
      { ' close ', 'RosasnippetsDim' },
    },
    footer_pos = 'center',
    zindex = 60,
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosasnippetsBorder'

  local timer = nil
  local function stop_timer()
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
  end
  local function save_now()
    local fresh = load_file(item.ft)
    if fresh[item.name] then
      fresh[item.name].body = api.nvim_buf_get_lines(buf, 0, -1, false)
      save_file(item.ft, fresh)
    end
  end
  api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    buffer = buf,
    callback = function()
      stop_timer()
      timer = vim.uv.new_timer()
      timer:start(400, 0, vim.schedule_wrap(function()
        timer = nil
        save_now()
      end))
    end,
  })
  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(win),
    once = true,
    callback = function()
      stop_timer()
      save_now()
      vim.schedule(function()
        if session_open() then
          render()
          api.nvim_set_current_win(S.list.win)
        end
      end)
    end,
  })
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, nowait = true, desc = 'Close body editor' })
  -- Insert the next numbered tabstop at the cursor, ready to type the
  -- placeholder text (cursor lands inside the braces).
  vim.keymap.set('i', '<C-t>', function()
    local max = 0
    for _, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
      for n in line:gmatch '%${(%d+)' do
        max = math.max(max, tonumber(n) or 0)
      end
      for n in line:gmatch '%$(%d+)' do
        max = math.max(max, tonumber(n) or 0)
      end
    end
    local snippet = ('${%d:}'):format(max + 1)
    api.nvim_put({ snippet }, 'c', false, true)
    local pos = api.nvim_win_get_cursor(0)
    api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
  end, { buffer = buf, desc = 'Insert next tabstop' })
end

--- Step-by-step wizard: filetype → trigger → description, saving as soon as
--- the entry exists, then straight into the body editor (which autosaves).
local function add_snippet()
  local NEW = '  new filetype…'
  local choices = list_filetypes()
  choices[#choices + 1] = NEW
  vim.ui.select(choices, { prompt = 'Rosasnippets · filetype', kind = 'rosasnippets_ft' }, function(ft)
    if not ft then
      return
    end
    local function with_ft(filetype)
      vim.ui.input({ prompt = 'Step 1/4 · Trigger (prefix): ' }, function(prefix)
        if not prefix or prefix == '' then
          return
        end
        vim.ui.input({ prompt = 'Step 2/4 · Description: ' }, function(desc)
          if not desc or desc == '' then
            desc = prefix
          end
          vim.ui.select(templates_for(filetype), {
            prompt = 'Step 3/4 · Start from',
            kind = 'rosasnippets_template',
            format_item = function(t)
              return t.label
            end,
          }, function(template)
            if not template then
              return
            end
            local data = load_file(filetype)
            local name = data[desc] == nil and desc or (desc .. ' (' .. prefix .. ')')
            data[name] = { prefix = prefix, description = desc, body = vim.deepcopy(template.body) }
            save_file(filetype, data)
            render()
            M.edit_body { ft = filetype, name = name }
          end)
        end)
      end)
    end
    if ft == NEW then
      vim.ui.input({ prompt = 'New filetype: ' }, function(new_ft)
        if new_ft and new_ft ~= '' then
          with_ft(new_ft)
        end
      end)
    else
      with_ft(ft)
    end
  end)
end

--- Edit the snippet's trigger and description (bound to `e`): two clearly
--- labeled prompts, prefilled, each saved as soon as it is confirmed. The
--- body is edited separately via <CR>.
local function edit_snippet(item)
  local data = load_file(item.ft)
  local snip = data[item.name]
  if not snip then
    return
  end
  vim.ui.input({ prompt = 'Edit 1/2 · Trigger (prefix): ', default = snip.prefix }, function(prefix)
    if not prefix or prefix == '' then
      return
    end
    local fresh = load_file(item.ft)
    if fresh[item.name] then
      fresh[item.name].prefix = prefix
      save_file(item.ft, fresh)
      render()
    end
    vim.ui.input({ prompt = 'Edit 2/2 · Description: ', default = snip.description or item.name }, function(desc)
      if not desc or desc == '' then
        return
      end
      local cur = load_file(item.ft)
      local entry = cur[item.name]
      if not entry then
        return
      end
      entry.description = desc
      -- The entry key is the description; move it when it changes.
      if desc ~= item.name and cur[desc] == nil then
        cur[item.name] = nil
        cur[desc] = entry
      end
      save_file(item.ft, cur)
      render()
    end)
  end)
end

local function delete_snippet(item)
  if vim.fn.confirm(('Delete snippet %q (%s)?'):format(item.prefix, item.ft), '&Yes\n&No', 2) ~= 1 then
    return
  end
  local data = load_file(item.ft)
  data[item.name] = nil
  save_file(item.ft, data)
  render()
end

--- Show the active language filter as a badge in the container title.
local function set_title()
  if not (S and api.nvim_win_is_valid(S.container.win)) then
    return
  end
  local text = S.ft_filter and (' 󰩫 Rosasnippets · ' .. S.ft_filter .. ' ') or ' 󰩫 Rosasnippets '
  pcall(api.nvim_win_set_config, S.container.win, {
    title = { { text, 'RosasnippetsTitle' } },
    title_pos = 'center',
  })
end

--- Language filter: a small popup (same vim.ui.select style as the theme
--- selector) listing every filetype plus `none` to clear.
local function pick_filter()
  local NONE = 'none'
  local choices = { NONE }
  vim.list_extend(choices, list_filetypes())
  local current = S and S.ft_filter or NONE
  vim.ui.select(choices, {
    prompt = 'Rosasnippets · filter by language',
    kind = 'rosasnippets_filter',
    format_item = function(ft)
      return ft .. (ft == current and ' ●' or '')
    end,
  }, function(choice)
    if not choice or not S then
      return
    end
    S.ft_filter = choice ~= NONE and choice or nil
    S.sel = 1
    set_title()
    render()
  end)
end

--- Slide the panel left and return a geometry docked on its right side for
--- a float of the wanted height (top-aligned with the panel). Returns nil on
--- screens too narrow to fit both — the caller then centers as usual. The
--- caller must restore with place_panel(S.col) when its window closes.
local function dock_beside(height_wanted)
  if not S then
    return nil
  end
  local gap = 3
  local w = math.min(vim.o.columns - 4 - S.width - gap, 96)
  if w < 30 then
    return nil
  end
  local total = S.width + gap + w
  local start_col = math.max(2, math.floor((vim.o.columns - total) / 2))
  place_panel(start_col)
  return {
    row = math.max(1, S.row),
    col = start_col + S.width + gap,
    width = w,
    height = math.min(height_wanted, vim.o.lines - 4),
  }
end

--- Re-center the panel once a docked window closes.
local function undock_on_close(win)
  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(win),
    once = true,
    callback = function()
      vim.schedule(function()
        if S then
          place_panel(S.col)
        end
      end)
    end,
  })
end

--- Float editor over a CUSTOM preset's body, autosaving (debounced) into the
--- user templates file — same feel as the snippet body editor.
local function edit_preset_body(key, idx)
  local user = read_user_templates()
  local preset = (user[key] or {})[idx]
  if not preset then
    return
  end
  setup_highlights()
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  api.nvim_buf_set_lines(buf, 0, -1, false, body_lines(preset.body))
  pcall(vim.diagnostic.enable, false, { bufnr = buf })
  local height = math.min(math.max(api.nvim_buf_line_count(buf) + 2, 10), 26)
  local geom = session_open() and dock_beside(height) or nil
  local width = geom and geom.width or math.min(100, vim.o.columns - 8)
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = geom and geom.height or height,
    row = geom and geom.row or math.floor((vim.o.lines - height) / 2),
    col = geom and geom.col or math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = { { ' 󰩫 ★ ' .. (preset.label or '?') .. ' · preset body ', 'RosasnippetsTitle' } },
    title_pos = 'center',
    footer = { { ' autosaves · ', 'RosasnippetsDim' }, { 'q', 'RosasnippetsKey' }, { ' close ', 'RosasnippetsDim' } },
    footer_pos = 'center',
    zindex = 60,
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:RosasnippetsBorder'
  local timer = nil
  local function stop_timer()
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
  end
  local function save_now()
    local fresh = read_user_templates()
    if fresh[key] and fresh[key][idx] then
      fresh[key][idx].body = api.nvim_buf_get_lines(buf, 0, -1, false)
      write_user_templates(fresh)
    end
  end
  api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    buffer = buf,
    callback = function()
      stop_timer()
      timer = vim.uv.new_timer()
      timer:start(400, 0, vim.schedule_wrap(function()
        timer = nil
        save_now()
      end))
    end,
  })
  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(win),
    once = true,
    callback = function()
      stop_timer()
      save_now()
    end,
  })
  if geom then
    undock_on_close(win)
  end
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, nowait = true })
end

--- Preset browser: a two-pane overlay — list on the left, an always-open
--- read-only preview on the right that follows the selection live. Built-in
--- presets are view-only; personal ones (★) can be edited (body via <CR>,
--- label via r) or deleted (d).
local function browse_presets(ft)
  local function collect()
    local user = read_user_templates()
    local families = TEMPLATE_FAMILY[ft] or {}
    local entries = {}
    local function add_customs(key)
      for i, t in ipairs(user[key] or {}) do
        entries[#entries + 1] = { editable = true, key = key, idx = i, label = '★ ' .. (t.label or '?'), body = body_lines(t.body) }
      end
    end
    add_customs(ft)
    for _, fam in ipairs(families) do
      if fam ~= ft then
        add_customs(fam)
      end
    end
    for _, fam in ipairs(families) do
      for _, t in ipairs(TEMPLATES[fam] or {}) do
        entries[#entries + 1] = { editable = false, label = t.label, body = body_lines(t.body) }
      end
    end
    return entries
  end

  local entries = collect()
  if #entries == 0 then
    vim.notify('Rosasnippets: no presets for ' .. ft)
    return
  end

  setup_highlights()
  local sel = 1
  local list_w = 44
  local gap = 2
  local prev_w = math.min(64, vim.o.columns - list_w - gap - 10)
  local total = list_w + gap + prev_w
  local height = math.min(math.max(#entries + 2, 12), vim.o.lines - 8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - total) / 2)

  local lbuf = api.nvim_create_buf(false, true)
  vim.bo[lbuf].bufhidden = 'wipe'
  local lwin = api.nvim_open_win(lbuf, true, {
    relative = 'editor',
    width = list_w,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = { { ' 󰩫 Presets · ' .. ft .. ' ', 'RosasnippetsTitle' } },
    title_pos = 'center',
    zindex = 61,
  })
  vim.wo[lwin].winhl = 'Normal:Normal,FloatBorder:RosasnippetsBorder'

  local pbuf = api.nvim_create_buf(false, true)
  vim.bo[pbuf].bufhidden = 'wipe'
  vim.bo[pbuf].modifiable = false
  local pwin = api.nvim_open_win(pbuf, false, {
    relative = 'editor',
    width = prev_w,
    height = height,
    row = row,
    col = col + list_w + gap + 2,
    style = 'minimal',
    border = 'rounded',
    title = { { ' preview ', 'RosasnippetsDim' } },
    title_pos = 'center',
    zindex = 61,
  })
  vim.wo[pwin].winhl = 'Normal:Normal,FloatBorder:RosasnippetsBorder'

  local function close_browser()
    for _, win in ipairs { lwin, pwin } do
      if api.nvim_win_is_valid(win) then
        pcall(api.nvim_win_close, win, true)
      end
    end
  end

  local function draw()
    sel = math.max(1, math.min(sel, #entries))
    local lines = {}
    for i, e in ipairs(entries) do
      lines[i] = (i == sel and ' ❯ ' or '   ') .. e.label
    end
    vim.bo[lbuf].modifiable = true
    api.nvim_buf_set_lines(lbuf, 0, -1, false, lines)
    vim.bo[lbuf].modifiable = false
    api.nvim_buf_clear_namespace(lbuf, list_ns, 0, -1)
    for i, e in ipairs(entries) do
      if i == sel then
        api.nvim_buf_set_extmark(lbuf, list_ns, i - 1, 0, { end_row = i, hl_eol = true, hl_group = 'Visual' })
      elseif not e.editable then
        api.nvim_buf_set_extmark(lbuf, list_ns, i - 1, 0, { end_col = #lines[i], hl_group = 'RosasnippetsDim' })
      end
    end
    pcall(api.nvim_win_set_cursor, lwin, { sel, 0 })
    -- Live preview of the selected preset's body.
    local e = entries[sel]
    -- Footer follows the selection: action keys only exist for customs (★),
    -- so never advertise them on a built-in.
    if e and api.nvim_win_is_valid(lwin) then
      local footer
      if e.editable then
        footer = {
          { ' e', 'RosasnippetsKey' },
          { ' edit  ', 'RosasnippetsDim' },
          { 'r', 'RosasnippetsKey' },
          { ' rename  ', 'RosasnippetsDim' },
          { 'd', 'RosasnippetsKey' },
          { ' delete  ', 'RosasnippetsDim' },
          { 'q', 'RosasnippetsKey' },
          { ' close ', 'RosasnippetsDim' },
        }
      else
        footer = {
          { ' built-in · read-only · ', 'RosasnippetsDim' },
          { 'q', 'RosasnippetsKey' },
          { ' close ', 'RosasnippetsDim' },
        }
      end
      pcall(api.nvim_win_set_config, lwin, { footer = footer, footer_pos = 'center' })
    end
    if e and api.nvim_win_is_valid(pwin) then
      vim.bo[pbuf].modifiable = true
      api.nvim_buf_set_lines(pbuf, 0, -1, false, e.body)
      vim.bo[pbuf].modifiable = false
      local tag = e.editable and ' ★ editable ' or ' read-only '
      pcall(api.nvim_win_set_config, pwin, {
        title = { { ' ' .. e.label:gsub('^★ ', '') .. ' ·' .. tag, e.editable and 'RosasnippetsTitle' or 'RosasnippetsDim' } },
        title_pos = 'center',
      })
    end
  end

  local function refresh()
    entries = collect()
    if #entries == 0 then
      close_browser()
      return
    end
    draw()
  end

  local bopts = { buffer = lbuf, silent = true, nowait = true }
  local function bmove(delta)
    sel = sel + delta
    draw()
  end
  vim.keymap.set('n', 'j', function() bmove(1) end, bopts)
  vim.keymap.set('n', 'k', function() bmove(-1) end, bopts)
  vim.keymap.set('n', '<Down>', function() bmove(1) end, bopts)
  vim.keymap.set('n', '<Up>', function() bmove(-1) end, bopts)
  vim.keymap.set('n', 'q', close_browser, bopts)
  vim.keymap.set('n', '<Esc>', close_browser, bopts)
  vim.keymap.set('n', 'e', function()
    local e = entries[sel]
    if not (e and e.editable) then
      return
    end
    close_browser()
    edit_preset_body(e.key, e.idx)
  end, bopts)
  vim.keymap.set('n', 'r', function()
    local e = entries[sel]
    if not (e and e.editable) then
      return
    end
    vim.ui.input({ prompt = 'Preset label: ', default = e.label:gsub('^★ ', '') }, function(label)
      if not label or label == '' then
        return
      end
      local fresh = read_user_templates()
      if fresh[e.key] and fresh[e.key][e.idx] then
        fresh[e.key][e.idx].label = label
        write_user_templates(fresh)
      end
      refresh()
    end)
  end, bopts)
  vim.keymap.set('n', 'd', function()
    local e = entries[sel]
    if not (e and e.editable) then
      return
    end
    if vim.fn.confirm(('Delete preset %s?'):format(e.label), '&Yes\n&No', 2) ~= 1 then
      return
    end
    local fresh = read_user_templates()
    if fresh[e.key] then
      table.remove(fresh[e.key], e.idx)
      if #fresh[e.key] == 0 then
        fresh[e.key] = nil
      end
      write_user_templates(fresh)
    end
    refresh()
  end, bopts)

  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(lwin),
    once = true,
    callback = function()
      vim.schedule(close_browser)
    end,
  })

  draw()
end

--- Save the selected snippet's body as a personal preset:
--- appended to the user templates file under its filetype, so it shows up
--- (★) in the wizard's Start-from step for that language.
local function save_as_preset(item)
  local data = load_file(item.ft)
  local snip = data[item.name]
  if not snip then
    return
  end
  vim.ui.input({ prompt = 'Preset label: ', default = snip.description or item.name }, function(label)
    if not label or label == '' then
      return
    end
    local user = read_user_templates()
    user[item.ft] = user[item.ft] or {}
    table.insert(user[item.ft], { label = label, body = body_lines(snip.body) })
    write_user_templates(user)
    vim.notify(('Rosasnippets: preset %q saved for %s'):format(label, item.ft))
  end)
end

--- Preset menu (bound to `t`): save the selected snippet as a preset, or
--- browse (and edit the custom ones) for its language.
local function preset_menu(item)
  vim.ui.select({ 'Save this snippet as preset', 'Browse presets (' .. item.ft .. ')' }, {
    prompt = 'Rosasnippets · presets',
    kind = 'rosasnippets_preset_menu',
  }, function(choice)
    if not choice then
      return
    end
    if choice:find('^Save') then
      save_as_preset(item)
    else
      browse_presets(item.ft)
    end
  end)
end

local function open_file(item)
  close_panel()
  vim.cmd.edit(file_path(item.ft))
  vim.fn.search('"' .. vim.fn.escape(item.name, '\\') .. '"', 'w')
end

--- Dock a rosapreview of the snippet file on the right, sliding the panel to
--- the left (mirrors the RosaAI review preview). Falls back to the centered
--- preview float when the terminal is too narrow to fit both.
local function preview(item)
  if not S then
    return
  end
  local lnum = 1
  local ok, lines = pcall(vim.fn.readfile, file_path(item.ft))
  if ok then
    for i, line in ipairs(lines) do
      if line:find(item.name, 1, true) then
        lnum = i
        break
      end
    end
  end

  local gap = 3
  local pv_width = math.min(vim.o.columns - 4 - S.width - gap, 96)
  local pv_h = math.min(S.inner_h + 14, vim.o.lines - 4)
  local pv_row = math.max(1, S.row - math.floor((pv_h - S.inner_h) / 2))

  local geom, docked
  if pv_width >= 30 then
    local total = S.width + gap + pv_width
    local start_col = math.max(2, math.floor((vim.o.columns - total) / 2))
    place_panel(start_col)
    geom = { row = pv_row, col = start_col + S.width + gap, width = pv_width, height = pv_h }
    docked = true
  end

  local pok, rp = pcall(require, 'rosavim.rosa_plugins.rosapreview')
  if not (pok and rp.file) then
    if docked then
      place_panel(S.col)
    end
    return
  end
  local pv = rp.file(file_path(item.ft), lnum, geom, { close_only = true })
  if docked and pv then
    api.nvim_create_autocmd('WinClosed', {
      pattern = tostring(pv),
      once = true,
      callback = function()
        vim.schedule(function()
          place_panel(S and S.col or 0)
        end)
      end,
    })
  elseif docked and not pv then
    place_panel(S.col)
  end
end

-- --- Panel -----------------------------------------------------------------

--- Open the panel: centered container with title + key hints, list child on
--- top, bordered live-filter search input at the bottom.
function M.open()
  if session_open() then
    api.nvim_set_current_win(S.list.win)
    return
  end
  setup_highlights()

  -- Size to content: tall enough for the grouped list (items + headers +
  -- separators), wide enough for the longest row — clamped so it never turns
  -- into a mostly-empty frame nor overflows the screen.
  local items = all_snippets()
  local fts = list_filetypes()
  local longest = 0
  for _, item in ipairs(items) do
    longest = math.max(longest, 4 + 15 + api.nvim_strwidth(item.name))
  end
  local width = math.max(92, math.min(longest + 12, math.min(110, vim.o.columns - 10)))
  local rows_est = #items + #fts * 2 + 1
  local list_h = math.max(10, math.min(rows_est, vim.o.lines - 13))
  local input_h = 3 -- bordered single line: top border + text + bottom border
  local hint_row = list_h + input_h
  local inner_h = hint_row + 1
  local row = math.floor((vim.o.lines - inner_h) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Outer container: the frame with border, title and key hints. Not focusable.
  local cbuf = api.nvim_create_buf(false, true)
  vim.bo[cbuf].bufhidden = 'wipe'
  local cwin = api.nvim_open_win(cbuf, false, {
    relative = 'editor',
    width = width,
    height = inner_h,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = { { ' 󰩫 Rosasnippets ', 'RosasnippetsTitle' } },
    title_pos = 'center',
    focusable = false,
    zindex = 50,
  })
  vim.wo[cwin].winhl = 'Normal:Normal,FloatBorder:RosasnippetsBorder,FloatTitle:RosasnippetsTitle'

  -- Key hints as real buffer text on the container's bottom row.
  local segs = {
    { '↵', 'RosasnippetsKey' },
    { ' body', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 'a', 'RosasnippetsKey' },
    { ' add', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 'e', 'RosasnippetsKey' },
    { ' trigger/desc', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 'd', 'RosasnippetsKey' },
    { ' delete', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 'o', 'RosasnippetsKey' },
    { ' file', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 'p', 'RosasnippetsKey' },
    { ' preview', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 'f', 'RosasnippetsKey' },
    { ' filter', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 't', 'RosasnippetsKey' },
    { ' preset', 'RosasnippetsDim' },
    { '  ', 'RosasnippetsDim' },
    { 'q', 'RosasnippetsKey' },
    { ' close', 'RosasnippetsDim' },
  }
  local text = ''
  for _, s in ipairs(segs) do
    text = text .. s[1]
  end
  local pad = math.max(0, math.floor((width - api.nvim_strwidth(text)) / 2))
  local hint_lines = {}
  for i = 1, inner_h do
    hint_lines[i] = ''
  end
  hint_lines[hint_row + 1] = string.rep(' ', pad) .. text
  api.nvim_buf_set_lines(cbuf, 0, -1, false, hint_lines)
  vim.bo[cbuf].modifiable = false
  local c = pad
  for _, s in ipairs(segs) do
    local ec = c + #s[1]
    pcall(api.nvim_buf_set_extmark, cbuf, list_ns, hint_row, c, { end_col = ec, hl_group = s[2] })
    c = ec
  end

  -- List child: borderless, pinned to the top of the container.
  local lbuf = api.nvim_create_buf(false, true)
  vim.bo[lbuf].bufhidden = 'wipe'
  vim.bo[lbuf].filetype = 'rosasnippets'
  local lwin = api.nvim_open_win(lbuf, true, {
    relative = 'win',
    win = cwin,
    row = 0,
    col = 0,
    width = width,
    height = list_h,
    style = 'minimal',
    border = 'none',
    zindex = 51,
  })
  vim.wo[lwin].winhl = 'Normal:Normal'
  vim.wo[lwin].cursorline = false

  -- Search input: its own bordered box under the list.
  local pbuf = api.nvim_create_buf(false, true)
  vim.bo[pbuf].bufhidden = 'wipe'
  -- No autocompletion in the search box: blink.cmp respects this per-buffer flag.
  vim.b[pbuf].completion = false
  local pwin = api.nvim_open_win(pbuf, false, {
    relative = 'win',
    win = cwin,
    row = list_h,
    col = 3,
    width = width - 6,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    title = { { ' search (/ or i) ', 'RosasnippetsDim' } },
    title_pos = 'left',
    zindex = 52,
  })
  vim.wo[pwin].winhl = 'Normal:Normal,FloatBorder:RosasnippetsBorder'

  S = {
    container = { buf = cbuf, win = cwin },
    list = { buf = lbuf, win = lwin },
    prompt = { buf = pbuf, win = pwin },
    query = '',
    ft_filter = nil,
    sel = 1,
    matches = {},
    width = width,
    row = row,
    col = col,
    list_h = list_h,
    inner_h = inner_h,
  }

  -- Search glyph + placeholder as inline virtual text, so reading the buffer
  -- line always yields just the query.
  local function redraw_prompt()
    local q = api.nvim_buf_get_lines(pbuf, 0, 1, false)[1] or ''
    api.nvim_buf_clear_namespace(pbuf, prompt_ns, 0, -1)
    pcall(api.nvim_buf_set_extmark, pbuf, prompt_ns, 0, 0, {
      virt_text = { { ' ❯ ', 'RosasnippetsKey' } },
      virt_text_pos = 'inline',
      right_gravity = false,
    })
    if q == '' then
      pcall(api.nvim_buf_set_extmark, pbuf, prompt_ns, 0, 0, {
        virt_text = { { 'type to filter snippets…', 'RosasnippetsDim' } },
        virt_text_pos = 'inline',
      })
    end
  end
  redraw_prompt()

  api.nvim_create_autocmd({ 'TextChangedI', 'TextChanged', 'TextChangedP' }, {
    buffer = pbuf,
    callback = function()
      if not S then
        return
      end
      S.query = api.nvim_buf_get_lines(pbuf, 0, 1, false)[1] or ''
      S.sel = 1
      redraw_prompt()
      render()
    end,
  })

  local function open_prompt()
    if S and api.nvim_win_is_valid(S.prompt.win) then
      api.nvim_set_current_win(S.prompt.win)
      vim.cmd 'startinsert!'
    end
  end
  local function focus_list()
    pcall(vim.cmd, 'stopinsert')
    if S and api.nvim_win_is_valid(S.list.win) then
      api.nvim_set_current_win(S.list.win)
    end
  end

  -- Prompt (insert-mode) keys: move the selection without leaving the input.
  local popts = { buffer = pbuf, silent = true, nowait = true }
  vim.keymap.set('i', '<CR>', function()
    focus_list()
    local item = current_item()
    if item then
      M.edit_body(item)
    end
  end, popts)
  vim.keymap.set('i', '<Esc>', focus_list, popts)
  vim.keymap.set('i', '<C-c>', close_panel, popts)
  for _, lhs in ipairs { '<Down>', '<C-j>', '<C-n>' } do
    vim.keymap.set('i', lhs, function()
      move(1)
    end, popts)
  end
  for _, lhs in ipairs { '<Up>', '<C-k>', '<C-p>' } do
    vim.keymap.set('i', lhs, function()
      move(-1)
    end, popts)
  end
  -- Normal-mode fallbacks for when focus lands on the prompt outside insert.
  vim.keymap.set('n', '<Esc>', focus_list, popts)
  vim.keymap.set('n', 'q', close_panel, popts)
  vim.keymap.set('n', '<CR>', function()
    focus_list()
    local item = current_item()
    if item then
      M.edit_body(item)
    end
  end, popts)

  -- List (normal-mode) keys.
  local kopts = { buffer = lbuf, silent = true, nowait = true }
  local function with_item(fn)
    return function()
      local item = current_item()
      if item then
        fn(item)
      end
    end
  end
  vim.keymap.set('n', 'j', function()
    move(1)
  end, kopts)
  vim.keymap.set('n', 'k', function()
    move(-1)
  end, kopts)
  vim.keymap.set('n', '<Down>', function()
    move(1)
  end, kopts)
  vim.keymap.set('n', '<Up>', function()
    move(-1)
  end, kopts)
  vim.keymap.set('n', '/', open_prompt, kopts)
  vim.keymap.set('n', 'i', open_prompt, kopts)
  vim.keymap.set('n', '<CR>', with_item(M.edit_body), kopts)
  vim.keymap.set('n', 'a', add_snippet, kopts)
  vim.keymap.set('n', 'e', with_item(edit_snippet), kopts)
  vim.keymap.set('n', 'd', with_item(delete_snippet), kopts)
  vim.keymap.set('n', 'o', with_item(open_file), kopts)
  vim.keymap.set('n', 'p', with_item(preview), kopts)
  vim.keymap.set('n', 'f', pick_filter, kopts)
  vim.keymap.set('n', 't', with_item(preset_menu), kopts)
  vim.keymap.set('n', 'q', close_panel, kopts)
  vim.keymap.set('n', '<Esc>', close_panel, kopts)

  -- Closing the list window by any other means tears the whole panel down.
  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(lwin),
    once = true,
    callback = function()
      vim.schedule(close_panel)
    end,
  })

  render()
end

--- Public: open the preset browser for a filetype directly.
function M.browse(ft)
  browse_presets(ft)
end

--- Test/debug hook: the live session table (nil when closed).
function M._session()
  return S
end

return M

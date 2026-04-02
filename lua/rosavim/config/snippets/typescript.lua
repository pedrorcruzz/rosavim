local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets('typescript', {
  s(
    { trig = 'cafn', dscr = 'Custom - Arrow Function' },
    fmt(
      [[const {} = ({}): {} => {{
  {}
}}]],
      { i(1, 'name'), i(2, 'args'), i(3, 'void'), i(4, '// code') }
    )
  ),
})

ls.add_snippets('typescript', {
  s(
    { trig = 'ctry', dscr = 'Custom - Try Catch' },
    fmt(
      [[try {{
  {}
}} catch (error) {{
  console.error(error)
}}]],
      { i(1, '// code') }
    )
  ),
})

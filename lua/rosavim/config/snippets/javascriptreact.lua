local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets('javascriptreact', {
  s(
    { trig = 'cjedf', dscr = 'Custom - Export Default Function Name - React JSX Component' },
    fmt(
      [[
export default function {}({}) {{
  return (
    <div>
      {}
    </div>
  )
}}
      ]],
      { i(1, 'ComponentName'), i(2, 'props'), i(0) }
    )
  ),

  s(
    { trig = 'cjef', dscr = 'Custom - Export Function Name - React JSX Component' },
    fmt(
      [[
export function {}({}) {{
  return (
    <div>
      {}
    </div>
  )
}}
      ]],
      { i(1, 'ComponentName'), i(2, 'props'), i(0) }
    )
  ),
})

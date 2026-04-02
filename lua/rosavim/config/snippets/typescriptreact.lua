local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets('typescriptreact', {
  s(
    { trig = 'cedf', dscr = 'Custom - Export Default Function Name - React TSX Component' },
    fmt(
      [[
export default function {}({}: {}): JSX.Element {{
  return (
    <div>
      {}
    </div>
  )
}}
      ]],
      { i(1, 'ComponentName'), i(2, 'props'), i(3, 'PropsType'), i(4, '/* content */') }
    )
  ),

  s(
    { trig = 'cef', dscr = 'Custom - Export Function - React TSX Component' },
    fmt(
      [[
export function {}({}: {}): JSX.Element {{
  return (
    <div>
      {}
    </div>
  )
}}
      ]],
      { i(1, 'ComponentName'), i(2, 'props'), i(3, 'PropsType'), i(4, '/* content */') }
    )
  ),
})

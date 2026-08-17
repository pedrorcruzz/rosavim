-- TypeScript server for Vue projects only. Plain projects get tsc (the native
-- TypeScript 7 compiler) instead - see lsp/tsc.lua and the gate in
-- lua/rosavim/helpers/vue_project.lua.
--
-- Why not tsc here: Vue Language Server 3 dropped takeover mode, so every
-- TypeScript answer inside a .vue file comes from @vue/typescript-plugin
-- running inside a real tsserver, reached over 'tsserver/request' notifications
-- (forwarded in lsp/vue_language_server.lua). tsc has no tsserver plugin
-- support and does not even ship a tsserver.js, so a .vue file under it gets no
-- type information at all.
--
-- Why the TypeScript 6 pin below: from the TypeScript 7.0 announcement,
-- 2026-07-08 - "workflows that use Vue, MDX, Astro, Svelte, and others will
-- likely not yet be able to leverage TypeScript 7 ... TypeScript 7 does not yet
-- expose a stable programmatic API, and so tools (such as Volar) which embed
-- TypeScript into their own compilers ... can only currently rely on TypeScript
-- 6.0." Volar is the engine behind vue_language_server, so 6.0 is the ceiling,
-- not a workaround. https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/
--
-- WARN: every comment in lsp/ is temporary and exists only for this Vue
-- arrangement. This is the ONLY file under lsp/ that carries any - the other 14
-- server files are bare cmd / filetypes / root_markers with zero comments, and
-- that is the house style. When the arrangement below is gone, the comments go
-- with it, including the ones in lua/rosavim/helpers/vue_project.lua and the
-- inline ones in lsp/vue_language_server.lua. Do not treat them as a precedent
-- for documenting servers inline: the how-to lives in lsp/README.txt.
--
-- WARN: this whole file is a temporary arrangement, delete it once it is not.
-- TypeScript 7.1 is the release that ships the API Volar is waiting on - its
-- iteration plan lists "Stabilize API" (Content Mapper, Emit, Language Service)
-- with stable targeted for 2026-11-10 (beta 2026-09-09, RC 2026-10-20).
-- Until Volar actually adopts it, the Vue, Svelte and Angular projects all tell
-- users to stay on TypeScript 6.0.x, which is exactly what the pin below does.
-- https://github.com/microsoft/TypeScript/issues/63703
--
-- FIRST CHECK WHETHER IT IS ACTUALLY TIME - two independent conditions, and
-- the second is the one that decides. TypeScript 7.1 shipping the API is not
-- enough on its own, Volar has to adopt it, which is another project's call and
-- can lag months behind:
--
--   1. :MasonUpdate            refresh the registry first
--   2. cat ~/.local/share/nvim/mason/packages/vue-language-server/package.json
--      Look at its "typescript" dependency. It reads "^6.0.3" today. While the
--      Volar package still ships TypeScript 6, it has NOT migrated, no matter
--      what any changelog claims. Only "^7.x" there means go.
--   3. still 6.x? stop, change nothing, check again later
--   4. 7.x? run the removal steps below, then test all three cases before
--      calling it done: a plain .ts, a .ts inside a Vue project, and a .vue
--      with a real type error in <script setup>
--
-- WHEN VOLAR SUPPORTS TYPESCRIPT 7, REMOVE IN THIS ORDER:
--   1. delete this file and drop 'vtsls' from vim.lsp.enable and
--      ensure_installed in lua/rosavim/plugins/env/lsp/mason.lua
--   2. in lsp/tsc.lua swap root_dir = vue.gate(false) back to
--      root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' }
--      and add 'vue' to its filetypes if tsc grew plugin support
--   3. DELETE lua/rosavim/helpers/vue_project.lua outright, do not try to adapt
--      it - its only job is picking between two TypeScript servers, so with one
--      server there is nothing left to decide. After steps 1 and 2 nothing
--      requires it (only this file and lsp/tsc.lua ever did). Also drop the
--      exception note at the end of lsp/README.txt
--   4. in lsp/vue_language_server.lua, keep the tsserver/request handler only if
--      Volar still forwards to a separate TS server - if it embeds the new API
--      itself, the whole on_init block goes too
--   5. strip the leftover comments so lsp/ is back to zero, then confirm:
--      for f in lsp/*.lua; do grep -c '^\s*--' $f; done   <-- all zeros
-- vue_language_server STAYS either way: template, <style scoped> and Vue
-- specific diagnostics are Volar's job, no TypeScript compiler does that.
--
-- Verify: :lua =vim.lsp.get_clients({ bufnr = 0 })
--   .ts plain project -> tsc      .ts Vue project -> vtsls
--   .vue -> vue_language_server + vtsls
-- A type error in <script setup> reports with source 'ts-plugin'.

local vue = require 'rosavim.helpers.vue_project'

return {
  cmd = { 'vtsls', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
  root_dir = vue.gate(true),
  settings = {
    vtsls = {
      -- vtsls bundles TypeScript 5.9.3, but @vue/typescript-plugin is built
      -- against the 6.0.3 shipped beside it. Mixing them makes every forwarded
      -- request fail with "TypeScript Server Error", so pin tsserver to that
      -- copy. Side effect: the project's own TypeScript version is ignored,
      -- which is also what VS Code does by default.
      typescript = { globalTsdk = vue.mason_vue .. '/typescript/lib' },
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vue.mason_vue .. '/@vue/typescript-plugin',
            languages = { 'vue' },
            configNamespace = 'typescript',
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
}

==============================================================================
 HOW TO ADD A NEW LSP SERVER
==============================================================================

This config uses Neovim's NATIVE LSP (no nvim-lspconfig).
Every server needs TWO things. That's it.

------------------------------------------------------------------------------
 STEP 1 - Create a file: lsp/<name>.lua
------------------------------------------------------------------------------

Minimum needed: cmd, filetypes, root_markers.

  return {
    cmd = { '<language-server-binary>', '--stdio' },
    filetypes = { '<filetype>' },
    root_markers = { '.git' },
  }

WHAT EACH FIELD MEANS:

  cmd          How to start the server. Usually the binary name from Mason
               plus a flag like '--stdio'. Check the binary name here:
                 ~/.local/share/nvim/mason/bin/

  filetypes    Which files start the server (e.g. 'python', 'go', 'rust').
               Run :set filetype? inside a file if unsure.

  root_markers Files/dirs that mark the project root. The server uses the
               closest folder containing one of these as the workspace.
               '.git' is a safe fallback. Add language-specific ones too.

------------------------------------------------------------------------------
 STEP 2 - Enable it in: lua/rosavim/plugins/env/lsp/mason.lua
------------------------------------------------------------------------------

Add the name to vim.lsp.enable{ ... }:

  vim.lsp.enable {
    'gopls',
    'lua_ls',
    'my_new_server',   <-- add here (must match the lsp/<name>.lua filename)
  }

Optional: add it to ensure_installed in the same file so Mason auto-installs
the binary.

Then restart Neovim. Done.

------------------------------------------------------------------------------
 WHERE TO COPY cmd / filetypes / root_markers FROM
------------------------------------------------------------------------------

Best source - the nvim-lspconfig repo. Every server has a ready-made file:

  https://github.com/neovim/nvim-lspconfig/tree/master/lsp

Open the file for your server (e.g. rust_analyzer.lua) and copy the
cmd / filetypes / root_markers values into your own lsp/<name>.lua.
You do NOT need to install the plugin - just copy the values.

------------------------------------------------------------------------------
 FULL EXAMPLE - adding rust_analyzer
------------------------------------------------------------------------------

1) Install the binary (Mason):  :MasonInstall rust-analyzer

2) Create lsp/rust_analyzer.lua:

  return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
  }

3) Add 'rust_analyzer' to vim.lsp.enable{ } in mason.lua

4) Restart Neovim, open a .rs file. Check it attached:
     :lua =vim.lsp.get_clients({ bufnr = 0 })

------------------------------------------------------------------------------
 EXAMPLE WITH SETTINGS (optional 4th field)
------------------------------------------------------------------------------

Some servers take extra options under 'settings'. See basedpyright.lua:

  return {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', '.git' },
    settings = {
      basedpyright = {
        analysis = { typeCheckingMode = 'standard' },
      },
    },
  }

The 'settings' shape is defined by each server - check its docs.

------------------------------------------------------------------------------
 TROUBLESHOOTING
------------------------------------------------------------------------------

Server not attaching? Check in order:

  1) Binary exists:   ls ~/.local/share/nvim/mason/bin/ | grep <name>
  2) File is enabled: name is in vim.lsp.enable{ } AND matches the filename
  3) Right filetype:  :set filetype?  (must match your filetypes = { })
  4) Live check:      :lua =vim.lsp.get_clients({ bufnr = 0 })
  5) Logs:            :LspLog

Do NOT enable two servers for the same language (e.g. pyright AND
basedpyright) - you get duplicated completions and diagnostics.

==============================================================================

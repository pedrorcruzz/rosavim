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

  cmd          How to start the server. Binary name from Mason plus its
               launch argument. THE ARGUMENT IS NOT ALWAYS '--stdio' - it
               changes per server. See the section below. Binary names live in:
                 ~/.local/share/nvim/mason/bin/

  filetypes    Which files start the server (e.g. 'python', 'go', 'rust').
               Run :set filetype? inside a file if unsure.

  root_markers Files/dirs that mark the project root. The server uses the
               closest folder containing one of these as the workspace.
               '.git' is a safe fallback. Add language-specific ones too.

------------------------------------------------------------------------------
 THE cmd LAUNCH ARGUMENT (--stdio vs server vs nothing)
------------------------------------------------------------------------------

There is NO universal flag. Each server decides how it is started, and
guessing '--stdio' for everything will silently fail. Examples:

  --stdio            Most Node/npm-based servers (they all speak LSP over
                     stdio the same way):
                       vscode-json-language-server --stdio
                       tailwindcss-language-server --stdio
                       pyright-langserver --stdio
                       emmet-ls --stdio        tsgo --lsp --stdio

  a subcommand       Servers with their own CLI use a word, not a flag:
                       marksman server         <-- NOT --stdio
                       sql-language-server up --method stdio

  no argument        Some just run and default to stdio:
                       gopls        lua-language-server        jdtls

Rule of thumb: Node-based -> almost always '--stdio'. A self-contained
binary (Go, Rust, .NET, etc.) -> check, it often uses a subcommand or none.
Rule of thumb is a GUESS. Always confirm one of these ways:

  1) The server's own help:   <binary> --help
       marksman --help  ->  "server  Start LSP server on stdin/stdout"
  2) The nvim-lspconfig file (canonical cmd, see section further below)
  3) If it dies on start, :LspLog shows the server rejecting the argument,
     e.g.  "Unrecognized command or argument '--stdio'"

Wrong argument = the process starts, immediately exits (code 1), and the
server "does not attach". Right binary, wrong launch word.

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

# Plugin Catalog

Rosavim ships with **79+ plugins**, all managed by [Lazy.nvim](https://github.com/folke/lazy.nvim) with intelligent lazy-loading for fast startup.

## Table of Contents

- [Core & Infrastructure](#core--infrastructure)
- [LSP & Completion](#lsp--completion)
- [Syntax & Treesitter](#syntax--treesitter)
- [Formatting & Linting](#formatting--linting)
- [Debugging](#debugging)
- [Testing](#testing)
- [UI & Appearance](#ui--appearance)
- [Navigation & Search](#navigation--search)
- [Editor Enhancements](#editor-enhancements)
- [Git](#git)
- [AI](#ai)
- [Language-Specific](#language-specific)
- [Database](#database)
- [Notes & Writing](#notes--writing)
- [Utilities](#utilities)

---

## Core & Infrastructure

| Plugin | Description |
|:-------|:------------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager — handles installation, updates, and lazy-loading |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Lua utility library used by many plugins |
| [nui.nvim](https://github.com/MunifTanjim/nui.nvim) | UI component library for plugin developers |
| [FixCursorHold.nvim](https://github.com/antoinemadec/FixCursorHold.nvim) | Fixes CursorHold performance issues |

---

## LSP & Completion

| Plugin | Description |
|:-------|:------------|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Configuration for built-in LSP client |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | Portable package manager — installs LSP servers, formatters, linters, and DAP adapters |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Automatically installs Mason tools on startup |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Rust-powered completion engine — blazingly fast autocompletion |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine with support for VSCode-style snippets |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Community-maintained snippet collection for many languages |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Development helpers for Lua/Neovim plugin development |
| [nvim-navic](https://github.com/SmiteshP/nvim-navic) | LSP-powered breadcrumb provider |
| [nvim-lsp-file-operations](https://github.com/antosha417/nvim-lsp-file-operations) | Automatic import updates on file rename/move |
| [blink-copilot](https://github.com/giuxtaposition/blink-copilot) | Copilot source for blink.cmp |
| [blink-emoji.nvim](https://github.com/moyiz/blink-emoji.nvim) | Emoji completion source |
| [blink-ripgrep.nvim](https://github.com/mikavilpas/blink-ripgrep.nvim) | Ripgrep completion source — complete from project-wide text |

---

## Syntax & Treesitter

| Plugin | Description |
|:-------|:------------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Treesitter integration — precise syntax highlighting, text objects, folding |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Shows the current function/class context at the top of the screen |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Treesitter-powered text objects (select function, class, parameter, etc.) |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto-close and auto-rename HTML/JSX tags |

---

## Formatting & Linting

| Plugin | Description |
|:-------|:------------|
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatter with async format-on-save support |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Asynchronous linter aggregator |

---

## Debugging

| Plugin | Description |
|:-------|:------------|
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol client |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | UI for nvim-dap — variables, breakpoints, call stack, console |
| [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline variable values during debugging |
| [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Python debug adapter (debugpy) |
| [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) | Go debug adapter (delve) |
| [mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim) | Bridges Mason and nvim-dap for auto-installing debug adapters |

---

## Testing

| Plugin | Description |
|:-------|:------------|
| Rosatest | Built-in test runner with popup UI (Go, Jest, Vitest, Pytest, Pest, PHPUnit, Java) |
| Rosafile | Built-in file operations menu (create, rename, duplicate, delete, info) |

---

## UI & Appearance

| Plugin | Description |
|:-------|:------------|
| [snacks.nvim](https://github.com/folke/snacks.nvim) | All-in-one: dashboard, file explorer, picker, notifier, profiler, and more |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Fast and customizable statusline |
| [noice.nvim](https://github.com/folke/noice.nvim) | Modern UI for messages, command line, and popups |
| [dropbar.nvim](https://github.com/Bekaboo/dropbar.nvim) | IDE-like breadcrumb navigation bar |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Displays available keybindings in a popup |
| [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) | Highlights color codes with their actual color |
| [mini.icons](https://github.com/echasnovski/mini.icons) | File type icons |
| [markview.nvim](https://github.com/OXY2DEV/markview.nvim) | Enhanced markdown rendering in the editor |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live markdown preview in the browser |

### Colorschemes

| Theme | Description |
|:------|:------------|
| [catppuccin](https://github.com/catppuccin/nvim) | Soothing pastel theme |
| [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) | Retro groove color scheme |
| [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | Inspired by the colors of the famous painting |
| min-theme | Custom minimal theme (default) |
| [rose-pine](https://github.com/rose-pine/neovim) | Soho vibes for Neovim |
| nvim-rusticated | Custom rusticated theme |
| vesper | Custom vesper theme |

---

## Navigation & Search

| Plugin | Description |
|:-------|:------------|
| [flash.nvim](https://github.com/folke/flash.nvim) | Navigate code with search labels — replaces f/F/t/T motions |
| [grapple.nvim](https://github.com/cbochs/grapple.nvim) | Tag/bookmark files for instant access |
| [goto-preview.nvim](https://github.com/rmagatti/goto-preview.nvim) | Preview LSP definitions in floating windows |
| [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | Search and replace powered by ripgrep |

---

## Editor Enhancements

| Plugin | Description |
|:-------|:------------|
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Add, change, and delete surrounding characters |
| [vim-matchup](https://github.com/andymass/vim-matchup) | Extended `%` matching for language constructs |
| [vim-visual-multi](https://github.com/mg979/vim-visual-multi) | Multi-cursor editing |
| [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | Code refactoring operations (extract, inline, debug print) |
| [yanky.nvim](https://github.com/gbprod/yanky.nvim) | Improved yank and put with history |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and search TODO, FIXME, HACK, etc. |
| [outline.nvim](https://github.com/hedyhli/outline.nvim) | Code outline sidebar |
| [winpick.nvim](https://github.com/gbrlsnchs/winpick.nvim) | Visual window picker |
| [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) | Smart window navigation and resizing |
| [auto-save.nvim](https://github.com/okuuva/auto-save.nvim) | Automatic file saving |
| [nvim-early-retirement](https://github.com/chrisgrieser/nvim-early-retirement) | Automatically close unused buffers |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating and split terminal emulator |
| [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) | Yazi file manager integration |

---

## Git

| Plugin | Description |
|:-------|:------------|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git change indicators, staging, blame, and hunk navigation |

---

## AI

| Plugin | Description |
|:-------|:------------|
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot integration |
| [copilot-lualine](https://github.com/AndreM222/copilot-lualine) | Copilot status in the statusline |
| [sidekick.nvim](https://github.com/atomicptr/sidekick.nvim) | AI sidekick assistant (Claude, Cursor, etc.) |

---

## Language-Specific

| Plugin | Description |
|:-------|:------------|
| Rosakit | Built-in language-aware project navigator with stack detection and LSP tools |
| [vim-blade](https://github.com/jwalton512/vim-blade) | Blade template syntax highlighting |
| [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) | Extended Java LSP support (Eclipse JDT.LS) |
| [venv-selector.nvim](https://github.com/linux-cultivator/venv-selector.nvim) | Python virtual environment selector |

---

## Database

| Plugin | Description |
|:-------|:------------|
| [vim-dadbod](https://github.com/tpope/vim-dadbod) | Database client — connects to PostgreSQL, MySQL, SQLite, and more |
| [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | UI for vim-dadbod — browse tables, run queries |
| [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion) | Autocompletion for SQL queries |

---

## Notes & Writing

| Plugin | Description |
|:-------|:------------|
| [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) | Obsidian vault integration — daily notes, templates, backlinks, search |

---

## Utilities

| Plugin | Description |
|:-------|:------------|
| [discord.nvim](https://github.com/vyfor/cord.nvim) | Discord Rich Presence |
| [codesnap.nvim](https://github.com/mistricky/codesnap.nvim) | Beautiful code screenshots |
| [logger.nvim](https://github.com/Tastyep/structlog.nvim) | Debug logging utility |
| [neovim-project](https://github.com/coffebar/neovim-project) | Project management and discovery |
| [neovim-session-manager](https://github.com/Shatur/neovim-session-manager) | Session persistence |
| [persistence.nvim](https://github.com/folke/persistence.nvim) | Session and buffer restoration |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Pretty diagnostics, references, and quickfix list |

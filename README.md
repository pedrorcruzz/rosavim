<div align="center">

<img src="assets/logo/rosavim.png" alt="Rosavim" width="420" />

# Rosavim

**A modern, productive Neovim distribution ready for the real world.**

[![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-57A143?style=for-the-badge&logo=neovim&logoColor=57A143&labelColor=1a1a2e)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge)](LICENSE)

*Turn your terminal into a full-featured IDE, no hassle.*

🇺🇸 **English** · 🇧🇷 **[Português](README.pt-br.md)**

| | |
|:---:|:---:|
| ![Rosamin Dashboard Dark](assets/screenshots/rosamin_dashboard_dark.png) | ![Rosaesthetic Dashboard Light](assets/screenshots/rosaaesthetic_dashboard_light.png) |
| ![Rosamin Code Dark](assets/screenshots/rosamin_code_dark.png) | ![Rosaesthetic Code Light](assets/screenshots/rosaaesthetic_code_light.png) |

</div>

## What is Rosavim?

Rosavim is a Neovim distribution for developers who want a complete, fast, and beautiful setup without spending hours configuring from scratch. It ships with first-class support for the most popular languages and frameworks — clone it and start coding.

Built on **Lazy.nvim**, it loads plugins lazily to keep startup fast, and comes with a suite of **built-in "rosa" plugins** (terminal, test runner, file operations, project navigator, and more) so most of what you need works out of the box.

## Quick Start

```bash
# Back up your current config (if any)
mv ~/.config/nvim ~/.config/nvim.bak

# Clone Rosavim
git clone https://github.com/pedrorcruzz/rosavim.git ~/.config/nvim

# Launch — plugins install automatically
nvim
```

On first launch, **Lazy.nvim** installs the plugins and **Mason** sets up LSP servers, formatters, linters, and debug adapters.

<details>
<summary><b>Requirements</b></summary>

<br>

| Dependency | Version |
|:-----------|:--------|
| **Neovim** | **>= 0.12** |
| Git | >= 2.19 |
| Node.js | >= 18 |
| Python | >= 3.10 |
| [Nerd Font](https://www.nerdfonts.com/) | Any |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Any |

**Recommended:** [lazygit](https://github.com/jesseduffield/lazygit) (Git UI) · [yazi](https://github.com/sxyazi/yazi) (file manager) · [chafa](https://hpjansson.org/chafa/) (dashboard image)

Full step-by-step guide (backup, dependencies, troubleshooting): **[Installation Manual](docs/manual/installation.md)**.

</details>

## Documentation

Detailed guides live in [`docs/manual`](docs/manual/):

[Installation](docs/manual/installation.md) · [Keybindings](docs/manual/keybinds.md) · [Plugins](docs/manual/plugins.md) · [Languages](docs/manual/languages.md) · [Debugging](docs/manual/debugging.md) · [Customization](docs/manual/customization.md) · [Toggles](docs/manual/toggles.md)

## Features

<details>
<summary><b>Editor & Navigation</b></summary>

<br>

- **blink.cmp** — Rust-powered completion engine, blazingly fast
- **Snippets** with LuaSnip + friendly-snippets
- **Native Treesitter** (Neovim 0.12+) for precise highlighting and indentation
- **Format on save** (conform.nvim) and **auto-save** on focus loss
- **Snacks Picker** for fuzzy finding files, grep, and buffers
- **Flash.nvim** for jump-anywhere navigation with visual labels
- **GrugFar** for project-wide search & replace (ripgrep)
- **Persistent toggles** — UI settings survive across sessions

</details>

<details>
<summary><b>Git, Debug & Testing</b></summary>

<br>

- **Gitsigns** — inline change indicators and per-line blame
- Built-in **lazygit** integration
- **DAP** — full debugger with UI, breakpoints, and inline variable inspection
- **Rosatest** — built-in test runner with popup UI: run nearest / file / all tests. Supports Go, Jest, Vitest, Pytest, Pest, PHPUnit, and Java

</details>

<details>
<summary><b>AI</b></summary>

<br>

- **GitHub Copilot** integrated into completion
- **RosaAI** — native AI CLI integration (Claude, Cursor, Gemini, …) with a themed, resizable in-editor window and preview prompt

</details>

<details>
<summary><b>UI & Appearance</b></summary>

<br>

- **2 built-in themes** — **Rosamin** (default, minimal) and **Rosaesthetic** (warm, earthy), both with dark/light mode and transparency
- **Dashboard**, **Lualine** statusline (selectable separators), **Bufferline** tabs, **Dropbar** breadcrumbs, **Incline** floating filenames, and **Noice** for modern messages
- One-shortcut **dark/light** and **theme** switching

</details>

<details>
<summary><b>Built-in "Rosa" plugins</b></summary>

<br>

| Plugin | What it does |
|:-------|:-------------|
| **Rosaterm** | Native float & split terminals — no external deps. Cycle floats, themed title chip, persistent toggles |
| **Rosatest** | Test runner with popup results (Go, Jest, Vitest, Pytest, Pest, PHPUnit, Java) |
| **Rosakit** | Language-aware project navigator with automatic stack detection (React, Next, Vue, Angular, Svelte, Nest, Express, Go, Django, FastAPI, Laravel, Spring) — monorepo support |
| **Rosafile** | File operations menu — create, rename, duplicate, delete, info |
| **Rosapreview** | LSP preview (definition, type, implementation, references) in a floating window |
| **Rosapoon** | Bookmark and jump between frequently used files, scoped per git repo |
| **Rosadirs** | Manage Projects & Obsidian vault directories at runtime |
| **Rosapick** | Visual window picker with letter labels |
| **Rosamaximize** | Maximize the current window and restore the full layout |
| **Rosayank** | Persistent yank history (ring buffer) |
| **Rosasave** | Debounced auto-save |
| **Rosasweep** | Auto-closes inactive buffers |

</details>

<details>
<summary><b>Extras</b></summary>

<br>

- **Database Client** (vim-dadbod) with UI for SQL
- **Obsidian** integration for notes
- **Discord Presence**

> The plugin system is modular — add, remove, or swap plugins to match your workflow.

</details>

## Languages & Frameworks

Full support (LSP, formatting, linting, testing, debugging) for the most popular stacks:

<details>
<summary><b>Show support table</b></summary>

<br>

| Language | LSP | Formatter | Linter | Tests | Debug |
|:---------|:---:|:---------:|:------:|:-----:|:-----:|
| **TypeScript / JavaScript** | vtsls | Biome / Prettier | Biome / eslint_d | Jest / Vitest | — |
| **React / JSX / TSX** | vtsls | Biome / Prettier | Biome / eslint_d | Jest / Vitest | — |
| **Go** | gopls | goimports | golangci-lint | gotestsum | Delve |
| **Python** | Pyright | autopep8 | Mypy / Pylint | pytest | debugpy |
| **Java** | JDTLS | google-java-format | Checkstyle | Gradle | Remote Attach |
| **PHP / Laravel** | Intelephense | php-cs-fixer | phpcs | Pest | Xdebug |
| **HTML / CSS** | Emmet + Tailwind | Prettier | djlint | — | — |
| **SQL** | sqlls | sql_formatter | — | — | — |
| **Lua** | lua_ls | StyLua | — | — | — |
| **JSON** | json_ls | Prettier | Biome | — | — |

</details>

> **Not listed?** Rosavim uses **Mason** as its tooling backbone — Rust, C/C++, Kotlin, Ruby, Elixir, Zig, and many more can be added in minutes.

## Themes

Rosavim ships with 2 built-in themes, fully integrated with dark/light and transparency toggles.

<details>
<summary><b>Rosamin</b> — minimal, clean, focused (default)</summary>

<br>

| Code (Dark) | Dashboard (Dark) | Code (Light) | Transparent |
|:------------|:-----------------|:-------------|:------------|
| ![Rosamin Code Dark](assets/screenshots/rosamin_code_dark.png) | ![Rosamin Dashboard Dark](assets/screenshots/rosamin_dashboard_dark.png) | ![Rosamin Code Light](assets/screenshots/rosamin_code_light.png) | ![Rosamin Transparent](assets/screenshots/rosamin_transparent.png) |

</details>

<details>
<summary><b>Rosaesthetic</b> — warm, earthy tones</summary>

<br>

| Code (Dark) | Dashboard (Dark) | Code (Light) | Dashboard (Light) | Transparent |
|:------------|:-----------------|:-------------|:------------------|:------------|
| ![Rosaesthetic Code Dark](assets/screenshots/rosaaesthetic_code_dark.png) | ![Rosaesthetic Dashboard Dark](assets/screenshots/rosaaesthetic_dashboard_dark.png) | ![Rosaesthetic Code Light](assets/screenshots/rosaaesthetic_code_light.png) | ![Rosaesthetic Dashboard Light](assets/screenshots/rosaaesthetic_dashboard_light.png) | ![Rosaesthetic Transparent](assets/screenshots/rosaaesthetic_transparent.png) |

</details>

## Key Shortcuts

> Leader key: `<Space>` · Press `<leader>` anytime to open **which-key** and browse everything.

<details>
<summary><b>Show essential shortcuts</b></summary>

<br>

**Files & Navigation**
| Key | Action |
|:----|:-------|
| `<leader><space>` | Find files |
| `<leader>e` | File explorer |
| `<leader>y` | Yazi file manager |
| `<leader>;` | Dashboard |
| `s` | Flash jump |
| `<leader>oo` / `<leader>oe` | Rosapoon: pin / menu |

**Search & Code**
| Key | Action |
|:----|:-------|
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep word under cursor |
| `<leader>lee` | Search & replace (GrugFar) |
| `gd` / `gr` / `gI` | Definition / references / implementation |
| `gp` | Rosapreview definition |
| `<leader>lf` | Format file |
| `<leader>xx` | Rosafile menu |
| `<leader>kk` | Rosakit menu |

**Git, Test & Debug**
| Key | Action |
|:----|:-------|
| `<leader>gg` | Lazygit |
| `<leader>gt` | Toggle git blame |
| `<leader>nn` | Rosatest menu |
| `<leader>nf` | Run file tests |
| `<leader>ds` | Start / continue debug |
| `<leader>db` | Toggle breakpoint |

**Windows, Terminal & AI**
| Key | Action |
|:----|:-------|
| `<C-h/j/k/l>` | Move between splits |
| `<leader>m` | Rosapick (window picker) |
| `<leader>cm` | Rosamaximize |
| `<C-\>` / `<S-z>` | Rosaterm: toggle float |
| `<S-x>` | Rosaterm: horizontal terminal |
| `<leader>cii` / `<leader>cie` | Rosaterm: vertical / horizontal split |
| `<leader>aa` | RosaAI: toggle CLI |

**UI & Misc**
| Key | Action |
|:----|:-------|
| `<leader>lqt` | Toggle dark/light mode |
| `<leader>lqs` | Switch theme |
| `<leader>lp` | Rosadirs (manage project dirs) |
| `<leader>ll` | Toggle statusline |
| `kj` | Exit insert mode |

Full reference: **[Keybindings Manual](docs/manual/keybinds.md)**.

</details>

## Project Structure

<details>
<summary><b>Show structure</b></summary>

<br>

```
~/.config/nvim/
├── init.lua                       # Entry point
├── lua/rosavim/
│   ├── init.lua                   # Bootstrap
│   ├── config/                    # options, keybinds, appearance, autocmds, toggles, focus, snippets
│   ├── plugins/
│   │   ├── env/                   # LSP, Mason, Treesitter, DAP, lint, format, git
│   │   ├── ai/                    # Copilot, RosaAI
│   │   ├── ui/                    # themes, statusline, dashboard, bufferline, noice
│   │   ├── editor/                # terminal, navigation, file ops, projects
│   │   ├── coding/                # flash, surround, multi-cursor, refactoring
│   │   ├── language/              # language-specific (Laravel, Spring, Django, …)
│   │   └── test/                  # Rosatest
│   ├── rosa_plugins/              # built-in plugins (see Features)
│   │   ├── rosaterm/  rosatest/  rosakit/  rosafile/
│   │   ├── rosapreview/  rosapoon/  rosadirs/  rosapick/
│   │   ├── rosamaximize/  rosayank/  rosasave/  rosasweep/
│   │   └── rosaai/
│   └── rosa_themes/
│       ├── rosamin/               # default theme (minimal)
│       └── rosaesthetic/          # earthy, warm theme
├── lsp/                           # individual LSP configs
└── assets/                        # logo and screenshots
```

</details>

---

<div align="center">

Built with care by **Pedro Rosa**

</div>

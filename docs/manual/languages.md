# Language Support

Rosavim provides a complete development environment for many languages out of the box. This guide details the tooling configured for each language and how to add support for new ones.

## Table of Contents

- [TypeScript / JavaScript / React](#typescript--javascript--react)
- [Go](#go)
- [Python](#python)
- [Java](#java)
- [PHP / Laravel](#php--laravel)
- [HTML / CSS / Tailwind](#html--css--tailwind)
- [SQL](#sql)
- [Lua](#lua)
- [JSON](#json)
- [Adding New Languages](#adding-new-languages)

---

## TypeScript / JavaScript / React

| Component | Tool |
|:----------|:-----|
| **LSP** | [vtsls](https://github.com/yioneko/vtsls) — TypeScript/JavaScript language server |
| **Formatter** | Biome (primary), Prettier (fallback) |
| **Linter** | Biome, eslint_d |
| **Tests** | Jest, Vitest (via Rosatest) |
| **Features** | Auto-close/rename JSX tags, Emmet support, Tailwind CSS intellisense |

**File types:** `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`

**Root markers:** `tsconfig.json`, `jsconfig.json`, `package.json`

**Treesitter parsers:** `javascript`, `typescript`, `tsx`, `html`, `css`

---

## Go

| Component | Tool |
|:----------|:-----|
| **LSP** | [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) — official Go language server |
| **Formatter** | goimports (organizes imports + formats) |
| **Linter** | golangci-lint |
| **Tests** | gotestsum (via Rosatest) |
| **Debug** | Delve (via nvim-dap-go) |

**File types:** `.go`, `go.mod`, `go.work`, `go.sum`

**Root markers:** `go.mod`, `go.work`

**Extra keybindings:**

| Key | Action |
|:----|:-------|
| `<leader>nga` | Generate test for current function |
| `<leader>ngA` | Generate tests for all functions |

---

## Python

| Component | Tool |
|:----------|:-----|
| **LSP** | [Pyright](https://github.com/microsoft/pyright) — fast type checker and language server |
| **Formatter** | autopep8 |
| **Linter** | Mypy (type checking), Pylint (code analysis) |
| **Tests** | pytest (via Rosatest) |
| **Debug** | debugpy (via nvim-dap-python) |

**File types:** `.py`, `.pyi`

**Root markers:** `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `pyrightconfig.json`

**Debug configurations:**
- Django server
- Django shell
- Attach to running process

**Extra tools:**
- **venv-selector** (`<leader>lxs`) — pick and activate virtual environments

---

## Java

| Component | Tool |
|:----------|:-----|
| **LSP** | [JDTLS](https://github.com/eclipse-jdtls/eclipse.jdt.ls) (Eclipse JDT Language Server) via nvim-jdtls |
| **Formatter** | google-java-format |
| **Linter** | Checkstyle |
| **Tests** | Gradle (via Rosatest) |
| **Debug** | Remote attach via DAP |

**File types:** `.java`

**Root markers:** `pom.xml`, `build.gradle`, `build.gradle.kts`

**Spring Boot keybindings:**

| Key | Action |
|:----|:-------|
| `<leader>ks*` | Spring-related tools |

---

## PHP / Laravel

| Component | Tool |
|:----------|:-----|
| **LSP** | [Intelephense](https://intelephense.com/) — premium PHP language server |
| **Formatter** | php-cs-fixer |
| **Linter** | phpcs |
| **Tests** | Pest (via Rosatest) |
| **Debug** | Xdebug |

**File types:** `.php`, `.blade.php`

**Root markers:** `composer.json`, `.git`

**Blade templates:** Full syntax highlighting with a custom Treesitter parser, Emmet support, and blade-formatter.

**Laravel keybindings (15+ commands):**

| Key | Action |
|:----|:-------|
| `<leader>kla` | Artisan commands |
| `<leader>klr` | Routes |
| `<leader>klg` | Make (generate classes) |
| `<leader>klm` | Goto model |
| `<leader>kle` | Goto controller |
| `<leader>klv` | Goto view |
| `<leader>kln*` | Sail commands |
| `<leader>klc*` | Composer commands |
| `<leader>klh*` | IDE Helper |
| `<leader>kld*` | Database schema |

---

## HTML / CSS / Tailwind

| Component | Tool |
|:----------|:-----|
| **LSP** | Emmet (abbreviations), Tailwind CSS Language Server (intellisense) |
| **Formatter** | Prettier |
| **Linter** | djlint |

**File types:** `.html`, `.css`, `.scss`

**Features:**
- Emmet abbreviations (`<C-y>` leader)
- Tailwind class completion and hover preview
- Auto-close and auto-rename HTML tags
- Django template detection (auto-switches to `htmldjango` filetype when `manage.py` is present)

---

## SQL

| Component | Tool |
|:----------|:-----|
| **LSP** | sqlls |
| **Formatter** | sql_formatter |
| **Completion** | vim-dadbod-completion (table names, columns, etc.) |

**Database UI:** vim-dadbod-ui provides a full database client with connection management, query execution, and result browsing.

| Key | Action |
|:----|:-------|
| `<leader>vb` | Toggle DB UI |
| `<leader>va` | Add connection |
| `<leader>vf` | Find query buffer |

---

## Lua

| Component | Tool |
|:----------|:-----|
| **LSP** | lua_ls (Lua Language Server) |
| **Formatter** | StyLua |

**Features:**
- lazydev.nvim provides enhanced completions for Neovim Lua API
- Full type checking and diagnostics

---

## JSON

| Component | Tool |
|:----------|:-----|
| **LSP** | json_ls (JSON Language Server) |
| **Formatter** | Prettier |
| **Linter** | Biome |

**File types:** `.json`, `.jsonc`

---

## Adding New Languages

Rosavim uses **Mason** to manage external tools. Adding support for a new language is straightforward:

### 1. Install the LSP Server

Open Neovim and run:
```
:Mason
```

Search for the LSP server you need (e.g., `rust-analyzer` for Rust) and press `i` to install.

### 2. Create an LSP Configuration

Create a new file in `lsp/` (e.g., `lsp/rust_analyzer.lua`):

```lua
return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },
}
```

Neovim 0.12+ automatically detects LSP configs in the `lsp/` directory.

### 3. Add a Formatter (optional)

Edit `lua/rosavim/plugins/env/conform.lua` and add your formatter to the `formatters_by_ft` table:

```lua
rust = { "rustfmt" },
```

### 4. Add a Linter (optional)

Edit `lua/rosavim/plugins/env/lint.lua` and add your linter:

```lua
rust = { "clippy" },
```

### 5. Add to Mason Auto-Install (optional)

Edit `lua/rosavim/plugins/env/mason.lua` to auto-install the tools:

```lua
ensure_installed = {
  -- ... existing tools
  "rust-analyzer",
  "rustfmt",
}
```

### Languages You Can Add in Minutes

Here are some popular languages and their recommended tools:

| Language | LSP | Formatter | Linter |
|:---------|:----|:----------|:-------|
| **Rust** | rust-analyzer | rustfmt | clippy |
| **C / C++** | clangd | clang-format | clang-tidy |
| **C#** | omnisharp | csharpier | — |
| **Kotlin** | kotlin-language-server | ktlint | ktlint |
| **Ruby** | solargraph | rubocop | rubocop |
| **Elixir** | elixir-ls | mix format | credo |
| **Zig** | zls | zig fmt | — |
| **Swift** | sourcekit-lsp | swift-format | swiftlint |
| **Dart** | dartls | dart format | — |
| **YAML** | yaml-language-server | prettier | yamllint |
| **TOML** | taplo | taplo | — |
| **Docker** | dockerls | — | hadolint |
| **Terraform** | terraformls | terraform fmt | tflint |
| **Svelte** | svelte-language-server | prettier | — |
| **Vue** | volar | prettier | eslint |
| **Astro** | astro-ls | prettier | — |

All of these can be installed via Mason (`:Mason`) without any external setup.

# Suporte a Linguagens

Rosavim fornece um ambiente de desenvolvimento completo para muitas linguagens prontas para uso. Este guia detalha as ferramentas configuradas para cada linguagem e como adicionar suporte para novas.

## Índice

- [TypeScript / JavaScript / React](#typescript--javascript--react)
- [Go](#go)
- [Python](#python)
- [Java](#java)
- [PHP / Laravel](#php--laravel)
- [HTML / CSS / Tailwind](#html--css--tailwind)
- [SQL](#sql)
- [Lua](#lua)
- [JSON](#json)
- [Adicionando Novas Linguagens](#adicionando-novas-linguagens)

---

## TypeScript / JavaScript / React

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | [vtsls](https://github.com/yioneko/vtsls) — Language server para TypeScript/JavaScript |
| **Formatter** | Biome (primário), Prettier (fallback) |
| **Linter** | Biome, eslint_d |
| **Testes** | Jest (via neotest-jest), Vitest (via neotest-vitest) |
| **Recursos** | Auto-fechar/renomear tags JSX, suporte Emmet, intellisense Tailwind CSS |

**Tipos de arquivo:** `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`

**Marcadores de raiz:** `tsconfig.json`, `jsconfig.json`, `package.json`

**Parsers Treesitter:** `javascript`, `typescript`, `tsx`, `html`, `css`

---

## Go

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) — Language server oficial do Go |
| **Formatter** | goimports (organiza imports + formata) |
| **Linter** | golangci-lint |
| **Testes** | gotestsum (via neotest-golang) |
| **Debug** | Delve (via nvim-dap-go) |

**Tipos de arquivo:** `.go`, `go.mod`, `go.work`, `go.sum`

**Marcadores de raiz:** `go.mod`, `go.work`

**Atalhos extras:**

| Tecla | Ação |
|:------|:-----|
| `<leader>nga` | Gerar teste para a função atual |
| `<leader>ngA` | Gerar testes para todas as funções |

---

## Python

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | [Pyright](https://github.com/microsoft/pyright) — Type checker e language server rápido |
| **Formatter** | autopep8 |
| **Linter** | Mypy (verificação de tipos), Pylint (análise de código) |
| **Testes** | pytest (via neotest-python) |
| **Debug** | debugpy (via nvim-dap-python) |

**Tipos de arquivo:** `.py`, `.pyi`

**Marcadores de raiz:** `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `pyrightconfig.json`

**Configurações de debug:**
- Servidor Django
- Shell Django
- Attach a processo em execução

**Ferramentas extras:**
- **venv-selector** (`<leader>lxs`) — selecione e ative ambientes virtuais

---

## Java

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | [JDTLS](https://github.com/eclipse-jdtls/eclipse.jdt.ls) (Eclipse JDT Language Server) via nvim-jdtls |
| **Formatter** | google-java-format |
| **Linter** | Checkstyle |
| **Testes** | Gradle (via neotest-java) |
| **Debug** | Remote attach via DAP |

**Tipos de arquivo:** `.java`

**Marcadores de raiz:** `pom.xml`, `build.gradle`, `build.gradle.kts`

**Atalhos Spring Boot:**

| Tecla | Ação |
|:------|:-----|
| `<leader>ks*` | Ferramentas relacionadas ao Spring |

---

## PHP / Laravel

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | [Intelephense](https://intelephense.com/) — Language server PHP premium |
| **Formatter** | php-cs-fixer |
| **Linter** | phpcs |
| **Testes** | Pest (via neotest-pest) |
| **Debug** | Xdebug |

**Tipos de arquivo:** `.php`, `.blade.php`

**Marcadores de raiz:** `composer.json`, `.git`

**Templates Blade:** Syntax highlighting completo com parser Treesitter customizado, suporte Emmet e blade-formatter.

**Atalhos Laravel (15+ comandos):**

| Tecla | Ação |
|:------|:-----|
| `<leader>kla` | Comandos Artisan |
| `<leader>klr` | Rotas |
| `<leader>klg` | Make (gerar classes) |
| `<leader>klm` | Ir para model |
| `<leader>kle` | Ir para controller |
| `<leader>klv` | Ir para view |
| `<leader>kln*` | Comandos Sail |
| `<leader>klc*` | Comandos Composer |
| `<leader>klh*` | IDE Helper |
| `<leader>kld*` | Schema do banco de dados |

---

## HTML / CSS / Tailwind

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | Emmet (abreviações), Tailwind CSS Language Server (intellisense) |
| **Formatter** | Prettier |
| **Linter** | djlint |

**Tipos de arquivo:** `.html`, `.css`, `.scss`

**Recursos:**
- Abreviações Emmet (leader `<C-y>`)
- Completion de classes Tailwind e preview ao passar o mouse
- Auto-fechar e auto-renomear tags HTML
- Detecção de templates Django (muda automaticamente para filetype `htmldjango` quando `manage.py` está presente)

---

## SQL

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | sqlls |
| **Formatter** | sql_formatter |
| **Completion** | vim-dadbod-completion (nomes de tabelas, colunas, etc.) |

**UI de Banco de Dados:** vim-dadbod-ui fornece um cliente de banco de dados completo com gerenciamento de conexões, execução de queries e visualização de resultados.

| Tecla | Ação |
|:------|:-----|
| `<leader>vb` | Alternar DB UI |
| `<leader>va` | Adicionar conexão |
| `<leader>vf` | Encontrar buffer de query |

---

## Lua

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | lua_ls (Lua Language Server) |
| **Formatter** | StyLua |

**Recursos:**
- lazydev.nvim fornece completions aprimorados para a API Lua do Neovim
- Verificação de tipos e diagnósticos completos

---

## JSON

| Componente | Ferramenta |
|:-----------|:-----------|
| **LSP** | json_ls (JSON Language Server) |
| **Formatter** | Prettier |
| **Linter** | Biome |

**Tipos de arquivo:** `.json`, `.jsonc`

---

## Adicionando Novas Linguagens

Rosavim usa o **Mason** para gerenciar ferramentas externas. Adicionar suporte a uma nova linguagem é simples:

### 1. Instalar o LSP Server

Abra o Neovim e execute:
```
:Mason
```

Busque o LSP server que você precisa (ex.: `rust-analyzer` para Rust) e pressione `i` para instalar.

### 2. Criar uma Configuração LSP

Crie um novo arquivo em `lsp/` (ex.: `lsp/rust_analyzer.lua`):

```lua
return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },
}
```

O Neovim 0.12+ detecta automaticamente configurações LSP no diretório `lsp/`.

### 3. Adicionar um Formatter (opcional)

Edite `lua/rosavim/plugins/env/conform.lua` e adicione seu formatter à tabela `formatters_by_ft`:

```lua
rust = { "rustfmt" },
```

### 4. Adicionar um Linter (opcional)

Edite `lua/rosavim/plugins/env/lint.lua` e adicione seu linter:

```lua
rust = { "clippy" },
```

### 5. Adicionar ao Auto-Install do Mason (opcional)

Edite `lua/rosavim/plugins/env/mason.lua` para auto-instalar as ferramentas:

```lua
ensure_installed = {
  -- ... ferramentas existentes
  "rust-analyzer",
  "rustfmt",
}
```

### Linguagens que Você Pode Adicionar em Minutos

Aqui estão algumas linguagens populares e suas ferramentas recomendadas:

| Linguagem | LSP | Formatter | Linter |
|:----------|:----|:----------|:-------|
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

Todas podem ser instaladas via Mason (`:Mason`) sem nenhuma configuração externa.

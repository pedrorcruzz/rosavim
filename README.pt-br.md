<div align="center">

<img src="assets/logo/rosavim.png" alt="Rosavim" width="420" />

# Rosavim

**Uma distribuição Neovim moderna, produtiva e pronta para o mundo real.**

[![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-57A143?style=for-the-badge&logo=neovim&logoColor=57A143&labelColor=1a1a2e)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge)](LICENSE)

*Transforme seu terminal em uma IDE completa, sem complicações.*

🇧🇷 **Português** · 🇺🇸 **[English](README.md)**

| | |
|:---:|:---:|
| ![Rosamin Dashboard Dark](assets/screenshots/rosamin_dashboard_dark.png) | ![Rosaesthetic Dashboard Light](assets/screenshots/rosaaesthetic_dashboard_light.png) |
| ![Rosamin Code Dark](assets/screenshots/rosamin_code_dark.png) | ![Rosaesthetic Code Light](assets/screenshots/rosaaesthetic_code_light.png) |

</div>

## O que é Rosavim?

Rosavim é uma distribuição do Neovim para quem quer um ambiente completo, rápido e bonito sem gastar horas configurando do zero. Já vem com suporte de primeira classe para as principais linguagens e frameworks — basta clonar e começar a codar.

Construída sobre o **Lazy.nvim**, carrega plugins de forma lazy para manter o startup rápido, e traz um conjunto de **plugins próprios "rosa"** (terminal, test runner, operações de arquivo, navegador de projeto e mais) para que a maior parte funcione de imediato.

## Início Rápido

```bash
# Faça backup da sua config atual (se houver)
mv ~/.config/nvim ~/.config/nvim.bak

# Clone o Rosavim
git clone https://github.com/pedrorcruzz/rosavim.git ~/.config/nvim

# Abra o Neovim — os plugins instalam automaticamente
nvim
```

Na primeira execução, o **Lazy.nvim** instala os plugins e o **Mason** configura LSP servers, formatters, linters e adaptadores de debug.

<details>
<summary><b>Requisitos</b></summary>

<br>

| Dependência | Versão |
|:------------|:-------|
| **Neovim** | **>= 0.12** |
| Git | >= 2.19 |
| Node.js | >= 18 |
| Python | >= 3.10 |
| [Nerd Font](https://www.nerdfonts.com/) | Qualquer |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Qualquer |

**Recomendado:** [lazygit](https://github.com/jesseduffield/lazygit) (UI de Git) · [yazi](https://github.com/sxyazi/yazi) (file manager) · [chafa](https://hpjansson.org/chafa/) (imagem do dashboard)

Guia completo passo a passo (backup, dependências, troubleshooting): **[Manual de Instalação](docs/manual/installation.pt-br.md)**.

</details>

## Documentação

Guias detalhados ficam em [`docs/manual`](docs/manual/):

[Instalação](docs/manual/installation.pt-br.md) · [Atalhos](docs/manual/keybinds.pt-br.md) · [Plugins](docs/manual/plugins.pt-br.md) · [Linguagens](docs/manual/languages.pt-br.md) · [Debugging](docs/manual/debugging.pt-br.md) · [Customização](docs/manual/customization.pt-br.md) · [Toggles](docs/manual/toggles.pt-br.md)

## Funcionalidades

<details>
<summary><b>Editor & Navegação</b></summary>

<br>

- **blink.cmp** — engine de completion em Rust, extremamente rápido
- **Snippets** com LuaSnip + friendly-snippets
- **Treesitter nativo** (Neovim 0.12+) para highlighting e indentação precisos
- **Format on save** (conform.nvim) e **auto-save** ao perder o foco
- **Snacks Picker** para fuzzy finding de arquivos, grep e buffers
- **Flash.nvim** para navegação instantânea com labels visuais
- **GrugFar** para search & replace no projeto inteiro (ripgrep)
- **Toggles persistentes** — configurações de UI sobrevivem entre sessões

</details>

<details>
<summary><b>Git, Debug & Testes</b></summary>

<br>

- **Gitsigns** — indicadores de mudança inline e blame por linha
- Integração nativa com **lazygit**
- **DAP** — debugger completo com UI, breakpoints e inspeção de variáveis inline
- **Rosatest** — test runner próprio com popup de resultados: roda testes nearest / file / all. Suporta Go, Jest, Vitest, Pytest, Pest, PHPUnit e Java

</details>

<details>
<summary><b>IA</b></summary>

<br>

- **GitHub Copilot** integrado ao completion
- **RosaAI** — integração nativa com CLIs de IA (Claude, Cursor, Gemini, …) com janela temática, redimensionável e preview no editor

</details>

<details>
<summary><b>UI & Aparência</b></summary>

<br>

- **2 temas próprios** — **Rosamin** (padrão, minimal) e **Rosaesthetic** (quente, terroso), ambos com dark/light mode e transparência
- **Dashboard**, statusline **Lualine** (separadores selecionáveis), abas **Bufferline**, breadcrumbs **Dropbar**, nomes flutuantes **Incline** e **Noice** para mensagens modernas
- Troca de **dark/light** e de **tema** com um atalho

</details>

<details>
<summary><b>Plugins próprios "Rosa"</b></summary>

<br>

| Plugin | O que faz |
|:-------|:----------|
| **Rosaterm** | Terminais float & split nativos — sem dependências externas. Cicla floats, chip de título temático, toggles persistentes |
| **Rosatest** | Test runner com popup de resultados (Go, Jest, Vitest, Pytest, Pest, PHPUnit, Java) |
| **Rosakit** | Navegador de projeto com detecção automática de stack (React, Next, Vue, Angular, Svelte, Nest, Express, Go, Django, FastAPI, Laravel, Spring) — suporta monorepos |
| **Rosafile** | Menu de operações de arquivo — criar, renomear, duplicar, deletar, info |
| **Rosapreview** | Preview de LSP (definição, tipo, implementação, referências) em janela flutuante |
| **Rosapoon** | Marca e salta entre arquivos frequentes, com escopo por repositório git |
| **Rosadirs** | Gerencia diretórios de Projetos & vaults do Obsidian em runtime |
| **Rosapick** | Seletor visual de janelas com labels de letra |
| **Rosamaximize** | Maximiza a janela atual e restaura o layout completo |
| **Rosayank** | Histórico de yank persistente (ring buffer) |
| **Rosasave** | Auto-save com debounce |
| **Rosasweep** | Fecha buffers inativos automaticamente |

</details>

<details>
<summary><b>Extras</b></summary>

<br>

- **Database Client** (vim-dadbod) com UI para SQL
- **Obsidian** integração para notas
- **Discord Presence**

> O sistema de plugins é modular — adicione, remova ou troque plugins para adaptar ao seu workflow.

</details>

## Linguagens & Frameworks

Suporte completo (LSP, formatação, linting, testes e debug) para as principais stacks:

<details>
<summary><b>Ver tabela de suporte</b></summary>

<br>

| Linguagem | LSP | Formatter | Linter | Testes | Debug |
|:----------|:---:|:---------:|:------:|:------:|:-----:|
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

> **Não encontrou sua linguagem?** Rosavim usa o **Mason** como backbone de ferramentas — Rust, C/C++, Kotlin, Ruby, Elixir, Zig e muitas outras podem ser adicionadas em minutos.

## Temas

Rosavim vem com 2 temas próprios, totalmente integrados aos toggles de dark/light e transparência.

<details>
<summary><b>Rosamin</b> — minimal, limpo e focado (padrão)</summary>

<br>

| Code (Dark) | Dashboard (Dark) | Code (Light) | Transparente |
|:------------|:-----------------|:-------------|:-------------|
| ![Rosamin Code Dark](assets/screenshots/rosamin_code_dark.png) | ![Rosamin Dashboard Dark](assets/screenshots/rosamin_dashboard_dark.png) | ![Rosamin Code Light](assets/screenshots/rosamin_code_light.png) | ![Rosamin Transparent](assets/screenshots/rosamin_transparent.png) |

</details>

<details>
<summary><b>Rosaesthetic</b> — tons quentes e terrosos</summary>

<br>

| Code (Dark) | Dashboard (Dark) | Code (Light) | Dashboard (Light) | Transparente |
|:------------|:-----------------|:-------------|:------------------|:-------------|
| ![Rosaesthetic Code Dark](assets/screenshots/rosaaesthetic_code_dark.png) | ![Rosaesthetic Dashboard Dark](assets/screenshots/rosaaesthetic_dashboard_dark.png) | ![Rosaesthetic Code Light](assets/screenshots/rosaaesthetic_code_light.png) | ![Rosaesthetic Dashboard Light](assets/screenshots/rosaaesthetic_dashboard_light.png) | ![Rosaesthetic Transparent](assets/screenshots/rosaaesthetic_transparent.png) |

</details>

## Atalhos Principais

> Leader: `<Space>` · Pressione `<leader>` a qualquer momento para abrir o **which-key** e explorar tudo.

<details>
<summary><b>Ver atalhos essenciais</b></summary>

<br>

**Arquivos & Navegação**
| Atalho | Ação |
|:-------|:-----|
| `<leader><space>` | Buscar arquivos |
| `<leader>e` | File explorer |
| `<leader>y` | Yazi file manager |
| `<leader>;` | Dashboard |
| `s` | Flash jump |
| `<leader>oo` / `<leader>oe` | Rosapoon: pin / menu |

**Busca & Código**
| Atalho | Ação |
|:-------|:-----|
| `<leader>sg` | Grep ao vivo |
| `<leader>sw` | Grep da palavra sob o cursor |
| `<leader>lee` | Search & replace (GrugFar) |
| `gd` / `gr` / `gI` | Definição / referências / implementação |
| `gp` | Rosapreview definição |
| `<leader>lf` | Formatar arquivo |
| `<leader>xx` | Menu Rosafile |
| `<leader>kk` | Menu Rosakit |

**Git, Testes & Debug**
| Atalho | Ação |
|:-------|:-----|
| `<leader>gg` | Lazygit |
| `<leader>gt` | Toggle git blame |
| `<leader>nn` | Menu Rosatest |
| `<leader>nf` | Rodar testes do arquivo |
| `<leader>ds` | Iniciar / continuar debug |
| `<leader>db` | Toggle breakpoint |

**Janelas, Terminal & IA**
| Atalho | Ação |
|:-------|:-----|
| `<C-h/j/k/l>` | Mover entre splits |
| `<leader>m` | Rosapick (seletor de janela) |
| `<leader>cm` | Rosamaximize |
| `<C-\>` / `<S-z>` | Rosaterm: toggle float |
| `<S-x>` | Rosaterm: terminal horizontal |
| `<leader>cii` / `<leader>cie` | Rosaterm: split vertical / horizontal |
| `<leader>aa` | RosaAI: toggle CLI |

**UI & Diversos**
| Atalho | Ação |
|:-------|:-----|
| `<leader>lqt` | Alternar dark/light mode |
| `<leader>lqs` | Trocar tema |
| `<leader>lp` | Rosadirs (gerenciar diretórios) |
| `<leader>ll` | Toggle statusline |
| `kj` | Sair do insert mode |

Referência completa: **[Manual de Atalhos](docs/manual/keybinds.pt-br.md)**.

</details>

## Estrutura do Projeto

<details>
<summary><b>Ver estrutura</b></summary>

<br>

```
~/.config/nvim/
├── init.lua                       # Ponto de entrada
├── lua/rosavim/
│   ├── init.lua                   # Bootstrap
│   ├── config/                    # options, keybinds, appearance, autocmds, toggles, focus, snippets
│   ├── plugins/
│   │   ├── env/                   # LSP, Mason, Treesitter, DAP, lint, format, git
│   │   ├── ai/                    # Copilot, RosaAI
│   │   ├── ui/                    # temas, statusline, dashboard, bufferline, noice
│   │   ├── editor/                # terminal, navegação, operações de arquivo, projetos
│   │   ├── coding/                # flash, surround, multi-cursor, refactoring
│   │   ├── language/              # específicos de linguagem (Laravel, Spring, Django, …)
│   │   └── test/                  # Rosatest
│   ├── rosa_plugins/              # plugins próprios (ver Funcionalidades)
│   │   ├── rosaterm/  rosatest/  rosakit/  rosafile/
│   │   ├── rosapreview/  rosapoon/  rosadirs/  rosapick/
│   │   ├── rosamaximize/  rosayank/  rosasave/  rosasweep/
│   │   └── rosaai/
│   └── rosa_themes/
│       ├── rosamin/               # tema padrão (minimal)
│       └── rosaesthetic/          # tema quente e terroso
├── lsp/                           # configs individuais de LSP
└── assets/                        # logo e screenshots
```

</details>

---

<div align="center">

Construído com carinho por **Pedro Rosa**

</div>

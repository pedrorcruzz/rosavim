<div align="center">

<img src="assets/logo/rosavim.png" alt="Rosavim" width="420" />

# Rosavim

**Uma distribuição Neovim moderna, produtiva e pronta para o mundo real.**

[![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-57A143?style=for-the-badge&logo=neovim&logoColor=57A143&labelColor=1a1a2e)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

---

*Transforme seu terminal em uma IDE completa — sem complicações.*

**[English](README.md)** | **[Português](#o-que-é-rosavim)**

[O que é Rosavim?](#o-que-é-rosavim) · [Documentação](#documentação) · [Linguagens](#linguagens--frameworks) · [Funcionalidades](#funcionalidades) · [Instalação](#instalação) · [Requisitos](#requisitos) · [Estrutura do Projeto](#estrutura-do-projeto) · [Atalhos Principais](#atalhos-principais)

</div>

## O que é Rosavim?

Rosavim é uma distribuição do Neovim pensada para desenvolvedores que querem um ambiente de desenvolvimento completo, rápido e bonito — sem precisar gastar horas configurando do zero. Com suporte de primeira classe para as principais linguagens e frameworks do mercado, basta clonar e começar a codar.

Construída sobre o **Lazy.nvim**, Rosavim carrega mais de **90 plugins** de forma inteligente, mantendo o startup rápido e a experiência fluida.

## Documentação

Para guias detalhados e referências completas, confira o diretório [docs/manual](docs/manual/):

- **[Atalhos](docs/manual/keybinds.pt-br.md)** — Referência completa de atalhos com exemplos de uso
- **[Plugins](docs/manual/plugins.pt-br.md)** — Catálogo completo de plugins com descrições
- **[Linguagens](docs/manual/languages.pt-br.md)** — Detalhes de suporte a linguagens e configuração
- **[Debugging](docs/manual/debugging.pt-br.md)** — Configuração e uso de debug por linguagem
- **[Customização](docs/manual/customization.pt-br.md)** — Temas, aparência e como estender o Rosavim

## Linguagens & Frameworks

Rosavim oferece suporte completo (LSP, formatação, linting, testes e debug) para as principais stacks de desenvolvimento:

| Linguagem | LSP | Formatter | Linter | Testes | Debug |
|:----------|:---:|:---------:|:------:|:------:|:-----:|
| **TypeScript / JavaScript** | vtsls | Biome / Prettier | ESLint / Biome | Jest / Vitest | — |
| **React / JSX / TSX** | vtsls | Biome / Prettier | ESLint / Biome | Jest / Vitest | — |
| **Go** | gopls | goimports | golangci-lint | gotestsum | Delve |
| **Python** | Pyright | autopep8 | Mypy / Pylint | pytest | debugpy |
| **Java** | JDTLS | google-java-format | Checkstyle | Gradle | Remote Attach |
| **PHP / Laravel** | Intelephense | php-cs-fixer | phpcs | Pest | Xdebug |
| **HTML / CSS** | Emmet + Tailwind CSS | Prettier | djlint | — | — |
| **SQL** | sqlls | sql_formatter | — | — | — |
| **Lua** | lua_ls | StyLua | — | — | — |
| **JSON** | json_ls | Prettier | Biome | — | — |

> **Não encontrou sua linguagem?** Rosavim usa o **Mason** como backbone de ferramentas — adicionar suporte a novas linguagens é tão simples quanto instalar o LSP server, formatter ou linter que você precisa. Rust, C/C++, Kotlin, Ruby, Elixir, Zig e muitas outras podem ser configuradas em minutos.

## Funcionalidades

### Editor Inteligente

- **Autocompletion** via [blink.cmp](https://github.com/Saghen/blink.cmp) — engine de completion em Rust, extremamente rápido
- **Snippets** com LuaSnip + friendly-snippets para produtividade máxima
- **Treesitter** para syntax highlighting preciso, text objects e contexto de código
- **Format on Save** automático com conform.nvim
- **Auto Save** ao perder foco da janela

### Navegação & Busca

- **Snacks Picker** para fuzzy finding de arquivos, grep, buffers e muito mais
- **Flash.nvim** para movimentação rápida no código com labels visuais
- **Grapple** para marcar e saltar entre arquivos frequentes
- **Snacks Explorer** como file tree integrado
- **Yazi** como file manager alternativo no terminal
- **GrugFar** para search & replace avançado com ripgrep

### Git

- **Gitsigns** com indicadores de mudanças inline e git blame por linha
- Integração com **lazygit** direto do editor

### Debug & Testes

- **DAP** (Debug Adapter Protocol) com UI visual, breakpoints e inspeção de variáveis inline
- **Neotest** como framework unificado de testes — rode, assista e inspecione testes sem sair do editor
- Adaptadores dedicados para Go, Python, JavaScript, Java e PHP

### IA

- **GitHub Copilot** integrado ao autocompletion
- **Sidekick** como assistente de IA no editor

### UI & Aparência

- **7 colorschemes** incluídos: Catppuccin, Gruvbox, Kanagawa, Min Theme, Rosé Pine, Rusticated e Vesper
- Alternância entre **dark/light mode** com um atalho
- **Modo transparente** para integrar com o wallpaper do terminal
- **Dashboard** customizado com acesso rápido a projetos e arquivos recentes
- **Lualine** com statusline informativa (modo, git, LSP, Copilot)
- **Dropbar** com breadcrumbs de navegação
- **Noice.nvim** para mensagens e command line modernos

### Ferramentas Extras

- **Database Client** (vim-dadbod) com UI para queries SQL
- **Obsidian** integração para notas e second brain
- **Laravel Tools** com 15+ comandos dedicados (Artisan, Sail, Routes, etc.)
- **Discord Presence** para mostrar o que você está editando
- **CodeSnap** para screenshots bonitos do código
- **ToggleTerm** para terminais flutuantes e splits

> Essas são apenas as ferramentas que já vem inclusas. O sistema de plugins do Rosavim é modular — você pode facilmente adicionar, remover ou trocar plugins para adaptar ao seu workflow.

## Instalação

Rosavim faz parte do repositório [**.dotfiles**](https://github.com/pedrorcruzz/.dotfiles). Para instalá-lo, siga as instruções na raiz do repositório de dotfiles — ele cuidará de fazer o symlink do Rosavim para `~/.config/nvim` junto com o restante do ambiente.

> Na primeira execução, o **Lazy.nvim** instalará automaticamente todos os plugins e o **Mason** instalará os LSP servers, formatters, linters e adaptadores de debug configurados.

## Requisitos

| Dependência | Versão |
|:------------|:-------|
| **Neovim** | **>= 0.12** |
| Git | >= 2.19 |
| Node.js | >= 18 |
| Python | >= 3.10 |
| [Nerd Font](https://www.nerdfonts.com/) | Qualquer |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Qualquer |

### Recomendado

- [lazygit](https://github.com/jesseduffield/lazygit) — UI de Git no terminal
- [yazi](https://github.com/sxyazi/yazi) — File manager no terminal
- [chafa](https://hpjansson.org/chafa/) — Imagens no terminal (usado no dashboard)

## Estrutura do Projeto

```
~/.config/nvim/
├── init.lua                          # Ponto de entrada
├── lua/rosavim/
│   ├── init.lua                      # Bootstrap
│   ├── config/
│   │   ├── options.lua               # Opções do Neovim
│   │   ├── keybinds.lua              # Mapeamentos globais
│   │   ├── appearance.lua            # Tema, transparência, dark/light
│   │   ├── autocmds.lua              # Autocommands
│   │   ├── filetypes.lua             # Detecção de filetypes
│   │   └── snippets/                 # Snippets customizados
│   └── plugins/
│       ├── env/                      # LSP, Mason, Treesitter, DAP, Lint, Format
│       ├── ai/                       # Copilot, Sidekick
│       ├── ui/                       # Temas, statusline, dashboard
│       ├── editor/                   # Terminal, file management, navegação
│       ├── coding/                   # Surround, multi-cursor, refactoring
│       ├── language/                 # Suporte específico (Laravel, Java, etc.)
│       └── test/                     # Neotest e adaptadores
├── lsp/                              # Configurações individuais de LSP
└── assets/                           # Logo e recursos visuais
```

## Atalhos Principais

> Leader key: `<Space>`

| Atalho | Ação |
|:-------|:-----|
| `<leader>e` | File Explorer |
| `<leader>y` | Yazi File Manager |
| `<leader>fp` | Descobrir Projetos |
| `<leader><space>` | Buscar Arquivos |
| `<leader>sg` | Grep ao Vivo |
| `<leader>lf` | Formatar Arquivo |
| `<leader>nn` | Rodar Teste Mais Próximo |
| `<leader>nf` | Rodar Testes do Arquivo |
| `<leader>ds` | Iniciar/Continuar Debug |
| `<leader>db` | Toggle Breakpoint |
| `<leader>gt` | Git Blame da Linha |
| `<leader>lqt` | Alternar Dark/Light Mode |
| `<leader>lqs` | Trocar Colorscheme |
| `<C-\>` | Terminal Flutuante |
| `s` | Flash Jump |
| `kj` | Sair do Insert Mode |

> Pressione `<leader>` para abrir o **which-key** e explorar todos os atalhos disponíveis.

---

<div align="center">

Construído com carinho por **Pedro Rosa**

</div>

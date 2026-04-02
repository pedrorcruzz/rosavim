<div align="center">

<img src="assets/logo/rosavim.png" alt="Rosavim" width="420" />

# Rosavim

**Uma distribuicao Neovim moderna, produtiva e pronta para o mundo real.**

[![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-57A143?style=for-the-badge&logo=neovim&logoColor=57A143&labelColor=1a1a2e)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

---

*Transforme seu terminal em uma IDE completa — sem complicacoes.*

**[English](README.md)** | **[Portugues](#o-que-e-rosavim)**

</div>

## O que e Rosavim?

Rosavim e uma distribuicao do Neovim pensada para desenvolvedores que querem um ambiente de desenvolvimento completo, rapido e bonito — sem precisar gastar horas configurando do zero. Com suporte de primeira classe para as principais linguagens e frameworks do mercado, basta clonar e comecar a codar.

Construida sobre o **Lazy.nvim**, Rosavim carrega mais de **90 plugins** de forma inteligente, mantendo o startup rapido e a experiencia fluida.

## Linguagens & Frameworks

Rosavim oferece suporte completo (LSP, formatacao, linting, testes e debug) para as principais stacks de desenvolvimento:

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

> **Nao encontrou sua linguagem?** Rosavim usa o **Mason** como backbone de ferramentas — adicionar suporte a novas linguagens e tao simples quanto instalar o LSP server, formatter ou linter que voce precisa. Rust, C/C++, Kotlin, Ruby, Elixir, Zig e muitas outras podem ser configuradas em minutos.

## Funcionalidades

### Editor Inteligente

- **Autocompletion** via [blink.cmp](https://github.com/Saghen/blink.cmp) — engine de completion em Rust, extremamente rapido
- **Snippets** com LuaSnip + friendly-snippets para produtividade maxima
- **Treesitter** para syntax highlighting preciso, text objects e contexto de codigo
- **Format on Save** automatico com conform.nvim
- **Auto Save** ao perder foco da janela

### Navegacao & Busca

- **Snacks Picker** para fuzzy finding de arquivos, grep, buffers e muito mais
- **Flash.nvim** para movimentacao rapida no codigo com labels visuais
- **Grapple** para marcar e saltar entre arquivos frequentes
- **Snacks Explorer** como file tree integrado
- **Yazi** como file manager alternativo no terminal
- **GrugFar** para search & replace avancado com ripgrep

### Git

- **Gitsigns** com indicadores de mudancas inline e git blame por linha
- Integracao com **lazygit** direto do editor

### Debug & Testes

- **DAP** (Debug Adapter Protocol) com UI visual, breakpoints e inspecao de variaveis inline
- **Neotest** como framework unificado de testes — rode, assista e inspecione testes sem sair do editor
- Adaptadores dedicados para Go, Python, JavaScript, Java e PHP

### IA

- **GitHub Copilot** integrado ao autocompletion
- **Sidekick** como assistente de IA no editor

### UI & Aparencia

- **7 colorschemes** incluidos: Catppuccin, Gruvbox, Kanagawa, Min Theme, Rose Pine, Rusticated e Vesper
- Alternancia entre **dark/light mode** com um atalho
- **Modo transparente** para integrar com o wallpaper do terminal
- **Dashboard** customizado com acesso rapido a projetos e arquivos recentes
- **Lualine** com statusline informativa (modo, git, LSP, Copilot)
- **Dropbar** com breadcrumbs de navegacao
- **Noice.nvim** para mensagens e command line modernos

### Ferramentas Extras

- **Database Client** (vim-dadbod) com UI para queries SQL
- **Obsidian** integration para notas e second brain
- **Laravel Tools** com 15+ comandos dedicados (Artisan, Sail, Routes, etc.)
- **Discord Presence** para mostrar o que voce esta editando
- **CodeSnap** para screenshots bonitos do codigo
- **ToggleTerm** para terminais flutuantes e splits

> Essas sao apenas as ferramentas que ja vem inclusas. O sistema de plugins do Rosavim e modular — voce pode facilmente adicionar, remover ou trocar plugins para adaptar ao seu workflow.

## Requisitos

| Dependencia | Versao |
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
├── init.lua                          # Entry point
├── lua/rosavim/
│   ├── init.lua                      # Bootstrap
│   ├── config/
│   │   ├── options.lua               # Opcoes do Neovim
│   │   ├── keybinds.lua              # Mapeamentos globais
│   │   ├── appearance.lua            # Tema, transparencia, dark/light
│   │   ├── autocmds.lua              # Autocommands
│   │   ├── filetypes.lua             # Deteccao de filetypes
│   │   └── snippets/                 # Snippets customizados
│   └── plugins/
│       ├── env/                      # LSP, Mason, Treesitter, DAP, Lint, Format
│       ├── ai/                       # Copilot, Sidekick
│       ├── ui/                       # Temas, statusline, dashboard
│       ├── editor/                   # Terminal, file management, navegacao
│       ├── coding/                   # Surround, multi-cursor, refactoring
│       ├── language/                 # Suporte especifico (Laravel, Java, etc.)
│       └── test/                     # Neotest e adaptadores
├── lsp/                              # Configuracoes individuais de LSP
└── assets/                           # Logo e recursos visuais
```

## Atalhos Principais

> Leader key: `<Space>`

| Atalho | Acao |
|:-------|:-----|
| `<leader>e` | File Explorer |
| `<leader>y` | Yazi File Manager |
| `<leader>fp` | Descobrir Projetos |
| `<leader><space>` | Buscar Arquivos |
| `<leader>sg` | Grep ao Vivo |
| `<leader>lf` | Formatar Arquivo |
| `<leader>nn` | Rodar Teste Mais Proximo |
| `<leader>nf` | Rodar Testes do Arquivo |
| `<leader>ds` | Iniciar/Continuar Debug |
| `<leader>db` | Toggle Breakpoint |
| `<leader>gt` | Git Blame da Linha |
| `<leader>lqt` | Alternar Dark/Light Mode |
| `<leader>lqs` | Trocar Colorscheme |
| `<C-\>` | Terminal Flutuante |
| `s` | Flash Jump |
| `kj` | Sair do Insert Mode |

> Pressione `<leader>` para abrir o **which-key** e explorar todos os atalhos disponiveis.

## Documentacao

Para guias detalhados e referencias completas, confira o diretorio [docs/manual](docs/manual/):

- **[Keybindings](docs/manual/keybinds.md)** — Referencia completa de atalhos com exemplos de uso
- **[Plugins](docs/manual/plugins.md)** — Catalogo completo de plugins com descricoes
- **[Linguagens](docs/manual/languages.md)** — Detalhes de suporte a linguagens e configuracao
- **[Debugging](docs/manual/debugging.md)** — Configuracao e uso de debug por linguagem
- **[Customizacao](docs/manual/customization.md)** — Temas, aparencia e como estender o Rosavim

---

<div align="center">

Construido com carinho por **Pedro Rosa**

</div>

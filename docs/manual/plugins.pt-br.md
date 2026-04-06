# Catálogo de Plugins

Rosavim vem com **75+ plugins**, todos gerenciados pelo [Lazy.nvim](https://github.com/folke/lazy.nvim) com carregamento inteligente para startup rápido.

## Índice

- [Core & Infraestrutura](#core--infraestrutura)
- [LSP & Completion](#lsp--completion)
- [Sintaxe & Treesitter](#sintaxe--treesitter)
- [Formatação & Linting](#formatação--linting)
- [Debugging](#debugging)
- [Testes](#testes)
- [UI & Aparência](#ui--aparência)
- [Navegação & Busca](#navegação--busca)
- [Melhorias do Editor](#melhorias-do-editor)
- [Git](#git)
- [IA](#ia)
- [Específicos por Linguagem](#específicos-por-linguagem)
- [Banco de Dados](#banco-de-dados)
- [Notas & Escrita](#notas--escrita)
- [Utilitários](#utilitários)

---

## Core & Infraestrutura

| Plugin | Descrição |
|:-------|:----------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Gerenciador de plugins — cuida da instalação, atualizações e lazy-loading |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Biblioteca utilitária Lua usada por muitos plugins |
| [nui.nvim](https://github.com/MunifTanjim/nui.nvim) | Biblioteca de componentes de UI para desenvolvedores de plugins |
| [FixCursorHold.nvim](https://github.com/antoinemadec/FixCursorHold.nvim) | Corrige problemas de performance do CursorHold |

---

## LSP & Completion

| Plugin | Descrição |
|:-------|:----------|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Configuração para o cliente LSP nativo |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | Gerenciador de pacotes portátil — instala LSP servers, formatters, linters e adaptadores DAP |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Instala automaticamente ferramentas do Mason no startup |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Engine de completion em Rust — autocompleção extremamente rápida |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Engine de snippets com suporte a snippets estilo VSCode |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Coleção de snippets mantida pela comunidade para muitas linguagens |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Helpers de desenvolvimento para criação de plugins Lua/Neovim |
| [nvim-navic](https://github.com/SmiteshP/nvim-navic) | Provedor de breadcrumb alimentado pelo LSP |
| [nvim-lsp-file-operations](https://github.com/antosha417/nvim-lsp-file-operations) | Atualização automática de imports ao renomear/mover arquivos |
| [blink-copilot](https://github.com/giuxtaposition/blink-copilot) | Fonte do Copilot para blink.cmp |
| [blink-emoji.nvim](https://github.com/moyiz/blink-emoji.nvim) | Fonte de completion de emojis |
| [blink-ripgrep.nvim](https://github.com/mikavilpas/blink-ripgrep.nvim) | Fonte de completion via ripgrep — completa a partir de texto de todo o projeto |

---

## Sintaxe & Treesitter

| Plugin | Descrição |
|:-------|:----------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Integração Treesitter — syntax highlighting preciso, text objects, folding |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Mostra o contexto da função/classe atual no topo da tela |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Text objects via Treesitter (selecionar função, classe, parâmetro, etc.) |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto-fechar e auto-renomear tags HTML/JSX |

---

## Formatação & Linting

| Plugin | Descrição |
|:-------|:----------|
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatador com suporte a format-on-save assíncrono |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Agregador de linters assíncronos |

---

## Debugging

| Plugin | Descrição |
|:-------|:----------|
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Cliente do Debug Adapter Protocol |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | UI para nvim-dap — variáveis, breakpoints, call stack, console |
| [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Valores de variáveis inline durante debugging |
| [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Adaptador de debug Python (debugpy) |
| [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) | Adaptador de debug Go (delve) |
| [mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim) | Ponte entre Mason e nvim-dap para auto-instalar adaptadores de debug |

---

## Testes

| Plugin | Descrição |
|:-------|:----------|
| Rosatest | Test runner nativo com popup UI (Go, Jest, Vitest, Pytest, Pest, PHPUnit, Java) |
| Rosafile | Menu nativo de operações com arquivos (criar, renomear, duplicar, deletar, info) |

---

## UI & Aparência

| Plugin | Descrição |
|:-------|:----------|
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Tudo-em-um: dashboard, file explorer, picker, notificador, profiler e mais |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline rápida e customizável |
| [noice.nvim](https://github.com/folke/noice.nvim) | UI moderna para mensagens, linha de comando e popups |
| [dropbar.nvim](https://github.com/Bekaboo/dropbar.nvim) | Barra de navegação com breadcrumbs estilo IDE |
| [incline.nvim](https://github.com/b0o/incline.nvim) | Indicador flutuante de nome de arquivo por janela |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Exibe atalhos disponíveis em um popup |
| [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) | Destaca códigos de cores com sua cor real |
| [mini.icons](https://github.com/echasnovski/mini.icons) | Ícones de tipo de arquivo |
| [markview.nvim](https://github.com/OXY2DEV/markview.nvim) | Renderização aprimorada de markdown no editor |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Preview de markdown ao vivo no navegador |

### Colorschemes

| Tema | Descrição |
|:-----|:----------|
| [catppuccin](https://github.com/catppuccin/nvim) | Tema pastel suave |
| [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) | Esquema de cores retrô |
| [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | Inspirado nas cores da famosa pintura |
| min-theme | Tema minimal customizado (padrão) |
| [rose-pine](https://github.com/rose-pine/neovim) | Vibes de Soho para Neovim |
| nvim-rusticated | Tema rusticated customizado |
| vesper | Tema vesper customizado |

---

## Navegação & Busca

| Plugin | Descrição |
|:-------|:----------|
| [flash.nvim](https://github.com/folke/flash.nvim) | Navegue pelo código com labels de busca — substitui movimentos f/F/t/T |
| Rosapoon (built-in) | Favorite/marque arquivos para acesso instantâneo (persistido por git repo) |
| Rosapreview (built-in) | Preview de definições LSP em janelas flutuantes |
| [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | Buscar e substituir alimentado por ripgrep |

---

## Melhorias do Editor

| Plugin | Descrição |
|:-------|:----------|
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Adicionar, mudar e deletar caracteres ao redor |
| [vim-matchup](https://github.com/andymass/vim-matchup) | Correspondência `%` estendida para construções de linguagem |
| [vim-visual-multi](https://github.com/mg979/vim-visual-multi) | Edição com múltiplos cursores |
| [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | Operações de refatoração de código (extrair, inline, debug print) |
| [yanky.nvim](https://github.com/gbprod/yanky.nvim) | Yank e put aprimorados com histórico |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Destacar e buscar TODO, FIXME, HACK, etc. |
| [outline.nvim](https://github.com/hedyhli/outline.nvim) | Barra lateral de outline do código |
| Rosapick (built-in) | Seletor visual de janelas com labels flutuantes |
| [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) | Navegação e redimensionamento inteligente de janelas |
| Rosamaximize (built-in) | Maximizador de janela — alterna entre maximizar a janela atual e restaurar o layout |
| Rosasave (built-in) | Salvamento automático de arquivos com debounce e toggle persistido |
| Rosasweep (built-in) | Fecha automaticamente buffers inativos após timeout configurável |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Emulador de terminal flutuante e em split |
| [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) | Integração com o file manager Yazi |

---

## Git

| Plugin | Descrição |
|:-------|:----------|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Indicadores de mudanças do git, staging, blame e navegação de hunks |

---

## IA

| Plugin | Descrição |
|:-------|:----------|
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | Integração com GitHub Copilot |
| [copilot-lualine](https://github.com/AndreM222/copilot-lualine) | Status do Copilot na statusline |
| [sidekick.nvim](https://github.com/atomicptr/sidekick.nvim) | Assistente de IA (Claude, Cursor, etc.) |

---

## Específicos por Linguagem

| Plugin | Descrição |
|:-------|:----------|
| Rosakit | Navegador de projeto nativo com detecção de stack e ferramentas LSP |
| [vim-blade](https://github.com/jwalton512/vim-blade) | Syntax highlighting para templates Blade |
| [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) | Suporte estendido a Java LSP (Eclipse JDT.LS) |
| [venv-selector.nvim](https://github.com/linux-cultivator/venv-selector.nvim) | Seletor de ambiente virtual Python |

---

## Banco de Dados

| Plugin | Descrição |
|:-------|:----------|
| [vim-dadbod](https://github.com/tpope/vim-dadbod) | Cliente de banco de dados — conecta a PostgreSQL, MySQL, SQLite e mais |
| [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | UI para vim-dadbod — navegar tabelas, executar queries |
| [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion) | Autocompleção para queries SQL |

---

## Notas & Escrita

| Plugin | Descrição |
|:-------|:----------|
| [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) | Integração com Obsidian vault — notas diárias, templates, backlinks, busca |

> **Configuração necessária:** Edite `plugins/editor/obsidian.lua` e altere o caminho do vault para o seu:
> ```lua
> -- Change this to your Obsidian vault path
> local vault_path = '~/Developer/second-brain'  -- padrão
> local vault_path = '~/Documents/meu-vault'     -- seu caminho
> ```

---

## Utilitários

| Plugin | Descrição |
|:-------|:----------|
| [discord.nvim](https://github.com/vyfor/cord.nvim) | Discord Rich Presence |
| [codesnap.nvim](https://github.com/mistricky/codesnap.nvim) | Screenshots bonitos de código |
| [logger.nvim](https://github.com/Tastyep/structlog.nvim) | Utilitário de debug logging |
| [neovim-project](https://github.com/coffebar/neovim-project) | Gerenciamento e descoberta de projetos |

> **Configuração necessária:** Edite `plugins/editor/projects.lua` e altere os diretórios para os seus:
> ```lua
> -- Change these to your own project directories
> projects = {
>   '~/Developer/Projects/Garage/*',    -- exemplo padrão
>   '~/Developer/Projects/Personal/*',
> }
> -- Altere para seus diretórios:
> projects = {
>   '~/projetos/*',
>   '~/trabalho/*',
> }
> ```
| [neovim-session-manager](https://github.com/Shatur/neovim-session-manager) | Persistência de sessão |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnósticos, referências e quickfix list em interface bonita |

# Guia de Customização

Rosavim foi feito para ser estendido. Este guia cobre temas, aparência e como fazer o Rosavim do seu jeito.

## Índice

- [Colorschemes](#colorschemes)
- [Modo Dark & Light](#modo-dark--light)
- [Transparência](#transparência)
- [Statusline](#statusline)
- [Dashboard](#dashboard)
- [Adicionando Plugins](#adicionando-plugins)
- [Sobrescrevendo Opções](#sobrescrevendo-opções)
- [Atalhos Customizados](#atalhos-customizados)
- [Snippets Customizados](#snippets-customizados)
- [Filetypes Customizados](#filetypes-customizados)

---

## Colorschemes

Rosavim vem com 7 colorschemes:

| Tema | Estilo | Descrição |
|:-----|:-------|:----------|
| **min-theme** | Minimal | Padrão — limpo e sem distrações |
| **Catppuccin** | Pastel | Paleta pastel suave com múltiplos sabores |
| **Gruvbox** | Retrô | Tons quentes e terrosos |
| **Kanagawa** | Japonês | Inspirado na pintura A Grande Onda |
| **Rosé Pine** | Suave | Vibes de Soho — suave e elegante |
| **Rusticated** | Quente | Visual rusticated customizado |
| **Vesper** | Escuro | Tema escuro customizado |

### Trocando Colorschemes

**Preview ao vivo:**
```
<leader>lqs → Abre o seletor de colorschemes com preview ao vivo
```

**Sua seleção é persistida automaticamente** — Rosavim salva sua escolha em cache e a restaura na próxima inicialização.

---

## Modo Dark & Light

Alterne entre fundos escuro e claro:

```
<leader>lqt → Alternar modo dark/light
```

O modo de fundo é salvo em cache — sua preferência é lembrada entre sessões.

A maioria dos colorschemes incluídos suporta variantes dark e light. A alternância muda a configuração `vim.o.background`, e o colorscheme ativo se adapta.

---

## Transparência

Ative um fundo transparente para deixar o wallpaper do terminal aparecer:

```
<leader>lqe → Alternar modo transparente
```

Quando ativado, Rosavim remove a cor de fundo dos grupos Normal, NormalFloat e outros, fazendo o editor se integrar com o terminal.

Esta configuração também é salva em cache entre sessões.

> Rosavim também persiste toggles de interface (statusline, indentação, spell, etc.) entre sessões. Veja o guia de **[Toggles](toggles.pt-br.md)** para detalhes.

---

## Statusline

Rosavim usa **lualine.nvim** com uma configuração customizada mostrando:

- **Indicador de modo** — modo Vim atual
- **Info do arquivo** — nome, status de modificação, flag de somente leitura
- **Info do Git** — nome da branch, contagem de adições/modificações/remoções (via gitsigns)
- **Diagnósticos** — contagem de erros/avisos/informações do LSP
- **Status LSP** — language servers ativos
- **Status Copilot** — estado do assistente de IA
- **Posição** — linha e coluna

### Alternar Statusline

```
<leader>ll → Mostrar/ocultar a statusline
```

### Customizando

Edite `lua/rosavim/plugins/ui/lualine/init.lua` para modificar seções, separadores ou adicionar seus próprios componentes.

---

## Dashboard

O dashboard do Rosavim (alimentado pelo snacks.nvim) aparece quando você abre o Neovim sem um arquivo. Ele mostra:

- Cabeçalho com ASCII art
- Menu de acesso rápido (Projetos, Arquivos, Recentes, etc.)
- Arquivos recentes

### Abrir Dashboard a Qualquer Momento

```
<leader>; → Retornar ao dashboard
```

---

## Adicionando Plugins

Rosavim usa Lazy.nvim. Para adicionar um novo plugin:

### 1. Criar um Plugin Spec

Crie um novo arquivo Lua no diretório apropriado de categoria de plugin:

```
lua/rosavim/plugins/
├── ai/          → Ferramentas de IA
├── coding/      → Edição de código
├── editor/      → Navegação, terminais, arquivos
├── env/         → LSP, formatters, linters, debug
├── language/    → Específicos por linguagem
├── test/        → Testes
└── ui/          → Visual e UI
```

Exemplo — adicionando um novo plugin (`lua/rosavim/plugins/editor/meu-plugin.lua`):

```lua
return {
  "autor/meu-plugin.nvim",
  event = "BufReadPost", -- lazy-load ao abrir arquivo
  opts = {
    -- opções do plugin
  },
  keys = {
    { "<leader>mp", "<cmd>MeuPluginComando<cr>", desc = "Meu Plugin" },
  },
}
```

### 2. Sincronizar

Reinicie o Neovim ou execute:
```
<leader>Ls → Lazy sync
```

### Estratégias de Carregamento

| Evento | Quando |
|:-------|:-------|
| `VeryLazy` | Após a UI ser carregada |
| `BufReadPost` | Quando um arquivo é aberto |
| `InsertEnter` | Ao entrar no modo de inserção |
| `CmdlineEnter` | Ao abrir a linha de comando |
| `ft = "python"` | Apenas para filetypes específicos |
| `keys = { ... }` | Apenas quando um atalho é pressionado |
| `cmd = "Comando"` | Apenas quando um comando é executado |

---

## Sobrescrevendo Opções

As opções do Neovim são definidas em `lua/rosavim/config/options.lua`. Configurações comuns que você pode querer alterar:

```lua
-- Largura do tab
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Números de linha
vim.opt.number = true
vim.opt.relativenumber = true

-- Offset de scroll
vim.opt.scrolloff = 8

-- Busca
vim.opt.ignorecase = true
vim.opt.smartcase = true
```

---

## Atalhos Customizados

Atalhos globais ficam em `lua/rosavim/config/keybinds.lua`. Para adicionar os seus:

```lua
vim.keymap.set("n", "<leader>xx", "<cmd>AlgumComando<cr>", {
  desc = "Descrição para o which-key",
  noremap = true,
  silent = true,
})
```

### Atalhos por Plugin

A maioria dos plugins define suas teclas no arquivo de spec usando a tabela `keys`. Isso também serve como gatilho de lazy-loading:

```lua
return {
  "plugin/nome",
  keys = {
    { "<leader>xx", "<cmd>ComandoPlugin<cr>", desc = "Fazer algo" },
    { "<leader>xy", function() require("plugin").acao() end, desc = "Outra ação" },
  },
}
```

---

## Snippets Customizados

Snippets customizados ficam em `lua/rosavim/config/snippets/`. Eles usam o formato LuaSnip:

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("python", {
  s("main", {
    t({ 'if __name__ == "__main__":', "    " }),
    i(1, "pass"),
  }),
})
```

---

## Filetypes Customizados

Regras de detecção de filetype estão em `lua/rosavim/config/filetypes.lua`. Regras customizadas atuais:

- Arquivos `.blade.php` → filetype `blade`
- Arquivos `.env*` → sintaxe `dosini`
- Arquivos HTML em projetos Django → filetype `htmldjango`

Para adicionar as suas:

```lua
vim.filetype.add({
  extension = {
    mdx = "markdown",
    astro = "astro",
  },
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
  },
  pattern = {
    [".*%.config/.*"] = "conf",
  },
})
```

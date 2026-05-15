# Guia de Customização

Rosavim foi feito para ser estendido. Este guia cobre temas, aparência e como fazer o Rosavim do seu jeito.

## Índice

- [Colorschemes](#colorschemes)
- [Modo Dark & Light](#modo-dark--light)
- [Transparência](#transparência)
- [Diretórios (Projects & Obsidian)](#diretórios-projects--obsidian)
- [Statusline](#statusline)
- [Dashboard](#dashboard)
- [Adicionando Plugins](#adicionando-plugins)
- [Sobrescrevendo Opções](#sobrescrevendo-opções)
- [Atalhos Customizados](#atalhos-customizados)
- [Snippets Customizados](#snippets-customizados)
- [Filetypes Customizados](#filetypes-customizados)

---

## Colorschemes

Rosavim vem com dois temas customizados embutidos, ambos totalmente integrados ao toggle dark/light, à transparência e aos overrides do Rosavim:

| Tema | Estilo | Descrição |
|:-----|:-------|:----------|
| **Rosamin** (padrão) | Minimal | Limpo e sem distrações, inspirado no min-theme |
| **Rosaesthetic** | Quente | Estética terrosa com tons quentes e ricos |

Os fontes ficam em `lua/rosavim/rosa_themes/` pra você ajustar as paletas diretamente. Outros colorschemes (qualquer um trazido pela LazyVim) ainda aparecem no picker, mas não compartilham os overrides do Rosavim.

### Trocando Colorschemes

**Preview ao vivo:**
```
<leader>lqs → Abre o seletor de colorschemes com preview ao vivo
```

**Sua seleção é persistida automaticamente.** Rosavim salva sua escolha em cache e a restaura na próxima inicialização.

---

## Modo Dark & Light

Alterne entre fundos escuro e claro:

```
<leader>lqt → Alternar modo dark/light
```

O modo de fundo é salvo em cache, sua preferência é lembrada entre sessões.

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

## Diretórios (Projects & Obsidian)

Diretórios de projetos e vaults do Obsidian são gerenciados dinamicamente pelo **Rosadirs**, um rosa_plugin embutido. Em vez de hardcodar caminhos em `projects.lua` ou `obsidian.lua`, você adiciona e remove em tempo de execução via um menu popup, e as escolhas são persistidas em disco.

### Abrindo o menu

```
<leader>lp → Rosadirs: Gerenciar Projects & Obsidian
```

O menu segue o mesmo estilo dos outros rosa_plugins (`<leader>xx`, `<leader>nn`, ...). Ele mostra os contadores atuais e deixa você:

| Tecla | Ação |
|:------|:-----|
| `a` | Adicionar diretório de projeto (suporta `~/caminho/*` pra cada subpasta como projeto) |
| `d` | Remover diretório de projeto (picker do Snacks listando todos) |
| `c` | Limpar todos os diretórios de projeto |
| `A` | Adicionar caminho de vault do Obsidian |
| `D` | Remover vault do Obsidian |
| `C` | Limpar todos os vaults do Obsidian |
| `X` | Limpar TUDO (projects + obsidian) |
| `q` / `<Esc>` | Fechar o menu |

### Como funciona

- A configuração fica em `~/.local/share/nvim/rosadirs/config.json`.
- `lua/rosavim/plugins/editor/projects.lua` lê `projects` do Rosadirs no load do plugin.
- `lua/rosavim/plugins/editor/obsidian.lua` lê `obsidian` e só carrega o plugin se houver pelo menos um vault configurado. Cada vault vira um workspace cujo nome é o basename da pasta.
- Os botões "Projects" e "Obsidian" do dashboard do Snacks lêem a mesma lista, então se nada estiver configurado eles avisam pra abrir `<leader>lp`.

### Aplicando mudanças

Rosadirs aplica as mudanças em tempo real sempre que possível:

- **Projects** — atualiza a config em memória do `neovim-project` imediatamente. O próximo `:NeovimProjectDiscover` (ou o botão "Projects" do dashboard) já mostra a nova lista, sem precisar reiniciar.
- **Obsidian** — se o `obsidian.nvim` já está carregado, o Rosadirs chama `Workspace.setup` com a nova lista e a sessão ativa se atualiza na hora. A exceção é o **primeiro** vault que você adiciona quando o Neovim iniciou sem nenhum configurado: o plugin foi pulado no startup (`cond = false`), então um restart é necessário pra carregar. A notificação te avisa quando esse for o caso.

### Sintaxe dos caminhos

Rosadirs guarda os caminhos exatamente como você digita. Pra fazer com que cada subpasta de uma pasta-pai vire um projeto separado (convenção de glob do `coffebar/neovim-project`), termine o caminho com `/*`:

```
~/Developer/Projects/*        → cada subpasta vira um projeto
~/Developer/Projects/Sandbox  → a pasta em si é um projeto único
```

Caminhos de vault do Obsidian precisam ser pastas literais (sem globs).

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

### Alternar Tema do Lualine

Alterne entre o tema default customizado e o tema `auto` do Lualine (que segue seu colorscheme):

```
<leader>lql → Alternar entre tema Default e Auto
```

Esta configuração é persistida entre sessões pelo sistema de toggles.

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

### Gif do Dashboard (chafa)

O dashboard pode renderizar uma imagem animada via `chafa`. **Vem desativado por padrão** — ative com `<leader>lqdt`. O gif ativo e suas dimensões são persistidos como toggles, então você pode trocar e redimensionar sem editar o `dashboard.lua`. As três ações fazem hot-reload — sem restart.

| Tecla | Ação |
|:------|:-----|
| `<leader>lqdt` | Liga/desliga o gif |
| `<leader>lqds` | Picker sobre `lua/rosavim/plugins/ui/dashboard_img/` — escolhe qualquer `.gif`, `.png`, `.jpg`, `.jpeg`, `.webp`, `.bmp` |
| `<leader>lqdc` | Popup mostrando height/width/indent atuais — escolhe `h`, `w` ou `i` pra editar só um |

Como o hot-reload funciona: a seção de terminal é definida como função, então é re-avaliada a cada render, e após cada mudança o Rosavim chama `Snacks.dashboard.update()`. O cache é desativado (`ttl = 0`) pra que mudanças de dimensão apareçam imediatamente.

Pra adicionar novas imagens, jogue os arquivos em `lua/rosavim/plugins/ui/dashboard_img/` e selecione com `<leader>lqds`. Cada gif pode ter height/width/indent ideais diferentes — ajuste com `<leader>lqdc` depois de trocar.

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

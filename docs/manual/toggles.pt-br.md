# Persistência de Toggles

Rosavim lembra o estado dos seus toggles de interface entre sessões. Quando você ativa ou desativa uma funcionalidade, ela permanece assim na próxima vez que abrir o Rosavim.

Todos os estados de toggle são armazenados em um único arquivo de cache em `~/.cache/nvim/rosavim-toggles`.

Todos os toggles utilizam `Snacks.toggle`, que oferece:

- **Notificações estilizadas** — popups bonitos do Snacks notifier ao alternar (Enabled/Disabled)
- **Ícones dinâmicos no which-key** — toggles mostram seu estado atual diretamente no which-key com ícones coloridos (verde = ativado, amarelo = desativado) e labels contextuais ("Enable X" / "Disable X")

As definições de toggles são organizadas em arquivos modulares em `lua/rosavim/plugins/ui/snacks/toggles/`:

| Módulo | Toggles |
|:-------|:--------|
| `options.lua` | Opções do Vim (wrap, número relativo, número de linha, indentação, dim, ortografia) |
| `plugins.lua` | Toggles de plugins (Rosasave, Incline, TSContext, Copilot, Dropbar) |
| `appearance.lua` | Toggles de tema (Dark/Light, Transparência, Lualine, Tema do Lualine) |
| `autocmds.lua` | Toggles de autocmd (Explorer, Editor, LSP, DBUI) |

O orquestrador em `lua/rosavim/plugins/ui/snacks/toggles.lua` carrega todos os módulos e restaura os estados persistidos.

---

## Toggles Persistidos

### Opções (`<leader>l`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lg` | Número Relativo | Ativado |
| `<leader>ln` | Números de Linha | Ativado |
| `<leader>lw` | Quebra de Linha | Desativado |
| `<leader>li` | Guia de Indentação | Desativado |
| `<leader>lk` | Dimming | Desativado |
| `<leader>ljj` | Verificação Ortográfica | Desativado |
| `<leader>ljp` / `<leader>lje` | Idioma Ortográfico (pt/en) | en |

### Aparência (`<leader>lq`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lqt` | Modo Claro (Dark/Light) | Dark |
| `<leader>lqe` | Transparência | Desativado |
| `<leader>lql` | Tema Custom do Lualine (Auto/Default) | Default |
| `<leader>ll` | Lualine (visibilidade da Statusline) | Ativado |

### Plugins (`<leader>l`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>ls` | Rosasave (Auto Save) | Desativado |
| `<leader>lt` | TSContext (Treesitter Context) | Desativado |
| `<leader>lc` | Incline (nome do arquivo flutuante) | Ativado |
| `<leader>lb` | Dropbar (breadcrumbs) | Desativado |

### IA (`<leader>ai`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>aii` | Copilot | Desativado |

> **Modo Zen** (`<leader>lz`) intencionalmente **não é** persistido, ele reseta a cada sessão.

---

## Toggles de Autocmd

Funcionalidades baseadas em autocmd também são persistidas e podem ser alternadas em runtime via `<leader>la`.

### Snacks (`<leader>las`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lase` | Abrir Explorer ao iniciar o Rosavim | Desativado |
| `<leader>lasf` | Focar no Explorer ao abrir (ou ficar no buffer) | Desativado |

### Editor (`<leader>lae`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>laec` | Restaurar cursor na última posição | Desativado |
| `<leader>laed` | Syntax highlight para arquivos .env | Ativado |
| `<leader>laeo` | Bloquear continuação automática de comentário | Ativado |
| `<leader>laes` | Salvar automático ao sair do foco/buffer | Ativado |

### LSP (`<leader>lal`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lalh` | Highlight bold branco nas referências LSP | Ativado |

### DBUI (`<leader>lad`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>ladf` | Expandir folds automático no resultado DBUI | Ativado |

---

## Como Funciona

O módulo de persistência fica em `lua/rosavim/config/toggles.lua`. Ele lê e escreve um arquivo JSON no diretório de cache do Rosavim. Cada toggle é salvo imediatamente ao ser alterado e restaurado automaticamente na inicialização.

Todos os keymaps de toggle são registrados via `Snacks.toggle():map()` nos arquivos modulares em `lua/rosavim/plugins/ui/snacks/toggles/`. Isso centraliza as definições de toggles e habilita a integração dinâmica com o which-key automaticamente.

Todas as notificações do Rosavim usam `Snacks.notify` para uma experiência de notificação consistente e estilizada.

---

## Resetando Toggles

Para resetar todos os toggles para os valores padrão, basta deletar o arquivo de cache:

```bash
rm ~/.cache/nvim/rosavim-toggles
```

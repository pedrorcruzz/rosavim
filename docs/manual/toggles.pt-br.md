# Persistência de Toggles

Rosavim lembra o estado dos seus toggles de interface entre sessões. Quando você ativa ou desativa uma funcionalidade, ela permanece assim na próxima vez que abrir o Neovim.

Todos os estados de toggle são armazenados em um único arquivo de cache em `~/.cache/nvim/rosavim-toggles`.

---

## Toggles Persistidos

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>ll` | Statusline (Lualine) | Ativado |
| `<leader>lb` | Dropbar (breadcrumbs) | Desativado |
| `<leader>ls` | Auto Save | Desativado |
| `<leader>lt` | Treesitter Context | Desativado |
| `<leader>ljj` | Verificação Ortográfica | Desativado |
| `<leader>ljp` / `<leader>lje` | Idioma Ortográfico (pt/en) | en |
| `<leader>lg` | Número Relativo | Ativado |
| `<leader>ln` | Números de Linha | Ativado |
| `<leader>li` | Guia de Indentação | Desativado |
| `<leader>lk` | Dimming | Desativado |
| `<leader>lw` | Quebra de Linha | Desativado |

> **Modo Zen** (`<leader>lz`) intencionalmente **não é** persistido, ele reseta a cada sessão.

---

## Como Funciona

O módulo de persistência fica em `lua/rosavim/config/toggles.lua`. Ele lê e escreve um arquivo JSON no diretório de cache do Neovim. Cada toggle é salvo imediatamente ao ser alterado e restaurado automaticamente na inicialização.

---

## Resetando Toggles

Para resetar todos os toggles para os valores padrão, basta deletar o arquivo de cache:

```bash
rm ~/.cache/nvim/rosavim-toggles
```

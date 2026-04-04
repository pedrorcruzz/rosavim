# Toggle Persistence

Rosavim remembers the state of your UI toggles across sessions. When you toggle a feature on or off, it stays that way the next time you open Rosavim.

All toggle states are stored in a single cache file at `~/.cache/nvim/rosavim-toggles`.

---

## Persisted Toggles

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>ll` | Statusline (Lualine) | On |
| `<leader>lb` | Dropbar (breadcrumbs) | Off |
| `<leader>ls` | Auto Save | Off |
| `<leader>lt` | Treesitter Context | Off |
| `<leader>ljj` | Spell Check | Off |
| `<leader>ljp` / `<leader>lje` | Spell Language (pt/en) | en |
| `<leader>lg` | Relative Number | On |
| `<leader>ln` | Line Numbers | On |
| `<leader>li` | Indent Guide | Off |
| `<leader>lk` | Dimming | Off |
| `<leader>lw` | Word Wrap | Off |
| `<leader>lql` | Lualine Theme (Auto/Default) | Default |

### AI (`<leader>ai`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>aii` | Copilot | Off |

> **Zen Mode** (`<leader>lz`) is intentionally **not** persisted, it resets on each session.

---

## Autocmd Toggles

Autocmd-based features are also persisted and can be toggled at runtime via `<leader>la`.

### Snacks (`<leader>las`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lase` | Open Explorer on Rosavim startup | Off |
| `<leader>lasf` | Focus Explorer on open (or stay on buffer) | Off |

### Editor (`<leader>lae`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>laec` | Restore cursor to last position | Off |
| `<leader>laed` | Syntax highlight for .env files | On |
| `<leader>laeo` | Block auto comment continuation on new lines | On |
| `<leader>laes` | Auto save on focus lost / buffer leave | On |

### LSP (`<leader>lal`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lalh` | Bold white highlight on LSP references | On |

### DBUI (`<leader>lad`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>ladf` | Auto expand folds in DBUI output | On |

---

## How It Works

The persistence module lives at `lua/rosavim/config/toggles.lua`. It reads and writes a JSON file to Rosavim's cache directory. Each toggle is saved immediately when changed, and restored automatically on startup.

---

## Resetting Toggles

To reset all toggles to their defaults, simply delete the cache file:

```bash
rm ~/.cache/nvim/rosavim-toggles
```

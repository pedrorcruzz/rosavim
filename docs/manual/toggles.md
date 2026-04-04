# Toggle Persistence

Rosavim remembers the state of your UI toggles across sessions. When you toggle a feature on or off, it stays that way the next time you open Neovim.

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

> **Zen Mode** (`<leader>lz`) is intentionally **not** persisted, it resets on each session.

---

## How It Works

The persistence module lives at `lua/rosavim/config/toggles.lua`. It reads and writes a JSON file to Neovim's cache directory. Each toggle is saved immediately when changed, and restored automatically on startup.

---

## Resetting Toggles

To reset all toggles to their defaults, simply delete the cache file:

```bash
rm ~/.cache/nvim/rosavim-toggles
```

# Toggle Persistence

Rosavim remembers the state of your UI toggles across sessions. When you toggle a feature on or off, it stays that way the next time you open Rosavim.

All toggle states are stored in a single cache file at `~/.cache/nvim/rosavim-toggles`.

All toggles are powered by `Snacks.toggle`, which provides:

- **Styled notifications** — beautiful Snacks notifier popups when toggling (Enabled/Disabled)
- **Dynamic which-key icons** — toggles show their current state directly in which-key with color-coded icons (green = enabled, yellow = disabled) and contextual labels ("Enable X" / "Disable X")

Toggle definitions are organized in modular files under `lua/rosavim/plugins/ui/snacks/toggles/`:

| Module | Toggles |
|:-------|:--------|
| `options.lua` | Vim options (wrap, relative number, line number, indent, dim, spell) |
| `plugins.lua` | Plugin toggles (Rosasave, Incline, TSContext, Copilot, Dropbar, Rosamaximize) |
| `appearance.lua` | Theme toggles (Dark/Light, Transparent, Lualine, Lualine Theme) |
| `autocmds.lua` | Tools toggles (Snacks, AI, Editor, LSP, DBUI) |

The orchestrator at `lua/rosavim/plugins/ui/snacks/toggles.lua` loads all modules and restores persisted states.

---

## Persisted Toggles

### Options (`<leader>l`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lg` | Relative Number | On |
| `<leader>ln` | Line Numbers | On |
| `<leader>lw` | Word Wrap | Off |
| `<leader>li` | Indent Guide | Off |
| `<leader>lk` | Dimming | Off |
| `<leader>ljj` | Spell Check | Off |
| `<leader>ljp` / `<leader>lje` | Spell Language (pt/en) | en |

### Appearance (`<leader>lq`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lqt` | Light Mode (Dark/Light) | Dark |
| `<leader>lqe` | Transparent | Off |
| `<leader>lql` | Lualine Custom Theme (Auto/Default) | Default |
| `<leader>ll` | Lualine (Statusline visibility) | On |

### Plugins (`<leader>l`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>ls` | Rosasave (Auto Save) | Off |
| `<leader>lt` | TSContext (Treesitter Context) | Off |
| `<leader>lc` | Incline (floating filename) | On |
| `<leader>lb` | Dropbar (breadcrumbs) | On |
| `<leader>cm` | Rosamaximize (maximize/restore window) | Off |

### AI (`<leader>ai`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>aii` | Copilot | Off |

> **Zen Mode** (`<leader>lz`) is intentionally **not** persisted, it resets on each session.

---

## Tools Toggles

Additional features are persisted and can be toggled at runtime via `<leader>la`.

### Snacks (`<leader>las`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lase` | Explorer Startup | Off |
| `<leader>lasf` | Explorer Focus | Off |
| `<leader>lasr` | Explorer Position (Left/Right) | Left |
| `<leader>lash` | Picker Hidden Files | Off |
| `<leader>lasi` | Picker Ignored Files | On |

### AI (`<leader>laa`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>laae` | Sidekick Position (Left/Right) | Right |

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

All toggle keymaps are registered via `Snacks.toggle():map()` in the modular files under `lua/rosavim/plugins/ui/snacks/toggles/`. This centralizes toggle definitions and enables the dynamic which-key integration automatically.

All notifications across Rosavim use `Snacks.notify` for a consistent, styled notification experience.

---

## Resetting Toggles

To reset all toggles to their defaults, simply delete the cache file:

```bash
rm ~/.cache/nvim/rosavim-toggles
```

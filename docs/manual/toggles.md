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
| `plugins.lua` | Plugin toggles (Rosasave, Incline, TSContext, Copilot, Bufferline, Dropbar, Markview, Rosamaximize, Image Preview) |
| `appearance.lua` | Theme toggles (Dark/Light, Transparent, Lualine, Lualine Theme) |
| `autocmds.lua` | Tools toggles (Snacks, Which-Key, AI, Editor, LSP, DBUI) |

The orchestrator at `lua/rosavim/plugins/ui/snacks/toggles.lua` loads all modules and restores persisted states.

---

## Persisted Toggles

### Options (`<leader>l`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lg` | Relative Number | On |
| `<leader>ln` | Line Numbers | On |
| `<leader>lw` | Word Wrap | Off |
| `<leader>li` | Indent Guide | On |
| `<leader>lk` | Dimming | Off |
| `<leader>ld` | Last Cursor Position | Off |
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
| `<leader>lb` | Bufferline (buffer tabs) | On |
| `<leader>lu` | Dropbar (breadcrumbs) | On |
| `<leader>uu` | Markview (enhanced markdown rendering) | On |
| `<leader>lm` | Image Preview (hover image preview) | Off |
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
| `<leader>lqp` | Picker Layout (popup selector) | default |
| `<leader>lasp` | Picker Preview | On |
| `<leader>lasb` | Picker Border (popup selector) | rounded |

Available picker layouts: `default`, `telescope`, `ivy`, `dropdown`, `vertical`, `vscode`

Available picker borders: `none`, `single`, `double`, `rounded`, `solid`, `shadow`

### Which-Key (`<leader>law`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lqw` | Which-Key Preset (popup selector) | modern |
| `<leader>lqb` | Which-Key Border (popup selector) | single |

Available which-key presets: `classic`, `modern`, `helix`

Available which-key borders: `none`, `single`, `double`, `shadow`

### RosaAI (`<leader>laa`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>laat` | Title chip (show/hide) | On |
| `<leader>laah` | Time in chip (show/hide) | On |
| `<leader>laai` | Auto Insert when opening a CLI | On |
| `<leader>laaf` | Auto Focus when sending a message | On |
| `<leader>lqa` | Theme picker (popup) — under Theme group | garland |
| `<leader>laap` | Position picker (popup) | right |
| `<leader>laaz` | Size picker (popup) | default |
| `<leader>laab` | Vertical border (right/left/float) | On |
| `<leader>laaB` | Horizontal border (bottom) | On |

Available RosaAI themes: `bloom`, `petal`, `garland`, `stem`

Available RosaAI positions: `right`, `left`, `bottom`, `float`

Available RosaAI sizes: `compact`, `default`, `wide`

### Editor (`<leader>lae`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>laed` | Syntax highlight for .env files | On |
| `<leader>laeo` | Block auto comment continuation on new lines | On |
| `<leader>laes` | Auto save on focus lost / buffer leave | On |

### LSP (`<leader>lal`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lalh` | Custom/default LSP reference highlights | On |
| `<leader>lalv` | Virtual Text (current line) | Off |

### DBUI (`<leader>lad`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>ladf` | Auto expand folds in DBUI output | On |

### Rosaterm (`<leader>lat`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>latt` | Title chip (show/hide) | On |
| `<leader>lath` | Time in chip (show/hide) | On |
| `<leader>lati` | Auto Insert when opening a terminal | On |
| `<leader>lqr` | Theme picker (popup) — under Theme group | garland |
| `<leader>latb` | Vertical border (vsplit becomes a pinned float) | Off |
| `<leader>latB` | Horizontal border (split becomes a pinned float) | Off |

Available rosaterm themes: `bloom`, `petal`, `garland`, `stem`

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

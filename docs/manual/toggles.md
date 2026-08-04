# Toggle Persistence

Rosavim remembers the state of your UI toggles across sessions. When you toggle a feature on or off, it stays that way the next time you open Rosavim.

All toggle states are stored in a single cache file at `~/.cache/nvim/rosavim-toggles`.

All toggles are powered by `Snacks.toggle`, which provides:

- **Styled notifications** — beautiful Snacks notifier popups when toggling (Enabled/Disabled)
- **Dynamic which-key icons** — toggles show their current state directly in which-key with color-coded icons (green = enabled, yellow = disabled) and contextual labels ("Enable X" / "Disable X")

Toggle definitions are organized in modular files under `lua/rosavim/plugins/ui/snacks/toggles/`:

| Module | Toggles |
|:-------|:--------|
| `options.lua` | Vim options (wrap, relative number, line number, indent, dim, spell, cursor shape, cursor line) |
| `plugins.lua` | Plugin toggles (Rosasave, Incline, TSContext, Copilot, Bufferline, Dropbar, Render Markdown, Rosamaximize, Image Preview) |
| `appearance.lua` | Theme toggles (Dark/Light, Transparent, Borderless, Lualine, Lualine Theme, Lualine Bar Y Transparent) |
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
| `<leader>ly` | Cursor Shape (block ↔ thin bar) | On (block) |
| `<leader>lY` | Cursor Line (current-line highlight) | On |
| `<leader>ld` | Last Cursor Position | Off |
| `<leader>ljj` | Spell Check | Off |
| `<leader>ljp` / `<leader>lje` | Spell Language (pt/en) | en |

`<leader>ly` is **On** by default (block cursor in normal mode, the Neovim native look). Turn it **off** to make the cursor a thin vertical bar (`ver25`) in every mode, so normal mode looks like insert. `<leader>lY` is **On** by default (the line the cursor sits on is highlighted); turn it off to remove that highlight.

### Appearance (`<leader>lq`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lqt` | Light Mode (Dark/Light) | Dark |
| `<leader>lqe` | Transparent | Off |
| `<leader>lql` | Lualine Custom Theme (Auto/Default) | Default |
| `<leader>lqg` | Lualine Separator (popup selector) | rounded |
| `<leader>lqy` | Lualine Bar Y Transparent (blend with theme bg vs solid `#1a1a1a`) | On |
| `<leader>lqs` | Theme picker (rosamin / rosavintage / rosanight) | rosamin |
| `<leader>lqn` | Borderless Theme — paint which-key / snacks picker / rosapick borders the same colour as their bg, in every theme | Off |
| `<leader>ll` | Lualine (Statusline visibility) | On |

Available lualine separators: `rounded`, `bar`, `arrow`, `slant`

### Force Dark BG (`<leader>lqf`)

Force-black background overrides for the yazi and lazygit floats (tools without their own Theme subgroup — RosaAI's live under `<leader>lqa`, Rosaterm's under `<leader>lqr`). Lowercase = light mode (default on), uppercase = dark mode (default off).

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lqfy` / `<leader>lqfY` | Yazi — force #000 in light / dark mode (else theme bg) | On / Off |
| `<leader>lqfg` / `<leader>lqfG` | Lazygit — force #000 in light / dark mode (else theme bg) | On / Off |

### Plugins (`<leader>l`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>ls` | Rosasave (Auto Save) | Off |
| `<leader>lt` | TSContext (Treesitter Context) | Off |
| `<leader>lc` | Incline (floating filename) | On |
| `<leader>lb` | Bufferline (buffer tabs) | On |
| `<leader>lu` | Dropbar (breadcrumbs) | On |
| `<leader>uu` | Render Markdown (enhanced markdown rendering) | On |
| `<leader>lqm` | Render Markdown theme (popup: none / lazy / obsidian) | none |
| `<leader>lm` | Image Preview (hover image preview) | Off |
| `<leader>cm` | Rosamaximize (maximize/restore window) | Off |

### Todo Comments (`<leader>lh` / `<leader>lqc`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lh` | Todo Comments plugin (on/off) | On |
| `<leader>lqcb` | Background highlight (colored chip) | On |
| `<leader>lqcf` | Foreground highlight (colored text) | Off |

`<leader>lh` disables the whole plugin (no highlights or signs). Background and foreground are mutually exclusive — enabling one turns the other off. With both off, keywords still work (jump `]t` / `[t`, search `<leader>ft*`) but show no colors.

### AI (`<leader>ai`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>aii` | Copilot | Off |

> **Rosazen** (`<leader>lz`) — the built-in distraction-free mode — **is** persisted: if it was active when you quit, it re-enters automatically on the next launch.

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
| `<leader>lqo` | Picker Border (popup selector) — under Theme group | rounded |

Available picker layouts: `default`, `telescope`, `ivy`, `dropdown`, `vertical`, `vscode`

Available picker borders: `none`, `single`, `double`, `rounded`, `solid`, `shadow`

### Which-Key (`<leader>lq`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lqw` | Which-Key Preset (popup selector) | modern |
| `<leader>lqb` | Which-Key Border (popup selector) | single |

Available which-key presets: `classic`, `modern`, `helix`

Available which-key borders: `none`, `single`, `double`, `shadow`

### RosaAI (`<leader>lqa`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lqat` | Title chip (show/hide) | On |
| `<leader>lqah` | Time in chip (show/hide) | On |
| `<leader>lqai` | Auto Insert when opening, focusing or sending to a CLI | On |
| `<leader>lqaf` | Auto Focus when sending a message | On |
| `<leader>lqar` | Auto Review — auto-open the review panel after the AI finishes editing files | Off |
| `<leader>lqas` | Theme picker (popup) | garland |
| `<leader>lqap` | Position picker (popup) | right |
| `<leader>lqaz` | Size picker (popup) | default |
| `<leader>lqab` | Vertical border (right/left/float) | On |
| `<leader>lqaB` | Horizontal border (bottom) | On |
| `<leader>lqad` / `<leader>lqaD` | Dark Background — force #000 in light / dark mode (else theme bg) | On / Off |

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

### Rosaterm (`<leader>lqr`)

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>lqrt` | Title chip (show/hide) | On |
| `<leader>lqrh` | Time in chip (show/hide) | On |
| `<leader>lqri` | Auto Insert when opening a terminal | On |
| `<leader>lqrn` | Display name: `Rosaterm` vs `Terminal` | Rosaterm |
| `<leader>lqrc` | Chip icon (show/hide) | On |
| `<leader>lqrC` | Chip icon style picker (Rosa / Terminal) | Terminal |
| `<leader>lqrz` | Size picker (compact / default / wide) | default |
| `<leader>lqrs` | Theme picker (popup) | garland |
| `<leader>lqrb` | Vertical border (vsplit becomes a pinned float) | Off |
| `<leader>lqrB` | Horizontal border (split becomes a pinned float) | Off |
| `<leader>lqrd` / `<leader>lqrD` | Dark Background — force #000 in light / dark mode (else theme bg) | On / Off |

Available rosaterm themes: `bloom`, `petal`, `garland`, `stem`

### Rosamaximize (`<leader>lam`)

When you maximize a window with `<leader>cm`, Rosamaximize shows a floating `max` badge in the top-right of the buffer and a matching `max` indicator on the lualine. This group controls how that indicator looks.

| Shortcut | Toggle | Default |
|:---------|:-------|:--------|
| `<leader>laml` | Lualine indicator (show/hide) | On |
| `<leader>lamb` | Buffer badge (show/hide) | On |
| `<leader>lamn` | Display: `max` text vs icon only | On (text) |
| `<leader>lqx` | Border picker (none / rounded / straight) — under Theme group | rounded |

Available rosamaximize borders: `none`, `rounded`, `single` (straight)

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

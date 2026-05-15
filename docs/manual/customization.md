# Customization Guide

Rosavim is designed to be extended. This guide covers themes, appearance, and how to make Rosavim your own.

## Table of Contents

- [Colorschemes](#colorschemes)
- [Dark & Light Mode](#dark--light-mode)
- [Transparency](#transparency)
- [Directories (Projects & Obsidian)](#directories-projects--obsidian)
- [Statusline](#statusline)
- [Dashboard](#dashboard)
- [Adding Plugins](#adding-plugins)
- [Overriding Options](#overriding-options)
- [Custom Keybindings](#custom-keybindings)
- [Custom Snippets](#custom-snippets)
- [Custom Filetypes](#custom-filetypes)

---

## Colorschemes

Rosavim ships with two custom built-in themes, both fully integrated with the dark/light toggle, transparency, and Rosavim's overrides:

| Theme | Style | Description |
|:------|:------|:------------|
| **Rosamin** (default) | Minimal | Clean, distraction-free, inspired by min-theme |
| **Rosaesthetic** | Warm | Earthy aesthetic with rich, warm tones |

Sources live in `lua/rosavim/rosa_themes/` so you can tweak palettes directly. Other colorschemes (anything provided by LazyVim) can still be picked from the picker, but they won't share Rosavim's overrides.

### Switching Colorschemes

**Live preview:**
```
<leader>lqs → Opens the colorscheme picker with live preview
```

**Your selection is persisted automatically.** Rosavim caches your choice and restores it on next launch.

---

## Dark & Light Mode

Toggle between dark and light backgrounds:

```
<leader>lqt → Toggle dark/light mode
```

The background mode is cached, your preference is remembered across sessions.

Most included colorschemes support both dark and light variants. The toggle switches the `vim.o.background` setting, and the active colorscheme adapts accordingly.

---

## Transparency

Enable a transparent background to let your terminal wallpaper show through:

```
<leader>lqe → Toggle transparent mode
```

When enabled, Rosavim removes the background color from the Normal, NormalFloat, and other highlight groups, making the editor blend with your terminal.

This setting is also cached across sessions.

> Rosavim also persists UI toggles (statusline, indent, spell, etc.) across sessions. See the **[Toggles](toggles.md)** guide for details.

---

## Directories (Projects & Obsidian)

Project directories and Obsidian vaults are managed dynamically through **Rosadirs**, a built-in rosa_plugin. Instead of hardcoding paths in `projects.lua` or `obsidian.lua`, you add and remove them at runtime through a popup menu, and the choices are persisted on disk.

### Opening the menu

```
<leader>lp → Rosadirs: Manage Projects & Obsidian
```

The menu mirrors the style of other rosa_plugins (`<leader>xx`, `<leader>nn`, ...). It shows the current counts and lets you:

| Key | Action |
|:----|:-------|
| `a` | Add project directory (supports `~/path/*` for subfolders as projects) |
| `d` | Remove project directory (Snacks picker over all entries) |
| `c` | Clear all project directories |
| `A` | Add Obsidian vault path |
| `D` | Remove Obsidian vault |
| `C` | Clear all Obsidian vaults |
| `X` | Clear EVERYTHING (projects + obsidian) |
| `q` / `<Esc>` | Close the menu |

### How it works

- The configuration lives at `~/.local/share/nvim/rosadirs/config.json`.
- `lua/rosavim/plugins/editor/projects.lua` reads `projects` from Rosadirs at plugin load.
- `lua/rosavim/plugins/editor/obsidian.lua` reads `obsidian` and only loads the plugin if at least one vault is configured. Each vault becomes a workspace whose name is the folder basename.
- The Snacks dashboard "Projects" and "Obsidian" buttons read the same list, so if you have nothing configured they tell you to open `<leader>lp`.

### Applying changes

Rosadirs applies changes live whenever it can:

- **Projects** — updates `neovim-project`'s in-memory config immediately. The next `:NeovimProjectDiscover` (or dashboard "Projects" button) shows the new list without a restart.
- **Obsidian** — if `obsidian.nvim` is already loaded, Rosadirs calls `Workspace.setup` with the new vault list so the active session updates on the spot. The exception is the **first** vault you add after starting Neovim with an empty config: the plugin was skipped at startup (`cond = false`), so a restart is required to load it. The notification tells you when that's the case.

### Project path syntax

Rosadirs stores paths exactly as you type them. To match every subfolder of a parent as a separate project (the `coffebar/neovim-project` glob convention), end the path with `/*`:

```
~/Developer/Projects/*        → every immediate subfolder is a project
~/Developer/Projects/Sandbox  → the folder itself is a single project
```

Obsidian vault paths must be literal directories (no globs).

---

## Statusline

Rosavim uses **lualine.nvim** with a custom configuration showing:

- **Mode indicator** — current Vim mode
- **File info** — filename, modification status, readonly flag
- **Git info** — branch name, added/modified/removed counts (via gitsigns)
- **Diagnostics** — error/warning/info counts from LSP
- **LSP status** — active language servers
- **Copilot status** — AI assistant state
- **Position** — line and column

### Toggle Statusline

```
<leader>ll → Show/hide the statusline
```

### Toggle Lualine Theme

Switch between the custom default theme and Lualine's `auto` theme (which follows your colorscheme):

```
<leader>lql → Toggle between Default and Auto theme
```

This setting is persisted across sessions via the toggles system.

### Customizing

Edit `lua/rosavim/plugins/ui/lualine/init.lua` to modify sections, separators, or add your own components.

---

## Dashboard

The Rosavim dashboard (powered by snacks.nvim) appears when you open Neovim without a file. It shows:

- ASCII art header
- Quick access menu (Projects, Files, Recent, etc.)
- Recent files

### Open Dashboard Anytime

```
<leader>; → Return to dashboard
```

### Dashboard Gif (chafa)

The dashboard can render an animated image via `chafa`. **It ships disabled by default** — toggle it on with `<leader>lqdt`. The active gif and its dimensions are persisted as toggles, so you can swap and resize without editing `dashboard.lua`. All three actions hot-reload — no restart required.

| Key | Action |
|:----|:-------|
| `<leader>lqdt` | Toggle the gif on/off |
| `<leader>lqds` | Picker over `lua/rosavim/plugins/ui/dashboard_img/` — choose any `.gif`, `.png`, `.jpg`, `.jpeg`, `.webp`, `.bmp` |
| `<leader>lqdc` | Popup showing the current height/width/indent — pick `h`, `w`, or `i` to edit just one |

How the hot-reload works: the terminal section is defined as a function so it's re-evaluated on every render, and after each change Rosavim calls `Snacks.dashboard.update()`. Cache is disabled (`ttl = 0`) so dimension changes show immediately.

Add new images by dropping files into `lua/rosavim/plugins/ui/dashboard_img/` and selecting them with `<leader>lqds`. Each gif may need its own height/width/indent — adjust with `<leader>lqdc` after switching.

---

## Adding Plugins

Rosavim uses Lazy.nvim. To add a new plugin:

### 1. Create a Plugin Spec

Create a new Lua file in the appropriate plugin category directory:

```
lua/rosavim/plugins/
├── ai/          → AI tools
├── coding/      → Code editing
├── editor/      → Navigation, terminals, files
├── env/         → LSP, formatters, linters, debug
├── language/    → Language-specific
├── test/        → Testing
└── ui/          → Visual and UI
```

Example — adding a new plugin (`lua/rosavim/plugins/editor/my-plugin.lua`):

```lua
return {
  "author/my-plugin.nvim",
  event = "BufReadPost", -- lazy-load on file open
  opts = {
    -- plugin options
  },
  keys = {
    { "<leader>mp", "<cmd>MyPluginCommand<cr>", desc = "My Plugin" },
  },
}
```

### 2. Sync

Restart Neovim or run:
```
<leader>Ls → Lazy sync
```

### Plugin Loading Strategies

| Event | When |
|:------|:-----|
| `VeryLazy` | After UI is loaded |
| `BufReadPost` | When a file is opened |
| `InsertEnter` | When entering insert mode |
| `CmdlineEnter` | When opening the command line |
| `ft = "python"` | Only for specific filetypes |
| `keys = { ... }` | Only when a keybinding is pressed |
| `cmd = "Command"` | Only when a command is run |

---

## Overriding Options

Neovim options are set in `lua/rosavim/config/options.lua`. Common settings you might want to change:

```lua
-- Tab width
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Scroll offset
vim.opt.scrolloff = 8

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
```

---

## Custom Keybindings

Global keybindings live in `lua/rosavim/config/keybinds.lua`. To add your own:

```lua
vim.keymap.set("n", "<leader>xx", "<cmd>SomeCommand<cr>", {
  desc = "Description for which-key",
  noremap = true,
  silent = true,
})
```

### Per-Plugin Keybindings

Most plugins define their keys in their spec file using the `keys` table. This also serves as a lazy-loading trigger:

```lua
return {
  "plugin/name",
  keys = {
    { "<leader>xx", "<cmd>PluginCmd<cr>", desc = "Do something" },
    { "<leader>xy", function() require("plugin").action() end, desc = "Another action" },
  },
}
```

---

## Custom Snippets

Custom snippets live in `lua/rosavim/config/snippets/`. They use the LuaSnip format:

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

## Custom Filetypes

Filetype detection rules are in `lua/rosavim/config/filetypes.lua`. Current custom rules:

- `.blade.php` files → `blade` filetype
- `.env*` files → `dosini` syntax
- HTML files in Django projects → `htmldjango` filetype

To add your own:

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

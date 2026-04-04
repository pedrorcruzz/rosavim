# Customization Guide

Rosavim is designed to be extended. This guide covers themes, appearance, and how to make Rosavim your own.

## Table of Contents

- [Colorschemes](#colorschemes)
- [Dark & Light Mode](#dark--light-mode)
- [Transparency](#transparency)
- [Statusline](#statusline)
- [Dashboard](#dashboard)
- [Adding Plugins](#adding-plugins)
- [Overriding Options](#overriding-options)
- [Custom Keybindings](#custom-keybindings)
- [Custom Snippets](#custom-snippets)
- [Custom Filetypes](#custom-filetypes)

---

## Colorschemes

Rosavim ships with 7 colorschemes:

| Theme | Style | Description |
|:------|:------|:------------|
| **min-theme** | Minimal | Default — clean and distraction-free |
| **Catppuccin** | Pastel | Soothing pastel palette with multiple flavors |
| **Gruvbox** | Retro | Warm, earthy tones |
| **Kanagawa** | Japanese | Inspired by the Great Wave painting |
| **Rose Pine** | Soft | Soho vibes — muted and elegant |
| **Rusticated** | Warm | Custom rusticated look |
| **Vesper** | Dark | Custom dark theme |

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

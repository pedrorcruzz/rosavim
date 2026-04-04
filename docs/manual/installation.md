# Installation

🇺🇸 **[English](#installation)** | 🇧🇷 **[Português](installation.pt-br.md)**

---

## Requirements

Before installing Rosavim, make sure you have these dependencies:

| Dependency | Version | How to install |
|:-----------|:--------|:---------------|
| **Neovim** | **>= 0.12** | `brew install neovim` / [neovim.io](https://neovim.io) |
| **Git** | >= 2.19 | `brew install git` / `sudo apt install git` |
| **Node.js** | >= 18 | `brew install node` / [nodejs.org](https://nodejs.org) |
| **Python** | >= 3.10 | `brew install python` / `sudo apt install python3` |
| **Nerd Font** | Any | [nerdfonts.com](https://www.nerdfonts.com/) |
| **ripgrep** | Any | `brew install ripgrep` / `sudo apt install ripgrep` |

### Recommended

These are optional but highly recommended for the full experience:

| Tool | What it does | How to install |
|:-----|:-------------|:---------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | Git UI in the terminal | `brew install lazygit` |
| [yazi](https://github.com/sxyazi/yazi) | Terminal file manager | `brew install yazi` |
| [chafa](https://hpjansson.org/chafa/) | Terminal image display (dashboard) | `brew install chafa` |

## Step 1: Back up your current config

If you already have a Neovim configuration, back it up first:

```bash
# Back up existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Also back up local data (optional, for a clean start)
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

## Step 2: Clone Rosavim

```bash
git clone https://github.com/pedrorcruzz/rosavim.git ~/.config/nvim
```

## Step 3: Launch Neovim

```bash
nvim
```

On the first launch:

1. **Lazy.nvim** will automatically bootstrap and install all plugins
2. **Mason** will install the configured LSP servers, formatters, linters, and debug adapters
3. **Treesitter** will download and compile language parsers

> This process may take a couple of minutes on the first run. Let it finish before closing Neovim.

## Step 4: Verify the installation

Inside Neovim, run:

```
:checkhealth
```

This will show you the status of all providers and dependencies. Fix any warnings or errors that appear.

You can also run Rosavim's own health check:

```
:checkhealth rosavim
```

## Updating

To update Rosavim, pull the latest changes:

```bash
cd ~/.config/nvim && git pull
```

Then open Neovim and sync plugins:

```
:Lazy sync
```

## Uninstalling

To completely remove Rosavim:

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

Then restore your backup if you have one:

```bash
mv ~/.config/nvim.bak ~/.config/nvim
```

## Troubleshooting

### Plugins fail to install

Make sure you have a working internet connection and Git is properly configured:

```bash
git --version
```

Try removing the plugin cache and reopening:

```bash
rm -rf ~/.local/share/nvim/lazy
nvim
```

### Mason tools fail to install

Some Mason packages require specific system dependencies. Check the Mason log:

```
:MasonLog
```

Common fixes:

- **npm packages**: Make sure `node` and `npm` are in your PATH
- **Python tools**: Make sure `python3` and `pip3` are available
- **Go tools**: Make sure `go` is installed and `GOPATH` is set

### Treesitter parsers fail to compile

Make sure you have a C compiler installed:

```bash
# macOS (should already have it)
xcode-select --install

# Linux
sudo apt install build-essential
```

### Icons not showing correctly

Install a [Nerd Font](https://www.nerdfonts.com/) and set it as your terminal font. Recommended: **JetBrains Mono Nerd Font** or **FiraCode Nerd Font**.

---

<div align="center">

[Back to README](../../README.md)

</div>

# Installation

🇺🇸 **[English](#installation)** | 🇧🇷 **[Português](installation.pt-br.md)**

---

## Requirements

Before installing Rosavim, make sure you have these dependencies:

| Dependency | Version | How to install |
|:-----------|:--------|:---------------|
| **Neovim** | **>= 0.12** | `brew install neovim` / [neovim.io](https://neovim.io) |
| **Lua** | >= 5.1 | `brew install lua` / `sudo apt install lua5.1` |
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

## Mason Dependencies (system runtimes)

Mason downloads LSP servers, formatters, linters, and debuggers — but it relies on **system runtimes** to install and run them. Without these, several packages will fail silently.

| Runtime | Needed for | Why |
|:--------|:-----------|:----|
| **Node.js + npm** | vtsls, tailwindcss, emmet-ls, intelephense, json-lsp, sqlls, prettierd, eslint_d, biome, sql-formatter, blade-formatter, php-debug-adapter | Most language servers and JS tools are npm packages |
| **Python 3 + pip** | pyright, autopep8, mypy, djlint, debugpy | Python tooling installs via pip |
| **Go** | gopls, goimports, go-debug-adapter | Built from source via `go install` |
| **Java (JDK 17+)** | jdtls, google-java-format, java-debug-adapter | Java tooling requires a JDK |
| **unzip / wget / curl** | Pre-built binaries (lua-language-server, stylua, etc.) | Used to download and extract releases |
| **C compiler** | Treesitter parsers, some native modules | Needed to compile parsers on first run |

### macOS

```bash
# Core (required by Rosavim itself)
brew install neovim git ripgrep

# Mason runtimes
brew install node python go openjdk
brew install wget unzip curl

# C compiler (if not already present)
xcode-select --install
```

### Linux — Debian / Ubuntu

```bash
sudo apt update
sudo apt install -y neovim git ripgrep
sudo apt install -y nodejs npm python3 python3-pip golang-go default-jdk
sudo apt install -y unzip wget curl build-essential
```

> If your distro's Node.js is too old (< 18), install via [nvm](https://github.com/nvm-sh/nvm) or [nodesource](https://github.com/nodesource/distributions).

### Linux — Arch / Manjaro

```bash
sudo pacman -S neovim git ripgrep
sudo pacman -S nodejs npm python python-pip go jdk-openjdk
sudo pacman -S unzip wget curl base-devel
```

### Linux — Fedora

```bash
sudo dnf install -y neovim git ripgrep
sudo dnf install -y nodejs npm python3 python3-pip golang java-latest-openjdk
sudo dnf install -y unzip wget curl
sudo dnf groupinstall -y "Development Tools"
```

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

### Mason did not auto-install the ensured tools

The configured LSP servers, formatters, linters, and debuggers are installed automatically on first launch via `mason-tool-installer.nvim`. If for some reason they did not install (closed Neovim too early, network failure, missing runtime), force a manual install:

```
:MasonToolsInstall
```

You can also open the Mason UI to inspect what is installed (`✓`), pending (`➜`), or missing (`✗`):

```
:Mason
```

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

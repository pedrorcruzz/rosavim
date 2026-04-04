# Instalacao

**[English](installation.md)** | **[Portugues](#instalacao)**

---

## Requisitos

Antes de instalar o Rosavim, certifique-se de ter estas dependencias:

| Dependencia | Versao | Como instalar |
|:------------|:-------|:--------------|
| **Neovim** | **>= 0.12** | `brew install neovim` / [neovim.io](https://neovim.io) |
| **Git** | >= 2.19 | `brew install git` / `sudo apt install git` |
| **Node.js** | >= 18 | `brew install node` / [nodejs.org](https://nodejs.org) |
| **Python** | >= 3.10 | `brew install python` / `sudo apt install python3` |
| **Nerd Font** | Qualquer | [nerdfonts.com](https://www.nerdfonts.com/) |
| **ripgrep** | Qualquer | `brew install ripgrep` / `sudo apt install ripgrep` |

### Recomendado

Opcionais, mas altamente recomendados para a experiencia completa:

| Ferramenta | O que faz | Como instalar |
|:-----------|:----------|:--------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | UI de Git no terminal | `brew install lazygit` |
| [yazi](https://github.com/sxyazi/yazi) | File manager no terminal | `brew install yazi` |
| [chafa](https://hpjansson.org/chafa/) | Imagens no terminal (dashboard) | `brew install chafa` |

## Passo 1: Faca backup da sua config atual

Se voce ja tem uma configuracao do Neovim, faca backup primeiro:

```bash
# Backup da config existente
mv ~/.config/nvim ~/.config/nvim.bak

# Backup dos dados locais tambem (opcional, para comecar do zero)
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

## Passo 2: Clone o Rosavim

```bash
git clone https://github.com/pedrorcruzz/rosavim.git ~/.config/nvim
```

## Passo 3: Abra o Neovim

```bash
nvim
```

Na primeira execucao:

1. O **Lazy.nvim** vai se instalar automaticamente e baixar todos os plugins
2. O **Mason** vai instalar os LSP servers, formatters, linters e adaptadores de debug configurados
3. O **Treesitter** vai baixar e compilar os parsers de linguagens

> Esse processo pode levar alguns minutos na primeira vez. Deixe terminar antes de fechar o Neovim.

## Passo 4: Verifique a instalacao

Dentro do Neovim, execute:

```
:checkhealth
```

Isso mostra o status de todos os providers e dependencias. Corrija qualquer warning ou erro.

Voce tambem pode rodar o health check do proprio Rosavim:

```
:checkhealth rosavim
```

## Atualizando

Para atualizar o Rosavim, puxe as ultimas mudancas:

```bash
cd ~/.config/nvim && git pull
```

Depois abra o Neovim e sincronize os plugins:

```
:Lazy sync
```

## Desinstalando

Para remover completamente o Rosavim:

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

Depois restaure seu backup se tiver um:

```bash
mv ~/.config/nvim.bak ~/.config/nvim
```

## Troubleshooting

### Plugins falham ao instalar

Certifique-se de que tem conexao com a internet e o Git esta configurado:

```bash
git --version
```

Tente remover o cache de plugins e reabrir:

```bash
rm -rf ~/.local/share/nvim/lazy
nvim
```

### Ferramentas do Mason falham ao instalar

Alguns pacotes do Mason precisam de dependencias do sistema. Verifique o log do Mason:

```
:MasonLog
```

Solucoes comuns:

- **Pacotes npm**: Certifique-se de que `node` e `npm` estao no seu PATH
- **Ferramentas Python**: Certifique-se de que `python3` e `pip3` estao disponiveis
- **Ferramentas Go**: Certifique-se de que `go` esta instalado e o `GOPATH` esta definido

### Parsers do Treesitter falham ao compilar

Certifique-se de ter um compilador C instalado:

```bash
# macOS (ja deve ter)
xcode-select --install

# Linux
sudo apt install build-essential
```

### Icones nao aparecem corretamente

Instale uma [Nerd Font](https://www.nerdfonts.com/) e defina como fonte do seu terminal. Recomendadas: **JetBrains Mono Nerd Font** ou **FiraCode Nerd Font**.

---

<div align="center">

[Voltar ao README](../../README.pt-br.md)

</div>

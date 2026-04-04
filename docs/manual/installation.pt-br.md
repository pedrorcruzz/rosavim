# Instalação

🇺🇸 **[English](installation.md)** | 🇧🇷 **[Português](#instalação)**

---

## Requisitos

Antes de instalar o Rosavim, certifique-se de ter estas dependências:

| Dependência | Versão | Como instalar |
|:------------|:-------|:--------------|
| **Neovim** | **>= 0.12** | `brew install neovim` / [neovim.io](https://neovim.io) |
| **Git** | >= 2.19 | `brew install git` / `sudo apt install git` |
| **Node.js** | >= 18 | `brew install node` / [nodejs.org](https://nodejs.org) |
| **Python** | >= 3.10 | `brew install python` / `sudo apt install python3` |
| **Nerd Font** | Qualquer | [nerdfonts.com](https://www.nerdfonts.com/) |
| **ripgrep** | Qualquer | `brew install ripgrep` / `sudo apt install ripgrep` |

### Recomendado

Opcionais, mas altamente recomendados para a experiência completa:

| Ferramenta | O que faz | Como instalar |
|:-----------|:----------|:--------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | UI de Git no terminal | `brew install lazygit` |
| [yazi](https://github.com/sxyazi/yazi) | File manager no terminal | `brew install yazi` |
| [chafa](https://hpjansson.org/chafa/) | Imagens no terminal (dashboard) | `brew install chafa` |

## Passo 1: Faça backup da sua config atual

Se você já tem uma configuração do Neovim, faça backup primeiro:

```bash
# Backup da config existente
mv ~/.config/nvim ~/.config/nvim.bak

# Backup dos dados locais também (opcional, para começar do zero)
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

Na primeira execução:

1. O **Lazy.nvim** vai se instalar automaticamente e baixar todos os plugins
2. O **Mason** vai instalar os LSP servers, formatters, linters e adaptadores de debug configurados
3. O **Treesitter** vai baixar e compilar os parsers de linguagens

> Esse processo pode levar alguns minutos na primeira vez. Deixe terminar antes de fechar o Neovim.

## Passo 4: Verifique a instalação

Dentro do Neovim, execute:

```
:checkhealth
```

Isso mostra o status de todos os providers e dependências. Corrija qualquer warning ou erro.

Você também pode rodar o health check do próprio Rosavim:

```
:checkhealth rosavim
```

## Atualizando

Para atualizar o Rosavim, puxe as últimas mudanças:

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

Certifique-se de que tem conexão com a internet e o Git está configurado:

```bash
git --version
```

Tente remover o cache de plugins e reabrir:

```bash
rm -rf ~/.local/share/nvim/lazy
nvim
```

### Ferramentas do Mason falham ao instalar

Alguns pacotes do Mason precisam de dependências do sistema. Verifique o log do Mason:

```
:MasonLog
```

Soluções comuns:

- **Pacotes npm**: Certifique-se de que `node` e `npm` estão no seu PATH
- **Ferramentas Python**: Certifique-se de que `python3` e `pip3` estão disponíveis
- **Ferramentas Go**: Certifique-se de que `go` está instalado e o `GOPATH` está definido

### Parsers do Treesitter falham ao compilar

Certifique-se de ter um compilador C instalado:

```bash
# macOS (já deve ter)
xcode-select --install

# Linux
sudo apt install build-essential
```

### Ícones não aparecem corretamente

Instale uma [Nerd Font](https://www.nerdfonts.com/) e defina como fonte do seu terminal. Recomendadas: **JetBrains Mono Nerd Font** ou **FiraCode Nerd Font**.

---

<div align="center">

[Voltar ao README](../../README.pt-br.md)

</div>

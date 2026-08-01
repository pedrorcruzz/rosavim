# Persistência de Toggles

Rosavim lembra o estado dos seus toggles de interface entre sessões. Quando você ativa ou desativa uma funcionalidade, ela permanece assim na próxima vez que abrir o Rosavim.

Todos os estados de toggle são armazenados em um único arquivo de cache em `~/.cache/nvim/rosavim-toggles`.

Todos os toggles utilizam `Snacks.toggle`, que oferece:

- **Notificações estilizadas** — popups bonitos do Snacks notifier ao alternar (Enabled/Disabled)
- **Ícones dinâmicos no which-key** — toggles mostram seu estado atual diretamente no which-key com ícones coloridos (verde = ativado, amarelo = desativado) e labels contextuais ("Enable X" / "Disable X")

As definições de toggles são organizadas em arquivos modulares em `lua/rosavim/plugins/ui/snacks/toggles/`:

| Módulo | Toggles |
|:-------|:--------|
| `options.lua` | Opções do Vim (wrap, número relativo, número de linha, indentação, dim, ortografia, formato do cursor, faixa da linha) |
| `plugins.lua` | Toggles de plugins (Rosasave, Incline, TSContext, Copilot, Bufferline, Dropbar, Render Markdown, Rosamaximize, Image Preview) |
| `appearance.lua` | Toggles de tema (Dark/Light, Transparência, Lualine, Tema do Lualine) |
| `autocmds.lua` | Tools toggles (Snacks, Which-Key, IA, Editor, LSP, DBUI) |

O orquestrador em `lua/rosavim/plugins/ui/snacks/toggles.lua` carrega todos os módulos e restaura os estados persistidos.

---

## Toggles Persistidos

### Opções (`<leader>l`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lg` | Número Relativo | Ativado |
| `<leader>ln` | Números de Linha | Ativado |
| `<leader>lw` | Quebra de Linha | Desativado |
| `<leader>li` | Guia de Indentação | Ativado |
| `<leader>lk` | Dimming | Desativado |
| `<leader>ly` | Formato do Cursor (bloco ↔ barra fina) | Ativado (bloco) |
| `<leader>lY` | Faixa da Linha (destaque da linha atual) | Ativado |
| `<leader>ld` | Last Cursor Position | Desativado |
| `<leader>ljj` | Verificação Ortográfica | Desativado |
| `<leader>ljp` / `<leader>lje` | Idioma Ortográfico (pt/en) | en |

O `<leader>ly` vem **ativado** por padrão (cursor em bloco no modo normal, o visual nativo do Neovim). **Desative** para deixar o cursor como uma barra vertical fina (`ver25`) em todos os modos, fazendo o normal parecer o insert. O `<leader>lY` vem **ativado** por padrão (a linha onde o cursor está fica destacada); desative para remover esse destaque.

### Aparência (`<leader>lq`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lqt` | Modo Claro (Dark/Light) | Dark |
| `<leader>lqe` | Transparência | Desativado |
| `<leader>lql` | Tema Custom do Lualine (Auto/Default) | Default |
| `<leader>lqg` | Separador do Lualine (seletor popup) | rounded |
| `<leader>lqs` | Picker de theme (rosamin / rosavintage) | rosamin |
| `<leader>ll` | Lualine (visibilidade da Statusline) | Ativado |

Separadores do Lualine disponíveis: `rounded`, `bar`, `arrow`, `slant`

### Plugins (`<leader>l`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>ls` | Rosasave (Auto Save) | Desativado |
| `<leader>lt` | TSContext (Treesitter Context) | Desativado |
| `<leader>lc` | Incline (nome do arquivo flutuante) | Ativado |
| `<leader>lb` | Bufferline (abas de buffers) | Ativado |
| `<leader>lu` | Dropbar (breadcrumbs) | Ativado |
| `<leader>uu` | Render Markdown (renderização aprimorada de markdown) | Ativado |
| `<leader>lqm` | Tema do Render Markdown (popup: none / lazy / obsidian) | none |
| `<leader>lm` | Image Preview (preview de imagem hover) | Desativado |
| `<leader>cm` | Rosamaximize (maximizar/restaurar janela) | Desativado |

### Todo Comments (`<leader>lh` / `<leader>lqc`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lh` | Plugin Todo Comments (ligar/desligar) | Ativado |
| `<leader>lqcb` | Destaque no fundo (chip colorido) | Ativado |
| `<leader>lqcf` | Destaque no texto (texto colorido) | Desativado |

`<leader>lh` desativa o plugin inteiro (sem destaques nem sinais). Fundo e texto são mutuamente exclusivos — ligar um desliga o outro. Com os dois desligados as keywords continuam funcionando (jump `]t` / `[t`, busca `<leader>ft*`) mas sem cores.

### IA (`<leader>ai`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>aii` | Copilot | Desativado |

> **Rosazen** (`<leader>lz`) — o modo sem distrações built-in — **é** persistido: se estava ativo quando você saiu, ele reativa automaticamente no próximo boot.

---

## Tools Toggles

Funcionalidades adicionais são persistidas e podem ser alternadas em runtime via `<leader>la`.

### Snacks (`<leader>las`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lase` | Explorer Startup | Desativado |
| `<leader>lasf` | Explorer Focus | Desativado |
| `<leader>lasr` | Explorer Position (Left/Right) | Left |
| `<leader>lash` | Picker Hidden Files | Desativado |
| `<leader>lasi` | Picker Ignored Files | Ativado |
| `<leader>lqp` | Picker Layout (seletor popup) | default |
| `<leader>lasp` | Picker Preview | Ativado |
| `<leader>lasb` | Picker Border (seletor popup) | rounded |

Layouts de picker disponíveis: `default`, `telescope`, `ivy`, `dropdown`, `vertical`, `vscode`

Bordas de picker disponíveis: `none`, `single`, `double`, `rounded`, `solid`, `shadow`

### Which-Key (`<leader>law`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lqw` | Which-Key Preset (seletor popup) | modern |
| `<leader>lqb` | Which-Key Border (seletor popup) | single |

Presets de which-key disponíveis: `classic`, `modern`, `helix`

Bordas de which-key disponíveis: `none`, `single`, `double`, `shadow`

### RosaAI (`<leader>laa`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>laat` | Chip de título (mostrar/esconder) | Ativado |
| `<leader>laah` | Relógio no chip (mostrar/esconder) | Ativado |
| `<leader>laai` | Auto Insert ao abrir, focar ou enviar para o CLI | Ativado |
| `<leader>laaf` | Auto Focus ao enviar mensagem | Ativado |
| `<leader>laar` | Auto Review — abre o painel de review automaticamente após a IA terminar de editar arquivos | Desativado |
| `<leader>lqa` | Picker de tema (popup) — fica no grupo Theme | garland |
| `<leader>laap` | Picker de posição (popup) | right |
| `<leader>laaz` | Picker de tamanho (popup) | default |
| `<leader>laab` | Borda vertical (right/left/float) | Ativado |
| `<leader>laaB` | Borda horizontal (bottom) | Ativado |
| `<leader>laad` | Fundo Escuro — força #000 no modo claro (senão bg do tema) | Desativado |

Temas RosaAI disponíveis: `bloom`, `petal`, `garland`, `stem`

Posições RosaAI disponíveis: `right`, `left`, `bottom`, `float`

Tamanhos RosaAI disponíveis: `compact`, `default`, `wide`

### Editor (`<leader>lae`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>laed` | Syntax highlight para arquivos .env | Ativado |
| `<leader>laeo` | Bloquear continuação automática de comentário | Ativado |
| `<leader>laes` | Salvar automático ao sair do foco/buffer | Ativado |

### LSP (`<leader>lal`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>lalh` | Highlights de referência LSP custom/padrão | Ativado |
| `<leader>lalv` | Virtual Text (linha atual) | Desativado |

### DBUI (`<leader>lad`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>ladf` | Expandir folds automático no resultado DBUI | Ativado |

### Rosaterm (`<leader>lat`)

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>latt` | Chip de título (mostrar/esconder) | Ativado |
| `<leader>lath` | Relógio no chip (mostrar/esconder) | Ativado |
| `<leader>lati` | Auto Insert ao abrir o terminal | Ativado |
| `<leader>latn` | Nome exibido: `Rosaterm` vs `Terminal` | Rosaterm |
| `<leader>latc` | Ícone do chip (mostrar/esconder) | Ativado |
| `<leader>lats` | Picker de estilo do ícone (Rosa / Terminal) | Terminal |
| `<leader>latz` | Picker de tamanho (compact / default / wide) | default |
| `<leader>lqr` | Picker de tema (popup) — fica no grupo Theme | garland |
| `<leader>latb` | Borda vertical (vsplit vira float pinado) | Desativado |
| `<leader>latB` | Borda horizontal (split vira float pinado) | Desativado |
| `<leader>latd` | Fundo Escuro — força #000 no modo claro (senão bg do tema) | Ativado |

Temas rosaterm disponíveis: `bloom`, `petal`, `garland`, `stem`

### Rosamaximize (`<leader>lam`)

Ao maximizar uma janela com `<leader>cm`, o Rosamaximize mostra um badge flutuante `max` no canto superior direito do buffer e um indicador `max` correspondente na lualine. Este grupo controla como esse indicador aparece.

| Atalho | Toggle | Padrão |
|:-------|:-------|:-------|
| `<leader>laml` | Indicador na lualine (mostrar/esconder) | Ativado |
| `<leader>lamb` | Badge no buffer (mostrar/esconder) | Ativado |
| `<leader>lamn` | Exibição: texto `max` vs só ícone | Ativado (texto) |
| `<leader>lams` | Picker de borda (none / rounded / reta) | rounded |

Bordas rosamaximize disponíveis: `none`, `rounded`, `single` (reta)

---

## Como Funciona

O módulo de persistência fica em `lua/rosavim/config/toggles.lua`. Ele lê e escreve um arquivo JSON no diretório de cache do Rosavim. Cada toggle é salvo imediatamente ao ser alterado e restaurado automaticamente na inicialização.

Todos os keymaps de toggle são registrados via `Snacks.toggle():map()` nos arquivos modulares em `lua/rosavim/plugins/ui/snacks/toggles/`. Isso centraliza as definições de toggles e habilita a integração dinâmica com o which-key automaticamente.

Todas as notificações do Rosavim usam `Snacks.notify` para uma experiência de notificação consistente e estilizada.

---

## Resetando Toggles

Para resetar todos os toggles para os valores padrão, basta deletar o arquivo de cache:

```bash
rm ~/.cache/nvim/rosavim-toggles
```

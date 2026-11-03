# Referência de Atalhos

> Leader key: `<Space>` | Modos: **n** = normal, **i** = inserção, **v** = visual, **x** = visual block, **t** = terminal, **o** = operator-pending, **c** = comando

## Índice

- [Essenciais](#essenciais)
- [Navegação de Arquivos & Projetos](#navegação-de-arquivos--projetos)
- [Busca & Pesquisa](#busca--pesquisa)
- [LSP](#lsp)
- [Gerenciamento de Janelas](#gerenciamento-de-janelas)
- [Abas & Buffers](#abas--buffers)
- [Git](#git)
- [Testes](#testes)
- [Debugging](#debugging)
- [Formatação & Code Actions](#formatação--code-actions)
- [Terminal](#terminal)
- [IA (Copilot & RosaAI)](#ia-copilot--rosaai)
- [Operações de Arquivo](#operações-de-arquivo)
- [Rosadirs (diretórios de Projects & Obsidian)](#rosadirs-diretórios-de-projects--obsidian)
- [Rosasnippets (Gerenciador de Snippets)](#rosasnippets-gerenciador-de-snippets)
- [Rosapoon (Favoritos)](#rosapoon-favoritos)
- [Flash (Movimentação)](#flash-movimentação)
- [Copiar & Colar (Yanky)](#copiar--colar-yanky)
- [UI & Aparência](#ui--aparência)
- [Diagnósticos (Trouble)](#diagnósticos-trouble)
- [Banco de Dados (Dadbod)](#banco-de-dados-dadbod)
- [Buscar & Substituir (GrugFar)](#buscar--substituir-grugfar)
- [Obsidian (Notas)](#obsidian-notas)
- [Rosakit](#rosakit)
- [Ortografia](#ortografia)
- [Lazy (Gerenciador de Plugins)](#lazy-gerenciador-de-plugins)
- [Diversos](#diversos)

---

## Essenciais

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| i | `kj` | Sair do modo de inserção | Digite `kj` rapidamente em vez de alcançar o `<Esc>` |
| n | `<BS>` | Alternar para último buffer | Pressione backspace para alternar entre os dois arquivos mais recentes |
| x | `<C-j>` | Mover seleção para baixo | Selecione linhas no modo visual, depois `Ctrl+j` para movê-las para baixo |
| x | `<C-k>` | Mover seleção para cima | Selecione linhas no modo visual, depois `Ctrl+k` para movê-las para cima |
| n | `<A-Down>` | Mover linha atual para baixo | Pressione `Alt+Down` para trocar a linha atual com a de baixo |
| n | `<leader>w` | Salvar arquivo | `Space w` para salvar rapidamente |
| n | `<leader>W` | Salvar sem formatar | `Space Shift+w` para salvar sem disparar o format-on-save |
| n | `<leader>h` | Limpar highlight de busca | `Space h` após uma busca para remover todos os destaques |
| n | `<leader>Q` | Sair | `Space Q` para fechar com confirmação |

---

## Navegação de Arquivos & Projetos

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>e` | File Explorer | `Space e` abre a árvore de arquivos lateral — navegue com `j/k`, abra com `<CR>` |
| n | `<leader>y` | Yazi file manager | `Space y` abre o Yazi em janela flutuante para gerenciamento completo de arquivos |
| n | `<leader><space>` | Buscar arquivos | `Space Space` depois digite parte do nome para busca fuzzy |
| n | `<leader>fs` | Busca inteligente | `Space f s` usa contexto inteligente para encontrar os arquivos mais relevantes |
| n | `<leader>ff` | Buscar arquivos | `Space f f` abre o seletor de arquivos |
| n | `<leader>fb` | Buscar buffers | `Space f b` para alternar entre buffers abertos |
| n | `<leader>fg` | Buscar arquivos git | `Space f g` para buscar apenas arquivos rastreados pelo git |
| n | `<leader>fr` | Arquivos recentes | `Space f r` para abrir arquivos editados recentemente |
| n | `<leader>fc` | Buscar arquivo de config | `Space f c` para ir rapidamente a um arquivo de configuração do Rosavim |
| n | `<leader>fp` | Descobrir projetos | `Space f p` para navegar e alternar entre projetos |
| n | `<leader>;` | Dashboard | `Space ;` retorna ao dashboard do Rosavim |

---

## Busca & Pesquisa

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>sg` | Grep | `Space s g` depois digite um padrão — busca em todos os arquivos do projeto |
| n | `<leader>sb` | Grep nos buffers | `Space s b` para buscar apenas nos buffers abertos |
| n,x | `<leader>sw` | Grep palavra | `Space s w` faz grep da palavra sob o cursor ou da seleção visual |
| n | `<leader>/` | Linhas do buffer | `Space /` para busca fuzzy dentro do buffer atual |
| n | `<leader>:` | Histórico de comandos | `Space :` para navegar e re-executar comandos anteriores |
| n | `<leader>s/` | Histórico de busca | `Space s /` para navegar padrões de busca anteriores |
| n | `<leader>sc` | Histórico de comandos | `Space s c` alternativa para acessar o histórico de comandos |
| n | `<leader>sC` | Comandos | `Space s Shift+c` para navegar todos os comandos disponíveis |
| n | `<leader>sd` | Diagnósticos | `Space s d` para buscar todos os diagnósticos do projeto |
| n | `<leader>sD` | Diagnósticos do buffer | `Space s Shift+d` para diagnósticos apenas do buffer atual |
| n | `<leader>sH` | Páginas de ajuda | `Space s Shift+h` para buscar na documentação de ajuda do Neovim |
| n | `<leader>sh` | Highlights | `Space s h` para navegar grupos de highlight |
| n | `<leader>si` | Ícones | `Space s i` para buscar e inserir ícones |
| n | `<leader>sj` | Jumps | `Space s j` para navegar a lista de saltos |
| n | `<leader>sk` | Keymaps | `Space s k` para buscar todos os atalhos |
| n | `<leader>sl` | Location list | `Space s l` para navegar a location list |
| n | `<leader>sm` | Marcas | `Space s m` para navegar marcas |
| n | `<leader>sM` | Man pages | `Space s Shift+m` para buscar man pages |
| n | `<leader>sp` | Plugin spec | `Space s p` para buscar specs de plugins do lazy.nvim |
| n | `<leader>sq` | Registradores | `Space s q` para navegar o conteúdo dos registradores |
| n | `<leader>sR` | Quickfix list | `Space s Shift+r` para navegar a quickfix list |
| n | `<leader>su` | Histórico de undo | `Space s u` para navegar e restaurar do histórico de undo |
| n | `<leader>sr` | Referências LSP | `Space s r` para listar todos os usos do símbolo sob o cursor (mesmo que `gr`) |
| n | `<leader>ss` | Símbolos LSP | `Space s s` para buscar símbolos no buffer atual |
| n | `<leader>sS` | Símbolos do workspace | `Space s Shift+s` para buscar símbolos em todo o workspace |

---

## LSP

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `gd` | Ir para definição | Em uma chamada de função, pressione `gd` para ir onde ela é definida |
| n | `gD` | Ir para declaração | Pressione `gD` para ir para a declaração do símbolo |
| n | `gr` | Referências | Em um nome de função, pressione `gr` para ver todos os usos no projeto (também `<leader>sr`) |
| n | `gI` | Ir para implementação | Em um método de interface, pressione `gI` para encontrar suas implementações |
| n | `gy` | Ir para definição de tipo | Pressione `gy` para ir para a definição de tipo do símbolo |
| n | `gp` | Rosapreview: Definição | Pressione `gp` para ver a definição em uma janela flutuante |
| n | `gP` | Rosapreview: Fechar Todos | Pressione `gP` para fechar todas as janelas de preview |
| n | `<leader>r` | Renomear símbolo | `Space r` em uma variável, digite o novo nome - renomeia em todo o projeto |
| n | `<leader>la` | Code action | `Space l a` para ver ações de código disponíveis (imports, correções, refatorações) |
| n | `<leader>R` | Renomear arquivo | `Space Shift+r` para renomear o arquivo atual e atualizar todos os imports |
| n | `<leader>Q` | Rosapreview: Expandir Vsplit | Abrir a definição do preview em um split vertical |
| n | `<leader>M` | Rosapreview: Substituir Janela | Abrir a definição do preview substituindo a janela atual |

---

## Gerenciamento de Janelas

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<C-h>` | Mover para split esquerdo | `Ctrl+h` para mover o foco para a janela à esquerda |
| n | `<C-j>` | Mover para split abaixo | `Ctrl+j` para mover o foco para a janela abaixo |
| n | `<C-k>` | Mover para split acima | `Ctrl+k` para mover o foco para a janela acima |
| n | `<C-l>` | Mover para split direito | `Ctrl+l` para mover o foco para a janela à direita |
| n | `<left>` | Redimensionar esquerda | Seta esquerda para diminuir/aumentar o split horizontalmente |
| n | `<down>` | Redimensionar abaixo | Seta para baixo para ajustar a altura do split |
| n | `<up>` | Redimensionar acima | Seta para cima para ajustar a altura do split |
| n | `<right>` | Redimensionar direita | Seta direita para diminuir/aumentar o split horizontalmente |
| n | `<leader>cq` | Split vertical | `Space c q` para criar um split vertical |
| n | `<leader>ce` | Split horizontal | `Space c e` para criar um split horizontal |
| n | `<leader>cc` | Fechar janela | `Space c c` para fechar a janela atual |
| n | `<leader>cC` | Fechar as outras do editor | `Space c Shift+c` para fechar as outras janelas do editor, sem mexer nas sidebars nem nos painéis |
| n | `<leader>C` | Fechar todo o resto | `Space Shift+c` para deixar só a janela focada - leva também os painéis Rosaterm e RosaAI, as outras sidebars e qualquer float perdido. O explorer do Snacks é a única exceção e continua aberto. Com o foco num painel, sobra um painel do editor (o Neovim sempre mantém uma janela nativa) |
| n | `<leader>ch` | Trocar esquerda | `Space c h` para trocar a janela atual para a esquerda. Com o foco num painel do Rosaterm, ele troca de lugar com o Rosaterm à esquerda e não mexe no layout do editor |
| n | `<leader>cl` | Trocar direita | `Space c l` para trocar a janela atual para a direita. Com o foco num painel do Rosaterm, ele troca de lugar com o Rosaterm à direita |
| n | `<leader>ck` | Trocar acima | `Space c k` para trocar a janela atual para cima. Com o foco num painel do Rosaterm, ele troca de lugar com o Rosaterm de cima |
| n | `<leader>cj` | Trocar abaixo | `Space c j` para trocar a janela atual para baixo. Com o foco num painel do Rosaterm, ele troca de lugar com o Rosaterm de baixo |
| n | `<leader>c1` | Redimensionar esq. 1/3 | Redimensionar a janela atual para ocupar 1/3 à esquerda |
| n | `<leader>c2` | Redimensionar dir. 2/3 | Redimensionar a janela atual para ocupar 2/3 à direita |
| n | `<leader>c3` | Redimensionar cima 1/3 | Redimensionar a janela atual para ocupar 1/3 de cima |
| n | `<leader>c4` | Redimensionar baixo 2/3 | Redimensionar a janela atual para ocupar 2/3 de baixo |
| n | `<leader>cr` | Resetar tamanhos | Resetar todas as janelas para tamanhos iguais |
| n | `<leader>1` | Focar janela esquerda | `Space 1` para ir para a janela da esquerda, incluindo um painel Rosaterm/RosaAI ancorado ali |
| n | `<leader>2` | Focar janela direita | `Space 2` para ir para a janela da direita, incluindo um painel Rosaterm/RosaAI ancorado ali |
| n | `<leader>3` | Focar janela inferior | `Space 3` para ir para a janela de baixo, incluindo um painel Rosaterm/RosaAI ancorado ali |
| n | `<leader>4` | Focar janela superior | `Space 4` para ir para a janela de cima, incluindo um painel Rosaterm/RosaAI ancorado ali |
| n | `<leader>cm` | Rosamaximize | `Space c m` para maximizar a janela atual ou restaurar o layout (mostra um badge `max` + indicador na lualine) |
| n | `<leader>m` | Escolher uma janela | `Space m` para escolher visualmente qual janela focar |
| n | `<leader>S` | Escolher uma janela | `Space S` faz o mesmo que `Space m`, alcançável só com a mão esquerda |

---

## Abas & Buffers

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>J` | Buffer anterior | `Space Shift+j` para ir ao buffer anterior |
| n | `<leader>K` | Próximo buffer | `Space Shift+k` para ir ao próximo buffer |
| n | `<leader>tt` | Nova aba | `Space t t` para criar uma nova aba |
| n | `<leader>tj` | Aba anterior | `Space t j` para ir à aba anterior |
| n | `<leader>tk` | Próxima aba | `Space t k` para ir à próxima aba |
| n | `<leader>tc` | Fechar aba | `Space t c` para fechar a aba atual |
| n | `<leader>tC` | Fechar outras abas | `Space t Shift+c` para fechar todas as abas exceto a atual |
| n | `<leader>t1`-`t0` | Ir para aba N | `Space t 1` até `t 0` para ir para a aba 1-10 |
| n | `<leader>tf` | Picker de abas (Snacks) | `Space t f` para abrir o picker de abas e trocar entre elas |
| n | `<leader>st` | Picker de abas (Snacks) | `Space s t` para abrir o picker de abas e trocar entre elas |
| n | `<leader>fw` | Picker de abas (Snacks) | `Space f w` para abrir o picker de abas e trocar entre elas |

### Bufferline

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>bb` | Pick buffer | `Space b b` para selecionar um buffer por letra |
| n | `<leader>bf` | Buscar buffers | `Space b f` para buscar entre buffers abertos |
| n | `<leader>bp` | Pick fechar buffer | `Space b p` para selecionar um buffer para fechar |
| n | `<leader>bh` | Fechar à esquerda | `Space b h` para fechar todos os buffers à esquerda |
| n | `<leader>bl` | Fechar à direita | `Space b l` para fechar todos os buffers à direita |
| n | `<leader>bC` | Fechar outros | `Space b Shift+c` para fechar todos os buffers exceto o atual |
| n | `<leader>bj` | Buffer anterior | `Space b j` para ir ao buffer anterior |
| n | `<leader>bk` | Próximo buffer | `Space b k` para ir ao próximo buffer |
| n | `<leader>bq` | Ordenar por diretório | `Space b q` para ordenar buffers por diretório |
| n | `<leader>be` | Ordenar por extensão | `Space b e` para ordenar buffers por extensão |
| n | `<leader>br` | Ordenar por dir relativo | `Space b r` para ordenar buffers por diretório relativo |
| n | `<leader>q` | Fechar janela | `Space q` fecha a janela atual (igual ao `Space c c`) |
| n | `<leader>lb` | Toggle bufferline | `Space l b` para mostrar/ocultar a barra de abas |

---

## Git

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>gt` | Alternar blame da linha | `Space g t` para mostrar/ocultar blame inline na linha atual |
| n | `<leader>gl` | Blame (flutuante) | `Space g l` para ver info de blame em uma janela flutuante |
| n | `<leader>gg` | Lazygit | `Space g g` para abrir o lazygit em um terminal flutuante |
| n | `<leader>gc` | Log do git | `Space g c` para navegar o log de commits |
| n | `<leader>gb` | Branches do git | `Space g b` para navegar e alternar entre branches |
| n | `<leader>gs` | Status do git | `Space g s` para ver o status atual do git |
| n | `<leader>gS` | Stash do git | `Space g Shift+s` para navegar as mudanças em stash |
| n | `<leader>gd` | Diff do git (hunks) | `Space g d` para navegar diff hunks |
| n | `<leader>gf` | Log do git (arquivo) | `Space g f` para ver o log do git para o arquivo atual |
| n | `<leader>gL` | Log do git (linha) | `Space g Shift+l` para ver o log do git para a linha atual |
| n | `<leader>gr` | Git Review | `Space g r` para abrir/alternar uma revisão keep/reject de **todas** as mudanças vs `HEAD` (mesmo painel do review da IA) |

---

## Testes

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>nn` | Menu Rosatest | `Space n n` com cursor dentro de uma função de teste para rodar apenas aquele teste |
| n | `<leader>nf` | Rodar testes do arquivo | `Space n f` para rodar todos os testes do arquivo atual |
| n | `<leader>nl` | Rodar último teste | `Space n l` para re-executar o último teste executado |
| n | `<leader>ns` | Parar testes | `Space n s` para parar testes em execução |
| n | `<leader>no` | Saída do teste | `Space n o` para ver a saída da última execução de teste |
| n | `<leader>np` | Painel de saída | `Space n p` para abrir o painel de saída dos testes |
| n | `<leader>nt` | Resumo dos testes | `Space n t` para alternar a barra lateral de resumo dos testes |
| n | `<leader>nw` | Observar arquivo | `Space n w` para observar o arquivo e re-executar testes ao salvar |
| n | `<leader>nga` | Go: Adicionar teste | `Space n g a` para gerar um teste para a função Go atual |
| n | `<leader>ngA` | Go: Adicionar todos os testes | `Space n g Shift+a` para gerar testes para todas as funções Go no arquivo |

---

## Debugging

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>ds` | Iniciar / Continuar | `Space d s` para iniciar o debugger ou continuar a execução |
| n | `<leader>dq` | Terminar | `Space d q` para parar a sessão de debug |
| n | `<leader>db` | Alternar breakpoint | `Space d b` em qualquer linha para definir/remover um breakpoint |
| n | `<leader>dc` | Limpar breakpoints | `Space d c` para remover todos os breakpoints |
| n | `<leader>dt` | Alternar DAP UI | `Space d t` para abrir/fechar os painéis de debug |
| n | `<leader>df` | DAP UI flutuante | `Space d f` para abrir a UI de debug em uma janela flutuante |
| n | `<leader>dd` | Step over | `Space d d` para executar a linha atual e mover para a próxima |
| n | `<leader>di` | Step into | `Space d i` para entrar na chamada de função |
| n | `<leader>do` | Step out | `Space d o` para sair da função atual |
| n | `<leader>dp` | Pausar | `Space d p` para pausar uma sessão de debug em execução |
| n | `<leader>dr` | Re-executar | `Space d r` para reiniciar a sessão de debug |
| n | `<leader>dR` | Reiniciar frame | `Space d Shift+r` para reiniciar o stack frame atual |
| n | `<leader>dn` | Nova sessão | `Space d n` para iniciar uma nova configuração de debug |
| n | `<leader>de` | Avaliar expressão | `Space d e` para avaliar uma expressão no contexto de debug |
| n | `<leader>dD` | Desconectar | `Space d Shift+d` para desconectar do debug adapter |

---

## Formatação & Code Actions

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,v | `<leader>lf` | Formatar arquivo/seleção | `Space l f` para formatar o arquivo atual — ou selecione linhas primeiro para formatar apenas aquelas |

---

## Terminal

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,t | `<C-\>` | Alternar terminal | `Ctrl+\` para abrir/fechar um terminal flutuante |
| n,t | `<S-x>` | Terminal horizontal | `Shift+x` para alternar um terminal em split horizontal |
| n,t | `<S-z>` | Terminal flutuante | `Shift+z` para alternar um terminal flutuante |
| n | `<leader>cii` | Split horizontal | `Space c i i` para abrir um terminal em split horizontal |
| n | `<leader>cie` | Split vertical | `Space c i e` para abrir um terminal em split vertical |

Com um painel Rosaterm focado, as setas redimensionam ele só no **modo normal** (painel vertical muda a largura, horizontal muda a altura, pares encaixados respondem às quatro setas). No modo terminal/inserção as setas ficam livres pro próprio shell, então `<up>` continua percorrendo o histórico de comandos. Aperte `<Esc>` pra cair no modo normal antes de redimensionar.

---

## IA (Copilot & RosaAI)

### Copilot

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| i | `<Tab>` | Aceitar sugestão | Enquanto digita, pressione `Tab` para aceitar a sugestão do Copilot |
| i | `<C-l>` | Próxima sugestão | `Ctrl+l` para ir para a próxima sugestão do Copilot |
| i | `<C-h>` | Sugestão anterior | `Ctrl+h` para ir para a sugestão anterior do Copilot |
| i | `<C-d>` | Dispensar sugestão | `Ctrl+d` para dispensar a sugestão atual do Copilot |
| n | `<leader>aia` | Auth | `Space a i a` para autenticar com o GitHub Copilot |
| n | `<leader>aii` | Alternar | `Space a i i` para alternar Copilot on/off (persistido) |
| n | `<leader>ail` | Ícone na lualine | `Space a i l` para mostrar/esconder o ícone do Copilot na statusline (persistido) |
| n | `<leader>aip` | Painel | `Space a i p` para abrir o painel de sugestões do Copilot |

### RosaAI

Integração nativa com CLIs de IA (Claude, Cursor, OpenClaude, OpenCode, Gemini etc.). Cada tool tem sua própria sessão persistente — trocar de tool ou de layout preserva o histórico. O popup de layout no `<leader>aa` só aparece na primeira vez; depois disso ele apenas alterna (toggle) o último layout.

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,t,i,x | `<C-.>` | Focar RosaAI | `Ctrl+.` para focar a janela do RosaAI |
| n | `<leader>aa` | Toggle CLI (smart) | Primeira vez pergunta layout `v/h/f`; depois alterna o último layout |
| x | `<leader>aa` | Ask AI (preview + prompt) | Selecione código, `Space a a` para abrir preview + caixa de prompt |
| n | `<leader>av` | Abrir Vertical | Abre (ou esconde se já estiver vertical) na borda oposta ao Snacks Explorer, dinamicamente |
| n | `<leader>ah` | Abrir Horizontal | Abre (ou esconde se já estiver horizontal) na borda inferior |
| n | `<leader>af` | Abrir Float | Abre (ou esconde se já estiver float) como janela flutuante central |
| n | `<leader>as` | Selecionar CLI | Escolhe entre os CLIs cujo binário está instalado |
| n,x | `<leader>at` | Enviar `{this}` | Envia referência do cursor (`@file:linha`) |
| n | `<leader>al` | Enviar `{file}` | Envia referência do arquivo inteiro (`@file`) |
| x | `<leader>av` | Enviar seleção | Envia o range visual (`@file:início-fim`) |
| n,x | `<leader>ap` | Selecionar prompt | Escolhe entre templates pré-definidos (explain / review / refactor / ...) |
| n | `<leader>ac` | Alternar Claude | Abrir/esconder Claude (`claude`) |
| n | `<leader>aC` | Alternar Claude YOLO | Abrir/esconder Claude com `--dangerously-skip-permissions` |
| n | `<leader>au` | Alternar Cursor | Abrir/esconder `cursor-agent` |
| n | `<leader>aU` | Alternar Cursor YOLO | Abrir/esconder `cursor-agent --yolo` |
| n | `<leader>ao` | Alternar OpenClaude | Abrir/esconder `openclaude` |
| n | `<leader>ae` | Alternar OpenCode | Abrir/esconder `opencode` |
| n | `<leader>ag` | Alternar Gemini | Abrir/esconder `gemini` |
| n | `<leader>ar` | Revisar Mudanças da IA | `Space a r` para abrir/alternar a revisão das edições **só da IA** (diffs inline verde/vermelho + painel de visão geral) |
| n | `<leader>ab` | Marcar Baseline do Review | `Space a b` para definir manualmente o ponto "antes" com que o review compara |
| n | `<leader>aR` | Review (chave mestra) | `Space a R` para ligar/desligar a feature de Review inteira - desligada, `<leader>ar` / `<leader>ab` somem e nenhum baseline é capturado (persistido) |
| n | `<leader>aA` | Auto Review | `Space a A` para abrir o painel de review automaticamente depois que a IA termina de editar arquivos (persistido, desligado por padrão) |

Dentro do terminal do CLI: um `<Esc>` sai pro modo normal do nvim; `<Esc> <Esc>` em 300ms envia ESC literal pro CLI (cancela operação corrente). No **modo normal**, as setas redimensionam a janela (vertical → largura, horizontal → altura, float → ambos os eixos, mantida centralizada); o tamanho persiste por posição até você escolher um preset de tamanho. No modo terminal/inserção as setas continuam livres pro próprio CLI. Com o RosaAI focado, o bloco de modo do lualine mostra `ROSAAI`.

#### Revisar Mudanças da IA

`<leader>ar` abre uma revisão estilo Cursor/VSCode das edições de arquivo que o RosaAI fez em disco, comparando com um snapshot de baseline capturado automaticamente quando você abriu o CLI. Ele mostra **só as mudanças da própria IA**: o resultado da IA é congelado no fim de cada turno, então edições que você faz depois ficam de fora do painel (o único caso ambíguo é uma edição sua exatamente em cima de um hunk da IA). As mudanças aparecem como diffs inline verde/vermelho, e um painel flutuante de visão geral lista cada arquivo alterado para você aceitar (keep) ou rejeitar (reject) cada hunk. O painel tem uma caixa de busca embutida pra filtrar a lista por fuzzy, um filtro `f` pra restringir por status do git, e um preview `p` que mostra o diff do arquivo num float do rosapreview ao lado do painel.

Quer revisar **tudo** no repositório (suas edições incluídas), não só as da IA? Use `<leader>gr` (**Git Review**) — o mesmo painel e as mesmas teclas, mas comparando contra o `HEAD`.

**No painel de visão geral (modo normal):**

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `j` / `k` (ou `↓`/`↑`) | Mover para baixo / cima | Navegar entre os arquivos listados |
| n | `a` / `i` / `/` | Buscar arquivos | Entra na caixa de busca e filtra a lista por fuzzy conforme você digita |
| n | `<CR>` | Ir para o hunk | Abrir o arquivo e saltar para a mudança sob o cursor |
| n | `e` | Aceitar arquivo | Aceitar todas as mudanças do arquivo selecionado |
| n | `r` | Rejeitar arquivo | Descartar todas as mudanças do arquivo selecionado |
| n | `p` | Preview | Abre o diff do arquivo selecionado num float do rosapreview ao lado do painel |
| n | `f` | Filtrar por status | Cicla a lista: all → added → modified (mostrado no título) |
| n | `A` | Aceitar tudo | Aceitar todas as mudanças pendentes de todos os arquivos |
| n | `R` | Rejeitar tudo | Descartar todas as mudanças pendentes de todos os arquivos |
| n | `q` / `<Esc>` | Fechar painel | Fechar o painel de visão geral |

**Na caixa de busca (modo insert):**

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| i | *(digitar)* | Filtrar | Filtra a lista por fuzzy ao vivo conforme você digita |
| i | `↓`/`↑`, `<C-j>`/`<C-k>`, `<C-n>`/`<C-p>` | Mover seleção | Move o arquivo destacado sem sair da caixa |
| i | `<CR>` | Ir para o arquivo | Salta para o arquivo selecionado |
| i | `<C-f>` | Filtrar por status | Cicla o filtro de status sem sair da caixa |
| i | `<Esc>` | Voltar pra lista | Volta pra lista em modo normal (mantém o filtro) |
| i | `<C-c>` | Fechar painel | Fecha o painel inteiro |

**Em um buffer sob revisão:**

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `]h` | Próximo hunk | Saltar para a próxima mudança da IA no arquivo |
| n | `[h` | Hunk anterior | Saltar para a mudança anterior da IA no arquivo |
| n | `<leader>ak` | Aceitar hunk | Aceitar a mudança sob o cursor |
| n | `<leader>ax` | Rejeitar hunk | Descartar a mudança sob o cursor |
| n | `<leader>aK` | Aceitar tudo | Aceitar todas as mudanças do arquivo |
| n | `<leader>aX` | Rejeitar tudo | Descartar todas as mudanças do arquivo |
| n | `<leader>ar` | Reabrir painel | Reabrir o painel flutuante de visão geral |

---

## Operações de Arquivo

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>xx` | Menu Rosafile | `Space x x` para abrir o popup de operações com arquivos |
| n | `<leader>xa` | Criar arquivo aqui | `Space x a` para criar um arquivo no diretório atual |
| n | `<leader>xd` | Deletar arquivo | `Space x d` para deletar o arquivo atual |
| n | `<leader>xn` | Renomear arquivo | `Space x n` para renomear o arquivo atual |
| n | `<leader>xc` | Duplicar arquivo | `Space x c` para duplicar o arquivo atual |
| n | `<leader>xi` | Info do arquivo | `Space x i` para ver informações do arquivo atual |
| n | `<leader>xr` | Criar da raiz | `Space x r` para criar um arquivo a partir da raiz do projeto |

---

## Rosadirs (diretórios de Projects & Obsidian)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>lp` | Menu Rosadirs | `Space l p` pra abrir o popup do gerenciador de diretórios |
| n (no menu) | `a` | Adicionar projeto | Digite o caminho (use `/*` pra subpastas como projetos) |
| n (no menu) | `d` | Remover projeto | Picker abre listando todos os projetos |
| n (no menu) | `c` | Limpar projetos | Confirma e remove todos os diretórios de projeto |
| n (no menu) | `A` | Adicionar vault do Obsidian | Digite o caminho do vault |
| n (no menu) | `D` | Remover vault do Obsidian | Picker abre listando todos os vaults |
| n (no menu) | `C` | Limpar vaults | Confirma e remove todos os vaults |
| n (no menu) | `X` | Limpar TUDO | Apaga as duas listas após confirmação |
| n (no menu) | `q` / `<Esc>` | Fechar | Fecha o menu |

> As mudanças entram em vigor na hora: projetos atualizam imediatamente, e o Obsidian re-executa `Workspace.setup` se já estiver carregado. Só o **primeiro** vault Obsidian adicionado na sessão exige restart (o plugin foi pulado no startup).

---

## Rosasnippets (Gerenciador de Snippets)

| Modo | Atalho | Ação | Exemplo |
|:----:|:-------|:-----|:--------|
| n | `<leader>lo` | Painel do Rosasnippets | `Space l o` abre o gerenciador (lista agrupada + barra de busca com filtro ao vivo) |
| n (painel) | `↵` | Editar corpo | Editor com syntax highlight e autosave — mudanças recarregam na hora no autocomplete |
| n (painel) | `a` | Adicionar snippet | Wizard em 4 etapas: filetype → atalho → descrição → preset inicial, terminando no editor de corpo |
| n (painel) | `e` | Editar atalho/descrição | Dois prompts pré-preenchidos (`Edit 1/2 · Trigger`, `Edit 2/2 · Description`), salvos a cada confirmação |
| n (painel) | `d` | Apagar snippet | Pede confirmação |
| n (painel) | `o` | Abrir arquivo JSON | Vai direto pro snippet dentro de `snippets/<filetype>.json` |
| n (painel) | `p` | Preview do arquivo | O Rosapreview doca ao lado do painel (volta ao centro ao fechar) |
| n (painel) | `f` | Filtrar por linguagem | Mini popup (mesmo estilo do seletor de tema); `none` limpa — o filtro ativo aparece no título |
| n (painel) | `t` | Presets | Salva o snippet selecionado como preset pessoal, ou navega por todos os presets |
| n (painel) | `/` ou `i` | Buscar | Filtro fuzzy ao vivo; `<C-j>`/`<C-k>` movem a seleção enquanto digita, `<Esc>` mantém o filtro |
| n (painel) | `q` / `<Esc>` | Fechar | Fecha o painel |
| i (editor de corpo) | `<C-t>` | Próximo tabstop | Insere o próximo `${N:}` numerado no cursor |
| n (navegador de presets) | `j`/`k` | Navegar | O preview read-only ao lado acompanha a seleção ao vivo |
| n (navegador de presets) | `e` / `r` / `d` | Editar corpo / renomear / apagar | Só nos presets pessoais (★) — os de fábrica são somente leitura |

> Os snippets são JSON no formato VSCode em `snippets/<filetype>.json`, expandidos pelo `vim.snippet` nativo (`<Tab>`/`<S-Tab>` pulam entre os placeholders com um snippet ativo). Presets pessoais ficam em `~/.config/rosasnippets/templates.json` — fora da config do Rosavim, então nunca vão junto com a distro. Toda mudança recarrega na hora no blink.cmp, sem reiniciar.

---

## Rosapoon (Favoritos)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>oo` | Pin | `Space o o` para fixar/desafixar o arquivo atual |
| n | `<leader>oe` | Menu | `Space o e` para gerenciar arquivos fixados (navegar, apagar, reordenar) |
| n | `dd` (no menu) | Remover pin | No menu do Rosapoon, `dd` em um tag para removê-lo |
| v | `d` (no menu) | Remover seleção | No menu do Rosapoon, selecione tags em visual mode e `d` para removê-los |
| n | `DD` (no menu) | Remover todos | No menu do Rosapoon, `DD` para remover todos os tags de uma vez |
| n | `<leader>o1`-`o0` | Jump 1-10 | `Space o 1` para ir instantaneamente ao seu primeiro arquivo fixado |
| n | `<leader>of` | Search | `Space o f` para busca fuzzy nos arquivos fixados |
| n | `<leader>oj` | Prev | `Space o j` para ir ao pin anterior |
| n | `<leader>ok` | Next | `Space o k` para ir ao próximo pin |

---

## Flash (Movimentação)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,x,o | `s` | Flash jump | Pressione `s` depois digite caracteres — labels aparecem para salto instantâneo |
| n,x,o | `S` | Flash treesitter | Pressione `Shift+s` para selecionar nós do treesitter com labels |
| o | `r` | Remote flash | No modo operator-pending, `r` para flash-jump a uma localização remota |
| o,x | `R` | Busca treesitter | `Shift+r` para buscar e selecionar nós do treesitter |
| c | `<C-s>` | Alternar flash na busca | `Ctrl+s` no modo de comando para alternar flash para buscas `/` |

---

## Copiar & Colar (Rosayank)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,x | `<leader>p` | Histórico de cópias | `Space p` para navegar e colar do histórico de cópias (persistido entre sessões) |
| n | `<leader>P` | Menu de cópias | `Space P` para abrir menu de cópias com entradas numeradas, `dd` remover, `DD` limpar tudo |

---

## UI & Aparência

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>lqt` | Alternar dark/light | `Space l q t` para alternar entre modo escuro e claro |
| n | `<leader>lqij` | Inverter BG: rosajet | `Space l q i j` troca o bg do editor do rosajet com o do explorer/tabs |
| n | `<leader>lqim` | Inverter BG: rosamin | `Space l q i m` mesma troca no rosamin |
| n | `<leader>lqiv` | Inverter BG: rosavintage | `Space l q i v` mesma troca no rosavintage |
| n | `<leader>lqs` | Selecionar theme | `Space l q s` para escolher um dos themes inclusos (rosamin / rosavintage / rosanight / rosajet) |
| n | `<leader>lqm` | Selecionar tema do Render Markdown | `Space l q m` para escolher o preset do render-markdown (none / lazy / obsidian) |
| n | `<leader>lqg` | Selecionar separador do lualine | `Space l q g` para escolher um preset de separador da statusline (rounded / bar / arrow / slant) |
| n | `<leader>lqe` | Alternar transparência | `Space l q e` para alternar a transparência do fundo |
| n | `<leader>lqna` | Sem Bordas: All | `Space l q n a` para fundir as bordas de todas as ferramentas no bg delas de uma vez (persiste) |
| n | `<leader>lqnw` | Sem Bordas: Which-Key | `Space l q n w` para fundir só a borda do which-key |
| n | `<leader>lqns` | Sem Bordas: Snacks Picker | `Space l q n s` para fundir as bordas do input, da lista, do preview e da caixa externa do snacks picker |
| n | `<leader>lqnp` | Sem Bordas: Rosapick | `Space l q n p` para fundir só a borda do label do rosapick |
| n | `<leader>lqnb` | Sem Bordas: Blink.cmp | `Space l q n b` para fundir as bordas do menu de completion, docs e signature |
| n | `<leader>lqnr` | Sem Bordas: Rosaterm | `Space l q n r` para fundir as bordas do float, do split e do chip do rosaterm |
| n | `<leader>lqni` | Sem Bordas: RosaAI | `Space l q n i` para fundir as bordas do painel, do chip e dos floats de ask/preview do RosaAI |
| n | `<leader>lqnn` | Sem Bordas: Notify | `Space l q n n` para fundir as bordas das notificações em todos os níveis |
| n | `<leader>lqfa` / `<leader>lqfA` | Forçar fundo escuro: Todos | `Space l q f a` (modo claro) / `Space l q f A` (modo escuro) pra virar o fundo #000 do rosaterm, rosaai, yazi e lazygit de uma vez; aparece como ativado só enquanto os quatro estiverem ativados (persiste) |
| n | `<leader>lqfr` / `<leader>lqfR` | Rosaterm forçar fundo escuro | `Space l q f r` (modo claro) / `Space l q f R` (modo escuro) para forçar fundo #000 no Rosaterm em vez do bg do tema (persiste) |
| n | `<leader>lqfi` / `<leader>lqfI` | RosaAI forçar fundo escuro | `Space l q f i` (modo claro) / `Space l q f I` (modo escuro) para forçar fundo #000 no painel do RosaAI em vez do bg do tema (persiste) |
| n | `<leader>lqfy` / `<leader>lqfY` | Yazi forçar fundo escuro | `Space l q f y` (modo claro) / `Space l q f Y` (modo escuro) para forçar fundo #000 no float do yazi em vez do bg do tema (persiste) |
| n | `<leader>lqfg` / `<leader>lqfG` | Lazygit forçar fundo escuro | `Space l q f g` (modo claro) / `Space l q f G` (modo escuro) para forçar fundo #000 no float do lazygit em vez do bg do tema (persiste) |
| n | `<leader>lqy` | Alternar transparência da barra-y do lualine | `Space l q y` — ativado (padrão) funde a barra central/y do lualine com o bg do tema; desativado mostra a barra sólida original `#1a1a1a` (funciona nos temas auto e custom do lualine) |
| n | `<leader>lqdt` | Liga/desliga gif do dashboard | `Space l q d t` pra ativar/desativar o gif chafa (persistido, hot-reload) |
| n | `<leader>lqds` | Buscar gif do dashboard | `Space l q d s` pra escolher uma imagem em `dashboard_img/` (persistido, hot-reload) |
| n | `<leader>lqdc` | Configurar gif do dashboard | `Space l q d c` abre popup — aperta `h`, `w` ou `i` pra editar só height/width/indent (persistido, hot-reload) |
| n | `<leader>lw` | Alternar wrap | `Space l w` para alternar quebra de linha |
| n | `<leader>lg` | Alternar números relativos | `Space l g` para alternar números de linha relativos |
| n | `<leader>ln` | Alternar números de linha | `Space l n` para ativar/desativar números de linha |
| n | `<leader>lz` | Alternar Rosazen | `Space l z` para alternar o Rosazen — modo sem distrações (maximiza + centraliza a janela, esconde a UI; persiste entre sessões) |
| n | `<leader>li` | Alternar guias de indentação | `Space l i` para alternar linhas guia de indentação |
| n | `<leader>lk` | Alternar dim | `Space l k` para escurecer código inativo |
| n | `<leader>ly` | Alternar formato do cursor | `Space l y` — ativado por padrão (cursor em bloco no modo normal); desative para uma barra vertical fina (`ver25`) em todos os modos |
| n | `<leader>lY` | Alternar faixa da linha | `Space l Y` para mostrar/ocultar o destaque da linha atual (ativado por padrão) |
| n | `<leader>ll` | Alternar lualine | `Space l l` para mostrar/ocultar a statusline |
| n | `<leader>lu` | Alternar dropbar | `Space l u` para mostrar/ocultar a barra de breadcrumb |
| v | `an` | Selecionar nó pai | No modo visual, expande a seleção para o nó pai do treesitter |
| v | `in` | Selecionar nó filho | No modo visual, reduz a seleção para um nó filho do treesitter |
| v | `]n` | Próximo nó irmão | No modo visual, move a seleção para o próximo nó irmão |
| v | `[n` | Nó irmão anterior | No modo visual, move a seleção para o nó irmão anterior |
| n | `<leader>lc` | Alternar Incline | `Space l c` para mostrar/ocultar o indicador flutuante de nome de arquivo |
| n | `<leader>ls` | Alternar auto-save | `Space l s` para ativar/desativar salvamento automático |
| n | `<leader>lm` | Toggle Image Preview | `Space l m` para alternar preview de imagem on/off (padrão: desativado) |
| n | `<leader>laml` | Indicador na lualine (Rosamaximize) | `Space l a m l` para mostrar/esconder o indicador `max` na lualine |
| n | `<leader>lamb` | Badge no buffer (Rosamaximize) | `Space l a m b` para mostrar/esconder o badge flutuante `max` no buffer |
| n | `<leader>lamn` | Nome/ícone (Rosamaximize) | `Space l a m n` para alternar entre o texto `max` e só o ícone |
| n | `<leader>lqx` | Borda (Rosamaximize) | `Space l q x` para abrir um popup e escolher a borda do badge (none / rounded / reta) |
| n | `<leader>lv` | Ligar/desligar o Rosatag | `Space l v` para ligar/desligar o plugin Rosatag inteiro (auto close + live rename, padrão: ligado) |
| n | `<leader>latc` | Auto close tag (Rosatag) | `Space l a t c` para ligar/desligar o fechamento automático de tags (padrão: ligado) |
| n | `<leader>latr` | Auto live rename tag (Rosatag) | `Space l a t r` para ligar/desligar a renomeação ao vivo da tag par (padrão: ligado) |
| n | `<leader>lqp` | Picker Layout | `Space l q p` para abrir popup de seleção de layout do picker |
| n | `<leader>lasp` | Picker Preview | `Space l a s p` para alternar preview do picker on/off |
| n | `<leader>lass` | Smooth Scrolling | `Space l a s s` para ligar/desligar a animação de scroll (padrão: ligado) |
| n | `<leader>lqo` | Picker Border | `Space l q o` para abrir popup de seleção de borda do picker |
| n | `<leader>lqw` | Which-Key Preset | `Space l q w` para abrir popup de seleção de preset do which-key |
| n | `<leader>lqb` | Which-Key Border | `Space l q b` para abrir popup de seleção de borda do which-key |
| n | `<leader>uu` | Alternar Render Markdown | `Space u t` para alternar renderização aprimorada de markdown |
| n | `<leader>ua` | Preview de markdown | `Space u a` para abrir preview de markdown no navegador |
| n | `<leader>zz` | Escolher símbolo da winbar | `Space z z` para escolher um símbolo da barra de breadcrumb |

---

## Diagnósticos (Trouble)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>,,` | Diagnósticos | `Space , ,` para abrir o painel de diagnósticos do projeto inteiro |
| n | `<leader>,x` | Diagnósticos do buffer | `Space , x` para ver diagnósticos apenas do buffer atual |
| n | `<leader>,s` | Símbolos | `Space , s` para navegar símbolos do documento no Trouble |
| n | `<leader>,l` | Referências LSP | `Space , l` para ver definições e referências LSP |
| n | `<leader>,g` | Location list | `Space , g` para navegar a location list |
| n | `<leader>,q` | Quickfix list | `Space , q` para navegar a quickfix list |

---

## Banco de Dados (Dadbod)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>vb` | Alternar DBUI | `Space v b` para abrir a UI do banco de dados |
| n | `<leader>va` | Adicionar conexão | `Space v a` para adicionar uma nova string de conexão |
| n | `<leader>vf` | Buscar buffer | `Space v f` para encontrar um buffer de query específico |

---

## Buscar & Substituir (GrugFar)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>lee` | GrugFar | `Space l e e` para abrir o painel de buscar & substituir |
| n | `<leader>lei` | GrugFar (arquivo atual) | `Space l e i` para buscar & substituir apenas no arquivo atual |
| v | `<leader>lev` | GrugFar (seleção) | Selecione texto, `Space l e v` para buscar & substituir a seleção |
| n | `<leader>lew` | GrugFar (palavra) | `Space l e w` para buscar & substituir a palavra sob o cursor |

---

## Todo Comments

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `]t` | Próximo todo | `]t` para ir ao próximo comentário TODO/FIXME/HACK |
| n | `[t` | Todo anterior | `[t` para ir ao comentário TODO anterior |
| n | `<leader>ftt` | Buscar todos os todos | `Space f t t` para buscar todos os comentários TODO no projeto |
| n | `<leader>ftf` | Buscar FIX | `Space f t f` para encontrar todos os comentários FIX/FIXME |
| n | `<leader>fte` | Buscar TODO | `Space f t e` para encontrar todos os comentários TODO |
| n | `<leader>ftn` | Buscar NOTE | `Space f t n` para encontrar todos os comentários NOTE |
| n | `<leader>fti` | Buscar INFO | `Space f t i` para encontrar todos os comentários INFO |
| n | `<leader>fth` | Buscar HACK | `Space f t h` para encontrar todos os comentários HACK |
| n | `<leader>ftw` | Buscar WARN | `Space f t w` para encontrar todos os comentários WARN |
| n | `<leader>lh` | Ligar/desligar plugin | `Space l h` para ativar/desativar o todo-comments por completo (persiste) |
| n | `<leader>lqcb` | Alternar fundo | `Space l q c b` para alternar o chip de fundo colorido (persiste) |
| n | `<leader>lqcf` | Alternar texto | `Space l q c f` para colorir o texto em vez do fundo (persiste) |

---

## CodeSnap (Screenshots)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| x | `<leader>lP` | Snap para clipboard | Selecione código, `Space l Shift+p` para copiar um screenshot para o clipboard |
| x | `<leader>lp` | Snap para arquivo | Selecione código, `Space l p` para salvar um screenshot |
| x | `<leader>lH` | Highlight para clipboard | Selecione código, `Space l Shift+h` para screenshot com destaque |
| x | `<leader>lh` | Highlight para arquivo | Selecione código, `Space l h` para salvar screenshot com destaque |
| x | `<leader>la` | ASCII snap | Selecione código, `Space l a` para screenshot em ASCII art |

---

## Obsidian (Notas)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>jj` | Buscar notas | `Space j j` para busca fuzzy em todas as notas do vault |
| n | `<leader>jo` | Abrir Obsidian | `Space j o` para abrir o app Obsidian |
| n | `<leader>jd` | Nota diária | `Space j d` para abrir/criar a nota diária de hoje |
| n | `<leader>jy` | Nota de ontem | `Space j y` para abrir a nota diária de ontem |
| n | `<leader>jt` | Nota de amanhã | `Space j t` para abrir a nota diária de amanhã |
| n | `<leader>jg` | Listar diárias | `Space j g` para navegar todas as notas diárias |
| n | `<leader>js` | Buscar (Obsidian) | `Space j s` para buscar notas usando a busca do Obsidian |
| n | `<leader>jr` | Renomear nota | `Space j r` para renomear a nota atual |
| n | `<leader>je` | Extrair nota | `Space j e` para extrair uma seção para uma nova nota |
| n | `<leader>jl` | Linkar nova nota | `Space j l` para criar e linkar uma nova nota |
| n | `<leader>ja` | A partir de template | `Space j a` para criar uma nota a partir de um template |
| n | `<leader>jz` | Nova nota | `Space j z` para criar uma nota em branco |
| n | `<leader>jb` | Backlinks | `Space j b` para ver todas as notas que linkam para esta |
| n | `<leader>jp` | Colar imagem | `Space j p` para colar uma imagem do clipboard |
| n | `<leader>jc` | Alternar checkbox | `Space j c` para alternar um checkbox em uma lista markdown |
| n | `<leader>jm` | Alternar checkbox (alt) | `Space j m` alternativa para alternar checkbox |

---

## Rosavisualmulti (Múltiplos cursores)

Os cursores ficam em extmarks, então acompanham qualquer edição. A sessão termina com `<Esc>` ou quando você troca de arquivo.

**Criando cursores**

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<C-n>` | Seleciona a palavra sob o cursor e depois cada ocorrência igual | `Ctrl n` em `pedro`, de novo para o próximo `pedro` |
| x | `<C-n>` | Um cursor por linha da seleção visual | `V j j` e `Ctrl n` para ficar com 3 cursores |
| n | `<C-Down>` / `<C-Up>` | Adiciona cursor na linha de baixo / de cima, mesma coluna | edição em coluna, ignora o texto |
| n | `<leader>kva` | Seleciona todas as ocorrências de uma vez | `Space k v a` |

**Gerenciando os cursores**

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `n` / `N` | Adiciona a próxima / anterior ocorrência | `N` também recupera uma ocorrência que você pulou |
| n | `q` | Pula: solta o cursor atual e pega a próxima ocorrência | mantém a quantidade de cursores |
| n | `Q` | Remove o cursor atual, sem repor | diminui a quantidade |
| n | `[` / `]` | Navega entre os cursores que você já tem | não mexe na lista |
| n | `<Esc>` | Encerra a sessão | |

**Editando em todos os cursores**

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `i` `a` `I` `A` | Insere antes / depois / no início / no fim da linha | o que você digita entra em todos os cursores quando aperta `<Esc>` |
| n | `c` | Troca a seleção | |
| n | `d` / `x` | Apaga a seleção | |
| n | `D` | Apaga as linhas inteiras | |
| n | `y` / `p` / `P` | Copia / cola por cima / cola antes | |
| n | `gu` / `gU` / `~` | Minúsculas / maiúsculas / inverte | |
| n | `.` | Roda um comando normal qualquer em todos os cursores | `ci"novo`, `>>`, `dt,`, `cit` |
| n | `@` | Roda um macro de um registrador em todos os cursores | |

**Menu e popups**

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>kvv` | Menu de ações. Os itens mudam conforme exista ou não uma sessão ativa | `Space k v v` |
| n | `<leader>kvr` | Popup de rename, já preenchido com a palavra selecionada | seleciona todos os `pedro`, reescreve uma vez, todos mudam |
| n | `<leader>kva` | Seleciona todas as ocorrências | |

Dentro do menu: `/` cursores por regex do vim, `.` comando normal, `@` macro, `l` alinha os cursores, `L` alinha num caractere, `s` surround, `#` numera os cursores, `r` rename.

Toda operação entra num único passo de undo. O bloco de modo do lualine mostra `ROSAVISUALMULTI` com a contagem viva de cursores enquanto a sessão está ativa.

---

## Rosakit

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>kk` | Menu Rosakit | `Space k k` para abrir o popup de ferramentas da linguagem |
| n | `<leader>ka` | LSP Actions | `Space k a` para abrir code actions do LSP |
| n | `<leader>kr` | Renomear tag (Rosatag) | `Space k r` para renomear a tag sob o cursor e o par dela. É buffer-local: só existe nos filetypes que o Rosatag atende, igual ao item dele no menu `<leader>kk` |

---

## Ortografia

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>ljj` | Alternar ortografia | `Space l j j` para ativar/desativar verificação ortográfica |
| n | `<leader>ljp` | Definir português | `Space l j p` para mudar a verificação ortográfica para português |
| n | `<leader>lje` | Definir inglês | `Space l j e` para mudar a verificação ortográfica para inglês |
| n | `<leader>ljl` | Sugestões ortográficas | `Space l j l` para ver sugestões ortográficas para a palavra sob o cursor |

---

## Lazy (Gerenciador de Plugins)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>Ll` | Lazy | `Space Shift+l l` para abrir a UI do gerenciador de plugins Lazy |
| n | `<leader>Lp` | Profile | `Space Shift+l p` para ver tempos de carregamento dos plugins |
| n | `<leader>Lh` | Health | `Space Shift+l h` para executar uma verificação de saúde |
| n | `<leader>LH` | Help | `Space Shift+l Shift+h` para abrir a ajuda do Lazy |
| n | `<leader>Lb` | Build | `Space Shift+l b` para reconstruir plugins |
| n | `<leader>Lc` | Clean | `Space Shift+l c` para remover plugins não utilizados |
| n | `<leader>LC` | Clear | `Space Shift+l Shift+c` para limpar o cache do Lazy |
| n | `<leader>Lu` | Update | `Space Shift+l u` para atualizar todos os plugins |
| n | `<leader>Ls` | Sync | `Space Shift+l s` para sincronizar todos os plugins |

---

## Diversos

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>lR` | Rosavim | `Space l Shift+r` para executar o comando Rosavim |
| n | `<leader>N` | Histórico de notificações | `Space Shift+n` para navegar notificações anteriores |
| n | `<leader>.` | Dispensar notificação | `Space .` para dispensar a notificação atual |
| n | `<leader>lxs` | Selecionar venv Python | `Space l x s` para escolher um ambiente virtual Python |

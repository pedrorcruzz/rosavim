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
- [Refatoração](#refatoração)
- [Terminal](#terminal)
- [IA (Copilot & Sidekick)](#ia-copilot--sidekick)
- [Operações de Arquivo](#operações-de-arquivo)
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
| n | `<leader>q` | Sair | `Space q` para fechar com confirmação |

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
| n | `<leader>ss` | Símbolos LSP | `Space s s` para buscar símbolos no buffer atual |
| n | `<leader>sS` | Símbolos do workspace | `Space s Shift+s` para buscar símbolos em todo o workspace |

---

## LSP

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `gd` | Ir para definição | Em uma chamada de função, pressione `gd` para ir onde ela é definida |
| n | `gD` | Ir para declaração | Pressione `gD` para ir para a declaração do símbolo |
| n | `gr` | Referências | Em um nome de função, pressione `gr` para ver todos os usos no projeto |
| n | `gI` | Ir para implementação | Em um método de interface, pressione `gI` para encontrar suas implementações |
| n | `gy` | Ir para definição de tipo | Pressione `gy` para ir para a definição de tipo do símbolo |
| n | `gp` | Rosapreview: Definição | Pressione `gp` para ver a definição em uma janela flutuante |
| n | `gP` | Rosapreview: Fechar Todos | Pressione `gP` para fechar todas as janelas de preview |
| n | `<leader>lr` | Renomear símbolo | `Space l r` em uma variável, digite o novo nome — renomeia em todo o projeto |
| n | `<leader>la` | Code action | `Space l a` para ver ações de código disponíveis (imports, correções, refatorações) |
| n | `<leader>lv` | Renomear arquivo | `Space l v` para renomear o arquivo atual e atualizar todos os imports |
| n | `<leader>lo` | Alternar outline | `Space l o` para abrir/fechar a barra lateral de outline do código |
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
| n | `<leader>cC` | Fechar todas as outras | `Space c Shift+c` para fechar todas as janelas exceto a atual |
| n | `<leader>ch` | Trocar esquerda | `Space c h` para trocar a janela atual para a esquerda |
| n | `<leader>cl` | Trocar direita | `Space c l` para trocar a janela atual para a direita |
| n | `<leader>ck` | Trocar acima | `Space c k` para trocar a janela atual para cima |
| n | `<leader>cj` | Trocar abaixo | `Space c j` para trocar a janela atual para baixo |
| n | `<leader>c1` | Redimensionar esq. 1/3 | Redimensionar a janela atual para ocupar 1/3 à esquerda |
| n | `<leader>c2` | Redimensionar dir. 2/3 | Redimensionar a janela atual para ocupar 2/3 à direita |
| n | `<leader>c3` | Redimensionar cima 1/3 | Redimensionar a janela atual para ocupar 1/3 de cima |
| n | `<leader>c4` | Redimensionar baixo 2/3 | Redimensionar a janela atual para ocupar 2/3 de baixo |
| n | `<leader>cr` | Resetar tamanhos | Resetar todas as janelas para tamanhos iguais |
| n | `<leader>1` | Focar janela esquerda | `Space 1` para ir para a janela da esquerda |
| n | `<leader>2` | Focar janela direita | `Space 2` para ir para a janela da direita |
| n | `<leader>3` | Focar janela inferior | `Space 3` para ir para a janela de baixo |
| n | `<leader>4` | Focar janela superior | `Space 4` para ir para a janela de cima |
| n | `<leader>m` | Escolher uma janela | `Space m` para escolher visualmente qual janela focar |

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

## Refatoração

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,x | `<leader>rr` | Selecionar refatoração | `Space r r` para abrir o menu de refatoração |
| v | `<leader>rs` | Refatorar (visual) | Selecione código, depois `Space r s` para escolher uma ação de refatoração |
| n,v | `<leader>ri` | Inline de variável | `Space r i` em uma variável para fazer inline do seu valor em todos os lugares |
| n | `<leader>rb` | Extrair bloco | `Space r b` para extrair o bloco atual para uma nova função |
| n | `<leader>rf` | Extrair bloco para arquivo | `Space r f` para extrair o bloco para um novo arquivo |
| v | `<leader>rf` | Extrair função | Selecione código, `Space r f` para extrair para uma nova função |
| v | `<leader>rF` | Extrair função para arquivo | Selecione código, `Space r Shift+f` para extrair para um novo arquivo |
| v | `<leader>rx` | Extrair variável | Selecione uma expressão, `Space r x` para extrair para uma variável |
| n | `<leader>rP` | Debug print | `Space r Shift+p` para inserir uma instrução de debug print |
| n,v | `<leader>rp` | Debug print variável | `Space r p` para imprimir o valor da variável sob o cursor |
| n | `<leader>rc` | Limpeza de debug | `Space r c` para remover todas as instruções de debug print |

---

## Terminal

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,t | `<C-\>` | Alternar terminal | `Ctrl+\` para abrir/fechar um terminal flutuante |
| n,t | `<S-x>` | Terminal horizontal | `Shift+x` para alternar um terminal em split horizontal |
| n,t | `<S-z>` | Terminal flutuante | `Shift+z` para alternar um terminal flutuante |
| n | `<leader>cii` | Split horizontal | `Space c i i` para abrir um terminal em split horizontal |
| n | `<leader>cie` | Split vertical | `Space c i e` para abrir um terminal em split vertical |

---

## IA (Copilot & Sidekick)

### Copilot

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| i | `<Tab>` | Aceitar sugestão | Enquanto digita, pressione `Tab` para aceitar a sugestão do Copilot |
| i | `<C-l>` | Próxima sugestão | `Ctrl+l` para ir para a próxima sugestão do Copilot |
| i | `<C-h>` | Sugestão anterior | `Ctrl+h` para ir para a sugestão anterior do Copilot |
| i | `<C-d>` | Dispensar sugestão | `Ctrl+d` para dispensar a sugestão atual do Copilot |
| n | `<leader>aia` | Auth | `Space a i a` para autenticar com o GitHub Copilot |
| n | `<leader>aii` | Alternar | `Space a i i` para alternar Copilot on/off (persistido) |
| n | `<leader>aip` | Painel | `Space a i p` para abrir o painel de sugestões do Copilot |

### Sidekick

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,t,i,x | `<C-.>` | Focar Sidekick | `Ctrl+.` para focar a janela de chat do Sidekick |
| n | `<leader>aa` | Alternar CLI | `Space a a` para alternar o CLI do Sidekick |
| n | `<leader>as` | Selecionar CLI | `Space a s` para selecionar qual backend de CLI usar |
| n | `<leader>ad` | Desconectar sessão | `Space a d` para fechar a sessão CLI atual |
| n,x | `<leader>at` | Enviar contexto | `Space a t` para enviar o contexto atual para o Sidekick |
| n | `<leader>af` | Enviar arquivo | `Space a f` para enviar o arquivo inteiro para o Sidekick |
| x | `<leader>av` | Enviar seleção | Selecione código, `Space a v` para enviar para o Sidekick |
| n,x | `<leader>ap` | Selecionar prompt | `Space a p` para escolher entre prompts salvos |
| n | `<leader>ac` | Alternar Claude | `Space a c` para usar o Claude como backend do Sidekick |
| n | `<leader>ag` | Alternar Cursor | `Space a g` para usar o Cursor como backend do Sidekick |

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

## Copiar & Colar (Yanky)

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n,x | `<leader>p` | Histórico de cópias | `Space p` para navegar e colar do histórico de cópias |
| n,x | `y` | Copiar | Funciona como `y` normal mas salva no histórico do Yanky |
| n,x | `p` | Colar depois | Colar após o cursor com rastreamento do Yanky |
| n,x | `P` | Colar antes | Colar antes do cursor com rastreamento do Yanky |
| n | `[y` | Ciclo para frente | Após colar, `[y` para navegar por cópias mais antigas |
| n | `]y` | Ciclo para trás | Após colar, `]y` para navegar por cópias mais recentes |
| n | `]p` | Colar indentado depois | Colar depois com indentação automática |
| n | `[p` | Colar indentado antes | Colar antes com indentação automática |
| n | `>p` | Colar e indentar direita | Colar e deslocar para direita |
| n | `<p` | Colar e indentar esquerda | Colar e deslocar para esquerda |
| n | `=p` | Colar filtrado depois | Colar depois aplicando um filtro |
| n | `=P` | Colar filtrado antes | Colar antes aplicando um filtro |

---

## UI & Aparência

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>lqt` | Alternar dark/light | `Space l q t` para alternar entre modo escuro e claro |
| n | `<leader>lqs` | Buscar colorscheme | `Space l q s` para escolher um colorscheme da lista |
| n | `<leader>lqe` | Alternar transparência | `Space l q e` para alternar a transparência do fundo |
| n | `<leader>lw` | Alternar wrap | `Space l w` para alternar quebra de linha |
| n | `<leader>lg` | Alternar números relativos | `Space l g` para alternar números de linha relativos |
| n | `<leader>ln` | Alternar números de linha | `Space l n` para ativar/desativar números de linha |
| n | `<leader>lz` | Alternar modo zen | `Space l z` para entrar no modo zen sem distrações |
| n | `<leader>li` | Alternar guias de indentação | `Space l i` para alternar linhas guia de indentação |
| n | `<leader>lk` | Alternar dim | `Space l k` para escurecer código inativo |
| n | `<leader>ll` | Alternar lualine | `Space l l` para mostrar/ocultar a statusline |
| n | `<leader>lb` | Alternar dropbar | `Space l b` para mostrar/ocultar a barra de breadcrumb |
| n | `<leader>lt` | Alternar TSContext | `Space l t` para mostrar/ocultar o cabeçalho de contexto do treesitter |
| n | `<leader>lc` | Alternar Incline | `Space l c` para mostrar/ocultar o indicador flutuante de nome de arquivo |
| n | `<leader>ls` | Alternar auto-save | `Space l s` para ativar/desativar salvamento automático |
| n | `<leader>lm` | Preview de imagem | `Space l m` para visualizar uma imagem em uma janela flutuante |
| n | `<leader>ut` | Alternar Markview | `Space u t` para alternar renderização aprimorada de markdown |
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

## Rosakit

| Modo | Tecla | Ação | Exemplo |
|:----:|:------|:-----|:--------|
| n | `<leader>kk` | Menu Rosakit | `Space k k` para abrir o popup de ferramentas da linguagem |
| n | `<leader>ka` | LSP Actions | `Space k a` para abrir code actions do LSP |

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
| n | `<leader>R` | Rosavim | `Space Shift+r` para executar o comando Rosavim |
| n | `<leader>N` | Histórico de notificações | `Space Shift+n` para navegar notificações anteriores |
| n | `<leader>.` | Dispensar notificação | `Space .` para dispensar a notificação atual |
| n | `<leader>lxs` | Selecionar venv Python | `Space l x s` para escolher um ambiente virtual Python |

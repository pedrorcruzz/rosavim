# Guia de Debugging

Rosavim inclui suporte completo a debugging via **Debug Adapter Protocol (DAP)**. Este guia cobre a configuração e o uso para cada linguagem suportada.

## Índice

- [Início Rápido](#início-rápido)
- [Atalhos](#atalhos)
- [Visão Geral da DAP UI](#visão-geral-da-dap-ui)
- [Python](#python)
- [Go](#go)
- [PHP](#php)
- [Java](#java)
- [Adicionando Novos Adaptadores de Debug](#adicionando-novos-adaptadores-de-debug)

---

## Início Rápido

1. Abra um arquivo em uma linguagem suportada
2. Coloque um breakpoint com `<leader>db`
3. Inicie o debugger com `<leader>ds`
4. Selecione uma configuração de debug quando solicitado
5. Use os controles de step para navegar pelo seu código

---

## Atalhos

| Tecla | Ação |
|:------|:-----|
| `<leader>ds` | Iniciar / Continuar |
| `<leader>dq` | Terminar sessão |
| `<leader>db` | Alternar breakpoint na linha atual |
| `<leader>dc` | Limpar todos os breakpoints |
| `<leader>dt` | Alternar a DAP UI |
| `<leader>df` | Abrir DAP UI em janela flutuante |
| `<leader>dd` | Step over — executar a linha atual, ir para a próxima |
| `<leader>di` | Step into — entrar na chamada de função |
| `<leader>do` | Step out — retornar da função atual |
| `<leader>dp` | Pausar execução |
| `<leader>dr` | Re-executar a última configuração de debug |
| `<leader>dR` | Reiniciar o stack frame atual |
| `<leader>dn` | Iniciar uma nova configuração de debug |
| `<leader>de` | Avaliar uma expressão |
| `<leader>dD` | Desconectar do adaptador de debug |

---

## Visão Geral da DAP UI

Quando você abre a UI de debug (`<leader>dt`), verá vários painéis:

- **Scopes** — Variáveis locais e globais no contexto atual
- **Breakpoints** — Lista de todos os breakpoints com arquivo e linha
- **Stacks** — Pilha de chamadas mostrando o caminho de execução
- **Watches** — Expressões customizadas que você quer monitorar
- **Console** — Saída do adaptador de debug e REPL
- **Virtual Text** — Valores de variáveis inline mostrados diretamente no código (via nvim-dap-virtual-text)

---

## Python

**Adaptador de debug:** [debugpy](https://github.com/microsoft/debugpy)

**Auto-instalado:** Sim, via Mason.

### Configurações Disponíveis

#### 1. Executar Arquivo Atual
Executa o arquivo Python atual com debugpy.

#### 2. Servidor Django
Inicia o servidor de desenvolvimento Django com debugging:
- Programa: `manage.py`
- Args: `runserver`, `--noreload`
- Modo Django ativado

#### 3. Shell Django
Abre o shell interativo Django com debugging:
- Programa: `manage.py`
- Args: `shell`
- Modo Django ativado

#### 4. Attach a Processo
Conecta a um processo Python já em execução:
- Host: `localhost`
- Porta: solicitada em tempo de execução

### Ambiente Virtual

Rosavim detecta automaticamente ambientes virtuais. Você também pode selecionar um manualmente:

```
<leader>lxs → Seletor VenvSelect
```

O debugger usa o Python do seu ambiente virtual ativo.

### Exemplo de Workflow

1. Abra seu projeto Django
2. Defina um breakpoint em uma view: `<leader>db`
3. Inicie o debugging: `<leader>ds`
4. Selecione "Django Server"
5. Faça uma requisição para disparar a view
6. Navegue pelo código com `<leader>dd` / `<leader>di`
7. Inspecione variáveis no painel de scopes da DAP UI

---

## Go

**Adaptador de debug:** [Delve](https://github.com/go-delve/delve)

**Auto-instalado:** Sim, via nvim-dap-go + Mason.

### Configurações Disponíveis

#### 1. Debug
Executa o pacote atual com Delve.

#### 2. Debug Test
Faz debug da função de teste mais próxima do cursor.

### Exemplo de Workflow

1. Abra um arquivo Go
2. Defina um breakpoint: `<leader>db`
3. Inicie: `<leader>ds`
4. Selecione "Debug" ou "Debug Test"
5. A DAP UI abre automaticamente com inspeção de variáveis

### Teclas Específicas do Go

| Tecla | Ação |
|:------|:-----|
| `<leader>nga` | Gerar um teste para a função sob o cursor |
| `<leader>ngA` | Gerar testes para todas as funções do arquivo |

---

## PHP

**Adaptador de debug:** Xdebug (extensão PHP)

### Pré-requisitos

O Xdebug deve estar instalado e configurado no seu ambiente PHP:

```ini
; php.ini
[xdebug]
xdebug.mode = debug
xdebug.start_with_request = yes
xdebug.client_port = 9003
```

### Configurações Disponíveis

#### 1. Escutar Xdebug
Escuta na porta 9003 por conexões Xdebug de entrada.

### Exemplo de Workflow

1. Configure o Xdebug no seu `php.ini`
2. Defina um breakpoint: `<leader>db`
3. Comece a escutar: `<leader>ds` → "Listen for Xdebug"
4. Dispare uma requisição (navegador, curl ou Sail)
5. O debugger captura o breakpoint

### Com Laravel Sail

Se estiver usando Sail, o Xdebug geralmente já vem pré-configurado. Basta:
1. Iniciar os containers: `<leader>klnu`
2. Iniciar o listener de debug: `<leader>ds`
3. Fazer uma requisição

---

## Java

**Adaptador de debug:** Java Debug Server (via JDTLS)

### Configurações Disponíveis

#### 1. Remote Attach
Conecta a um processo Java em execução via JDWP:
- Host: `127.0.0.1`
- Porta: solicitada em tempo de execução (padrão: 5005)

### Iniciando Java em Modo Debug

Execute sua aplicação Java com flags de debug:

```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar sua-app.jar
```

Ou com Gradle:

```bash
./gradlew bootRun --debug-jvm
```

Ou com Maven:

```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
```

### Exemplo de Workflow

1. Inicie sua app Java em modo debug
2. Defina um breakpoint: `<leader>db`
3. Inicie: `<leader>ds` → "Remote Attach"
4. Informe a porta (5005)
5. Dispare o caminho de código
6. Navegue com `<leader>dd` / `<leader>di`

---

## Adicionando Novos Adaptadores de Debug

### Via Mason

1. Abra o Mason: `:Mason`
2. Busque um adaptador DAP (ex.: `codelldb` para C/C++/Rust)
3. Instale-o

### Configuração Manual

Adicione um novo adaptador na sua configuração DAP:

```lua
-- Em um novo arquivo ou estendendo a configuração do plugin de debug
local dap = require("dap")

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "codelldb",
    args = { "--port", "${port}" },
  },
}

dap.configurations.rust = {
  {
    name = "Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Caminho do executável: ", vim.fn.getcwd() .. "/target/debug/", "file")
    end,
    cwd = "${workspaceFolder}",
  },
}
```

### Adaptadores Suportados via Mason

| Linguagem | Adaptador | Pacote Mason |
|:----------|:----------|:-------------|
| Python | debugpy | `debugpy` |
| Go | Delve | `delve` |
| C/C++/Rust | CodeLLDB | `codelldb` |
| C/C++ | cppdbg | `cpptools` |
| JavaScript/TypeScript | Node | `node-debug2-adapter` |
| .NET | netcoredbg | `netcoredbg` |
| PHP | Xdebug | (instalação do sistema) |
| Java | Java Debug | (via jdtls) |

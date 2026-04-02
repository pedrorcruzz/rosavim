# Debugging Guide

Rosavim includes full debugging support via the **Debug Adapter Protocol (DAP)**. This guide covers setup and usage for each supported language.

## Table of Contents

- [Quick Start](#quick-start)
- [Keybindings](#keybindings)
- [DAP UI Overview](#dap-ui-overview)
- [Python](#python)
- [Go](#go)
- [PHP](#php)
- [Java](#java)
- [Adding New Debug Adapters](#adding-new-debug-adapters)

---

## Quick Start

1. Open a file in a supported language
2. Place a breakpoint with `<leader>db`
3. Start the debugger with `<leader>ds`
4. Select a debug configuration when prompted
5. Use step controls to navigate through your code

---

## Keybindings

| Key | Action |
|:----|:-------|
| `<leader>ds` | Start / Continue |
| `<leader>dq` | Terminate session |
| `<leader>db` | Toggle breakpoint on current line |
| `<leader>dc` | Clear all breakpoints |
| `<leader>dt` | Toggle the DAP UI |
| `<leader>df` | Open DAP UI in floating window |
| `<leader>dd` | Step over — execute current line, move to next |
| `<leader>di` | Step into — enter the function call |
| `<leader>do` | Step out — return from current function |
| `<leader>dp` | Pause execution |
| `<leader>dr` | Rerun the last debug configuration |
| `<leader>dR` | Restart the current stack frame |
| `<leader>dn` | Start a new debug configuration |
| `<leader>de` | Evaluate an expression |
| `<leader>dD` | Disconnect from the debug adapter |

---

## DAP UI Overview

When you open the debug UI (`<leader>dt`), you'll see several panels:

- **Scopes** — Local and global variables in the current context
- **Breakpoints** — List of all breakpoints with file and line info
- **Stacks** — Call stack showing the execution path
- **Watches** — Custom expressions you want to monitor
- **Console** — Debug adapter output and REPL
- **Virtual Text** — Inline variable values shown directly in the code (via nvim-dap-virtual-text)

---

## Python

**Debug adapter:** [debugpy](https://github.com/microsoft/debugpy)

**Auto-installed:** Yes, via Mason.

### Available Configurations

#### 1. Run Current File
Runs the current Python file with debugpy.

#### 2. Django Server
Starts the Django development server with debugging:
- Program: `manage.py`
- Args: `runserver`, `--noreload`
- Django mode enabled

#### 3. Django Shell
Opens the Django interactive shell with debugging:
- Program: `manage.py`
- Args: `shell`
- Django mode enabled

#### 4. Attach to Process
Attaches to an already running Python process:
- Host: `localhost`
- Port: prompted at runtime

### Virtual Environment

Rosavim automatically detects virtual environments. You can also manually select one:

```
<leader>lxs → VenvSelect picker
```

The debugger uses the Python from your active virtual environment.

### Example Workflow

1. Open your Django project
2. Set a breakpoint in a view: `<leader>db`
3. Start debugging: `<leader>ds`
4. Select "Django Server"
5. Make a request to trigger the view
6. Step through the code with `<leader>dd` / `<leader>di`
7. Inspect variables in the DAP UI scopes panel

---

## Go

**Debug adapter:** [Delve](https://github.com/go-delve/delve)

**Auto-installed:** Yes, via nvim-dap-go + Mason.

### Available Configurations

#### 1. Debug
Runs the current package with Delve.

#### 2. Debug Test
Debugs the test function nearest to the cursor.

### Example Workflow

1. Open a Go file
2. Set a breakpoint: `<leader>db`
3. Start: `<leader>ds`
4. Select "Debug" or "Debug Test"
5. The DAP UI opens automatically with variable inspection

### Go-Specific Keys

| Key | Action |
|:----|:-------|
| `<leader>nga` | Generate a test for the function under cursor |
| `<leader>ngA` | Generate tests for all functions in the file |

---

## PHP

**Debug adapter:** Xdebug (PHP extension)

### Prerequisites

Xdebug must be installed and configured in your PHP environment:

```ini
; php.ini
[xdebug]
xdebug.mode = debug
xdebug.start_with_request = yes
xdebug.client_port = 9003
```

### Available Configurations

#### 1. Listen for Xdebug
Listens on port 9003 for incoming Xdebug connections.

### Example Workflow

1. Configure Xdebug in your `php.ini`
2. Set a breakpoint: `<leader>db`
3. Start listening: `<leader>ds` → "Listen for Xdebug"
4. Trigger a request (browser, curl, or Sail)
5. The debugger catches the breakpoint

### With Laravel Sail

If using Sail, Xdebug is typically pre-configured. Just:
1. Start containers: `<leader>klnu`
2. Start the debug listener: `<leader>ds`
3. Make a request

---

## Java

**Debug adapter:** Java Debug Server (via JDTLS)

### Available Configurations

#### 1. Remote Attach
Attaches to a running Java process via JDWP:
- Host: `127.0.0.1`
- Port: prompted at runtime (default: 5005)

### Starting Java in Debug Mode

Run your Java application with debug flags:

```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar your-app.jar
```

Or with Gradle:

```bash
./gradlew bootRun --debug-jvm
```

Or with Maven:

```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
```

### Example Workflow

1. Start your Java app in debug mode
2. Set a breakpoint: `<leader>db`
3. Start: `<leader>ds` → "Remote Attach"
4. Enter the port (5005)
5. Trigger the code path
6. Step through with `<leader>dd` / `<leader>di`

---

## Adding New Debug Adapters

### Via Mason

1. Open Mason: `:Mason`
2. Search for a DAP adapter (e.g., `codelldb` for C/C++/Rust)
3. Install it

### Manual Configuration

Add a new adapter in your DAP config:

```lua
-- In a new file or extending the debug plugin config
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
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
    end,
    cwd = "${workspaceFolder}",
  },
}
```

### Supported Adapters via Mason

| Language | Adapter | Mason Package |
|:---------|:--------|:-------------|
| Python | debugpy | `debugpy` |
| Go | Delve | `delve` |
| C/C++/Rust | CodeLLDB | `codelldb` |
| C/C++ | cppdbg | `cpptools` |
| JavaScript/TypeScript | Node | `node-debug2-adapter` |
| .NET | netcoredbg | `netcoredbg` |
| PHP | Xdebug | (system install) |
| Java | Java Debug | (via jdtls) |

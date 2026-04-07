# Security Policy

## Supported Versions

Rosavim follows a rolling-release model. Only the latest version on the `main` branch is actively supported with security updates.

| Version        | Supported          |
| -------------- | ------------------ |
| Latest (`main`) | :white_check_mark: |
| Older commits   | :x:                |

We recommend always pulling the latest changes to stay up to date.

## Reporting a Vulnerability

If you discover a security vulnerability in Rosavim, please report it responsibly:

1. **Do NOT open a public issue.** Security vulnerabilities should be reported privately.
2. **Send an email to:** [pedrorcruzz](https://github.com/pedrorcruzz) via GitHub private message or open a [GitHub Security Advisory](https://github.com/pedrorcruzz/rosavim/security/advisories/new).
3. **Include:**
   - A description of the vulnerability
   - Steps to reproduce the issue
   - The potential impact
   - Any suggested fix (if applicable)

### What to expect

- **Acknowledgment:** You will receive a response within **48 hours** confirming we received your report.
- **Updates:** We will keep you informed of the progress toward a fix.
- **Resolution:** Once the vulnerability is confirmed and fixed, we will release a patch and credit you (unless you prefer to remain anonymous).

## Scope

This policy covers the Rosavim Neovim distribution, including:

- Lua configuration files
- Plugin configurations and custom plugins
- LSP, formatter, linter, and debugger setups
- Any scripts distributed as part of Rosavim

Third-party plugins used by Rosavim are maintained by their respective authors. If you find a vulnerability in a third-party plugin, please report it to that plugin's maintainer directly.

## Best Practices for Users

- Always install Rosavim from the [official repository](https://github.com/pedrorcruzz/rosavim).
- Keep Neovim updated to version **0.12+** as recommended.
- Review any custom plugins or configurations you add on top of Rosavim.

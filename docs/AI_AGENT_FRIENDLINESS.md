# AI agent friendliness

Botstrap is designed so **coding agents** (Cursor, Claude Code, Codex, and similar) can drive installation and day-to-day development reliably. This document captures the design principles; see `docs/ARCHITECTURE.md` for where they appear in the system.

## Principles

### Non-interactive by default

Core Phase 1 installs use package managers and flags that do not prompt (`-y`, `--yes`, `--accept-package-agreements` on Windows where applicable). Agents cannot answer graphical or surprise prompts; failing fast with a clear error is preferable to hanging on stdin.

### Structured, discoverable layout

- **Registry (`registry/*.yaml`)** — Tools and commands are data, not hidden in one-off scripts. Agents can read the same manifest humans do.
- **`configs/agent/`** — Default `AGENTS.md`, Cursor rules templates, and similar files give new repos a consistent starting point for agent instructions.

### Deterministic runtimes

- **mise** pins language versions (`mise use --global …`). Agents inherit a predictable `PATH` and avoid “wrong Node on this machine” issues.

### Git defaults

Global git templates in `configs/git/` aim for sensible defaults for automated commits (clear diff behavior, delta when available, identity collected once in Phase 2). Contributors should avoid interactive git hooks in templates.

### Containers for side effects

- **Docker** for databases and ad-hoc services reduces host mutation and matches how many agents expect to run tests or migrations.

### JSON and YAML tooling

- **jq** and **yq** are core so agents can parse CLI output and config without extra installs.

### Shell ergonomics

- **fzf**, **zoxide**, **ripgrep**, and **fd** improve navigation and search in long sessions; they behave well in scripted pipelines when used non-interactively.
- History and completion configuration (Phase 3) should not require a TTY for basic PATH and alias setup.

### Multiple AI CLIs as optional

Phase 2 lets users opt into **Claude Code**, **OpenClaw**, **Codex CLI**, **Gemini CLI**, **Ollama**, etc., with `requires` metadata (e.g. Node) so ordering stays explicit.

## What agents should avoid

- Piping unaudited remote scripts without reading them first (same as for humans).
- Assuming GUI-only installers; Botstrap should prefer winget/brew/apt where possible.

## Extending for agents

When adding a tool:

1. Prefer registry entries with a clear `verify` command.
2. Document any required API keys or login steps in tool descriptions so agents know manual steps remain.
3. Keep post-install hooks idempotent where possible so `botstrap update` can re-run safely.

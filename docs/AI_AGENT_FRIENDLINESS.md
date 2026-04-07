# AI agent friendliness

Botstrap is designed so **coding agents** (Cursor, Claude Code, Codex, and similar) can drive installation and day-to-day development reliably. This document captures the design principles; see [Introduction](./INTRODUCTION.md) for the end-to-end story and [Architecture](./ARCHITECTURE.md) for where they appear in the system.

## Principles

### Non-interactive by default

Registry-driven installs use package managers and flags that do not prompt (`-y`, `--yes`, `--accept-package-agreements` on Windows where applicable). Agents cannot answer graphical or surprise prompts; failing fast with a clear error is preferable to hanging on stdin.

### Structured, discoverable layout

- **Registry (`registry/*.yaml`)** — Tools and commands are data, not hidden in one-off scripts. Agents can read the same manifest humans do.
- **`configs/agent/`** — Default `AGENTS.md`, Cursor rules templates, and similar files give new repos a consistent starting point for agent instructions.
- **`CLAUDE.md`** — Root-level guidance file for Claude Code and compatible AI coding agents. Summarises the architecture, key commands, and project conventions so agents can onboard without reading every file.

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

## Automated documentation maintenance

Botstrap uses a **GitHub Copilot agentic workflow** to keep project documentation up to date automatically.

### `daily-doc-updater` workflow

Defined in `.github/workflows/daily-doc-updater.md`, this workflow runs on a daily schedule and:

1. Scans merged pull requests and significant commits from the last 24 hours.
2. Analyzes changes for new features, removed features, modified behavior, and breaking changes.
3. Reviews existing documentation in `docs/` and `README.md` for gaps.
4. Updates the appropriate documentation file(s) to reflect new functionality.
5. Opens a pull request (with labels `documentation` and `automation`) for human review before merging.

The workflow is powered by [GitHub Copilot agentic workflows](https://github.github.com/gh-aw/introduction/overview/) (`gh aw`). The compiled GitHub Actions workflow is stored in `daily-doc-updater.lock.yml` (auto-generated — do not edit directly). Regenerate with:

```bash
gh aw compile
```

### Agentics maintenance

`agentics-maintenance.yml` runs every 6 hours to close expired agentic pull requests and issues (based on the `expires: 2d` setting in the `daily-doc-updater` safe-outputs configuration). It also supports manual `workflow_dispatch` operations (`disable`, `enable`, `update`, `upgrade`, `safe_outputs`, `create_labels`).

### Lock files

`.gitattributes` marks `*.lock.yml` workflow files as linguist-generated so they are excluded from language stats and treated as generated files for diffs:

```gitattributes
.github/workflows/*.lock.yml linguist-generated=true merge=ours
```

## Extending for agents

When adding a tool:

1. Prefer registry entries with a clear `verify` command.
2. Document any required API keys or login steps in tool descriptions so agents know manual steps remain.
3. Keep post-install hooks idempotent where possible so re-running `./install.sh` or `./bin/botstrap reconfigure` after a `git pull` does not break machines.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Botstrap is a cross-platform bootstrap (macOS, Linux, Windows) that turns a fresh machine into a configured developer environment. One entry point runs phased installs driven by YAML registries. Targets both **developers** and **AI coding agents**.

## Key commands

```bash
# Local development (from repo root)
export BOTSTRAP_ROOT="$(pwd)" && ./install.sh    # Unix
$env:BOTSTRAP_ROOT = (Get-Location).Path; .\install.ps1  # Windows

# Docs (VitePress, deployed to Cloudflare Pages)
npm ci && npm run docs:build   # production build
npm run docs:dev               # dev server with hot reload

# CLI (available after Phase 3)
./bin/botstrap version
./bin/botstrap update         # git pull --ff-only
./bin/botstrap reconfigure     # Phase 2 + 3
./bin/botstrap doctor          # Phase 4 verification
```

## Architecture

```
boot.sh / boot.ps1          → Clone repo to BOTSTRAP_HOME, exec install.*
install.sh / install.ps1     → Orchestrators: run phases in order
lib/                        → Shared primitives: detect, log, pkg
install/                    → Phase scripts (phase-0-prerequisites, phase-2-tui, etc.)
registry/                   → YAML tool definitions (prerequisites.yaml, core.yaml, optional.yaml)
configs/                    → Templates: shell, git, editor, agent configs
bin/botstrap                → Thin CLI: version / update / reconfigure / doctor
```

### Phases

| Phase | Purpose |
|-------|---------|
| 0 | Prerequisites: git, curl, jq, yq, gum via registry-driven `lib/pkg` |
| 0b | Windows only: OS developer tuning from `configs/os/windows.yaml` |
| 2 | Interactive TUI via gum (core/optional selections); non-interactive defaults without gum |
| 3 | Install selected tools from registry, apply `configs/` templates |
| 4 | Verify prerequisites + selected core tools |

### Package layer

- **Unix (`lib/pkg.sh`)**: Homebrew (macOS), apt/dnf/pacman (Linux), registry YAML lookup via yq
- **Windows (`lib/pkg.ps1`)**: winget, same registry YAML files

Registry entries use OS keys: `darwin`, `linux-apt`, `linux-dnf`, `linux-pacman`, `windows`, `all`.

## Agent-specific guidance

See `configs/agent/AGENTS.md` for project conventions:
- Plan first, then implement — use tasks to track progress
- Dual-audience positioning: always mention both "developers" and "AI coding agents"
- Concise, conventional commits (e.g. `feat(scope): short summary`)
- Do not commit or push unless explicitly asked
- Use context7 MCP for library documentation lookup
- English only in code, docs, and comments

## Deployment

Docs site served from Cloudflare Pages. Build output: `docs/.vitepress/dist`. Install scripts synced to `docs/public/install` and `docs/public/install.ps1` via `scripts/sync-install-assets.mjs` before each build.

## Adding a new tool

1. Add entry to `registry/core.yaml` (core) or `registry/optional.yaml` (optional)
2. Use OS-specific install keys (`darwin`, `linux-apt`, etc.) with package manager commands
3. Include `verify:` command that returns version string on success
4. For complex setup, add a module under `install/modules/` and reference it in Phase 3

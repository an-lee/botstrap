# Botstrap

Cross-platform bootstrap for **developers** and **AI coding agents**: one entry point on macOS, Linux, and Windows to install a **core** toolchain from a **YAML registry**, pick **optional** tools in a **gum** TUI, then apply **configs** and **verify** installs — with predictable PATH, non-interactive CLIs by default, and **configs/** scaffolding suited to agents.

## Quick start (from a published clone)

```bash
# macOS / Linux (default BOTSTRAP_REPO is https://github.com/botstrap/botstrap.git; override to use a fork)
curl -fsSL https://botstrap.org/install | bash
```

```powershell
# Windows (PowerShell); default clone URL matches boot.sh — set $env:BOTSTRAP_REPO to use a fork
irm https://botstrap.org/install.ps1 | iex
```

For local development, run the orchestrator from this repository:

```bash
export BOTSTRAP_ROOT="$(pwd)"
./install.sh
```

## Layout

- `boot.sh` / `boot.ps1` — clone `~/.botstrap` and start `install.*`
- `install.sh` / `install.ps1` — phases 0–4
- `lib/` — `detect`, `log`, `pkg` (registry-driven installs on Unix)
- `registry/core.yaml` — always-installed tools
- `registry/optional.yaml` — TUI selections (editor, languages, databases, AI CLIs, themes, apps)
- `configs/` — shell, git, editor, and agent templates
- `docs/` — architecture, registry spec, contributing

## CLI (this checkout)

```bash
./bin/botstrap version
./bin/botstrap update      # git pull in repo root
./bin/botstrap reconfigure # TUI + configure phases
./bin/botstrap doctor      # run core verify steps
```

## Documentation

- **Site:** [botstrap.org](https://botstrap.org) — browsable docs (VitePress)
- [Introduction](docs/INTRODUCTION.md) — what Botstrap does, end to end
- [Getting started](docs/GETTING_STARTED.md) — install, local dev, non-interactive runs
- [Reference](docs/REFERENCE.md) — CLI, environment variables, artifacts
- [Configuration](docs/CONFIGURATION.md) — `configs/` templates and where they land
- [Architecture](docs/ARCHITECTURE.md)
- [Registry specification](docs/REGISTRY_SPEC.md)
- [Tool selection](docs/TOOL_SELECTION.md)
- [Cross-platform notes](docs/CROSS_PLATFORM.md)
- [AI agent friendliness](docs/AI_AGENT_FRIENDLINESS.md) — including automated doc maintenance via the `daily-doc-updater` workflow
- [Contributing](docs/CONTRIBUTING.md)

## Version

See the `version` file (semver reported by `./bin/botstrap version` and Phase 4 summary).

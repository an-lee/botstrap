# Botstrap

Cross-platform bootstrap: one entry point on macOS, Linux, and Windows to install a **core** developer toolchain from a **YAML registry**, pick **optional** tools in a **gum** TUI, then apply **configs** and **verify** installs.

## Quick start (from a published clone)

```bash
# macOS / Linux (default clone URL; override with BOTSTRAP_REPO)
curl -fsSL https://botstrap.org/install | bash
```

```powershell
# Windows (PowerShell)
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

- [Architecture](docs/ARCHITECTURE.md)
- [Registry specification](docs/REGISTRY_SPEC.md)
- [Tool selection](docs/TOOL_SELECTION.md)
- [Cross-platform notes](docs/CROSS_PLATFORM.md)
- [AI agent friendliness](docs/AI_AGENT_FRIENDLINESS.md)
- [Contributing](docs/CONTRIBUTING.md)

## Version

See the `version` file (semver for migrations and reporting).

# Botstrap

<p align="center">
  <img src="docs/public/logo.svg" alt="Botstrap" width="300" />
</p>

Cross-platform bootstrap for **developers** and **AI coding agents**: one entry point on macOS, Linux, and Windows to install a **core** toolchain from a **YAML registry**, pick **optional** tools in a **gum** TUI, then apply **configs** and **verify** installs — with predictable PATH, non-interactive CLIs by default, and **configs/** scaffolding suited to agents.

## Quick start (from a published clone)

```bash
# macOS / Linux (default BOTSTRAP_REPO is https://github.com/botstrap/botstrap.git; override to use a fork)
curl -fsSL https://botstrap.dev/install | bash
```

```powershell
# Windows (PowerShell); default clone URL matches boot.sh — set $env:BOTSTRAP_REPO to use a fork
irm https://botstrap.dev/install.ps1 | iex
```

For local development, run the orchestrator from this repository:

**macOS / Linux**

```bash
export BOTSTRAP_ROOT="$(pwd)"
./install.sh
```

**Windows (PowerShell)**

```powershell
$env:BOTSTRAP_ROOT = (Get-Location).Path
.\install.ps1
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

After **Phase 3** on macOS/Linux, open a **new** shell (or `source ~/.zshrc` / `~/.bashrc`): **`botstrap`** is on your `PATH` via `~/.config/botstrap/env.sh`. Until then, or on Windows without that hook, use the script path:

```bash
./bin/botstrap version
./bin/botstrap update      # git pull in repo root
./bin/botstrap reconfigure # TUI + configure phases
./bin/botstrap doctor      # install status + core verify (exits 1 if any verify fails)
```

## Documentation

- **Site:** [botstrap.dev](https://botstrap.dev) — browsable docs (VitePress)
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

## Deployment (Cloudflare Pages)

Production docs and install scripts are served from **https://botstrap.dev** via [Cloudflare Pages](https://developers.cloudflare.com/pages/).

| Setting | Value |
|--------|--------|
| Build command | `npm ci && npm run docs:build` |
| Build output directory | `docs/.vitepress/dist` |
| Node.js version | 22 |

Connect this repository in the Cloudflare dashboard (**Workers & Pages** → **Create** → **Pages**), then attach the custom domain `botstrap.dev`. Boot scripts are copied into the static output as `/install` and `/install.ps1` on each build (see `scripts/sync-install-assets.mjs`).

Manual deploy after a local build:

```bash
npm run docs:build
npx wrangler pages deploy
```

With [`wrangler.toml`](wrangler.toml) at the repo root, Wrangler uses `pages_build_output_dir` and project `name`; override with `npx wrangler pages deploy docs/.vitepress/dist --project-name=botstrap` if needed.

## Version

See the `version` file (semver reported by `./bin/botstrap version` and Phase 4 summary).

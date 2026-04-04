# Getting started

This guide covers **how to run Botstrap**, **prerequisites**, **local development**, **non-interactive behavior**, and **security expectations**.

## Prerequisites

### Before the one-liner (boot)

- **Git** must be installed. `boot.sh` and `boot.ps1` exit with an error if `git` is missing.
- **Network access** to clone the repository and to download packages or release binaries during Phase 0 and Phase 1.

### After clone (Unix orchestrator)

- **Bash** (the project uses `#!/usr/bin/env bash` with `set -euo pipefail`; use Bash 4+ where possible).
- **sudo** (or equivalent) on Linux/macOS when Phase 0 or package installs need it.
- Phase 0 installs **jq**, **yq**, and **gum** when possible; **yq** is **required** for Phase 1 and Phase 4.

### Windows

- **PowerShell** (scripts use `#requires -Version 5.1`; PowerShell 7+ is recommended for testing).
- **Git for Windows**.
- For the **same** interactive TUI and optional-tool flow as macOS/Linux, use **WSL** and run **`install.sh`** inside the clone. Native **`install.ps1`** may be incomplete; the script prints a reminder at the end. See [Cross-platform notes](./CROSS_PLATFORM.md).

## Install from the web (recommended)

Default clone URL is set in **`boot.sh`** / **`boot.ps1`**: `https://github.com/botstrap/botstrap.git`. To use a **fork** or mirror, set **`BOTSTRAP_REPO`** before running boot. To change the install directory, set **`BOTSTRAP_HOME`** (default: `~/.botstrap` or `%USERPROFILE%\.botstrap`).

**macOS / Linux**

```bash
curl -fsSL https://botstrap.org/install | bash
```

**Windows (PowerShell)**

```powershell
irm https://botstrap.org/install.ps1 | iex
```

The host may serve different scripts per URL or `User-Agent`; use explicit `.sh` / `.ps1` URLs if your environment requires it.

## Local development (this repository)

From the root of a Git checkout:

```bash
export BOTSTRAP_ROOT="$(pwd)"
./install.sh
```

On Windows, from the checkout root:

```powershell
$env:BOTSTRAP_ROOT = (Get-Location).Path
.\install.ps1
```

`install.sh` sets **`BOTSTRAP_ROOT`** automatically when you run it from the repo root; exporting it explicitly is mainly for running individual phase scripts by hand.

## Non-interactive and CI runs

### Unix: no TTY or no gum

In **`install/phase-2-tui.sh`**, if **`gum`** is not on `PATH`, the script:

- Logs a warning.
- Exports **default** `BOTSTRAP_*` variables (empty or sensible defaults, e.g. `BOTSTRAP_EDITOR=none`, `BOTSTRAP_THEME=catppuccin`).
- **Exits 0** immediately so Phase 3 and Phase 4 still run.

So a headless run completes without hanging on prompts, but you will not get interactive choices unless gum is available.

### Windows Phase 2

If **gum** is missing, **`phase-2-tui.ps1`** sets only **`BOTSTRAP_EDITOR`** and **`BOTSTRAP_THEME`** defaults and returns. If gum is present, the script currently **warns** that the full TUI should be run under WSL—it does not run the full macOS/Linux gum flow. Plan on **WSL + `install.sh`** for automated parity with Unix.

## After install: `bin/botstrap`

From the clone (e.g. `~/.botstrap`):

```bash
./bin/botstrap version   # prints semver from `version` file
./bin/botstrap update    # git pull --ff-only in the clone
./bin/botstrap reconfigure  # Phase 2 + Phase 3 only
./bin/botstrap doctor    # Phase 4 verification only
```

Details: [Reference](./REFERENCE.md).

## Security and trust

- **Pipe-to-shell** (`curl | bash`, `irm | iex`) means you execute whatever the URL returns. Review **`boot.sh`** / **`boot.ps1`** and this repository **before** running on important machines.
- Registry **`install`** snippets on Unix run as shell commands; keep the registry auditable and prefer package managers over opaque `curl | sh` when possible.
- Botstrap may invoke **sudo** / admin actions for packages and OS tuning; understand what each phase does in [Introduction](./INTRODUCTION.md) and [Architecture](./ARCHITECTURE.md).

## Next steps

- [Introduction](./INTRODUCTION.md) — full end-to-end narrative.
- [Configuration](./CONFIGURATION.md) — what files land in your home directory.
- [Registry specification](./REGISTRY_SPEC.md) — adding or changing tools.

# Getting started

This guide covers **how to run Botstrap**, **prerequisites**, **local development**, **non-interactive behavior**, and **security expectations**.

## Prerequisites

### Before the one-liner (boot)

- **Git** is required to clone the repo, but boot tries to install it when missing:
  - **macOS / Linux (`boot.sh`):** loads `install/boot-prereqs-git.sh` from a **local checkout** (if you run `boot.sh` from disk) or fetches it over **HTTPS** when `BOTSTRAP_REPO` is a **GitHub** `https://github.com/...` or `git@github.com:...` URL (needs **curl** for that fetch). It then runs the same git/curl install logic as Phase 0 (Homebrew, apt, dnf, or pacman; **sudo** where needed). For **non-GitHub** remotes, set **`BOTSTRAP_BOOT_PREREQS_URL`** to the raw URL of `install/boot-prereqs-git.sh`, or install **git** yourself first.
  - **Windows (`boot.ps1`):** if **winget** is available, installs **Git.Git**; otherwise install Git for Windows manually.
- If git still cannot be installed, boot exits with instructions.
- **Network access** to clone the repository and to download packages or release binaries during Phase 0 and later phases.

### After clone (Unix orchestrator)

- **Bash** (the project uses `#!/usr/bin/env bash` with `set -euo pipefail`; use Bash 4+ where possible).
- **sudo** (or equivalent) on Linux/macOS when Phase 0 or package installs need it.
- Phase 0 installs **jq**, **yq**, and **gum** when possible (from **`registry/prerequisites.yaml`**); **yq** is **required** for registry-driven installs and Phase 4.

### Windows

- **PowerShell** (scripts use `#requires -Version 5.1`; PowerShell 7+ is recommended for testing).
- **Git for Windows** (boot and Phase 0 try **winget** first when git is missing).
- Phase 0 requires **winget** (App Installer) and installs **yq**, **jq**, and **gum** when missing. **yq** is required for registry-driven installs and Phase 4 on Windows, same as Unix.
- **Administrator rights are not required** to run the install; it completes without elevation.
- For **full OS tuning** (Developer Mode and long paths in Phase 0b), run from an **elevated PowerShell** ("Run as Administrator") if you want those applied automatically. If not elevated, those two items are skipped with a warning; you can enable them manually in Settings or re-run elevated. See [Cross-platform notes](./CROSS_PLATFORM.md).
- Native **`install.ps1`** runs the full gum TUI (when **gum** is on `PATH`), registry-driven prerequisite, selected core, and optional installs, PowerShell profile hooks, and verification.

## Install from the web (recommended)

Default clone URL is set in **`boot.sh`** / **`boot.ps1`**: `https://github.com/an-lee/botstrap.git`. To use a **fork** or mirror, set **`BOTSTRAP_REPO`** before running boot. To change the install directory, set **`BOTSTRAP_HOME`** (default: `~/.botstrap` or `%USERPROFILE%\.botstrap`).

**macOS / Linux**

```bash
curl -fsSL https://botstrap.dev/install | bash
```

**Windows (PowerShell)**

```powershell
irm https://botstrap.dev/install.ps1 | iex
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
- Exports **default** `BOTSTRAP_*` variables (empty or sensible defaults, e.g. **`BOTSTRAP_CORE_TOOLS`** = all names from **`registry/core.yaml`** unless preset, `BOTSTRAP_EDITOR=none`, `BOTSTRAP_THEME=catppuccin`).
- **Exits 0** immediately so Phase 3 and Phase 4 still run.

So a headless run completes without hanging on prompts, but you will not get interactive choices unless gum is available.

### Windows Phase 2

If **gum** is missing, **`phase-2-tui.ps1`** exports the same safe defaults as Unix (including **`BOTSTRAP_CORE_TOOLS`** = all **`core.yaml`** names unless preset, **`BOTSTRAP_EDITOR=none`**, **`BOTSTRAP_THEME=catppuccin`**, empty optional lists) and returns so Phase 3 and Phase 4 still run. If **gum** is present, the script runs the same interactive prompts as **`phase-2-tui.sh`** (core tools, editor, languages, databases, AI tools, theme, optional apps).

## After install: `bin/botstrap`

Phase 3 writes **`~/.config/botstrap/env.sh`** and appends a **botstrap PATH** block to **`~/.zshrc`** and **`~/.bashrc`**. After a **new** login shell (or sourcing your rc file), you can run **`botstrap`** from anywhere.

From the clone (e.g. `~/.botstrap`) you can always use:

```bash
./bin/botstrap           # interactive menu (TTY + gum); for automation use explicit subcommands
./bin/botstrap version   # prints semver from `version` file
./bin/botstrap update    # git pull --ff-only in the clone
./bin/botstrap reconfigure  # Phase 2 + Phase 3 only
./bin/botstrap doctor    # status lines + Phase 4 verification (prerequisites + selected core; exits 1 on verify failures)
```

On **native Windows** (PowerShell install), Phase 3 appends a **`# botstrap PATH`** block to your PowerShell **profile** (same marker pattern as starship/zoxide): it sets **`$env:BOTSTRAP_ROOT`**, prepends **`bin\`** to **`$env:PATH`**, and defines a **`botstrap`** function that runs **`bin/botstrap.ps1`**. Open a **new** PowerShell session (or **`. $PROFILE`**) to use **`botstrap`** from anywhere. **Git Bash** / **WSL** with **`install.sh`** still use the Bash **`bin/botstrap`** and **`~/.config/botstrap/env.sh`** hook.

Details: [Reference](./REFERENCE.md).

## Security and trust

- **Pipe-to-shell** (`curl | bash`, `irm | iex`) means you execute whatever the URL returns. Review **`boot.sh`** / **`boot.ps1`** and this repository **before** running on important machines.
- Registry **`install`** snippets on Unix run as shell commands; keep the registry auditable and prefer package managers over opaque `curl | sh` when possible.
- Botstrap may invoke **sudo** / admin actions for packages and OS tuning; understand what each phase does in [Introduction](./INTRODUCTION.md) and [Architecture](./ARCHITECTURE.md).

## Next steps

- [Introduction](./INTRODUCTION.md) — full end-to-end narrative.
- [After install](./AFTER_INSTALL.md) — what was installed and how to use it.
- [Defaults & customization](./DEFAULTS_AND_CUSTOMIZATION.md) — default config and how to change it.
- [Configuration file map](./CONFIGURATION.md) — `configs/` templates → paths in your home directory.
- [Registry specification](./REGISTRY_SPEC.md) — adding or changing tools.

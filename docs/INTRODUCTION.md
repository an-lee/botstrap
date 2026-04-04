# Introduction

Botstrap is a **cross-platform bootstrap**: one entry point on macOS, Linux, and Windows that clones a single Git repository into a fixed home on your machine, then runs a **phased installer** driven by YAML registries. It installs a **core** toolchain for everyone, lets you pick **optional** tools through a terminal UI (where supported), writes **configuration templates** into your home directory, and **verifies** that core tools work.

This page explains **what Botstrap does end to end**, in plain language. For install commands, see [Getting started](./GETTING_STARTED.md). For flags and file paths, see [Reference](./REFERENCE.md).

## Who it is for

- **Developers** who want a repeatable baseline on a new laptop or VM: shell utilities, version managers, Git, containers, JSON/YAML CLIs, and sensible defaults.
- **AI coding agents** and people who drive the terminal non-interactively: core installs avoid prompts; the repo layout (`registry/*.yaml`, `configs/agent/`) is easy to read and extend.

## What Botstrap is not

- **Not a full dotfile manager** like Chezmoi or Nix Home Manager. It appends marked blocks to shell rc files and copies selected templates; it does not manage arbitrary symlink farms unless you extend it.
- **Not identical on every OS.** Package commands and paths differ. Native **Windows** support is **partial** compared to macOS/Linux; the maintainers recommend **WSL + `install.sh`** for the same experience as Unix. See [Cross-platform notes](./CROSS_PLATFORM.md).
- **Not a silent guarantee** that every `registry/core.yaml` tool exists in every package manager. Failed installs are logged and Phase 4 reports verification failures; you may need manual fixes on exotic distros.

## The story of one install

### 1. You run a one-liner

- **macOS / Linux:** the site serves `boot.sh` (or you use the documented `curl … | bash` flow).
- **Windows:** `boot.ps1` via PowerShell.

The boot script requires **Git** already (or tells you to install it). It clones the Botstrap repository into **`BOTSTRAP_HOME`** (default `~/.botstrap` on Unix, `%USERPROFILE%\.botstrap` on Windows), unless that directory is already a Git checkout. You can override the remote with **`BOTSTRAP_REPO`**. The default remote in `boot.sh` / `boot.ps1` is `https://github.com/botstrap/botstrap.git`.

Then the boot script runs **`install.sh`** (Unix) or **`install.ps1`** (Windows) from that clone.

### 2. Phase 0: prerequisites

Ensures the rest of the pipeline can run: **git**, **curl**, **jq**, **yq**, and **gum** (Unix script installs or downloads them where possible). Without **yq**, later phases cannot read the registry. If **gum** cannot be installed, Phase 2 falls back to **non-interactive defaults** on Unix; on Windows, Phase 2 is limited—see [Getting started](./GETTING_STARTED.md).

### 3. Phase 0b (Windows only)

Optional **OS tuning** (developer mode hints, long paths, execution policy, etc.) driven by `configs/os/windows.yaml`. Steps can require elevation or manual follow-up; the installer does not always stop on failure. See [Cross-platform notes](./CROSS_PLATFORM.md).

### 4. Phase 1: core tools

Reads **`registry/core.yaml`** in order and installs each tool using **`lib/pkg.sh`** or **`lib/pkg.ps1`**, which pick the right snippet for your OS (Homebrew, apt, dnf, pacman, winget, etc.). Complex tools may call scripts under **`install/modules/`**. Installs aim to be **non-interactive** (`-y`, silent flags).

### 5. Phase 2: choices (TUI)

On **macOS/Linux**, if **gum** is available, an interactive flow asks for Git identity, editor, languages, databases, AI CLIs, theme, and optional apps. Answers are exported as **`BOTSTRAP_*`** environment variables (see [Reference](./REFERENCE.md)).

If **gum** is missing on Unix, the script exports **safe defaults** and skips the interactive UI so automated runs do not hang.

On **native Windows**, Phase 2 is minimal: without gum, only default editor/theme are set; with gum, you still get a warning to use WSL for the full TUI. Prefer WSL for parity.

### 6. Phase 3: configure

Applies **`configs/`** templates and installs **optional** registry entries selected in Phase 2 (editors, languages, databases, etc.—see [Configuration](./CONFIGURATION.md)). This phase may copy files to `~/.config`, append blocks to **`~/.zshrc`** and **`~/.bashrc`**, set global Git name/email, and place **sample** agent files under `~/.config/botstrap/agent/`.

### 7. Phase 4: verify

Runs **`verify`** commands from **`registry/core.yaml`** for each core tool and prints a short summary (pass/fail counts and hints to re-run TUI + configure). This phase requires **yq** on PATH.

## Where the project lives on your machine

After boot, your **Botstrap checkout** is at **`BOTSTRAP_HOME`**. That directory contains `install.sh`, `registry/`, `configs/`, `lib/`, and everything else in the repo. When you work from a **different** Git clone (for development), you set **`BOTSTRAP_ROOT`** to that clone’s path so phases resolve files correctly.

The thin CLI **`bin/botstrap`** in the repo is meant for a **local checkout**; it runs `git pull`, re-runs Phase 2+3, or runs verification from **`BOTSTRAP_ROOT`** (the parent of `bin/`). See [Reference](./REFERENCE.md).

## How to learn more

| Topic | Document |
|--------|----------|
| Install and trust | [Getting started](./GETTING_STARTED.md) |
| CLI, env vars, artifacts | [Reference](./REFERENCE.md) |
| Template → home paths | [Configuration](./CONFIGURATION.md) |
| Phases, `lib/`, diagrams | [Architecture](./ARCHITECTURE.md) |
| YAML schema | [Registry specification](./REGISTRY_SPEC.md) |
| Why each tool exists | [Tool selection](./TOOL_SELECTION.md) |
| OS and package managers | [Cross-platform notes](./CROSS_PLATFORM.md) |
| Agents and automation | [AI agent friendliness](./AI_AGENT_FRIENDLINESS.md) |

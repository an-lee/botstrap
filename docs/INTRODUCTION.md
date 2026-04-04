# Introduction

Botstrap is a **cross-platform bootstrap**: one entry point on macOS, Linux, and Windows that clones a single Git repository into a fixed home on your machine, then runs a **phased installer** driven by YAML registries. It installs **prerequisite** CLI tooling for everyone, lets you pick **core** and **optional** tools through a terminal UI (where supported), writes **configuration templates** into your home directory, and **verifies** prerequisites and your selected **core** set.

This page explains **what Botstrap does end to end**, in plain language. For install commands, see [Getting started](./GETTING_STARTED.md). For flags and file paths, see [Reference](./REFERENCE.md).

## Who it is for

- **Developers** who want a repeatable baseline on a new laptop or VM: shell utilities, version managers, Git, containers, JSON/YAML CLIs, and sensible defaults.
- **AI coding agents** and people who drive the terminal non-interactively: core installs avoid prompts; the repo layout (`registry/*.yaml`, `configs/agent/`) is easy to read and extend.

## What Botstrap is not

- **Not a full dotfile manager** like Chezmoi or Nix Home Manager. It appends marked blocks to shell rc files and copies selected templates; it does not manage arbitrary symlink farms unless you extend it.
- **Not identical on every OS.** Package commands and paths differ. Native **Windows** uses **winget** and **`lib/pkg.ps1`** with the same registry files; **WSL + `install.sh`** is optional if you prefer a Linux-only terminal. See [Cross-platform notes](./CROSS_PLATFORM.md).
- **Not a silent guarantee** that every `registry/core.yaml` tool exists in every package manager. Failed installs are logged and Phase 4 reports verification failures; you may need manual fixes on exotic distros.

## The story of one install

### 1. You run a one-liner

- **macOS / Linux:** the site serves `boot.sh` (or you use the documented `curl … | bash` flow).
- **Windows:** `boot.ps1` via PowerShell.

The boot script **needs Git to clone** but attempts to **install git** first when it is missing (Unix: via `install/boot-prereqs-git.sh` and your package manager; Windows: **winget** when available). If installation is not possible—for example, a non-GitHub **`BOTSTRAP_REPO`** without **`BOTSTRAP_BOOT_PREREQS_URL`**—it tells you to install Git manually. It clones the Botstrap repository into **`BOTSTRAP_HOME`** (default `~/.botstrap` on Unix, `%USERPROFILE%\.botstrap` on Windows), unless that directory is already a Git checkout. You can override the remote with **`BOTSTRAP_REPO`**. The default remote in `boot.sh` / `boot.ps1` is `https://github.com/an-lee/botstrap.git`.

Then the boot script runs **`install.sh`** (Unix) or **`install.ps1`** (Windows) from that clone.

### 2. Phase 0: prerequisites

Ensures the rest of the pipeline can run: installs **`registry/prerequisites.yaml`** (**git**, **curl**, **jq**, **yq**, **gum**) via the registry package layer after a minimal **yq** bootstrap on Unix (Unix: `install/boot-prereqs-git.sh` for git/curl, then `lib/pkg.sh`). Without **yq**, later phases cannot read the registry. If **gum** cannot be installed, Phase 2 falls back to **non-interactive defaults** on Unix; on Windows, Phase 2 is limited—see [Getting started](./GETTING_STARTED.md).

### 3. Phase 0b (Windows only)

Optional **OS tuning** (developer mode hints, long paths, execution policy, etc.) driven by `configs/os/windows.yaml`. Steps can require elevation or manual follow-up; the installer does not always stop on failure. See [Cross-platform notes](./CROSS_PLATFORM.md).

### 4. Phase 2: choices (TUI)

On **macOS/Linux**, if **gum** is available, an interactive flow asks for Git identity, **core** tools (multi-select from **`registry/core.yaml`**, all selected by default), editor, languages, databases, AI CLIs, theme, and optional apps. Answers are exported as **`BOTSTRAP_*`** environment variables (see [Reference](./REFERENCE.md)).

If **gum** is missing on Unix, the script exports **safe defaults** (including **`BOTSTRAP_CORE_TOOLS`** = all **`core.yaml`** names unless preset) and skips the interactive UI so automated runs do not hang.

On **native Windows**, Phase 2 matches Unix when **gum** is installed: the same prompts; without gum, the same non-interactive defaults apply.

### 5. Phase 3: configure

Persists **`core_tools=`** to **`~/.config/botstrap/core-tools.env`**, installs **selected core** from **`registry/core.yaml`** in registry order, then installs **optional** registry entries from Phase 2, then applies **`configs/`** templates (see [Configuration file map](./CONFIGURATION.md)). This phase may copy files to `~/.config`, append blocks to **`~/.zshrc`** and **`~/.bashrc`**, set global Git name/email, and place **sample** agent files under `~/.config/botstrap/agent/`.

### 6. Phase 4: verify

Runs **`verify`** for every tool in **`registry/prerequisites.yaml`**, then for **selected** core (from **`BOTSTRAP_CORE_TOOLS`**, else **`core-tools.env`**, else all **`registry/core.yaml`** for legacy installs), and prints a short summary. This phase requires **yq** on PATH.

## Where the project lives on your machine

After boot, your **Botstrap checkout** is at **`BOTSTRAP_HOME`**. That directory contains `install.sh`, `registry/`, `configs/`, `lib/`, and everything else in the repo. When you work from a **different** Git clone (for development), you set **`BOTSTRAP_ROOT`** to that clone’s path so phases resolve files correctly.

The thin CLI **`bin/botstrap`** in the repo is meant for a **local checkout**; it runs `git pull`, re-runs Phase 2+3, or runs verification from **`BOTSTRAP_ROOT`** (the parent of `bin/`). See [Reference](./REFERENCE.md).

## How to learn more

| Topic | Document |
|--------|----------|
| Install and trust | [Getting started](./GETTING_STARTED.md) |
| Installed stack and usage | [After install](./AFTER_INSTALL.md) |
| Defaults and customization | [Defaults & customization](./DEFAULTS_AND_CUSTOMIZATION.md) |
| CLI, env vars, artifacts | [Reference](./REFERENCE.md) |
| Template → home paths | [Configuration file map](./CONFIGURATION.md) |
| Phases, `lib/`, diagrams | [Architecture](./ARCHITECTURE.md) |
| YAML schema | [Registry specification](./REGISTRY_SPEC.md) |
| Why each tool exists | [Tool selection](./TOOL_SELECTION.md) |
| OS and package managers | [Cross-platform notes](./CROSS_PLATFORM.md) |
| Agents and automation | [AI agent friendliness](./AI_AGENT_FRIENDLINESS.md) |

---
layout: home

hero:
  image:
    src: /logo.svg
    alt: Botstrap
  text: Bootstrap for developers and AI agents
  tagline: YAML registries, non-interactive installs, agent-friendly layout—macOS, Linux, and Windows.
  actions:
    - theme: brand
      text: Getting started
      link: /GETTING_STARTED
    - theme: alt
      text: GitHub
      link: https://github.com/an-lee/botstrap

features:
  - title: Registry-driven
    details: Core and optional tools live in YAML registries instead of hardcoded install lists.
    link: /REGISTRY_SPEC
    linkText: Open
  - title: Phased install
    details: Prerequisites, core install, optional gum TUI, configuration, then verification.
    link: /ARCHITECTURE
    linkText: Open
  - title: Cross-platform
    details: boot.sh / boot.ps1, shared YAML registries, and winget-driven installs on Windows (WSL optional).
    link: /CROSS_PLATFORM
    linkText: Open
  - title: Agent-ready environment
    details: Stable layout for people and AI coding agents — predictable PATH, non-interactive tools by default, and structured scaffolding under configs/.
    link: /AI_AGENT_FRIENDLINESS
    linkText: Open
---

## What Botstrap does

1. **Boot** — Clone the repo to `~/.botstrap` (or `%USERPROFILE%\.botstrap`), then run the orchestrator (`install.sh` / `install.ps1`). Override clone URL with `BOTSTRAP_REPO`.
2. **Phase 0** — Install prerequisites: Unix installs `git`, `curl`, `jq`, `yq`, `gum` where possible; Windows requires **winget** and installs `git`, `yq`, `jq`, and `gum` when missing.
3. **Phase 0b** — Windows-only optional OS tuning from `configs/os/windows.yaml`.
4. **Phase 1** — Non-interactive install of every tool in `registry/core.yaml`.
5. **Phase 2** — Gum TUI choices (safe defaults when gum is missing or in CI; same behavior on Windows PowerShell).
6. **Phase 3** — Copy `configs/` templates and install optional registry selections.
7. **Phase 4** — Verify core tools and print a summary (optional selections on Windows depend on environment; see [After install](/AFTER_INSTALL)).

Read the full narrative in [Introduction](/INTRODUCTION). After setup, use [After install](/AFTER_INSTALL) for the installed stack and [Defaults & customization](/DEFAULTS_AND_CUSTOMIZATION) for defaults and changes. For commands, variables, and template paths, see [Reference](/REFERENCE) and [Configuration file map](/CONFIGURATION).

::: tip Local install
From a git checkout, set `BOTSTRAP_ROOT` and run `./install.sh`. See the [repository README](https://github.com/an-lee/botstrap) for details. [Contributing](/CONTRIBUTING) covers how to help with the project.
:::

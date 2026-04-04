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
    details: boot.sh / boot.ps1 and shared registry concepts; use WSL + install.sh on Windows for full Unix parity.
    link: /CROSS_PLATFORM
    linkText: Open
  - title: Agent-ready environment
    details: Stable layout for people and AI coding agents — predictable PATH, non-interactive tools by default, and structured scaffolding under configs/.
    link: /AI_AGENT_FRIENDLINESS
    linkText: Open
---

## What Botstrap does

1. **Boot** — Clone the repo to `~/.botstrap` (or `%USERPROFILE%\.botstrap`), then run the orchestrator (`install.sh` / `install.ps1`). Override clone URL with `BOTSTRAP_REPO`.
2. **Phase 0** — Install prerequisites (`git`, `curl`, `jq`, `yq`, `gum` where possible).
3. **Phase 0b** — Windows-only optional OS tuning from `configs/os/windows.yaml`.
4. **Phase 1** — Non-interactive install of every tool in `registry/core.yaml`.
5. **Phase 2** — Gum TUI choices on macOS/Linux (safe defaults when gum is missing or in CI).
6. **Phase 3** — Copy `configs/` templates and install optional registry selections.
7. **Phase 4** — Verify core tools and print a summary.

Read the full narrative in [Introduction](/INTRODUCTION). For commands, variables, and files touched on disk, see [Reference](/REFERENCE) and [Configuration](/CONFIGURATION).

::: tip Local install
From a git checkout, set `BOTSTRAP_ROOT` and run `./install.sh`. See the [repository README](https://github.com/an-lee/botstrap) for details. [Contributing](/CONTRIBUTING) covers how to help with the project.
:::

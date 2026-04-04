---
layout: home

hero:
  name: Botstrap
  text: Cross-platform developer bootstrap
  tagline: One entry point on macOS, Linux, and Windows — YAML registry, optional TUI, configs, and verification.
  actions:
    - theme: brand
      text: Read the architecture
      link: /ARCHITECTURE
    - theme: alt
      text: GitHub
      link: https://github.com/an-lee/botstrap

features:
  - title: Registry-driven
    details: Core and optional tools are defined in YAML registries instead of hardcoded install lists in the orchestrator.
  - title: Phased install
    details: Prerequisites, non-interactive core, interactive gum TUI for optional tools, configuration, then verification.
  - title: Cross-platform
    details: Same logical flow via boot.sh / boot.ps1, install scripts, and shared registry concepts across Unix and Windows.
  - title: AI-friendly layout
    details: Predictable PATH, non-interactive CLIs by default, and structured agent scaffolding under configs/.
---

## Quick install

**macOS / Linux**

```bash
curl -fsSL https://botstrap.org/install | bash
```

**Windows (PowerShell)**

```powershell
irm https://botstrap.org/install.ps1 | iex
```

For a local checkout, set `BOTSTRAP_ROOT` and run `./install.sh` (see the [repository README](https://github.com/an-lee/botstrap)).

## Documentation

- [Architecture](/ARCHITECTURE) — structure and boot sequence
- [Registry specification](/REGISTRY_SPEC) — YAML tool definitions
- [Tool selection](/TOOL_SELECTION) — how optional tools are chosen
- [Cross-platform notes](/CROSS_PLATFORM)
- [AI agent friendliness](/AI_AGENT_FRIENDLINESS)
- [Contributing](/CONTRIBUTING)

---
layout: home

hero:
  name: Botstrap
  text: Cross-platform bootstrap for developers and AI coding agents
  tagline: One entry point on macOS, Linux, and Windows — YAML registry, optional TUI, configs, and verification — with predictable PATH, non-interactive CLIs by default, and agent scaffolding under configs/.
  actions:
    - theme: brand
      text: Read the docs
      link: /ARCHITECTURE
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
    details: Same flow via boot.sh / boot.ps1 and shared registry concepts on Unix and Windows.
    link: /CROSS_PLATFORM
    linkText: Open
  - title: Agent-ready environment
    details: Stable layout for people and AI coding agents — predictable PATH, non-interactive tools by default, and structured scaffolding under configs/.
    link: /AI_AGENT_FRIENDLINESS
    linkText: Open
---

::: tip Local install
From a git checkout, set `BOTSTRAP_ROOT` and run `./install.sh`. See the [repository README](https://github.com/an-lee/botstrap) for details. [Contributing](/CONTRIBUTING) covers how to help with the project.
:::

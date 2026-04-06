# Tool selection rationale

This document explains why Botstrap includes each **prerequisite** and **core** tool and how **optional** groups are scoped. The goal is a baseline that works well for humans and for AI agents driving a terminal. **Core** rows are TUI-selectable (default all); **prerequisites** are Phase 0 only. For how items are installed after the TUI, see [Introduction](./INTRODUCTION.md) and [Registry specification](./REGISTRY_SPEC.md).

## Prerequisites (Phase 0)

Git, curl, jq, yq, and gum are defined in **`registry/prerequisites.yaml`** so the registry package layer and gum TUI can run. They are not part of the **core** multi-select.

## Core tools (Phase 2 → Phase 3)

### Shell and navigation

| Tool | Rationale |
|------|-----------|
| **zsh** (Linux; default shell on macOS) | Modern defaults, strong completion ecosystem; aligns with common developer setups. |
| **Starship** | Fast, cross-shell prompt with consistent info (git, lang versions); easy to theme. |
| **zoxide** | Smarter `cd` with frecency; reduces friction in long sessions and agent scripts. |
| **fzf** | Fuzzy finder for files, history, and pipes; ubiquitous in CLI workflows. |
| **bat** | Syntax-highlighted `cat`; improves log and config inspection. |
| **eza** | Modern `ls` with git awareness and trees. |
| **ripgrep** | Fast recursive search; default for code search in editors and agents. |
| **fd** | User-friendly `find` for scripts and quick discovery. |

### Version management

| Tool | Rationale |
|------|-----------|
| **mise** | Single tool for Node, Python, Ruby, Go, and more; replaces nvm/pyenv/rbenv fragmentation and keeps PATH deterministic for agents. **`uv`** (fast Python package manager) is installed alongside mise automatically. |

### Containers

| Tool | Rationale |
|------|-----------|
| **Docker** + **Docker Compose** | Standard way to run databases and services locally without polluting the host; agents often expect Docker for reproducible environments. |

### Git

| Tool | Rationale |
|------|-----------|
| **git** | Baseline VCS. |
| **GitHub CLI (`gh`)** | Non-interactive-friendly PR/issue flows from the terminal. |
| **lazygit** | TUI for complex git operations when desired. |
| **git-delta** | Readable diffs in the terminal and in git pagers. |

### Structured data and HTTP

| Tool | Rationale |
|------|-----------|
| **jq** | JSON is the lingua franca of APIs and agent outputs. |
| **yq** | Same for YAML (including Botstrap’s own registry). |
| **curlie / httpie** | Human-friendly HTTP CLI: **curlie** where upstream ships it (macOS/Windows); **httpie** on common Linux distros via `registry/core.yaml` mapping. |

### Terminal multiplexing and monitoring

| Tool | Rationale |
|------|-----------|
| **zellij** (or **tmux** where preferred) | Persistent sessions, layouts, and remote-friendly workflows. |
| **btop** | Interactive resource monitor. |
| **fastfetch** | Fast system info for screenshots and support requests. |

### Security

| Tool | Rationale |
|------|-----------|
| **age** | Simple file encryption. |
| **sops** | Encrypted secrets in YAML/JSON; common in GitOps and agent-assisted infra work. |

### Typography

| Tool | Rationale |
|------|-----------|
| **Nerd Font (e.g. Fira Code)** | Icons and glyphs for Starship, editors, and terminals without broken fallback boxes. |

### TUI prerequisite

| Tool | Rationale |
|------|-----------|
| **gum** | Cross-platform TUI for Phase 2; minimal dependency, consistent UX. |

## Optional tools (Phase 2)

Optional items are grouped so users can tailor the machine without breaking the baseline.

| Group | Rationale |
|-------|-----------|
| **Editor** | Optional GUI editors: Cursor, VS Code, Zed. **Neovim** (with LazyVim) is a **core** tool in **`registry/core.yaml`** when selected in the core list; the primary editor prompt still includes **`neovim`** so Phase 3 applies matching templates. |
| **Programming languages** | Runtimes are installed via **mise** when selected, keeping versions explicit and agent-repeatable. |
| **Databases** | PostgreSQL, MySQL, Redis, SQLite via **Docker** keeps the host clean and matches production-like setups. |
| **AI agent tools** | Claude Code, OpenClaw, Codex CLI, Gemini CLI, Ollama — users pick what they use; many require Node or native installers per upstream docs. |
| **Theme** | Catppuccin, Tokyo Night, Gruvbox, Nord, Rose Pine — visual consistency across terminal, prompt, and editor where configs exist. |
| **Optional apps** | 1Password CLI, Tailscale, ngrok, Postman — common but not universal. |

## What we intentionally avoid in core

- **Heavy GUI IDEs** in core — Cursor, VS Code, and Zed stay optional. **Neovim** is an exception: it is a small core tool when selected so **`nvim`**, LazyVim bootstrap, **`doctor`**, and **`update --tools`** stay consistent.
- **Native database daemons** — Docker-first for optional data stores.
- **Language-specific version managers** beyond mise — mise is the single source of truth for versions.

## Changing the set

- Add or adjust **prerequisite** tools in `registry/prerequisites.yaml` or **core** tools in `registry/core.yaml` and preserve YAML order if dependencies matter.
- Add **optional** entries in `registry/optional.yaml` and wire new TUI group logic if you add a new group `id`.

See `docs/CONTRIBUTING.md` for the contribution workflow.

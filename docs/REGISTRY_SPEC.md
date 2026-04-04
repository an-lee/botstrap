# Registry specification

Botstrap defines installable tools in YAML. There are two files:

- **`registry/core.yaml`** — Installed automatically in Phase 1 (non-interactive, opinionated baseline).
- **`registry/optional.yaml`** — Presented in Phase 2 (TUI); users choose editors, languages, databases, AI CLIs, themes, and optional apps.

## General rules

- **Encoding**: UTF-8.
- **Indentation**: Two spaces (YAML).
- **Names**: Tool `name` fields use lowercase letters, digits, and hyphens (`kebab-case`). They must be unique within their file.
- **Shell install snippets** (Unix): Multi-line scalar blocks are run with `bash` (e.g. `bash -c` or equivalent). Use non-interactive flags (`-y`, `--yes`) everywhere.
- **PowerShell snippets** (Windows): Use non-interactive `winget`, `scoop`, or documented silent installers.
- **Order**: In `core.yaml`, `tools` is an ordered list; Phase 1 should respect order so dependencies (e.g. `yq` before registry-driven loops) can be enforced in the orchestrator when needed.

## `registry/core.yaml` schema

Top-level keys:

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `schema_version` | integer | recommended | Bump when breaking the schema (default `1`). |
| `tools` | list | yes | Ordered list of core tool definitions. |

Each **tool** object:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Identifier; used by `pkg_install` and verify. |
| `description` | string | yes | Short human-readable summary. |
| `category` | string | yes | Logical grouping (e.g. `shell`, `git`, `container`, `security`). |
| `install` | map | yes | Platform-keyed install commands (see keys below). |
| `verify` | string | recommended | Single shell command that exits 0 when the tool works (e.g. `mise --version`). |
| `post_install` | string | no | Shell script run after install on Unix (optional on Windows in future). |
| `configure` | string | no | Human-oriented note or machine path mapping, e.g. `configs/shell/prompt.toml -> ~/.config/starship.toml` (Phase 3 interprets this). |

### `install` map keys (core)

The package layer picks the **first matching** key for the current environment. Implementations should define a deterministic resolution order.

| Key | When to use |
|-----|-------------|
| `darwin` | macOS (Homebrew or documented curl installer). |
| `linux-apt` | Debian / Ubuntu and derivatives (`apt`). |
| `linux-dnf` | Fedora / RHEL / derivatives (`dnf`). |
| `linux-pacman` | Arch Linux (`pacman`). |
| `linux` | Generic Linux when distro-specific key is absent (often `curl \| sh` installers). |
| `windows` | Windows (`winget` or PowerShell). |
| `all` | Cross-platform when the same command works everywhere (e.g. `npm install -g ...` after Node is available). |

**Note**: If both `linux-apt` and `linux` exist, the implementation should prefer the distro-specific key.

Optional extended keys (allowed if the pkg layer supports them):

- `linux-brew` — Linuxbrew when used as a gap-fill.
- `windows-scoop` — Fallback when `winget` lacks a package.

## `registry/optional.yaml` schema

Top-level keys:

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `schema_version` | integer | recommended | Default `1`. |
| `groups` | list | yes | TUI groups (editor, languages, etc.). |

Each **group** object:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Display name for the TUI (e.g. `Editor`). |
| `id` | string | recommended | Stable id (`editor`, `languages`, …) for env vars and scripts. |
| `select` | string | yes | `single` or `multiple`. |
| `items` | list | yes | Selectable entries. |

Each **item** object:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Tool id (kebab-case). |
| `description` | string | yes | Shown in the TUI. |
| `install` | map | yes | Same platform keys as core `install`. |
| `verify` | string | no | Post-install check when selected. |
| `requires` | list of strings | no | Names of other tools that must be installed first (e.g. `node` for npm-based CLIs). |
| `post_install` | string | no | Like core. |
| `configure` | string | no | Like core. |

### Environment variables

Phase 2 should export selections in a stable way, for example:

- Single-select group with `id` `editor`: `BOTSTRAP_EDITOR=cursor`
- Multi-select group with `id` `languages`: `BOTSTRAP_LANGUAGES=node,python,go` (comma-separated)

Exact naming is implemented in `install/phase-2-tui.sh`; contributors should document any new group `id` in `docs/CONTRIBUTING.md`.

## Validation

Contributors should keep YAML valid and avoid breaking `yq` queries used by `lib/pkg.sh`. Prefer adding a new tool via YAML before adding bespoke script logic.

## Example (minimal)

```yaml
schema_version: 1
tools:
  - name: example-cli
    description: "Example CLI"
    category: utility
    install:
      darwin: brew install example-cli
      linux-apt: sudo apt-get update && sudo apt-get install -y example-cli
      windows: winget install --id Example.ExampleCLI -e --accept-package-agreements
    verify: example-cli --version
```

See `registry/core.yaml` and `registry/optional.yaml` for the live manifests.

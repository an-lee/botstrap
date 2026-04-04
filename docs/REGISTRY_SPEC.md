# Registry specification

Botstrap defines installable tools in YAML. There are three files:

- **`registry/prerequisites.yaml`** — Installed in **Phase 0** only (non-interactive): **git**, **curl**, **jq**, **yq**, **gum** so registry parsing, TUI, and later installs can run. Same per-tool schema as **`core.yaml`**; passed to **`botstrap_pkg_install`** / **`Install-BotstrapPackageFromRegistry`** with this path.
- **`registry/core.yaml`** — Presented in **Phase 2** (TUI) as a multi-select list (all selected by default); installed after confirm in **Phase 3** for the subset stored in **`BOTSTRAP_CORE_TOOLS`** / **`~/.config/botstrap/core-tools.env`**.
- **`registry/optional.yaml`** — Presented in Phase 2 (TUI); users choose editors, languages, databases, AI CLIs, themes, and optional apps.

## General rules

- **Encoding**: UTF-8.
- **Indentation**: Two spaces (YAML).
- **Names**: Tool `name` fields use lowercase letters, digits, and hyphens (`kebab-case`). They must be unique within their file.
- **Shell install snippets** (Unix): Multi-line scalar blocks are run with `bash` (e.g. `bash -c` or equivalent). Use non-interactive flags (`-y`, `--yes`) everywhere.
- **PowerShell snippets** (Windows): Use non-interactive `winget`, `scoop`, or documented silent installers.
- **Order**: In each `tools` list, order is significant: Phase 0 / Phase 3 install in YAML order (e.g. dependency-friendly ordering within **`prerequisites.yaml`** and **`core.yaml`**).

## `registry/prerequisites.yaml` schema

Same as **`registry/core.yaml`** below: top-level **`schema_version`**, **`tools`** list, and the same fields on each tool (**`name`**, **`description`**, **`category`**, **`install`**, **`verify`**, optional **`verify_windows`**, **`post_install`**, **`post_install_windows`**, **`configure`**). Only **`prerequisites.yaml`** and **`core.yaml`** use this shape; **`optional.yaml`** uses **`groups`**.

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
| `verify` | string | recommended | Single shell command that exits 0 when the tool works (e.g. `mise --version`). Often `bash -c` on Unix. |
| `verify_windows` | string | no | PowerShell snippet for Windows verification when `verify` is bash-only or needs a different PATH (e.g. `mise`). If absent, the Windows package layer may normalize `verify` (e.g. strip `bash -c`) or fall back to `Get-Command`. |
| `post_install` | string | no | Bash script run after install on Unix (`lib/pkg.sh`). |
| `post_install_windows` | string | no | PowerShell script run after install on Windows (`lib/pkg.ps1`). If absent on Windows, `post_install` is not run (Unix bash). |
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
| `windows` | Windows (`winget` or PowerShell). Omit this key for a tool to skip native Windows install (e.g. Linux-only shells). |
| `all` | Cross-platform when the same command works everywhere (e.g. `npm install -g ...` after Node is available). On Windows, prefer a dedicated `windows` entry when the `all` snippet is bash-only. |

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
| `verify_windows` | string | no | Like core `verify_windows`. |
| `requires` | list of strings | no | Names of other tools that must be installed first (e.g. `node` for npm-based CLIs). |
| `post_install` | string | no | Like core. |
| `post_install_windows` | string | no | Like core `post_install_windows`. |
| `configure` | string | no | Like core. |

### Environment variables

Phase 2 should export selections in a stable way, for example:

- Single-select group with `id` `editor`: `BOTSTRAP_EDITOR=cursor`
- Multi-select group with `id` `languages`: `BOTSTRAP_LANGUAGES=node,python,go` (comma-separated)

Exact naming is implemented in `install/phase-2-tui.sh`; contributors should document any new group `id` in `docs/CONTRIBUTING.md` and `docs/REFERENCE.md`.

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

See `registry/prerequisites.yaml`, `registry/core.yaml`, and `registry/optional.yaml` for the live manifests.

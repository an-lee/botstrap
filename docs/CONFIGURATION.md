# Configuration

Botstrap ships templates under **`configs/`** in the repository. **Phase 3** (`install/phase-3-configure.sh` on Unix; `install/phase-3-configure.ps1` on Windows) copies or merges them according to TUI selections and fixed rules. This page maps **repository paths** to **destination paths** on your machine.

For environment variables that drive Phase 3, see [Reference](./REFERENCE.md). For Windows-only OS policy tuning (not under `configs/` in the same way), see [Cross-platform notes](./CROSS_PLATFORM.md) (`configs/os/windows.yaml`).

## `configs/git/`

| Repository file | Destination / effect |
|-----------------|----------------------|
| `configs/git/gitconfig` | Copied to **`~/.gitconfig`** only when that file does **not** already exist (Unix Phase 3). |
| `configs/git/gitignore_global` | Copied to **`~/.gitignore_global`**; `git config --global core.excludesfile` set to that path when Git is available. |

Global **`user.name`** and **`user.email`** are set from **`BOTSTRAP_GIT_NAME`** and **`BOTSTRAP_GIT_EMAIL`** when non-empty (not from static files).

## `configs/shell/`

| Repository file | Destination / effect |
|-----------------|----------------------|
| `configs/shell/prompt.toml` | Copied to **`~/.config/starship.toml`** (overwrites when present in repo). |
| `configs/shell/aliases` | Appended once to **`~/.zshrc`** and **`~/.bashrc`** inside a block marked `# botstrap aliases`. |
| `configs/shell/functions` | Appended once to **`~/.zshrc`** and **`~/.bashrc`** inside a block marked `# botstrap functions`. |

## `configs/editor/`

Applied when **`BOTSTRAP_EDITOR`** matches (Unix Phase 3):

| Editor choice | Repository file | Destination |
|---------------|-----------------|-------------|
| `cursor` | `configs/editor/cursor-settings.json` | `~/.cursor/settings.json` |
| `vscode` | `configs/editor/vscode.json` | `~/.config/Code/User/settings.json` |
| `neovim` | `configs/editor/neovim/init.lua` | `~/.config/nvim/init.lua` |

Other editor values skip these copies.

## `configs/agent/`

Copied as **samples** only (Unix Phase 3):

| Repository file | Destination |
|-----------------|-------------|
| `configs/agent/AGENTS.md` | `~/.config/botstrap/agent/AGENTS.md.sample` |
| `configs/agent/cursorrules` | `~/.config/botstrap/agent/cursorrules.sample` |
| `configs/agent/claude-config.json` | `~/.config/botstrap/agent/claude-config.json.sample` |

Rename or merge into project-specific locations as needed; Botstrap does not overwrite live Cursor or Claude config paths by default.

## `configs/os/`

| Repository file | Consumer |
|-----------------|----------|
| `configs/os/windows.yaml` | **Phase 0b** on Windows (`install/phase-0b-os-tune.ps1` + `lib/os-tune-windows.ps1`). |

## Generated state (not under `configs/` in repo)

Phase 3 also writes:

- **`~/.config/botstrap/theme.env`** — `theme=<value>`
- **`~/.config/botstrap/editor.env`** — `editor=<value>`

## Optional tools and themes

Selections from Phase 2 trigger installs from **`registry/optional.yaml`** during Phase 3 (via **`lib/pkg`**), not only file copies from `configs/`. Theme bundles may live under **`themes/`** in the repo; wiring depends on optional registry entries and scripts—see [Registry specification](./REGISTRY_SPEC.md) and [Architecture](./ARCHITECTURE.md).

## Related

- [Introduction](./INTRODUCTION.md) — where Phase 3 fits in the install story.
- [Getting started](./GETTING_STARTED.md) — running the installer.

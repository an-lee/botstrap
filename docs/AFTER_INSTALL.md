# After install

This guide is for **developers** and **AI coding agents** who need a clear picture of **what Botstrap put on the machine** and **how to use** the common pieces. For defaults, automation, and changing templates, see [Defaults & customization](./DEFAULTS_AND_CUSTOMIZATION.md). For CLI flags, env vars, and file paths, see [Reference](./REFERENCE.md).

## Where the checkout lives

After boot, the Git checkout is at **`BOTSTRAP_HOME`** (default **`~/.botstrap`** on macOS/Linux, **`%USERPROFILE%\.botstrap`** on Windows). That directory is **`BOTSTRAP_ROOT`** when you run the installer or `bin/botstrap` from it.

From a **new shell** after Phase 3:

- **Unix / Git Bash:** `~/.config/botstrap/env.sh` sets **`BOTSTRAP_ROOT`** and prepends **`$BOTSTRAP_ROOT/bin`** to **`PATH`** (via the `# botstrap PATH` block in your rc file). Run **`botstrap`** from anywhere.
- **Native Windows PowerShell:** The profile block sets **`$env:BOTSTRAP_ROOT`**, updates **`PATH`**, and defines the **`botstrap`** function. Open a new session or dot-source **`$PROFILE`**.

Useful commands (same semantics on Bash and PowerShell entry points):

| Command | Purpose |
|---------|---------|
| `botstrap version` | Semver from the `version` file. |
| `botstrap update` | `git pull --ff-only` in the checkout only. |
| `botstrap reconfigure` | Phase 2 (TUI or defaults) + Phase 3. |
| `botstrap doctor` | Status lines + verification (see below). |

Details: [Reference — `bin/botstrap` CLI](./REFERENCE.md#binbotstrap-cli).

## Prerequisites and core stack

The **prerequisite** set is **[`registry/prerequisites.yaml`](https://github.com/an-lee/botstrap/blob/main/registry/prerequisites.yaml)** (Phase 0). The **selectable core** list is **[`registry/core.yaml`](https://github.com/an-lee/botstrap/blob/main/registry/core.yaml)**; Phase 3 installs the subset you chose in the TUI (default: all), persisted as **`core_tools=`** in **`~/.config/botstrap/core-tools.env`**.

Rationale for why each tool exists: [Tool selection](./TOOL_SELECTION.md).

**`botstrap doctor` verification:**

- **Unix:** Runs **`install/phase-4-verify.sh`**, which verifies **prerequisites**, then **selected** core (see [Reference](./REFERENCE.md#phase-4-verification)). It does **not** re-verify optional TUI selections.
- **Windows:** Runs **`install/phase-4-verify.ps1`**, which verifies prerequisites, selected core, **and** optional groups **when `BOTSTRAP_*` variables are set** (as during install). In a **fresh** PowerShell session, **`BOTSTRAP_LANGUAGES`**, **`BOTSTRAP_DATABASES`**, etc. may be unset, so optional checks may not run the same way as at the end of install.

To confirm optional pieces manually, use **`command -v`**, **`mise ls`**, **`docker image ls`**, or the **`verify`** snippets in **`registry/optional.yaml`**.

## Optional stack (Phase 2 → Phase 3)

Interactive choices (when **gum** is available) map to groups in **[`registry/optional.yaml`](https://github.com/an-lee/botstrap/blob/main/registry/optional.yaml)**: editor, languages, databases, AI tools, theme, optional apps.

**What is persisted on disk:**

- **`~/.config/botstrap/core-tools.env`** — `core_tools=<comma-separated names>` from **`registry/core.yaml`** (Windows: same path under **`%USERPROFILE%\.config\botstrap\`**).
- **`~/.config/botstrap/theme.env`** — `theme=<value>` (Windows: under **`%USERPROFILE%\.config\botstrap\`**).
- **`~/.config/botstrap/editor.env`** — `editor=<value>`.

Other groups (languages, databases, AI CLIs, optional apps) are **not** written to separate state files. Infer them from installed binaries/images or run **`botstrap reconfigure`** to change them.

## How to use common pieces

### Shell, Starship, zoxide

Open a **new** terminal or **`source ~/.zshrc`** / **`~/.bashrc`** (Unix) so PATH and Botstrap blocks load. Starship config: **`~/.config/starship.toml`** (from `configs/shell/prompt.toml`). On Windows, Phase 3 adds profile blocks for Starship and zoxide when missing.

### mise (optional languages)

Core install includes **mise**. Optional language rows run **`mise use --global …`** with PATH including **`~/.local/bin`** (Unix) or **`%LOCALAPPDATA%\mise\bin`** and **`%USERPROFILE%\.local\bin`** (Windows). Check **`mise ls`** and **`mise current`**.

### Docker database images

If you selected databases, Phase 3 pulls images such as **`postgres:16-alpine`**, **`mysql:8`**, **`redis:7-alpine`**. They are not started automatically. Run containers with **`docker run`** or Compose per [Docker documentation](https://docs.docker.com/).

### Editors

- **VS Code:** `code` on PATH after install.
- **Neovim:** `nvim --version`.
- **Cursor / Zed:** see optional registry **`verify`** / desktop integration for your OS.

### AI CLIs

Optional entries install tools such as **`claude`**, **`codex`**, **`openclaw`**, **`ollama`** where defined in **`registry/optional.yaml`**. Many npm-based CLIs expect **Node** on PATH (often via mise). **`gemini`** may require a manual step per Google’s current distribution.

### Themes

Theme choice is recorded in **`theme.env`**. Assets live under **`themes/`** in the repo (e.g. **catppuccin**, **tokyo-night**); wiring is described in [Architecture](./ARCHITECTURE.md) and the optional registry. Some theme ids are placeholders until extended under **`themes/`**.

## Related

- [Defaults & customization](./DEFAULTS_AND_CUSTOMIZATION.md) — TUI defaults and how to change config.
- [Configuration file map](./CONFIGURATION.md) — `configs/` → home paths.
- [Getting started](./GETTING_STARTED.md) — install and trust.

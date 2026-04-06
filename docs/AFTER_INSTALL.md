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
| `botstrap` | No subcommand: **`gum choose`** menu when the terminal is interactive and **`gum`** is installed; otherwise usage (exit **1**). Prefer explicit subcommands in scripts and for **AI agents**. |
| `botstrap version` | Semver from the `version` file. |
| `botstrap self-update` | `git pull --ff-only` in the checkout (refresh Botstrap only). |
| `botstrap update` | Interactive: choose repo refresh, tool upgrades, or both. Non-interactive: same as **`self-update`**, with a hint to use **`--tools`** / **`--all`**. **`botstrap update --tools`** upgrades packages/images defined in registry **`update`** maps for prerequisites, your selected core tools, and persisted optional selections. |
| `botstrap reconfigure` | Phase 2 (TUI or defaults) + Phase 3. |
| `botstrap doctor` | Status lines + verification (see below). |
| `botstrap uninstall` | Removes Phase 3 **shell hooks** (rc/profile markers and **`env.sh`** on Unix). Optional **`--purge`** clears **`~/.config/botstrap`**; optional **`--remove-checkout`** deletes the clone. Does **not** remove packages or dotfiles Botstrap copied outside that config dir. |

Details: [Reference — `bin/botstrap` CLI](./REFERENCE.md#binbotstrap-cli).

## Prerequisites and core stack

The **prerequisite** set is **[`registry/prerequisites.yaml`](https://github.com/an-lee/botstrap/blob/main/registry/prerequisites.yaml)** (Phase 0). The **selectable core** list is **[`registry/core.yaml`](https://github.com/an-lee/botstrap/blob/main/registry/core.yaml)**; Phase 3 installs the subset you chose in the TUI (default: all), persisted as **`core_tools=`** in **`~/.config/botstrap/core-tools.env`**.

Rationale for why each tool exists: [Tool selection](./TOOL_SELECTION.md).

**`botstrap doctor` verification:**

- **Unix:** Runs **`install/phase-4-verify.sh`**, which verifies **prerequisites**, then **selected** core (see [Reference](./REFERENCE.md#phase-4-verification)). It does **not** re-verify optional TUI selections.
- **Windows:** Runs **`install/phase-4-verify.ps1`**, which verifies prerequisites, selected core, **and** optional groups **when `BOTSTRAP_*` variables are set** (as during install). In a **fresh** PowerShell session, **`BOTSTRAP_LANGUAGES`**, **`BOTSTRAP_DATABASES`**, etc. may be unset, so optional checks may not run the same way as at the end of install.

To confirm optional pieces manually, use **`command -v`**, **`mise ls`**, **`docker image ls`**, or the **`verify`** snippets in **`registry/optional.yaml`**.

## Optional stack (Phase 2 → Phase 3)

Interactive choices (when **gum** is available) map to **[`registry/core.yaml`](https://github.com/an-lee/botstrap/blob/main/registry/core.yaml)** (core tools, including **Neovim** when selected) and groups in **[`registry/optional.yaml`](https://github.com/an-lee/botstrap/blob/main/registry/optional.yaml)**: optional GUI editors (Cursor, VS Code, Zed), languages, databases, AI tools, theme, optional apps.

**What is persisted on disk:**

- **`~/.config/botstrap/core-tools.env`** — `core_tools=<comma-separated names>` from **`registry/core.yaml`** (Windows: same path under **`%USERPROFILE%\.config\botstrap\`**).
- **`~/.config/botstrap/optional-selections.env`** — `languages=`, `databases=`, `ai_tools=`, `optional_apps=` (comma-separated where applicable) for **`botstrap update --tools`** and reconfigure TUI defaults.
- **`~/.config/botstrap/theme.env`** — `theme=<value>` (Windows: under **`%USERPROFILE%\.config\botstrap\`**).
- **`~/.config/botstrap/editor.env`** — `editor=<value>`.

## How to use common pieces

### Shell, Starship, zoxide

Open a **new** terminal or **`source ~/.zshrc`** / **`~/.bashrc`** (Unix) so PATH and Botstrap blocks load. Starship config: **`~/.config/starship.toml`** (from `configs/shell/prompt.toml`). On Windows, Phase 3 adds profile blocks for Starship and zoxide when missing.

### Zellij

When **`zellij`** is in **`core_tools`**, Phase 3 installs it and on **Windows** also writes a `default_shell` line to **`config.kdl`** so new panes launch **PowerShell** (or `pwsh` 7+ when available) instead of `cmd.exe`. The config file location is resolved via `zellij setup --check`; fallback is **`%USERPROFILE%\.config\zellij\config.kdl`**. On Unix no automatic config is written; use `zellij setup --dump-config` to create a starter file.

### mise (optional languages)

Core install includes **mise**. Optional language rows run **`mise use --global …`** with PATH including **`~/.local/bin`** (Unix) or **`%LOCALAPPDATA%\mise\bin`** and **`%USERPROFILE%\.local\bin`** (Windows). Check **`mise ls`** and **`mise current`**.

**`uv`** (Astral's fast Python package and project manager) is also installed automatically during the **`mise` post_install** step, alongside Node and Python. It is available on PATH after opening a new shell. Verify with **`uv --version`**.

### Docker database images

If you selected databases, Phase 3 pulls images such as **`postgres:16-alpine`**, **`mysql:8`**, **`redis:7-alpine`**. They are not started automatically. Run containers with **`docker run`** or Compose per [Docker documentation](https://docs.docker.com/).

### Editors

- **VS Code:** `code` on PATH after install.
- **Neovim:** installed when **`neovim`** is in **`core_tools`**; LazyVim bootstrap runs via core **`post_install`**. Check `nvim --version`.
- **Cursor / Zed:** see optional registry **`verify`** / desktop integration for your OS.

### AI CLIs

Optional entries install tools such as **`claude`**, **`codex`**, **`openclaw`**, **`ollama`** where defined in **`registry/optional.yaml`**. Many npm-based CLIs expect **Node** on PATH (often via mise). **`gemini`** may require a manual step per Google’s current distribution.

### Themes

Theme choice is recorded in **`theme.env`**. Phase 3 copies **`themes/<id>/starship.toml`** to your Starship config when present, and merges **`themes/<id>/editor.json`** into Cursor/VS Code settings when you chose that editor. Details: [Configuration file map](./CONFIGURATION.md#themes).

## Related

- [Defaults & customization](./DEFAULTS_AND_CUSTOMIZATION.md) — TUI defaults and how to change config.
- [Configuration file map](./CONFIGURATION.md) — `configs/` → home paths.
- [Getting started](./GETTING_STARTED.md) — install and trust.

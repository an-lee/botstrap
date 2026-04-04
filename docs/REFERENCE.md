# Reference

Operational facts: **CLI**, **environment variables**, and **artifacts** Botstrap creates or expects. Behavior described here matches the shell and PowerShell sources in the repository. For a post-install inventory and **`botstrap doctor`** behavior (core vs optional verification), see [After install](./AFTER_INSTALL.md). For defaults and customization workflows, see [Defaults & customization](./DEFAULTS_AND_CUSTOMIZATION.md).

## `bin/botstrap` CLI

**Unix / Git Bash:** **`bin/botstrap`** (Bash) resolves the repository root as the parent of **`bin/`** and does **not** read `BOTSTRAP_HOME` unless you set **`BOTSTRAP_ROOT`** for subprocesses yourself.

**Native Windows PowerShell:** **`bin/botstrap.ps1`** exposes the same subcommands and runs **`install/phase-2-tui.ps1`**, **`install/phase-3-configure.ps1`**, and **`install/phase-4-verify.ps1`** for **`reconfigure`** / **`doctor`**. It does **not** invoke Bash.

| Command | Behavior |
|---------|----------|
| `botstrap version` | Prints `botstrap <semver>` from the **`version`** file at repo root, or `unknown` if missing. |
| `botstrap update` | Runs **`git pull --ff-only`** in the repo root. Does **not** re-run install phases or migration scripts. |
| `botstrap reconfigure` | **Bash:** sets **`BOTSTRAP_ROOT`**, runs **`lib/detect`**, then sources **`install/phase-2-tui.sh`** and **`install/phase-3-configure.sh`** only. **PowerShell:** sets **`BOTSTRAP_ROOT`**, dot-sources **`install/phase-2-tui.ps1`** and **`install/phase-3-configure.ps1`**. |
| `botstrap doctor` | **Bash:** prints a short **status** header (`BOTSTRAP_ROOT`, semver, optional git head, whether **`~/.config/botstrap/env.sh`** exists), then runs **`install/phase-4-verify.sh`**. **PowerShell:** similar header (profile **`# botstrap PATH`** hook instead of **`env.sh`**), then dot-sources **`install/phase-4-verify.ps1`**. Exits **0** if every verify passes, **1** if **`yq`** is missing or any verify fails. |

Any other first argument prints usage and exits with code 1.

**Note:** There is **no** `botstrap uninstall` subcommand in the current CLI.

## Boot and install environment variables

| Variable | Used by | Purpose |
|----------|---------|---------|
| `BOTSTRAP_HOME` | `boot.sh`, `boot.ps1` | Directory to clone or use as the Botstrap Git checkout (default: `$HOME/.botstrap` / `%USERPROFILE%\.botstrap`). |
| `BOTSTRAP_REPO` | `boot.sh`, `boot.ps1` | Git remote URL for clone (default: `https://github.com/an-lee/botstrap.git`). |
| `BOTSTRAP_BOOT_PREREQS_URL` | `boot.sh` | Optional raw HTTPS URL to **`install/boot-prereqs-git.sh`** when **`BOTSTRAP_REPO`** is not GitHub-hosted and git is missing (so boot can still source the prerequisite installer). |
| `BOTSTRAP_ROOT` | `install.sh`, phases, `bin/botstrap` | Absolute path to the Botstrap checkout containing `registry/`, `install/`, etc. Set automatically by `install.sh`; required when sourcing phases manually. |

## Phase 2 selection variables (Unix)

Set by **`install/phase-2-tui.sh`** (or defaults when gum is missing). Group ids are documented in that file’s header.

| Variable | Meaning |
|----------|---------|
| `BOTSTRAP_GIT_NAME` | Global Git `user.name` (Phase 3). |
| `BOTSTRAP_GIT_EMAIL` | Global Git `user.email` (Phase 3). |
| `BOTSTRAP_CORE_TOOLS` | Comma-separated tool **`name`** values from **`registry/core.yaml`** to install in Phase 3 (registry order). Set by the TUI (default: all names) or non-interactive defaults; may be preset for automation. |
| `BOTSTRAP_EDITOR` | One of: `cursor`, `vscode`, `neovim`, `zed`, `none`. |
| `BOTSTRAP_LANGUAGES` | Comma-separated mise-related choices: `node`, `python`, `ruby`, `go`, `rust`, `java`, `elixir`, `php`, `none`, … |
| `BOTSTRAP_DATABASES` | Comma-separated: `postgresql`, `mysql`, `redis`, `sqlite`, `none`, … |
| `BOTSTRAP_AI_TOOLS` | Comma-separated: `claude-code`, `openclaw`, `codex`, `gemini`, `ollama`, `none`, … |
| `BOTSTRAP_THEME` | One of: `catppuccin`, `tokyo-night`, `gruvbox`, `nord`, `rose-pine`. |
| `BOTSTRAP_OPTIONAL_APPS` | Comma-separated: `1password-cli`, `tailscale`, `ngrok`, `postman`, `none`, … |

Phase 3 installs **core** via **`BOTSTRAP_CORE_TOOLS`** and **`registry/core.yaml`**, then passes the remaining variables into **`lib/pkg`** helpers for **`registry/optional.yaml`**.

## Windows OS tuning variables

See [Cross-platform notes](./CROSS_PLATFORM.md) for **`BOTSTRAP_OS_TUNE`**, **`BOTSTRAP_OS_TUNE_SKIP`**, and **`BOTSTRAP_OS_TUNE_UTF8`**.

## Artifacts and side effects (Unix Phase 3)

Unless otherwise noted, paths are under **`$HOME`**.

| Action | Condition |
|--------|-----------|
| `~/.config/`, `~/.config/git/` | Created if needed. |
| `~/.gitconfig` | Copied from `configs/git/gitconfig` **only if** `~/.gitconfig` does **not** already exist. |
| Optional registry installs | Editor, languages, databases, AI tools, theme, optional apps from **`registry/optional.yaml`**. |
| `~/.config/starship.toml` | Overwritten from `configs/shell/prompt.toml` when that file exists in the repo. |
| `~/.gitignore_global` | Copied from `configs/git/gitignore_global`; `core.excludesfile` set globally. |
| Git user.name / user.email | Set from `BOTSTRAP_GIT_*` when non-empty. |
| `~/.zshrc`, `~/.bashrc` | Appended **once** (marker-guarded) with contents of `configs/shell/aliases`, `configs/shell/functions`, and `configs/shell/env_path_snippet.bash` when those repo files exist. The PATH snippet sources **`~/.config/botstrap/env.sh`**. |
| `~/.config/botstrap/core-tools.env` | **`core_tools=`** comma-separated list (persisted Phase 3) for **`botstrap doctor`** / reconfigure default core selection when **`BOTSTRAP_CORE_TOOLS`** is not set in the shell. |
| `~/.config/botstrap/env.sh` | **Unix Phase 3:** sets **`BOTSTRAP_ROOT`** and prepends **`$BOTSTRAP_ROOT/bin`** to **`PATH`** (duplicate-safe). Regenerated each Phase 3 run. |
| Editor configs | **cursor:** `~/.cursor/settings.json` from `configs/editor/cursor-settings.json`. **vscode:** `~/.config/Code/User/settings.json` from `configs/editor/vscode.json`. **neovim:** `~/.config/nvim/init.lua` from `configs/editor/neovim/init.lua`. |
| `~/.config/botstrap/theme.env`, `editor.env` | Small key=value files for theme and editor. |
| `~/.config/botstrap/agent/*.sample` | Copies of `configs/agent/AGENTS.md`, `cursorrules`, `claude-config.json` as **`.sample`** files (not live agent config unless you copy them). |

## Artifacts and side effects (Windows Phase 3)

Paths use **`%USERPROFILE%`** where relevant.

| Action | Condition |
|--------|-----------|
| **`%USERPROFILE%\.config\botstrap\core-tools.env`** | **`core_tools=`** persisted list (Phase 3) for **`doctor`** / TUI defaults when **`BOTSTRAP_CORE_TOOLS`** is unset. |
| PowerShell **profile** (`$PROFILE`, or **`Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`** if **`$PROFILE`** is empty) | Appended **once** (marker-guarded) with **`# botstrap PATH`**: sets **`$env:BOTSTRAP_ROOT`** to the checkout, prepends **`$BOTSTRAP_ROOT\bin`** to **`$env:PATH`**, and defines **`function Global:botstrap`** that invokes **`bin\botstrap.ps1`**. Also appends **`# botstrap starship`**, **`# botstrap zoxide`**, and **`# botstrap aliases`** blocks when missing. |

There is **no** **`~/.config/botstrap/env.sh`** on native Windows; the profile block is the shell hook for the **`botstrap`** command.

## Phase 4 verification

- **Unix (`install/phase-4-verify.sh`):** Verifies every tool in **`registry/prerequisites.yaml`**, then **selected** core: if **`BOTSTRAP_CORE_TOOLS`** is set in the environment (including empty), uses that; else if **`~/.config/botstrap/core-tools.env`** contains **`core_tools=`**, uses its value; else verifies **all** names in **`registry/core.yaml`** (legacy installs without persistence). Warns per failure; exits **1** if **`yq`** is missing or any run verify fails. **Optional** TUI selections are **not** verified on Unix.
- **Windows (`install/phase-4-verify.ps1`):** Same **prerequisites** + **selected core** resolution via **`Get-BotstrapCoreToolNamesForVerify`**, then verifies **optional** groups when **`BOTSTRAP_*`** variables are set (see [After install](./AFTER_INSTALL.md)).

## Related

- [After install](./AFTER_INSTALL.md) — installed stack, `doctor`, persisted selections.
- [Defaults & customization](./DEFAULTS_AND_CUSTOMIZATION.md) — defaults and how to change config.
- [Configuration file map](./CONFIGURATION.md) — template tree under `configs/` → home paths.
- [Architecture](./ARCHITECTURE.md) — phase scripts and `lib/` overview.

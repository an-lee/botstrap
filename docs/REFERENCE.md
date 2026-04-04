# Reference

Operational facts: **CLI**, **environment variables**, and **artifacts** Botstrap creates or expects. Behavior described here matches the shell and PowerShell sources in the repository.

## `bin/botstrap` CLI

The script lives at **`bin/botstrap`** (Bash). It resolves the repository root as the parent of **`bin/`** and does **not** read `BOTSTRAP_HOME` unless you set **`BOTSTRAP_ROOT`** for subprocesses yourself.

| Command | Behavior |
|---------|----------|
| `botstrap version` | Prints `botstrap <semver>` from the **`version`** file at repo root, or `unknown` if missing. |
| `botstrap update` | Runs **`git pull --ff-only`** in the repo root. Does **not** re-run install phases or migration scripts. |
| `botstrap reconfigure` | Sets **`BOTSTRAP_ROOT`** to the repo root, runs **`lib/detect`**, then sources **`install/phase-2-tui.sh`** and **`install/phase-3-configure.sh`** only. |
| `botstrap doctor` | Prints a short **status** header (`BOTSTRAP_ROOT`, semver, optional git head, whether **`~/.config/botstrap/env.sh`** exists), then runs **`install/phase-4-verify.sh`** (core registry verification). Exits **0** if every verify passes, **1** if **`yq`** is missing or any verify fails. |

Any other first argument prints usage and exits with code 1.

**Note:** There is **no** `botstrap uninstall` subcommand in the current CLI.

## Boot and install environment variables

| Variable | Used by | Purpose |
|----------|---------|---------|
| `BOTSTRAP_HOME` | `boot.sh`, `boot.ps1` | Directory to clone or use as the Botstrap Git checkout (default: `$HOME/.botstrap` / `%USERPROFILE%\.botstrap`). |
| `BOTSTRAP_REPO` | `boot.sh`, `boot.ps1` | Git remote URL for clone (default: `https://github.com/an-lee/botstrap.git`). |
| `BOTSTRAP_BOOT_PREREQS_URL` | `boot.sh` | Optional raw HTTPS URL to **`install/boot-prereqs-git.sh`** when **`BOTSTRAP_REPO`** is not GitHub-hosted and git is missing (so boot can still source the prerequisite installer). |
| `BOTSTRAP_ROOT` | `install.sh`, phases, `bin/botstrap` | Absolute path to the Botstrap checkout containing `registry/`, `install/`, etc. Set automatically by `install.sh`; required when sourcing phases manually. |
| `BOTSTRAP_LOG_COLOR` | `lib/log.sh` (Unix only) | Set to `0` to disable color output from logging helpers (default: `1`). Useful in CI or non-terminal environments. |

## Phase 2 selection variables (Unix)

Set by **`install/phase-2-tui.sh`** (or defaults when gum is missing). Group ids are documented in that file’s header.

| Variable | Meaning |
|----------|---------|
| `BOTSTRAP_GIT_NAME` | Global Git `user.name` (Phase 3). |
| `BOTSTRAP_GIT_EMAIL` | Global Git `user.email` (Phase 3). |
| `BOTSTRAP_EDITOR` | One of: `cursor`, `vscode`, `neovim`, `zed`, `none`. |
| `BOTSTRAP_LANGUAGES` | Comma-separated mise-related choices: `node`, `python`, `ruby`, `go`, `rust`, `java`, `elixir`, `php`, `none`, … |
| `BOTSTRAP_DATABASES` | Comma-separated: `postgresql`, `mysql`, `redis`, `sqlite`, `none`, … |
| `BOTSTRAP_AI_TOOLS` | Comma-separated: `claude-code`, `openclaw`, `codex`, `gemini`, `ollama`, `none`, … |
| `BOTSTRAP_THEME` | One of: `catppuccin`, `tokyo-night`, `gruvbox`, `nord`, `rose-pine`. |
| `BOTSTRAP_OPTIONAL_APPS` | Comma-separated: `1password-cli`, `tailscale`, `ngrok`, `postman`, `none`, … |

Phase 3 passes these into **`lib/pkg`** helpers to install matching rows in **`registry/optional.yaml`**.

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
| `~/.config/botstrap/env.sh` | **Unix Phase 3:** sets **`BOTSTRAP_ROOT`** and prepends **`$BOTSTRAP_ROOT/bin`** to **`PATH`** (duplicate-safe). Regenerated each Phase 3 run. |
| Editor configs | **cursor:** `~/.cursor/settings.json` from `configs/editor/cursor-settings.json`. **vscode:** `~/.config/Code/User/settings.json` from `configs/editor/vscode.json`. **neovim:** `~/.config/nvim/init.lua` from `configs/editor/neovim/init.lua`. |
| `~/.config/botstrap/theme.env`, `editor.env` | Small key=value files for theme and editor. |
| `~/.config/botstrap/agent/*.sample` | Copies of `configs/agent/AGENTS.md`, `cursorrules`, `claude-config.json` as **`.sample`** files (not live agent config unless you copy them). |

## Phase 4 verification

- Reads every **`name`** in **`registry/core.yaml`** with **yq**.
- Runs each tool’s **`verify`** command via **`botstrap_pkg_verify`**.
- Warns per failure, prints total failure count, prints **`version`** file contents, and suggests re-running Phase 2 + Phase 3 manually if needed.
- Exits **1** if **`yq`** is missing or if **any** verify fails (so **`botstrap doctor`** and the end of **`install.sh`** reflect failure).

## Related

- [Configuration](./CONFIGURATION.md) — full template tree under `configs/`.
- [Architecture](./ARCHITECTURE.md) — phase scripts and `lib/` overview.

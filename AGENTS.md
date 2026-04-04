## Learned User Preferences

- Prefers a "plan first, then implement" workflow — create a detailed plan with todos, then execute step by step
- Wants dual-audience positioning: always mention both "developers" and "AI coding agents"
- Favors minimal, clean design inspired by Omakub / Tokyo Night dark palette
- Expects Windows and Unix feature parity where feasible; recommends WSL + install.sh when native Windows is partial
- Prefers concise, conventional commit messages (e.g. `feat(scope): short summary`)
- Does not want agents to commit or push unless explicitly asked
- Uses context7 MCP to check library documentation before implementation
- Uses English exclusively in all code, docs, and comments

## Learned Workspace Facts

- Botstrap is a cross-platform dev environment bootstrapper with YAML registries and phased installs (0 → 0b → 2 → 3 → 4)
- Docs site is VitePress 1.6+ deployed to Cloudflare Pages at `botstrap.dev` (changed from `botstrap.org`), with Tokyo Night–inspired custom CSS in `docs/.vitepress/theme/custom.css`
- Build command: `npm ci && npm run docs:build`; output: `docs/.vitepress/dist`; Node 22; `scripts/sync-install-assets.mjs` copies `boot.sh` → `docs/public/install` and `boot.ps1` → `docs/public/install.ps1` before each build
- CLI at `bin/botstrap` supports: `version`, `update` (git pull only), `reconfigure` (Phase 2+3), `doctor` (Phase 4, exits 1 on failure)
- Phase 3: Unix writes `~/.config/botstrap/env.sh` and appends PATH snippet to `.zshrc`/`.bashrc`; Windows appends a `# botstrap PATH` block to the PowerShell profile (`bin/botstrap.ps1` + `botstrap` function). `botstrap` is available after a new shell
- Registry files: `registry/prerequisites.yaml` (Phase 0), `registry/core.yaml` (TUI-selected subset, default all), and `registry/optional.yaml` (TUI-selected)
- Git remote: `github.com/an-lee/botstrap`; default `BOTSTRAP_REPO` in boot scripts: `https://github.com/an-lee/botstrap.git`
- Boot scripts auto-install git when missing (Unix: `install/boot-prereqs-git.sh`, Windows: winget). On Linux, `boot.sh` may run `sudo -v` once before that when git is absent; `install.sh` sources `lib/sudo.sh` and calls `botstrap_sudo_init` after `botstrap_detect` so a background keepalive refreshes sudo during long installs
- Windows Phase 0b applies OS developer tuning from `configs/os/windows.yaml` (Developer Mode, long paths, execution policy, etc.); Administrator rights are not required to complete the install, but elevation is needed for full HKLM tuning (`developer_mode`, `long_paths`) — `install.ps1` warns when not elevated
- Windows registry-driven installs use `lib/pkg.ps1` (yq lookups, scriptblock snippets, `post_install_windows`); Phase 0 should ensure **Mike Farah** `yq` (winget `MikeFarah.yq`) — other `yq` builds break registry parsing; yq filter strings avoid embedded double quotes in process argv (e.g. `strenv(...)` / `Invoke-BotstrapYqWithEnv`) because PowerShell 5.1 mishandles them for native `yq`
- Unix `lib/pkg.sh`: tools whose registry `verify` already pass are skipped; when `gum` is on PATH and stdout is a TTY, installs run under `gum spin --show-output` so long package commands stay visible
- `wrangler.toml` at repo root for optional manual Cloudflare Pages deploy via `npx wrangler pages deploy`

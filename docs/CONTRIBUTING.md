# Contributing to Botstrap

Thank you for helping improve Botstrap. This project aims to stay **transparent** (shell-first), **registry-driven**, and **safe** for non-interactive use.

## Before you start

- Read `docs/INTRODUCTION.md` and `docs/ARCHITECTURE.md` for the overall flow.
- Read `docs/REGISTRY_SPEC.md` before editing `registry/core.yaml` or `registry/optional.yaml`.
- See `docs/REFERENCE.md` for CLI and environment variable naming when changing phases.
- Prefer YAML registry changes over new orchestration logic when a tool installs cleanly from package managers.

## Development setup

1. Clone the repository (or use your fork).
2. On Unix, run phases manually from the repo root for testing:

   ```bash
   export BOTSTRAP_ROOT="$(pwd)"
   # Optional: dry-run or step through install/phase-0-prerequisites.sh etc.
   ```

3. Ensure **bash 4+**; **git** and **curl** are required for many tests but Phase 0 can install them on supported macOS/Linux. **yq** is required once Phase 1 has run or if you test `lib/pkg.sh` against the registry.

## Adding a tool

### Core (always installed)

1. Add an entry to `registry/core.yaml` with `name`, `description`, `category`, `install` keys per OS, and `verify`.
2. If install cannot be expressed safely in YAML, add `install/modules/<name>.sh` (and `.ps1` on Windows) and call it from the phase script or from `post_install`.
3. Update `docs/TOOL_SELECTION.md` with a one-line rationale.

### Optional (TUI)

1. Add an item under the appropriate `groups` entry in `registry/optional.yaml`.
2. Set `requires` if the tool needs Node, Docker, etc.
3. Extend `install/phase-2-tui.sh` if you introduce a **new group** (`id`); document the environment variable naming in this file’s header comment and update `docs/REFERENCE.md`.

## Style

- **English** for all user-facing strings, comments, and docs.
- Shell: `set -euo pipefail` at the top of bash scripts; quote variables; avoid `eval` of untrusted remote content.
- Keep scripts **idempotent** where reasonable so re-runs and updates do not break machines.

## Windows

- Mirror critical logic in `*.ps1` where Unix uses `*.sh`.
- Test with **PowerShell 7+** when possible; note if Windows PowerShell 5.1 differs.

## Pull requests

- Describe **what** changed and **why** (motivation, tradeoffs).
- Link related issues if any.
- If you change install behavior, mention **platforms** you tested.

## Code of conduct

Be respectful and assume good intent. Report problems maintainers should know about via issues (or your project’s preferred channel).

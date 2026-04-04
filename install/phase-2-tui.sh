#!/usr/bin/env bash
# Phase 2: gum-powered TUI. Exports BOTSTRAP_* env vars for later phases.
# Group ids: editor, languages, databases, ai_tools, theme, optional_apps
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"

if ! command -v gum &>/dev/null; then
  botstrap_log_warn "gum not found; exporting safe defaults for non-interactive runs."
  export BOTSTRAP_GIT_NAME="${BOTSTRAP_GIT_NAME:-}"
  export BOTSTRAP_GIT_EMAIL="${BOTSTRAP_GIT_EMAIL:-}"
  export BOTSTRAP_EDITOR="${BOTSTRAP_EDITOR:-none}"
  export BOTSTRAP_LANGUAGES="${BOTSTRAP_LANGUAGES:-}"
  export BOTSTRAP_DATABASES="${BOTSTRAP_DATABASES:-}"
  export BOTSTRAP_AI_TOOLS="${BOTSTRAP_AI_TOOLS:-}"
  export BOTSTRAP_THEME="${BOTSTRAP_THEME:-catppuccin}"
  export BOTSTRAP_OPTIONAL_APPS="${BOTSTRAP_OPTIONAL_APPS:-}"
  exit 0
fi

gum style --border rounded --padding "1 2" --foreground 212 "Botstrap" "" "Cross-platform developer bootstrap."

export BOTSTRAP_GIT_NAME="${BOTSTRAP_GIT_NAME:-$(gum input --placeholder 'Git user name' --value "${GIT_AUTHOR_NAME:-}")}"
export BOTSTRAP_GIT_EMAIL="${BOTSTRAP_GIT_EMAIL:-$(gum input --placeholder 'Git email' --value "${GIT_AUTHOR_EMAIL:-}")}"

export BOTSTRAP_EDITOR="$(
  gum choose --header "Primary editor" \
    cursor vscode neovim zed none
)"

export BOTSTRAP_LANGUAGES="$(
  gum choose --no-limit --header "Programming languages (mise)" \
    node python ruby go rust java elixir php none || true
)"
export BOTSTRAP_LANGUAGES="${BOTSTRAP_LANGUAGES//$'\n'/,}"

export BOTSTRAP_DATABASES="$(
  gum choose --no-limit --header "Databases (Docker)" \
    postgresql mysql redis sqlite none || true
)"
export BOTSTRAP_DATABASES="${BOTSTRAP_DATABASES//$'\n'/,}"

export BOTSTRAP_AI_TOOLS="$(
  gum choose --no-limit --header "AI agent CLIs" \
    claude-code openclaw codex gemini ollama none || true
)"
export BOTSTRAP_AI_TOOLS="${BOTSTRAP_AI_TOOLS//$'\n'/,}"

export BOTSTRAP_THEME="$(
  gum choose --header "Theme" \
    catppuccin tokyo-night gruvbox nord rose-pine
)"

export BOTSTRAP_OPTIONAL_APPS="$(
  gum choose --no-limit --header "Optional apps" \
    1password-cli tailscale ngrok postman none || true
)"
export BOTSTRAP_OPTIONAL_APPS="${BOTSTRAP_OPTIONAL_APPS//$'\n'/,}"

if ! gum confirm "Apply these choices and continue?"; then
  botstrap_log_warn "Aborted at confirmation; exiting."
  exit 1
fi

botstrap_log_info "Phase 2 complete."

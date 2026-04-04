#!/usr/bin/env bash
# Phase 2: gum-powered TUI. Exports BOTSTRAP_* env vars for later phases.
# Group ids: core (registry/core.yaml names), editor, languages, databases, ai_tools, theme, optional_apps
# BOTSTRAP_CORE_TOOLS: comma-separated names from registry/core.yaml (prerequisites are Phase 0 only).
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"

if ! command -v gum &>/dev/null; then
  botstrap_log_warn "gum not found; exporting safe defaults for non-interactive runs."
  export BOTSTRAP_GIT_NAME="${BOTSTRAP_GIT_NAME:-}"
  export BOTSTRAP_GIT_EMAIL="${BOTSTRAP_GIT_EMAIL:-}"
  _all_core_csv="$(yq -r '.tools[].name' "${BOTSTRAP_ROOT}/registry/core.yaml" | paste -sd, -)"
  export BOTSTRAP_CORE_TOOLS="${BOTSTRAP_CORE_TOOLS:-${_all_core_csv}}"
  export BOTSTRAP_EDITOR="${BOTSTRAP_EDITOR:-none}"
  export BOTSTRAP_LANGUAGES="${BOTSTRAP_LANGUAGES:-}"
  export BOTSTRAP_DATABASES="${BOTSTRAP_DATABASES:-}"
  export BOTSTRAP_AI_TOOLS="${BOTSTRAP_AI_TOOLS:-}"
  export BOTSTRAP_THEME="${BOTSTRAP_THEME:-catppuccin}"
  export BOTSTRAP_OPTIONAL_APPS="${BOTSTRAP_OPTIONAL_APPS:-}"
  exit 0
fi

gum style --border rounded --padding "1 2" --foreground 212 "Botstrap" "" "Cross-platform developer bootstrap."

_git_name_args=()
if [[ -n "${GIT_AUTHOR_NAME:-}" ]]; then
  _git_name_args=(--value "${GIT_AUTHOR_NAME}")
fi
export BOTSTRAP_GIT_NAME="${BOTSTRAP_GIT_NAME:-$(gum input --placeholder 'Git user name' "${_git_name_args[@]}")}"

_git_email_args=()
if [[ -n "${GIT_AUTHOR_EMAIL:-}" ]]; then
  _git_email_args=(--value "${GIT_AUTHOR_EMAIL}")
fi
export BOTSTRAP_GIT_EMAIL="${BOTSTRAP_GIT_EMAIL:-$(gum input --placeholder 'Git email' "${_git_email_args[@]}")}"

_core_yaml="${BOTSTRAP_ROOT}/registry/core.yaml"
mapfile -t _core_tool_names < <(yq -r '.tools[].name' "${_core_yaml}")
_selected_flag='*'
_core_env_file="${HOME}/.config/botstrap/core-tools.env"
if [[ -f "${_core_env_file}" ]]; then
  _ln="$(grep -m1 '^core_tools=' "${_core_env_file}" 2>/dev/null || true)"
  if [[ -n "${_ln}" ]]; then
    _v="${_ln#core_tools=}"
    [[ -n "${_v}" ]] && _selected_flag="${_v}"
  fi
fi
_core_lines="$(
  gum choose --no-limit --ordered --header "Core tools (registry/core.yaml)" --selected "${_selected_flag}" "${_core_tool_names[@]}" || true
)"
export BOTSTRAP_CORE_TOOLS="${_core_lines//$'\n'/,}"

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

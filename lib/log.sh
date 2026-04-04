#!/usr/bin/env bash
# Logging helpers for Botstrap (Unix).

if [[ -z "${BOTSTRAP_LOG_COLOR:-}" ]]; then
  BOTSTRAP_LOG_COLOR=1
fi

botstrap_log_prefix() {
  printf '[botstrap] '
}

botstrap_log_info() {
  if [[ "${BOTSTRAP_LOG_COLOR}" == "1" ]]; then
    printf '\033[0;36m'
    botstrap_log_prefix
    printf '%s\033[0m\n' "$*"
  else
    botstrap_log_prefix
    printf '%s\n' "$*"
  fi
}

botstrap_log_warn() {
  if [[ "${BOTSTRAP_LOG_COLOR}" == "1" ]]; then
    printf '\033[0;33m'
    botstrap_log_prefix
    printf '%s\033[0m\n' "$*"
  else
    botstrap_log_prefix
    printf '%s\n' "$*"
  fi
}

botstrap_log_err() {
  if [[ "${BOTSTRAP_LOG_COLOR}" == "1" ]]; then
    printf '\033[0;31m'
    botstrap_log_prefix
    printf '%s\033[0m\n' "$*" >&2
  else
    botstrap_log_prefix
    printf '%s\n' "$*" >&2
  fi
}

# args: num total label — prominent phase header (gum style if available).
botstrap_log_phase() {
  local num="$1"
  local total="$2"
  local label="$3"
  if command -v gum &>/dev/null; then
    printf '\n'
    gum style --border rounded --padding "0 2" --border-foreground 212 \
      "Step ${num}/${total}: ${label}"
  else
    if [[ "${BOTSTRAP_LOG_COLOR}" == "1" ]]; then
      printf '\n\033[1;35m══ Step %s/%s: %s ══\033[0m\n\n' "${num}" "${total}" "${label}"
    else
      printf '\n══ Step %s/%s: %s ══\n\n' "${num}" "${total}" "${label}"
    fi
  fi
}

# args: current total label — N-of-M step line.
botstrap_log_step() {
  botstrap_log_info "[${1}/${2}] ${3}"
}

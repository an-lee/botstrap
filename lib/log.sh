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

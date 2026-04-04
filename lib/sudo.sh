#!/usr/bin/env bash
# One-time sudo credential acquisition with background keepalive (Linux only).
# Requires lib/log.sh for botstrap_log_info when prompting.

BOTSTRAP_SUDO_PID=""

botstrap_sudo_init() {
  [[ "${BOTSTRAP_OS:-}" == "linux" ]] || return 0
  if ! sudo -n true 2>/dev/null; then
    botstrap_log_info "Administrator privileges are required for system-wide package installs."
    botstrap_log_info "You will only be asked for your password once."
    sudo -v
  fi
  _botstrap_sudo_keepalive &
  BOTSTRAP_SUDO_PID=$!
  trap 'botstrap_sudo_cleanup' EXIT INT TERM
}

_botstrap_sudo_keepalive() {
  while true; do
    sleep 50
    sudo -n -v 2>/dev/null || break
  done
}

botstrap_sudo_cleanup() {
  if [[ -n "${BOTSTRAP_SUDO_PID}" ]]; then
    kill "${BOTSTRAP_SUDO_PID}" 2>/dev/null || true
    BOTSTRAP_SUDO_PID=""
  fi
}

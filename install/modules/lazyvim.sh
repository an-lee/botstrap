#!/usr/bin/env bash
# Clone LazyVim starter into the standard Neovim config directory (Unix).
# Idempotent: skips when lua/config/lazy.lua already exists.
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"

if ! command -v git >/dev/null 2>&1; then
  botstrap_log_err "git is required to install the LazyVim starter."
  exit 1
fi

NVIM_CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
LAZY_LUA="${NVIM_CONFIG}/lua/config/lazy.lua"
STARTER_URL="https://github.com/LazyVim/starter"

botstrap_lazyvim_clone() {
  mkdir -p "$(dirname "${NVIM_CONFIG}")"
  botstrap_log_info "Installing LazyVim starter into ${NVIM_CONFIG}"
  git clone --filter=blob:none "${STARTER_URL}" "${NVIM_CONFIG}"
  rm -rf "${NVIM_CONFIG}/.git"
}

if [[ -f "${LAZY_LUA}" ]]; then
  botstrap_log_info "LazyVim starter already present (${LAZY_LUA}); skipping clone."
  exit 0
fi

if [[ ! -d "${NVIM_CONFIG}" ]] || [[ -z "$(ls -A "${NVIM_CONFIG}" 2>/dev/null || true)" ]]; then
  if [[ -d "${NVIM_CONFIG}" ]]; then
    rmdir "${NVIM_CONFIG}" 2>/dev/null || true
  fi
  botstrap_lazyvim_clone
  exit 0
fi

if [[ -f "${NVIM_CONFIG}/init.lua" ]] && [[ ! -d "${NVIM_CONFIG}/lua" ]]; then
  backup="${NVIM_CONFIG}.botstrap.bak"
  if [[ -e "${backup}" ]]; then
    backup="${NVIM_CONFIG}.botstrap.bak.$(date +%s)"
  fi
  botstrap_log_info "Backing up existing Neovim config to ${backup}"
  mv "${NVIM_CONFIG}" "${backup}"
  botstrap_lazyvim_clone
  exit 0
fi

botstrap_log_warn "Existing ${NVIM_CONFIG} has a custom layout; not replacing with LazyVim."
exit 0

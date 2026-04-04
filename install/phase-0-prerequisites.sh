#!/usr/bin/env bash
# Phase 0: git, curl, jq, yq, gum — minimum to run registry + TUI.
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/detect.sh
source "${BOTSTRAP_ROOT}/lib/detect.sh"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"

botstrap_detect

botstrap_ensure_git_curl() {
  if command -v git &>/dev/null && command -v curl &>/dev/null; then
    return 0
  fi
  case "${BOTSTRAP_OS}" in
    darwin)
      if ! command -v brew &>/dev/null; then
        botstrap_log_info "Installing Homebrew (non-interactive standard install)"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # shellcheck disable=SC1091
        [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        # shellcheck disable=SC1091
        [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
      fi
      brew install git curl
      ;;
    linux)
      case "${BOTSTRAP_PKG}" in
        apt)
          sudo apt-get update
          sudo apt-get install -y git curl ca-certificates
          ;;
        dnf)
          sudo dnf install -y git curl
          ;;
        pacman)
          sudo pacman -Sy --noconfirm git curl
          ;;
        *)
          botstrap_log_err "Unsupported Linux package manager: ${BOTSTRAP_PKG}"
          return 1
          ;;
      esac
      ;;
    *)
      botstrap_log_err "Phase 0: install git and curl manually for OS=${BOTSTRAP_OS}"
      return 1
      ;;
  esac
}

botstrap_install_yq() {
  command -v yq &>/dev/null && return 0
  local yq_ver="v4.44.3"
  local arch="${BOTSTRAP_UNAME_M}"
  local asset=""
  case "${arch}" in
    x86_64) asset="yq_linux_amd64" ;;
    aarch64 | arm64) asset="yq_linux_arm64" ;;
    *)
      botstrap_log_err "No prebuilt yq asset for arch=${arch}; install yq manually."
      return 1
      ;;
  esac
  case "${BOTSTRAP_OS}" in
    darwin)
      brew install yq
      ;;
    linux)
      sudo curl -fsSL "https://github.com/mikefarah/yq/releases/download/${yq_ver}/${asset}" -o /usr/local/bin/yq
      sudo chmod +x /usr/local/bin/yq
      ;;
    *)
      return 1
      ;;
  esac
}

botstrap_install_jq() {
  command -v jq &>/dev/null && return 0
  case "${BOTSTRAP_OS}" in
    darwin)
      brew install jq
      ;;
    linux)
      case "${BOTSTRAP_PKG}" in
        apt) sudo apt-get install -y jq ;;
        dnf) sudo dnf install -y jq ;;
        pacman) sudo pacman -Sy --noconfirm jq ;;
        *) return 1 ;;
      esac
      ;;
    *) return 1 ;;
  esac
}

botstrap_install_gum() {
  command -v gum &>/dev/null && return 0
  local gum_ver="0.14.5"
  case "${BOTSTRAP_OS}" in
    darwin)
      brew install gum
      ;;
    linux)
      local arch="${BOTSTRAP_UNAME_M}"
      local deb_arch="amd64"
      [[ "${arch}" == "aarch64" || "${arch}" == "arm64" ]] && deb_arch="arm64"
      local url="https://github.com/charmbracelet/gum/releases/download/v${gum_ver}/gum_${gum_ver}_Linux_${deb_arch}.tar.gz"
      local tmp
      tmp="$(mktemp -d)"
      curl -fsSL "${url}" | tar -xz -C "${tmp}"
      sudo install -m 0755 "${tmp}/gum" /usr/local/bin/gum
      rm -rf "${tmp}"
      ;;
    *)
      botstrap_log_warn "Install gum manually for OS=${BOTSTRAP_OS}"
      return 0
      ;;
  esac
}

botstrap_ensure_git_curl
botstrap_install_jq || botstrap_log_warn "jq not installed; some scripts may skip JSON helpers."
botstrap_install_yq || {
  botstrap_log_err "yq install failed"
  exit 1
}
botstrap_install_gum || botstrap_log_warn "gum missing; Phase 2 TUI will be limited."

botstrap_log_info "Phase 0 complete."

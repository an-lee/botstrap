#!/usr/bin/env bash
# Shared git + curl bootstrap for Botstrap.
# Sourced from boot.sh (via curl or local path) and install/phase-0-prerequisites.sh.
# Uses stderr messages only so it works before lib/log.sh is loaded.
# botstrap_detect_minimal must stay aligned with lib/detect.sh (OS / BOTSTRAP_PKG mapping).

botstrap_detect_minimal() {
  local uname_s uname_m
  uname_s="$(uname -s)"
  uname_m="$(uname -m)"
  case "${uname_s}" in
    Darwin)
      BOTSTRAP_OS=darwin
      BOTSTRAP_DISTRO=darwin
      BOTSTRAP_PKG=brew
      ;;
    Linux)
      BOTSTRAP_OS=linux
      BOTSTRAP_DISTRO=unknown
      BOTSTRAP_PKG=unknown
      if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        BOTSTRAP_DISTRO="${ID:-unknown}"
        case "${BOTSTRAP_DISTRO}" in
          ubuntu | debian) BOTSTRAP_PKG=apt ;;
          fedora | rhel | centos | rocky | alma) BOTSTRAP_PKG=dnf ;;
          arch | endeavouros | manjaro) BOTSTRAP_PKG=pacman ;;
          *) BOTSTRAP_PKG=apt ;;
        esac
      fi
      ;;
    MINGW* | MSYS* | CYGWIN*)
      BOTSTRAP_OS=windows
      BOTSTRAP_DISTRO=windows
      BOTSTRAP_PKG=winget
      ;;
    *)
      BOTSTRAP_OS=unknown
      BOTSTRAP_DISTRO=unknown
      BOTSTRAP_PKG=unknown
      ;;
  esac
  export BOTSTRAP_OS BOTSTRAP_DISTRO BOTSTRAP_PKG
  export BOTSTRAP_UNAME_S="${uname_s}" BOTSTRAP_UNAME_M="${uname_m}"
}

# Ensure git and curl are on PATH (install when missing on supported platforms).
# Keep behavior aligned with historical phase-0-prerequisites.sh.
botstrap_ensure_git_curl() {
  if command -v git &>/dev/null && command -v curl &>/dev/null; then
    return 0
  fi

  if [[ -z "${BOTSTRAP_OS:-}" ]]; then
    botstrap_detect_minimal
  fi

  case "${BOTSTRAP_OS}" in
    darwin)
      if ! command -v brew &>/dev/null; then
        echo "[botstrap] Installing Homebrew (non-interactive standard install)" >&2
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
          echo "[botstrap] Unsupported Linux package manager: ${BOTSTRAP_PKG:-unknown}; install git and curl manually." >&2
          return 1
          ;;
      esac
      ;;
    *)
      echo "[botstrap] Install git and curl manually for OS=${BOTSTRAP_OS:-unknown}" >&2
      return 1
      ;;
  esac
}

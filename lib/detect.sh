#!/usr/bin/env bash
# OS, distro, and architecture detection for Botstrap (Unix).

botstrap_detect() {
  BOTSTRAP_UNAME_S="$(uname -s)"
  BOTSTRAP_UNAME_M="$(uname -m)"

  case "${BOTSTRAP_UNAME_S}" in
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

  export BOTSTRAP_OS BOTSTRAP_DISTRO BOTSTRAP_PKG BOTSTRAP_UNAME_S BOTSTRAP_UNAME_M
}

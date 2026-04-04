#!/usr/bin/env bash
# Botstrap boot entry (curl | bash). Clones the repo and runs install.sh.
set -euo pipefail

BOTSTRAP_HOME="${BOTSTRAP_HOME:-${HOME}/.botstrap}"
BOTSTRAP_REPO="${BOTSTRAP_REPO:-https://github.com/botstrap/botstrap.git}"

# Map BOTSTRAP_REPO to raw.githubusercontent.com base (HEAD). Used to fetch
# install/boot-prereqs-git.sh when git is missing. Non-GitHub remotes: set
# BOTSTRAP_BOOT_PREREQS_URL to the raw URL of that file, or clone manually.
botstrap_repo_raw_base() {
  local repo="$1"
  if [[ "${repo}" =~ ^https://github\.com/([^/]+)/([^/.]+)(\.git)?$ ]]; then
    printf '%s\n' "https://raw.githubusercontent.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/HEAD"
    return 0
  fi
  if [[ "${repo}" =~ ^git@github\.com:([^/]+)/([^/.]+)(\.git)?$ ]]; then
    printf '%s\n' "https://raw.githubusercontent.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/HEAD"
    return 0
  fi
  return 1
}

botstrap_boot_load_prereqs_git_script() {
  local _here _local url base tmp
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  _local="${_here}/install/boot-prereqs-git.sh"
  if [[ -f "${_local}" ]]; then
    # shellcheck source=install/boot-prereqs-git.sh
    source "${_local}"
    return 0
  fi
  url=""
  if [[ -n "${BOTSTRAP_BOOT_PREREQS_URL:-}" ]]; then
    url="${BOTSTRAP_BOOT_PREREQS_URL}"
  elif command -v curl &>/dev/null && base="$(botstrap_repo_raw_base "${BOTSTRAP_REPO}")"; then
    url="${base}/install/boot-prereqs-git.sh"
  fi
  if [[ -z "${url}" ]]; then
    return 1
  fi
  tmp="$(mktemp)"
  if ! curl -fsSL "${url}" -o "${tmp}"; then
    rm -f "${tmp}"
    return 1
  fi
  # shellcheck disable=SC1090
  source "${tmp}"
  rm -f "${tmp}"
  return 0
}

if ! command -v git &>/dev/null; then
  if botstrap_boot_load_prereqs_git_script; then
    botstrap_ensure_git_curl
  else
    echo "[botstrap] git is missing and the prerequisite script could not be loaded." >&2
    echo "[botstrap] Use a GitHub https or git@github.com BOTSTRAP_REPO, set BOTSTRAP_BOOT_PREREQS_URL," >&2
    echo "[botstrap] run boot.sh from a full checkout, or install git manually, then re-run." >&2
    exit 1
  fi
fi

if ! command -v git &>/dev/null; then
  echo "[botstrap] git is still not available after the prerequisite step. Install git, then re-run." >&2
  exit 1
fi

if [[ ! -d "${BOTSTRAP_HOME}/.git" ]]; then
  echo "[botstrap] Cloning ${BOTSTRAP_REPO} -> ${BOTSTRAP_HOME}"
  git clone "${BOTSTRAP_REPO}" "${BOTSTRAP_HOME}"
fi

exec bash "${BOTSTRAP_HOME}/install.sh"

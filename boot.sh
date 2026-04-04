#!/usr/bin/env bash
# Botstrap boot entry (curl | bash). Clones the repo and runs install.sh.
set -euo pipefail

BOTSTRAP_HOME="${BOTSTRAP_HOME:-${HOME}/.botstrap}"
BOTSTRAP_REPO="${BOTSTRAP_REPO:-https://github.com/botstrap/botstrap.git}"

if ! command -v git &>/dev/null; then
  echo "[botstrap] git is required. Install git for your OS, then re-run this script." >&2
  exit 1
fi

if [[ ! -d "${BOTSTRAP_HOME}/.git" ]]; then
  echo "[botstrap] Cloning ${BOTSTRAP_REPO} -> ${BOTSTRAP_HOME}"
  git clone "${BOTSTRAP_REPO}" "${BOTSTRAP_HOME}"
fi

exec bash "${BOTSTRAP_HOME}/install.sh"

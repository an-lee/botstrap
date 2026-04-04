#!/usr/bin/env bash
# Main Unix orchestrator: prerequisites, core tools, TUI, configure, verify.
set -euo pipefail

export BOTSTRAP_ROOT
BOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BOTSTRAP_ROOT}"

# shellcheck source=lib/detect.sh
source "${BOTSTRAP_ROOT}/lib/detect.sh"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"
# shellcheck source=lib/pkg.sh
source "${BOTSTRAP_ROOT}/lib/pkg.sh"

botstrap_detect
botstrap_log_info "Detected OS=${BOTSTRAP_OS} distro=${BOTSTRAP_DISTRO} pkg=${BOTSTRAP_PKG} arch=${BOTSTRAP_UNAME_M}"

# shellcheck source=install/phase-0-prerequisites.sh
source "${BOTSTRAP_ROOT}/install/phase-0-prerequisites.sh"
if [[ "${BOTSTRAP_OS}" == darwin ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    # shellcheck disable=SC1091
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    # shellcheck disable=SC1091
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi
# shellcheck source=install/phase-1-core.sh
source "${BOTSTRAP_ROOT}/install/phase-1-core.sh"
# shellcheck source=install/phase-2-tui.sh
source "${BOTSTRAP_ROOT}/install/phase-2-tui.sh"
# shellcheck source=install/phase-3-configure.sh
source "${BOTSTRAP_ROOT}/install/phase-3-configure.sh"
# shellcheck source=install/phase-4-verify.sh
source "${BOTSTRAP_ROOT}/install/phase-4-verify.sh"

botstrap_log_info "Botstrap install phases finished."

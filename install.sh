#!/usr/bin/env bash
# Main Unix orchestrator: prerequisites, TUI (core + optional choices), apply installs, verify.
set -euo pipefail

export BOTSTRAP_ROOT
BOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BOTSTRAP_ROOT}"

# shellcheck source=lib/detect.sh
source "${BOTSTRAP_ROOT}/lib/detect.sh"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"
# shellcheck source=lib/sudo.sh
source "${BOTSTRAP_ROOT}/lib/sudo.sh"
# shellcheck source=lib/pkg.sh
source "${BOTSTRAP_ROOT}/lib/pkg.sh"

botstrap_detect
botstrap_sudo_init
botstrap_log_info "Detected OS=${BOTSTRAP_OS} distro=${BOTSTRAP_DISTRO} pkg=${BOTSTRAP_PKG} arch=${BOTSTRAP_UNAME_M}"

botstrap_log_phase 1 4 "Prerequisites - git, curl, jq, yq, gum"
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
botstrap_log_phase 2 4 "Interactive configuration"
# shellcheck source=install/phase-2-tui.sh
source "${BOTSTRAP_ROOT}/install/phase-2-tui.sh"
botstrap_log_phase 3 4 "Apply installs and dotfiles"
# shellcheck source=install/phase-3-configure.sh
source "${BOTSTRAP_ROOT}/install/phase-3-configure.sh"
botstrap_log_phase 4 4 "Verification"
# shellcheck source=install/phase-4-verify.sh
source "${BOTSTRAP_ROOT}/install/phase-4-verify.sh"

botstrap_log_info "Botstrap install phases finished."

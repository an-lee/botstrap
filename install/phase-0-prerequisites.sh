#!/usr/bin/env bash
# Phase 0: git, curl, jq, yq, gum — minimum to run registry + TUI (from registry/prerequisites.yaml).
# yq is bootstrapped inline first because registry-driven installs require yq to read YAML.
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/detect.sh
source "${BOTSTRAP_ROOT}/lib/detect.sh"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"

botstrap_detect

# shellcheck source=install/boot-prereqs-git.sh
source "${BOTSTRAP_ROOT}/install/boot-prereqs-git.sh"

botstrap_bootstrap_yq_for_registry() {
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
      botstrap_log_err "Cannot bootstrap yq for OS=${BOTSTRAP_OS}"
      return 1
      ;;
  esac
}

botstrap_ensure_git_curl
botstrap_bootstrap_yq_for_registry || {
  botstrap_log_err "yq bootstrap failed"
  exit 1
}

# shellcheck source=lib/pkg.sh
source "${BOTSTRAP_ROOT}/lib/pkg.sh"

_prereq_reg="${BOTSTRAP_ROOT}/registry/prerequisites.yaml"
mapfile -t _botstrap_prereq_tools < <(yq -r '.tools[].name' "${_prereq_reg}")
_total="${#_botstrap_prereq_tools[@]}"
_current=0
for _tool in "${_botstrap_prereq_tools[@]}"; do
  [[ -z "${_tool}" ]] && continue
  _current=$((_current + 1))
  botstrap_log_step "${_current}" "${_total}" "Prerequisite ${_tool}"
  botstrap_pkg_install "${_tool}" "${_prereq_reg}" || botstrap_log_warn "Install reported failure for ${_tool} (continuing)."
done

if ! command -v jq &>/dev/null; then
  botstrap_log_warn "jq not installed; some scripts may skip JSON helpers."
fi
if ! command -v gum &>/dev/null; then
  botstrap_log_warn "gum missing; Phase 2 TUI will be limited."
fi

botstrap_log_info "Phase 0 complete."

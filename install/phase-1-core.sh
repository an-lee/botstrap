#!/usr/bin/env bash
# Phase 1: non-interactive core tools from registry/core.yaml.
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"
# shellcheck source=lib/pkg.sh
source "${BOTSTRAP_ROOT}/lib/pkg.sh"

if ! command -v yq &>/dev/null; then
  botstrap_log_err "yq missing; re-run phase-0."
  exit 1
fi

mapfile -t _botstrap_core_tools < <(yq -r '.tools[].name' "${BOTSTRAP_ROOT}/registry/core.yaml")
_botstrap_core_tools_filtered=()
for _tool in "${_botstrap_core_tools[@]}"; do
  [[ -z "${_tool}" ]] && continue
  _botstrap_core_tools_filtered+=("${_tool}")
done
_total="${#_botstrap_core_tools_filtered[@]}"
_current=0
for _tool in "${_botstrap_core_tools_filtered[@]}"; do
  _current=$((_current + 1))
  botstrap_log_step "${_current}" "${_total}" "Installing ${_tool}"
  botstrap_pkg_install "${_tool}" "${BOTSTRAP_ROOT}/registry/core.yaml" || botstrap_log_warn "Install reported failure for ${_tool} (continuing)."
done

botstrap_log_info "Phase 1 complete."

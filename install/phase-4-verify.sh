#!/usr/bin/env bash
# Phase 4: verify prerequisite tools, selected core tools, and optional TUI selections.
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"
# shellcheck source=lib/pkg.sh
source "${BOTSTRAP_ROOT}/lib/pkg.sh"

if ! command -v yq &>/dev/null; then
  botstrap_log_err "yq missing; cannot verify registry."
  exit 1
fi

_failures=0
_prereq_reg="${BOTSTRAP_ROOT}/registry/prerequisites.yaml"
mapfile -t _pre_tools < <(yq -r '.tools[].name' "${_prereq_reg}")
_pre_filtered=()
for _t in "${_pre_tools[@]}"; do
  [[ -z "${_t}" ]] && continue
  _pre_filtered+=("${_t}")
done
_total_pre="${#_pre_filtered[@]}"
_current=0
for _t in "${_pre_filtered[@]}"; do
  _current=$((_current + 1))
  botstrap_log_step "${_current}" "${_total_pre}" "Verifying prerequisite ${_t}"
  if ! botstrap_pkg_verify "${_t}" "${_prereq_reg}"; then
    botstrap_log_warn "Verify failed: ${_t}"
    _failures=$((_failures + 1))
  fi
done

mapfile -t _core_list < <(botstrap_core_tool_names_for_verify)
_total_core="${#_core_list[@]}"
_current=0
for _t in "${_core_list[@]}"; do
  [[ -z "${_t}" ]] && continue
  _current=$((_current + 1))
  botstrap_log_step "${_current}" "${_total_core}" "Verifying core ${_t}"
  if ! botstrap_pkg_verify "${_t}" "${BOTSTRAP_ROOT}/registry/core.yaml"; then
    botstrap_log_warn "Verify failed: ${_t}"
    _failures=$((_failures + 1))
  fi
done

botstrap_log_info "Verification finished with ${_failures} failure(s)."
botstrap_log_info "Version file: $(cat "${BOTSTRAP_ROOT}/version" 2>/dev/null || echo unknown)"
botstrap_log_info "Re-run TUI choices: bash ${BOTSTRAP_ROOT}/install/phase-2-tui.sh && bash ${BOTSTRAP_ROOT}/install/phase-3-configure.sh"
if [[ "${_failures}" -gt 0 ]]; then
  exit 1
fi

#!/usr/bin/env bash
# Phase 4: verify core tools and print a short summary.
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

mapfile -t _tools < <(yq -r '.tools[].name' "${BOTSTRAP_ROOT}/registry/core.yaml")
_failures=0
for _t in "${_tools[@]}"; do
  [[ -z "${_t}" ]] && continue
  if ! botstrap_pkg_verify "${_t}" "${BOTSTRAP_ROOT}/registry/core.yaml"; then
    botstrap_log_warn "Verify failed: ${_t}"
    _failures=$((_failures + 1))
  fi
done

botstrap_log_info "Verification finished with ${_failures} failure(s)."
botstrap_log_info "Version file: $(cat "${BOTSTRAP_ROOT}/version" 2>/dev/null || echo unknown)"
botstrap_log_info "Re-run TUI choices: bash ${BOTSTRAP_ROOT}/install/phase-2-tui.sh && bash ${BOTSTRAP_ROOT}/install/phase-3-configure.sh"

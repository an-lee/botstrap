#!/usr/bin/env bash
# Registry-driven upgrades for prerequisites, selected core, and persisted optional selections.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BOTSTRAP_ROOT="${BOTSTRAP_ROOT:-${ROOT}}"

# shellcheck source=lib/detect.sh
source "${BOTSTRAP_ROOT}/lib/detect.sh"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"
# shellcheck source=lib/pkg.sh
source "${BOTSTRAP_ROOT}/lib/pkg.sh"

botstrap_detect

_prereq_reg="${BOTSTRAP_ROOT}/registry/prerequisites.yaml"
_core_reg="${BOTSTRAP_ROOT}/registry/core.yaml"
_optional_reg="${BOTSTRAP_ROOT}/registry/optional.yaml"
_config_dir="${HOME}/.config/botstrap"
_optional_sel="${_config_dir}/optional-selections.env"
_editor_env="${_config_dir}/editor.env"
_theme_env="${_config_dir}/theme.env"

botstrap_kv_from_file() {
  local key="$1"
  local file="$2"
  [[ -f "${file}" ]] || return 1
  local line
  line="$(grep -m1 "^${key}=" "${file}" 2>/dev/null || true)"
  [[ -n "${line}" ]] || return 1
  printf '%s\n' "${line#"${key}"=}"
}

botstrap_log_info "Update tools: prerequisites (${_prereq_reg})"
while IFS= read -r _tname; do
  [[ -z "${_tname}" ]] && continue
  botstrap_pkg_update_tool "${_tname}" "${_prereq_reg}" || true
done < <(yq -r '.tools[].name' "${_prereq_reg}" 2>/dev/null || true)

_core_csv=""
while IFS= read -r _n; do
  [[ -z "${_n}" ]] && continue
  if [[ -n "${_core_csv}" ]]; then
    _core_csv="${_core_csv},${_n}"
  else
    _core_csv="${_n}"
  fi
done < <(botstrap_core_tool_names_for_verify)

botstrap_log_info "Update tools: core (resolved selection, ${_core_reg})"
botstrap_pkg_update_tools_from_csv "${_core_csv}" "${_core_reg}"

_editor="${BOTSTRAP_EDITOR-}"
if [[ -z "${_editor}" ]] && botstrap_kv_from_file editor "${_editor_env}" >/dev/null 2>&1; then
  _editor="$(botstrap_kv_from_file editor "${_editor_env}")"
fi
_theme="${BOTSTRAP_THEME-}"
if [[ -z "${_theme}" ]] && botstrap_kv_from_file theme "${_theme_env}" >/dev/null 2>&1; then
  _theme="$(botstrap_kv_from_file theme "${_theme_env}")"
fi
_langs="${BOTSTRAP_LANGUAGES-}"
if [[ -z "${_langs}" ]] && botstrap_kv_from_file languages "${_optional_sel}" >/dev/null 2>&1; then
  _langs="$(botstrap_kv_from_file languages "${_optional_sel}")"
fi
_dbs="${BOTSTRAP_DATABASES-}"
if [[ -z "${_dbs}" ]] && botstrap_kv_from_file databases "${_optional_sel}" >/dev/null 2>&1; then
  _dbs="$(botstrap_kv_from_file databases "${_optional_sel}")"
fi
_ai="${BOTSTRAP_AI_TOOLS-}"
if [[ -z "${_ai}" ]] && botstrap_kv_from_file ai_tools "${_optional_sel}" >/dev/null 2>&1; then
  _ai="$(botstrap_kv_from_file ai_tools "${_optional_sel}")"
fi
_apps="${BOTSTRAP_OPTIONAL_APPS-}"
if [[ -z "${_apps}" ]] && botstrap_kv_from_file optional_apps "${_optional_sel}" >/dev/null 2>&1; then
  _apps="$(botstrap_kv_from_file optional_apps "${_optional_sel}")"
fi

botstrap_log_info "Update tools: optional registry (${_optional_reg})"
botstrap_pkg_update_optional_item "editor" "${_editor:-none}" "${_optional_reg}" || true
botstrap_pkg_update_optional_csv "languages" "${_langs:-}" "${_optional_reg}"
botstrap_pkg_update_optional_csv "databases" "${_dbs:-}" "${_optional_reg}"
botstrap_pkg_update_optional_csv "ai_tools" "${_ai:-}" "${_optional_reg}"
botstrap_pkg_update_optional_item "theme" "${_theme:-catppuccin}" "${_optional_reg}" || true
botstrap_pkg_update_optional_csv "optional_apps" "${_apps:-}" "${_optional_reg}"

botstrap_log_info "Update tools finished."

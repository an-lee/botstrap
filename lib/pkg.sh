#!/usr/bin/env bash
# Registry-driven install helpers (Unix). Requires mikefarah/yq on PATH.

# shellcheck source=lib/bash-compat.sh
source "${BOTSTRAP_ROOT}/lib/bash-compat.sh"

botstrap_pkg_resolve_keys() {
  local keys=()
  case "${BOTSTRAP_OS}" in
    darwin)
      keys=(darwin all)
      ;;
    windows)
      keys=(windows all)
      ;;
    linux)
      case "${BOTSTRAP_DISTRO}" in
        ubuntu | debian)
          keys=(linux-apt linux all)
          ;;
        fedora | rhel | centos | rocky | alma)
          keys=(linux-dnf linux all)
          ;;
        arch | endeavouros | manjaro)
          keys=(linux-pacman linux all)
          ;;
        *)
          keys=(linux all)
          ;;
      esac
      ;;
    *)
      keys=(all)
      ;;
  esac
  printf '%s\n' "${keys[@]}"
}

botstrap_pkg_get_snippet() {
  local tool_name="$1"
  local registry_file="$2"
  local key="$3"
  yq -r ".tools[] | select(.name == \"${tool_name}\") | .install[\"${key}\"] // \"\"" "${registry_file}" 2>/dev/null || true
}

botstrap_pkg_run_snippet() {
  local snippet="$1"
  if [[ -z "${snippet}" || "${snippet}" == "null" ]]; then
    return 1
  fi
  bash -c "${snippet}"
}

# Run core registry post_install if present (also after verify-skip so idempotent hooks run).
botstrap_pkg_run_core_post_install() {
  local tool_name="$1"
  local registry_file="$2"
  local post
  post="$(yq -r ".tools[] | select(.name == \"${tool_name}\") | .post_install // \"\"" "${registry_file}" 2>/dev/null || true)"
  if [[ -n "${post}" && "${post}" != "null" ]]; then
    botstrap_pkg_run_snippet "${post}"
  fi
}

botstrap_pkg_install() {
  local tool_name="$1"
  local registry_file="${2:-${BOTSTRAP_ROOT}/registry/core.yaml}"

  if ! command -v yq &>/dev/null; then
    botstrap_log_err "yq is required for registry-driven installs. Install yq (mikefarah/yq) and re-run Phase 0."
    return 1
  fi

  # Skip if tool already satisfies its verify command
  local verify_cmd
  verify_cmd="$(yq -r ".tools[] | select(.name == \"${tool_name}\") | .verify // \"\"" "${registry_file}" 2>/dev/null || true)"
  if [[ -n "${verify_cmd}" && "${verify_cmd}" != "null" ]]; then
    if bash -c "${verify_cmd}" &>/dev/null; then
      botstrap_log_info "Skipping ${tool_name} (already installed)"
      botstrap_pkg_run_core_post_install "${tool_name}" "${registry_file}"
      return 0
    fi
  fi

  local key snippet=""
  while IFS= read -r key; do
    [[ -z "${key}" ]] && continue
    snippet="$(botstrap_pkg_get_snippet "${tool_name}" "${registry_file}" "${key}")"
    if [[ -n "${snippet}" && "${snippet}" != "null" ]]; then
      if command -v gum &>/dev/null && [[ -t 1 ]]; then
        gum spin --show-output --spinner dot --title "  ${tool_name}..." -- bash -c "${snippet}"
      else
        botstrap_log_info "Installing ${tool_name} (using registry key: ${key})"
        botstrap_pkg_run_snippet "${snippet}"
      fi
      botstrap_pkg_run_core_post_install "${tool_name}" "${registry_file}"
      return 0
    fi
  done < <(botstrap_pkg_resolve_keys)

  botstrap_log_warn "No install snippet found for '${tool_name}' on this platform (see ${registry_file})."
  return 1
}

botstrap_pkg_verify() {
  local tool_name="$1"
  local registry_file="${2:-${BOTSTRAP_ROOT}/registry/core.yaml}"
  if ! command -v yq &>/dev/null; then
    botstrap_log_err "yq is required for pkg_verify."
    return 1
  fi
  local verify_cmd
  verify_cmd="$(yq -r ".tools[] | select(.name == \"${tool_name}\") | .verify // \"\"" "${registry_file}" 2>/dev/null || true)"
  if [[ -z "${verify_cmd}" || "${verify_cmd}" == "null" ]]; then
    botstrap_log_warn "No verify command for '${tool_name}'."
    return 0
  fi
  botstrap_log_info "Verifying ${tool_name}: ${verify_cmd}"
  bash -c "${verify_cmd}"
}

botstrap_pkg_get_optional_snippet_for_key() {
  local group_id="$1"
  local item_name="$2"
  local registry_file="$3"
  local key="$4"
  yq -r ".groups[] | select(.id == \"${group_id}\") | .items[] | select(.name == \"${item_name}\") | .install[\"${key}\"] // \"\"" "${registry_file}" 2>/dev/null || true
}

botstrap_pkg_optional_requires_satisfied() {
  local group_id="$1"
  local item_name="$2"
  local registry_file="$3"
  local reqs
  while IFS= read -r reqs; do
    [[ -z "${reqs}" || "${reqs}" == "null" ]] && continue
    case "${reqs}" in
      node)
        if ! bash -c 'export PATH="$HOME/.local/bin:$PATH"; command -v node >/dev/null'; then
          botstrap_log_warn "Optional '${item_name}' requires node; skipping."
          return 1
        fi
        ;;
      docker)
        if ! command -v docker &>/dev/null; then
          botstrap_log_warn "Optional '${item_name}' requires docker; skipping."
          return 1
        fi
        ;;
      mise)
        if ! bash -c 'export PATH="$HOME/.local/bin:$PATH"; command -v mise >/dev/null'; then
          botstrap_log_warn "Optional '${item_name}' requires mise; skipping."
          return 1
        fi
        ;;
      *)
        botstrap_log_warn "Unknown requires '${reqs}' for '${item_name}'; skipping."
        return 1
        ;;
    esac
  done < <(yq -r ".groups[] | select(.id == \"${group_id}\") | .items[] | select(.name == \"${item_name}\") | .requires[]?" "${registry_file}" 2>/dev/null || true)
  return 0
}

botstrap_pkg_install_optional_item() {
  local group_id="$1"
  local item_name="$2"
  local registry_file="${3:-${BOTSTRAP_ROOT}/registry/optional.yaml}"

  [[ -z "${item_name}" || "${item_name}" == "none" ]] && return 0

  if ! command -v yq &>/dev/null; then
    botstrap_log_err "yq is required for optional installs."
    return 1
  fi

  if ! botstrap_pkg_optional_requires_satisfied "${group_id}" "${item_name}" "${registry_file}"; then
    return 0
  fi

  local key snippet=""
  while IFS= read -r key; do
    [[ -z "${key}" ]] && continue
    snippet="$(botstrap_pkg_get_optional_snippet_for_key "${group_id}" "${item_name}" "${registry_file}" "${key}")"
    if [[ -n "${snippet}" && "${snippet}" != "null" ]]; then
      botstrap_log_info "Installing optional ${group_id}/${item_name} (registry key: ${key})"
      botstrap_pkg_run_snippet "${snippet}"
      local post
      post="$(yq -r ".groups[] | select(.id == \"${group_id}\") | .items[] | select(.name == \"${item_name}\") | .post_install // \"\"" "${registry_file}" 2>/dev/null || true)"
      if [[ -n "${post}" && "${post}" != "null" ]]; then
        botstrap_pkg_run_snippet "${post}"
      fi
      return 0
    fi
  done < <(botstrap_pkg_resolve_keys)

  botstrap_log_warn "No optional install snippet for ${group_id}/${item_name} on this platform."
  return 1
}

botstrap_pkg_install_optional_csv() {
  local group_id="$1"
  local csv="$2"
  local reg="${3:-${BOTSTRAP_ROOT}/registry/optional.yaml}"
  local parts item raw
  IFS=',' read -ra parts <<<"${csv}"
  for raw in "${parts[@]}"; do
    item="${raw//[[:space:]]/}"
    [[ -z "${item}" || "${item}" == "none" ]] && continue
    botstrap_pkg_install_optional_item "${group_id}" "${item}" "${reg}" || true
  done
}

botstrap_csv_has_item() {
  local needle="$1"
  local csv="$2"
  [[ -z "${csv}" ]] && return 1
  local IFS=',' parts raw
  read -ra parts <<<"${csv}"
  for raw in "${parts[@]}"; do
    raw="${raw//[[:space:]]/}"
    [[ "${raw}" == "${needle}" ]] && return 0
  done
  return 1
}

# Install tools listed in csv (comma-separated names) in registry file order.
botstrap_pkg_install_tools_from_csv() {
  local csv="$1"
  local reg="$2"
  [[ -z "${csv}" ]] && return 0
  local name
  _botstrap_pkg_csv_order=()
  botstrap_read_lines_to_array _botstrap_pkg_csv_order < <(yq -r '.tools[].name' "${reg}")
  for name in "${_botstrap_pkg_csv_order[@]}"; do
    [[ -z "${name}" ]] && continue
    botstrap_csv_has_item "${name}" "${csv}" || continue
    botstrap_pkg_install "${name}" "${reg}" || botstrap_log_warn "Install reported failure for ${name} (continuing)."
  done
}

botstrap_pkg_get_update_snippet() {
  local tool_name="$1"
  local registry_file="$2"
  local key="$3"
  yq -r ".tools[] | select(.name == \"${tool_name}\") | .update[\"${key}\"] // \"\"" "${registry_file}" 2>/dev/null || true
}

botstrap_pkg_get_optional_update_snippet_for_key() {
  local group_id="$1"
  local item_name="$2"
  local registry_file="$3"
  local key="$4"
  yq -r ".groups[] | select(.id == \"${group_id}\") | .items[] | select(.name == \"${item_name}\") | .update[\"${key}\"] // \"\"" "${registry_file}" 2>/dev/null || true
}

botstrap_pkg_optional_item_verify_passes() {
  local group_id="$1"
  local item_name="$2"
  local registry_file="$3"
  local verify_cmd
  verify_cmd="$(yq -r ".groups[] | select(.id == \"${group_id}\") | .items[] | select(.name == \"${item_name}\") | .verify // \"\"" "${registry_file}" 2>/dev/null || true)"
  if [[ -z "${verify_cmd}" || "${verify_cmd}" == "null" ]]; then
    return 1
  fi
  bash -c "${verify_cmd}" &>/dev/null
}

# Run registry update snippet when verify passes (unlike install, does not skip when verify passes).
botstrap_pkg_update_tool() {
  local tool_name="$1"
  local registry_file="${2:-${BOTSTRAP_ROOT}/registry/core.yaml}"

  if ! command -v yq &>/dev/null; then
    botstrap_log_err "yq is required for registry-driven updates."
    return 1
  fi

  local verify_cmd
  verify_cmd="$(yq -r ".tools[] | select(.name == \"${tool_name}\") | .verify // \"\"" "${registry_file}" 2>/dev/null || true)"
  if [[ -z "${verify_cmd}" || "${verify_cmd}" == "null" ]]; then
    botstrap_log_info "Skipping update for ${tool_name} (no verify command)"
    return 0
  fi
  if ! bash -c "${verify_cmd}" &>/dev/null; then
    botstrap_log_info "Skipping update for ${tool_name} (not installed or verify failed)"
    return 0
  fi

  local key snippet=""
  while IFS= read -r key; do
    [[ -z "${key}" ]] && continue
    snippet="$(botstrap_pkg_get_update_snippet "${tool_name}" "${registry_file}" "${key}")"
    if [[ -n "${snippet}" && "${snippet}" != "null" ]]; then
      if command -v gum &>/dev/null && [[ -t 1 ]]; then
        gum spin --show-output --spinner dot --title "  update ${tool_name}..." -- bash -c "${snippet}" || botstrap_log_warn "Update reported failure for ${tool_name}"
      else
        botstrap_log_info "Updating ${tool_name} (registry key: ${key})"
        botstrap_pkg_run_snippet "${snippet}" || botstrap_log_warn "Update reported failure for ${tool_name}"
      fi
      return 0
    fi
  done < <(botstrap_pkg_resolve_keys)

  botstrap_log_info "No update snippet for '${tool_name}' on this platform (see ${registry_file})."
  return 0
}

botstrap_pkg_update_tools_from_csv() {
  local csv="$1"
  local reg="$2"
  [[ -z "${csv}" ]] && return 0
  local name
  _botstrap_pkg_up_csv_order=()
  botstrap_read_lines_to_array _botstrap_pkg_up_csv_order < <(yq -r '.tools[].name' "${reg}")
  for name in "${_botstrap_pkg_up_csv_order[@]}"; do
    [[ -z "${name}" ]] && continue
    botstrap_csv_has_item "${name}" "${csv}" || continue
    botstrap_pkg_update_tool "${name}" "${reg}" || true
  done
}

botstrap_pkg_update_optional_item() {
  local group_id="$1"
  local item_name="$2"
  local registry_file="${3:-${BOTSTRAP_ROOT}/registry/optional.yaml}"

  [[ -z "${item_name}" || "${item_name}" == "none" ]] && return 0

  if ! command -v yq &>/dev/null; then
    botstrap_log_err "yq is required for optional updates."
    return 1
  fi

  if ! botstrap_pkg_optional_requires_satisfied "${group_id}" "${item_name}" "${registry_file}"; then
    return 0
  fi

  if ! botstrap_pkg_optional_item_verify_passes "${group_id}" "${item_name}" "${registry_file}"; then
    botstrap_log_info "Skipping optional update ${group_id}/${item_name} (not installed or verify failed)"
    return 0
  fi

  local key snippet=""
  while IFS= read -r key; do
    [[ -z "${key}" ]] && continue
    snippet="$(botstrap_pkg_get_optional_update_snippet_for_key "${group_id}" "${item_name}" "${registry_file}" "${key}")"
    if [[ -n "${snippet}" && "${snippet}" != "null" ]]; then
      if command -v gum &>/dev/null && [[ -t 1 ]]; then
        gum spin --show-output --spinner dot --title "  update ${group_id}/${item_name}..." -- bash -c "${snippet}" || botstrap_log_warn "Optional update reported failure for ${group_id}/${item_name}"
      else
        botstrap_log_info "Updating optional ${group_id}/${item_name} (registry key: ${key})"
        botstrap_pkg_run_snippet "${snippet}" || botstrap_log_warn "Optional update reported failure for ${group_id}/${item_name}"
      fi
      return 0
    fi
  done < <(botstrap_pkg_resolve_keys)

  botstrap_log_info "No optional update snippet for ${group_id}/${item_name} on this platform."
  return 0
}

botstrap_pkg_update_optional_csv() {
  local group_id="$1"
  local csv="$2"
  local reg="${3:-${BOTSTRAP_ROOT}/registry/optional.yaml}"
  local parts item raw
  IFS=',' read -ra parts <<<"${csv}"
  for raw in "${parts[@]}"; do
    item="${raw//[[:space:]]/}"
    [[ -z "${item}" || "${item}" == "none" ]] && continue
    botstrap_pkg_update_optional_item "${group_id}" "${item}" "${reg}" || true
  done
}

# Core tool names to verify: explicit BOTSTRAP_CORE_TOOLS, else core-tools.env, else all core (legacy).
botstrap_core_tool_names_for_verify() {
  local core_reg="${BOTSTRAP_ROOT}/registry/core.yaml"
  local raw mode="legacy"
  if [[ -n "${BOTSTRAP_CORE_TOOLS+x}" ]]; then
    mode="env"
    raw="${BOTSTRAP_CORE_TOOLS-}"
  else
    local cf="${HOME}/.config/botstrap/core-tools.env"
    if [[ -f "${cf}" ]] && grep -q '^core_tools=' "${cf}"; then
      mode="file"
      raw="$(grep -m1 '^core_tools=' "${cf}" | sed 's/^core_tools=//')"
    fi
  fi
  if [[ "${mode}" == "legacy" ]]; then
    yq -r '.tools[].name' "${core_reg}"
    return
  fi
  _botstrap_cv_order=()
  botstrap_read_lines_to_array _botstrap_cv_order < <(yq -r '.tools[].name' "${core_reg}")
  local n
  for n in "${_botstrap_cv_order[@]}"; do
    [[ -z "${n}" ]] && continue
    botstrap_csv_has_item "${n}" "${raw}" && printf '%s\n' "${n}"
  done
}

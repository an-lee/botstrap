#!/usr/bin/env bash
# Registry-driven install helpers (Unix). Requires mikefarah/yq on PATH.

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

botstrap_pkg_install() {
  local tool_name="$1"
  local registry_file="${2:-${BOTSTRAP_ROOT}/registry/core.yaml}"

  if ! command -v yq &>/dev/null; then
    botstrap_log_err "yq is required for registry-driven installs. Install yq (mikefarah/yq) and re-run Phase 1."
    return 1
  fi

  local key snippet=""
  while IFS= read -r key; do
    [[ -z "${key}" ]] && continue
    snippet="$(botstrap_pkg_get_snippet "${tool_name}" "${registry_file}" "${key}")"
    if [[ -n "${snippet}" && "${snippet}" != "null" ]]; then
      botstrap_log_info "Installing ${tool_name} (using registry key: ${key})"
      botstrap_pkg_run_snippet "${snippet}"
      local post
      post="$(yq -r ".tools[] | select(.name == \"${tool_name}\") | .post_install // \"\"" "${registry_file}" 2>/dev/null || true)"
      if [[ -n "${post}" && "${post}" != "null" ]]; then
        botstrap_pkg_run_snippet "${post}"
      fi
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

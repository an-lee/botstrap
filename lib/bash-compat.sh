#!/usr/bin/env bash
# Bash 3.2 compatibility: macOS ships Bash 3.2 as /usr/bin/env bash; mapfile/readarray
# and nameref (local -n) require Bash 4+. Use this helper instead of mapfile for portable arrays.

# Read all lines from stdin into the array named by $1. Caller must pass a safe identifier only
# (internal names like _botstrap_prereq_tools), never user-controlled input.
botstrap_read_lines_to_array() {
  local _arr_name="$1"
  local line
  # shellcheck disable=SC2294
  eval "${_arr_name}=()"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    # shellcheck disable=SC2294
    eval "${_arr_name}+=(\"\${line}\")"
  done
}

#!/usr/bin/env bash
# Verify Neovim for registry core.yaml: Linux uses official /opt binary only (avoids skipping install when an old distro nvim exists).
set -euo pipefail

case "$(uname -s)" in
  Linux)
    for _nvim in /opt/nvim-linux-x86_64/bin/nvim /opt/nvim-linux-arm64/bin/nvim; do
      if [[ -x "${_nvim}" ]]; then
        exec "${_nvim}" --version
      fi
    done
    exit 1
    ;;
  *)
    exec nvim --version
    ;;
esac

#!/usr/bin/env bash
# Install or update Neovim on Linux from the official GitHub release tarball (see https://neovim.io/doc/install/).
set -euo pipefail

: "${BOTSTRAP_ROOT:?BOTSTRAP_ROOT must be set}"
# shellcheck source=lib/log.sh
source "${BOTSTRAP_ROOT}/lib/log.sh"

if ! command -v curl >/dev/null 2>&1; then
  botstrap_log_err "curl is required to install Neovim on Linux."
  exit 1
fi

_arch="$(uname -m)"
case "${_arch}" in
  x86_64)
    _name="nvim-linux-x86_64"
    ;;
  aarch64 | arm64)
    _name="nvim-linux-arm64"
    ;;
  *)
    botstrap_log_err "Unsupported architecture for Neovim Linux binary: ${_arch}"
    exit 1
    ;;
esac

_url="https://github.com/neovim/neovim/releases/latest/download/${_name}.tar.gz"
_tdir="$(mktemp -d)"
trap 'rm -rf "${_tdir}"' EXIT

curl -fL -o "${_tdir}/nvim.tar.gz" "${_url}"
sudo rm -rf "/opt/${_name}"
sudo tar -C /opt -xzf "${_tdir}/nvim.tar.gz"

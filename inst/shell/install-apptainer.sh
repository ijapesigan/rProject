#!/bin/bash

# Apptainer: the official unprivileged installer, into ~/.local.
# The old ~/.local/<arch> is moved aside, not deleted: a running container can
# hold its files open (NFS .nfs* files), and deleting them then fails halfway.

set -euo pipefail

# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

arch="$(uname -m)"
dest="${HOME}/.local/${arch}"
old=""
if [[ -d "${dest}" ]]; then
  old="${dest}.old.$(date +%Y%m%d%H%M%S)"
  mv "${dest}" "${old}"
fi

if fetch "https://raw.githubusercontent.com/apptainer/apptainer/main/tools/install-unprivileged.sh" - |
  bash -s -- -a "${arch}" "${HOME}/.local" &&
  [[ -n "$(version "${BIN}/apptainer")" ]]; then
  say "apptainer: $(version "${BIN}/apptainer")"
  if [[ -n "${old}" ]]; then
    rm -rf "${old}" 2>/dev/null ||
      say "kept ${old} (files in use); remove it later"
  fi
else
  rm -rf "${dest}"
  if [[ -n "${old}" ]]; then
    mv "${old}" "${dest}"
    die "apptainer: install failed; kept the previous version"
  fi
  die "apptainer: install failed"
fi

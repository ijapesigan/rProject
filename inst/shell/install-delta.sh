#!/bin/bash
# delta, a viewer for git diffs: the static GitHub release, into ~/.local/bin (~/work/tools where
# ~/work exists). The dotfiles use it only if present.
set -euo pipefail
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_delta() {
  install_release delta dandavison/delta 'delta-[0-9.]+-{arch}-unknown-linux-(musl|gnu)\.tar\.gz'
}

safe_install delta install_delta

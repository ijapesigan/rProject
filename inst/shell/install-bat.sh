#!/bin/bash
# bat, cat with syntax highlighting: the static GitHub release, into ~/.local/bin (~/work/tools where
# ~/work exists). The dotfiles use it only if present.
set -euo pipefail
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_bat() {
  install_release bat sharkdp/bat 'bat-v[0-9.]+-{arch}-unknown-linux-(musl|gnu)\.tar\.gz'
}

safe_install bat install_bat

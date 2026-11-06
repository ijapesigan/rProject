#!/bin/bash
# eza, a modern ls: the static GitHub release, into ~/.local/bin (~/work/tools where
# ~/work exists). The dotfiles use it only if present.
set -euo pipefail
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_eza() {
  install_release eza eza-community/eza 'eza_{arch}-unknown-linux-(musl|gnu)\.tar\.gz'
}

safe_install eza install_eza

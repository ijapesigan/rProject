#!/bin/bash
# zoxide, a smarter cd: the static GitHub release, into ~/.local/bin (~/work/tools where
# ~/work exists). The dotfiles use it only if present.
set -euo pipefail
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_zoxide() {
  install_release zoxide ajeetdsouza/zoxide 'zoxide-[0-9.]+-{arch}-unknown-linux-musl\.tar\.gz'
}

safe_install zoxide install_zoxide

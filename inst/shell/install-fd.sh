#!/bin/bash
# fd, a simple find: the static GitHub release, into ~/.local/bin (~/work/tools where
# ~/work exists). The dotfiles use it only if present.
set -euo pipefail
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_fd() {
  install_release fd sharkdp/fd 'fd-v[0-9.]+-{arch}-unknown-linux-(musl|gnu)\.tar\.gz'
}

safe_install fd install_fd

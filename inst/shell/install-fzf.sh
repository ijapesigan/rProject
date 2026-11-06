#!/bin/bash
# fzf, the fuzzy finder: the static GitHub release, into ~/.local/bin (~/work/tools where
# ~/work exists). The dotfiles use it only if present.
set -euo pipefail
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_fzf() {
  install_release fzf junegunn/fzf 'fzf-[0-9.]+-linux_{go}\.tar\.gz'
}

safe_install fzf install_fzf

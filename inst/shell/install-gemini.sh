#!/bin/bash

# Gemini CLI: Node.js 20+ through nvm when needed, then npm into ~/.local.

set -euo pipefail

# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_gemini() {
  local need_node=true
  if command -v node >/dev/null 2>&1 &&
    [[ "$(node -p 'process.versions.node.split(".")[0]')" -ge 20 ]]; then
    need_node=false
  fi
  if ${need_node}; then
    export NVM_DIR="${HOME}/.nvm"
    if [[ ! -s "${NVM_DIR}/nvm.sh" ]]; then
      fetch "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh" - | bash
    fi
    # nvm does not work with set -u
    set +u
    # shellcheck source=/dev/null
    source "${NVM_DIR}/nvm.sh"
    nvm install 22
    nvm use 22
    set -u
    # gemini runs `env node`: link node into ~/.local/bin (on PATH through the
    # dotfiles), so it works without nvm being loaded by ~/.bashrc
    ln -sf "$(command -v node)" "${BIN}/node"
  fi
  npm install -g --prefix "${HOME}/.local" @google/gemini-cli
}

safe_install gemini install_gemini

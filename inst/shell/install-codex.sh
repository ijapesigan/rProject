#!/bin/bash

# Codex CLI: the official installer, into ~/.local/bin.

set -euo pipefail

# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_codex() {
  fetch "https://chatgpt.com/codex/install.sh" - |
    CODEX_INSTALL_DIR="${BIN}" bash
}

safe_install codex install_codex

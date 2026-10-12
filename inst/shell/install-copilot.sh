#!/bin/bash

# GitHub Copilot CLI: the official installer, into ~/.local.

set -euo pipefail

# shellcheck source=install-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_copilot() {
  fetch "https://gh.io/copilot-install" - |
    PREFIX="${HOME}/.local" bash
}

safe_install copilot install_copilot

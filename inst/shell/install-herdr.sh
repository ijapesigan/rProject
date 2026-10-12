#!/bin/bash

# herdr: the official installer, into ~/.local/bin.

set -euo pipefail

# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_herdr() {
  fetch "https://herdr.dev/install.sh" - |
    HERDR_INSTALL_DIR="${BIN}" bash
}

safe_install herdr install_herdr

#!/bin/bash

# Claude Code: the official installer, into ~/.local/bin.

set -euo pipefail

# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_claude() {
  fetch "https://claude.ai/install.sh" - | bash
}

safe_install claude install_claude

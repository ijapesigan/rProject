#!/bin/bash

# Claude Code: the official installer, into ~/.local/bin. Its versions, about
# 300 MB each, live in ~/work/tools where ~/work exists.

set -euo pipefail

# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_claude() {
  fetch "https://claude.ai/install.sh" - | bash
}

link_tool .local/share/claude
safe_install claude install_claude

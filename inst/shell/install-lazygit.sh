#!/bin/bash

set -e

# pre TMP ----------------------------------------------------------------------
TMP_FOLDER=$(mktemp -d -q "$PWD/TEMPDIR" || exit 1)
# ------------------------------------------------------------------------------

cd TMP_FOLDER
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
mkdir -p "$HOME/.local/bin"
install lazygit "$HOME/.local/bin"

# post TMP ---------------------------------------------------------------------
rm -rf -- "$TMP_FOLDER"
trap - EXIT
exit
# ------------------------------------------------------------------------------

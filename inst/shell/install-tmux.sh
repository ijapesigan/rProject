#!/bin/bash

set -e

# pre TMP ----------------------------------------------------------------------
TMP_FOLDER=$(mktemp -d -q "$PWD/TEMPDIR" || exit 1)
# ------------------------------------------------------------------------------

cd TMP_FOLDER
TMUX_VERSION="$(curl -s https://api.github.com/repos/tmux/tmux/releases/latest | grep '\"tag_name\":' | sed -E 's/.*\"v*([^"]+)\".*/\1/')"
wget "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
tar -zxvf "tmux-${TMUX_VERSION}.tar.gz"
cd "tmux-${TMUX_VERSION}"
./configure --prefix="$HOME/.local"
make
make install

# post TMP ---------------------------------------------------------------------
rm -rf -- "$TMP_FOLDER"
trap - EXIT
exit
# ------------------------------------------------------------------------------

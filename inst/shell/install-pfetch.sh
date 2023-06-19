#!/bin/bash

set -e

# pre TMP ----------------------------------------------------------------------
TMP_FOLDER=$(mktemp -d -q "$PWD/TEMPDIR" || exit 1)
# ------------------------------------------------------------------------------

cd TMP_FOLDER
git clone https://github.com/dylanaraps/pfetch.git
mkdir -p $HOME/.local/bin
install pfetch/pfetch $HOME/.local/bin/
ls -l $HOME/.local/bin/pfetch

# post TMP ---------------------------------------------------------------------
rm -rf -- "$TMP_FOLDER"
trap - EXIT
exit
# ------------------------------------------------------------------------------

#!/bin/bash

set -e

# pre TMP ----------------------------------------------------------------------
TMP_FOLDER=$(mktemp -d -q "${PWD}"/TEMPDIR.XXXXXXXXXX || exit 1)
# ------------------------------------------------------------------------------

cd TMP_FOLDER
wget https://www.statmodel.com/download/install_mpluslinux_demo64.bin
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "Use ${RED}$HOME/.local/bin${NC} as installation folder.\n"
sh install_mpluslinux_demo64.bin
rm -rf install_mpluslinux_demo64.bin

# post TMP ---------------------------------------------------------------------
rm -rf -- "$TMP_FOLDER"
trap - EXIT
exit
# ------------------------------------------------------------------------------

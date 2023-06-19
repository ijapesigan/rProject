#!/bin/bash

set -e

wget https://www.statmodel.com/download/install_mpluslinux_demo64.bin
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "Use ${RED}$HOME/.local/bin${NC} as installation folder.\n"
sh install_mpluslinux_demo64.bin
rm -rf install_mpluslinux_demo64.bin
mkdir -p "$HOME/.local/bin"
rm -rf install_mpluslinux_demo64.bin

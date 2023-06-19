#!/bin/bash

set -e

git clone https://github.com/dylanaraps/pfetch.git
mkdir -p "$HOME/.local/bin"
install pfetch/pfetch "$HOME/.local/bin/"
ls -l "$HOME/.local/bin/pfetch"
rm-rf pfetch*

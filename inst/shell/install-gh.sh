#!/bin/bash

set -e

# requires go

git clone https://github.com/cli/cli.git gh-cli
cd gh-cli
mkdir -p "$HOME/.local/bin"
make install prefix="$HOME/.local/bin"
cd ..
rm -rf gh-cli

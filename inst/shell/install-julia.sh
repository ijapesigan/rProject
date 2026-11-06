#!/bin/bash

set -e

JULIA_VERSION="$(curl -s https://api.github.com/repos/JuliaLang/julia/releases/latest | grep -Po '\"tag_name\": \"v\K[^\"]*')"
wget "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-$JULIA_VERSION-linux-x86_64.tar.gz"
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
link_tool .local/julia
mkdir -p "$HOME/.local/julia"
tar -zxvf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -C "$HOME/.local/julia" --strip-components 1
ln -sf "$HOME/.local/julia/bin/julia" "$HOME/.local/bin/julia" 
rm -rf julia*

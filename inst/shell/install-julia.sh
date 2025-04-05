#!/bin/bash

set -e

JULIA_VERSION="$(curl -s https://api.github.com/repos/JuliaLang/julia/releases/latest | grep -Po '\"tag_name\": \"v\K[^\"]*')"
wget "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-$JULIA_VERSION-linux-x86_64.tar.gz"
mkdir -p "$HOME/.local/julia"
tar -zxvf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -C "$HOME/.local/julia" --strip-components 1
ln -s "$HOME/.local/julia/bin/julia" "$HOME/.local/bin/julia" 
rm -rf julia*

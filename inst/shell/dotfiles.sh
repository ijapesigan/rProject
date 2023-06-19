#!/bin/bash

set -e

git clone https://github.com/jeksterslab/dotfiles.git
cd dotfiles
make
cd ..
rm -rf dotfiles

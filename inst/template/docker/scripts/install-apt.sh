#!/bin/bash

set -e

# system packages in apt.txt (the project's list), one call; nothing to do
# without the list
if [ ! -f apt.txt ]; then
    exit 0
fi

apt-get update
grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' apt.txt |
    xargs -r apt-get install -y --no-install-recommends

echo -e "\nInstall apt.txt, done!"

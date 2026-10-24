#!/bin/bash

set -e

# CRAN packages in cran.txt (the project's list: the packages wanted, never
# their dependencies), one call. install2.r resolves each package's
# current dependencies: on r2u as binaries through bspm (with the system
# libraries), elsewhere from the image's repository (PPM binaries on
# rocker). Nothing to do without the list
if [ ! -f cran.txt ]; then
    exit 0
fi

grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' cran.txt |
    xargs -r install2.r --error --skipinstalled -n -1

echo -e "\nInstall cran.txt, done!"

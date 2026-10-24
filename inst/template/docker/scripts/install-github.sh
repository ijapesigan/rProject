#!/bin/bash

set -e

# GitHub packages in github.txt (the project's list: owner/repo[@ref]),
# one call, after the CRAN packages; remotes reads each DESCRIPTION and
# installs what is missing. Nothing to do without the list
if [ ! -f github.txt ]; then
    exit 0
fi

# without a token the GitHub API allows 60 requests an hour, which these
# installs exceed: stop instead of failing halfway
if [ -z "$GITHUB_PAT" ]; then
    echo "GITHUB_PAT NOT set: cannot install github.txt" >&2
    exit 1
fi

Rscript -e "
  pkg <- readLines('github.txt', warn = FALSE)
  pkg <- trimws(pkg[!grepl('^[[:space:]]*(#|$)', pkg)])
  if (length(pkg) > 0L) {
    remotes::install_github(pkg, upgrade = 'never')
  }
"

echo -e "\nInstall github.txt, done!"

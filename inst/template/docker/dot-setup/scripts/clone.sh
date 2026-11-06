#!/bin/bash

# stop at the first error: a failed clone must not go on to remove .git
set -Eeuo pipefail

# the SSH host: github-<owner> when ~/.ssh/config defines that alias (for
# example on Roar), else github.com
host="github.com"
if grep -Eqs "^Host[[:space:]]+(.*[[:space:]])?github-{{owner}}([[:space:]]|$)" ~/.ssh/config; then
  host="github-{{owner}}"
fi
git clone "git@${host}:{{public}}.git"
rm -rf "$PWD/.git"
mv "{{repo}}/.git" "$PWD"
rm -rf "{{repo}}"

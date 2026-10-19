#!/usr/bin/env bash

# Watch a project's private repository after the agent gives an upload
# folder, so the push is verified as soon as it lands (no "O2G" needed).
# rProject only; run on the host (it needs SSH), in the agent's background
# tool:
#
#   bash <rProject>/.setup/scripts/o2g-watch.sh <project folder> "<subject>" [hours]
#
#   <subject>  the first line of the commit message in the change-set log
#   [hours]    how long to watch (default 8)
#
# Every 60 seconds it reads the private HEAD (git ls-remote, no download).
# When HEAD changes, the project's verify.sh pulls it into .verify, and the
# commit's first line is compared with <subject>. It prints one line and
# exits:
#   0  match <sha>              the agent runs make verify RECORD=TRUE
#   3  other <sha> <subject>    someone else's push: report, record nothing
#   4  timeout                  the user's "O2G" works as before
#   1  an error (no .verify, no project)

set -Eeuo pipefail

if [[ $# -lt 2 ]]; then
  sed -n '8,11p' "$0" >&2
  exit 1
fi
project_dir="$1"
subject="$2"
hours="${3:-8}"

cd "${project_dir}"
[[ -f .setup/scripts/verify.sh ]] || {
  echo "no .setup/scripts/verify.sh in ${project_dir}" >&2
  exit 1
}
# .verify, as verify.sh keeps it (its first run clones it)
[[ -d .verify/.git ]] || bash .setup/scripts/verify.sh > /dev/null

head_sha() {
  git -C .verify ls-remote origin HEAD 2>/dev/null | cut -f 1
}

start="$(head_sha)"
[[ -n "${start}" ]] || {
  echo "cannot read the private HEAD of ${project_dir}" >&2
  exit 1
}
for ((i = 0; i < hours * 60; i++)); do
  sleep 60
  now="$(head_sha)"
  [[ -z "${now}" || "${now}" == "${start}" ]] && continue
  bash .setup/scripts/verify.sh > /dev/null
  pushed="$(git -C .verify log -1 --format=%s)"
  if [[ "${pushed}" == "${subject}" ]]; then
    echo "match ${now:0:7}"
    exit 0
  fi
  echo "other ${now:0:7} ${pushed}"
  exit 3
done
echo "timeout"
exit 4

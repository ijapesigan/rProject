#!/usr/bin/env bash

# Watch a project's private repository after the agent gives an upload
# folder, so the push is verified as soon as it lands (no "O2G" needed).
# rProject only; run on the host (it needs SSH), in the agent's background
# tool:
#
#   bash <rProject>/.setup/scripts/o2g-watch.sh <project folder> "<subject>" [hours] [upload]
#
#   <subject>  the first line of the commit message in the change-set log
#   [hours]    how long to watch (default 8)
#   [upload]   the upload folder (default: the newest
#              <work>/upload/*-<project>-*/ folder)
#
# Every 60 seconds it reads the private HEAD (git ls-remote, no download).
# When HEAD changes, the project's verify.sh pulls it into .verify, and the
# commit's first line is compared with <subject>, then the upload folder's
# files with the pushed ones (cmp): Overleaf prefills the previous subject,
# so a push may carry the files under an old subject. It prints one line and
# exits:
#   0  match <sha>              the agent runs make verify RECORD=TRUE
#   0  match-files <sha> <subject>
#                               the files match, the subject does not: the
#                               agent verifies, records, and tells the user
#   3  other <sha> <subject>    someone else's push: report, record nothing
#   4  timeout                  the user's "O2G" works as before
#   1  an error (no .verify, no project)

set -Eeuo pipefail

if [[ $# -lt 2 ]]; then
  sed -n '8,14p' "$0" >&2
  exit 1
fi
project_dir="$1"
subject="$2"
hours="${3:-8}"
upload="${4:-}"

cd "${project_dir}"
if [[ -z "${upload}" ]]; then
  # the newest upload folder of this project (names start with the date)
  upload="$(
    find "$(dirname "${PWD}")/upload" -maxdepth 1 -type d \
      -name "*-$(basename "${PWD}")-*" 2>/dev/null | sort | tail -n 1
  )"
fi

# every file of the upload folder equals the pushed one (an empty or missing
# folder never matches)
files_match() {
  [[ -n "${upload}" && -d "${upload}" ]] || return 1
  local n=0 file
  while IFS= read -r -d '' file; do
    n=$((n + 1))
    cmp -s "${upload}/${file}" ".verify/${file}" || return 1
  done < <(cd "${upload}" && find . -type f -printf '%P\0')
  [[ "${n}" -gt 0 ]]
}
[[ -f .setup/scripts/verify.sh ]] || {
  echo "no .setup/scripts/verify.sh in ${project_dir}" >&2
  exit 1
}
# .verify, as verify.sh keeps it (its first run clones it)
[[ -d .verify/.git ]] || bash .setup/scripts/verify.sh > /dev/null

# a failed read prints nothing and succeeds: it counts as no change
head_sha() {
  git -C .verify ls-remote origin HEAD 2>/dev/null | cut -f 1 || true
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
  if files_match; then
    echo "match-files ${now:0:7} ${pushed}"
    exit 0
  fi
  echo "other ${now:0:7} ${pushed}"
  exit 3
done
echo "timeout"
exit 4

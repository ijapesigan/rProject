#!/usr/bin/env bash

# "build rProject": build and publish rProject from the private repository.
# rProject only; run on the host (it needs SSH and gh):
#
#   bash .setup/scripts/build-rproject.sh [--rebuild] <image>
#
#   <image>     Apptainer image (agents pass ~/work/sif/docs.sif unless the user
#               names another)
#   --rebuild   publish a version equal to the public one (never a lower one)
#   BUILD=host  run make all here instead of on a compute node
#   DRY_RUN=1   stop before the commit: no push
#
# Agents start it detached, as build-docs.sh. The log is
# <work>/tmp/YYYY-MM-DD-build-rproject.log; the status file next to it says
# "running", then "done" or "STOPPED: <reason>". The keyword is the user's
# explicit request to push. The PUB checks and the record follow, as for "PUB".
#
# It stops, before anything is pushed, when the newest private push is not
# verified, the version is not above the public one, or R CMD check has any
# error, warning, or note. `origin` must be the public repository at the push.

set -Eeuo pipefail

if [[ -z "${BUILD_RPROJECT_ROOT:-}" ]]; then
  BUILD_RPROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  export BUILD_RPROJECT_ROOT
  build_copy="$(dirname "${BUILD_RPROJECT_ROOT}")/tmp/build-rproject-copy-$$.sh"
  mkdir -p "$(dirname "${build_copy}")"
  cp "${BASH_SOURCE[0]}" "${build_copy}"
  export BUILD_RPROJECT_COPY="${build_copy}"
  exec bash "${build_copy}" "$@"
fi

rebuild=FALSE
if [[ "${1:-}" == "--rebuild" ]]; then
  rebuild=TRUE
  shift
fi
if [[ $# -lt 1 ]]; then
  sed -n '6,13p' "$0" >&2
  exit 2
fi
image="$1"
dry_run="${DRY_RUN:-0}"
binds=(-B "${HOME}/work:$(readlink -f "${HOME}/work")")
if [[ -d /scratch/ibp5092 ]]; then
  binds+=(-B /scratch/ibp5092)
fi

root="${BUILD_RPROJECT_ROOT}"
work="$(dirname "${root}")"
dir="${work}/tmp/$(date +%Y-%m-%d)-build-rproject"
log_file="${dir}.log"
status_file="${dir}.status"
gh="$(command -v gh || echo "${HOME}/.local/bin/gh")"
public_repo="$(tr -d '[:space:]' < "${root}/.setup/repo/public-github.md")"

for f in "${work}"/tmp/*-build-rproject.status; do
  [[ -f "${f}" ]] || continue
  read -r state pid host _ < "${f}" || true
  [[ "${state:-}" == running ]] || continue
  if [[ "${host}" != "$(hostname)" ]] || kill -0 "${pid}" 2>/dev/null; then
    echo "build-rproject.sh: another run is running (${f}: $(cat "${f}"))" >&2
    exit 1
  fi
done

mkdir -p "${dir}"
exec > >(tee -a "${log_file}") 2>&1

log() { echo "[$(date '+%F %T')] $*"; }
reason=""
fail() {
  reason="$*"
  log "STOPPED: $*"
  log "download kept in ${dir}"
  exit 1
}
finish() {
  local code=$?
  if [[ ${code} -eq 0 ]]; then
    echo "done $(date '+%F %T')" > "${status_file}"
  else
    echo "STOPPED $(date '+%F %T'): ${reason:-exit ${code}}" > "${status_file}"
  fi
  rm -f "${BUILD_RPROJECT_COPY:-}"
}
trap finish EXIT
trap 'reason="hangup"; exit 129' HUP
trap 'reason="interrupted"; exit 130' INT
trap 'reason="terminated"; exit 143' TERM
echo "running $$ $(hostname) $(date '+%F %T')" > "${status_file}"

[[ -f "${image}" ]] || fail "no image ${image}"
[[ -x "${gh}" ]] || fail "gh not found"

ssh_host() {
  local owner=$1
  if ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "Hi ${owner}!"; then
    echo "github.com"
  else
    echo "github-${owner}"
  fi
}
private_host="$(ssh_host jeksterslab-psu)"
public_host="$(ssh_host ijapesigan)"
if [[ "${public_host}" != "github.com" ]]; then
  export GIT_CONFIG_COUNT=1
  export GIT_CONFIG_KEY_0="url.git@${public_host}:.insteadOf"
  export GIT_CONFIG_VALUE_0="git@github.com:"
fi

# the private repository, into a copy
copy="${dir}/rProject"
rm -rf "${copy}"
git clone -q "git@${private_host}:jeksterslab-psu/rProject.git" "${copy}" ||
  fail "cannot download jeksterslab-psu/rProject"
cd "${copy}"
head_sha="$(git rev-parse --short=7 HEAD)"
log "private ${head_sha}"

# nothing unverified gets published: the newest row for a private commit, or
# the record pushed right after it, is verified
index=".setup/logs/index.md"
# as bytes, to keep this file ASCII: U+2713 in the index, U+2716 in R CMD check
check_mark=$'\xe2\x9c\x93'
cross_mark=$'\xe2\x9c\x96'
verified="$(grep -E '^\| [0-9-]+ \| [0-9a-f]{7,} \|' "${index}" | head -n 1 || true)"
[[ -n "${verified}" ]] || fail "no private push in ${index}"
[[ "${verified}" == *"${check_mark}"* ]] || fail "the newest push in ${index} is not verified: ${verified}"
recorded="$(printf '%s' "${verified}" | cut -d'|' -f3 | tr -d '[:space:]')"
git merge-base --is-ancestor "${recorded}" HEAD ||
  fail "the verified ${recorded} is not in the private history"
later="$(git diff --name-only "${recorded}" HEAD | grep -v -E '^\.setup/(logs|ai|notes)/' || true)"
[[ -z "${later}" ]] || fail "files changed after the verified ${recorded}: ${later}"

# the version rule
version="$(sed -n 's/^Version: *//p' DESCRIPTION)"
public_version="$("${gh}" api "repos/${public_repo}/contents/DESCRIPTION" --jq .content |
  base64 -d | sed -n 's/^Version: *//p')"
newest="$(printf '%s\n%s\n' "${version}" "${public_version}" | sort -V | tail -n 1)"
if [[ "${version}" == "${public_version}" ]]; then
  [[ "${rebuild}" == TRUE ]] || fail "${version} is already public: use --rebuild"
elif [[ "${newest}" != "${version}" ]]; then
  fail "private ${version} is below public ${public_version}"
fi
log "private ${version}, public ${public_version}"

# make all, on a compute node as "build lib" does
all_log="${dir}.make-all.log"
log "make all (log: ${all_log})"
if [[ "${BUILD:-}" == "host" ]] || ! command -v srun > /dev/null 2>&1; then
  nice -n 19 apptainer exec "${binds[@]}" "${image}" make all > "${all_log}" 2>&1 ||
    fail "make all (see ${all_log})"
else
  srun --account=open --partition=basic --cpus-per-task=4 --mem=16G --time=6:00:00 \
    apptainer exec "${binds[@]}" "${image}" make all > "${all_log}" 2>&1 ||
    fail "make all (see ${all_log})"
fi
# strict: any error, warning, or note stops the run
if grep -E '^Status: .*(ERROR|WARNING|NOTE)|[1-9][0-9]* (error|warning|note)s? '"${cross_mark}" "${all_log}" > "${dir}.check.txt"; then
  fail "R CMD check is not clean: $(head -n 3 "${dir}.check.txt" | tr '\n' ' ')"
fi
log "make all done; R CMD check is clean"

# make auto, split: the container has no SSH keys and the host has no R
bash .setup/scripts/clone.sh || fail "clone.sh"
origin="$(git remote get-url origin)"
case "${origin}" in
  *"${public_repo}.git" | *"${public_repo}") ;;
  *) fail "origin is ${origin}, not ${public_repo}: nothing was published" ;;
esac
apptainer exec "${binds[@]}" "${image}" Rscript -e "rProject::Public(\"${PWD}\")" ||
  fail "Public()"
apptainer exec "${binds[@]}" "${image}" make secretscan || fail "make secretscan"
apptainer exec "${binds[@]}" "${image}" Rscript -e "rProject::Lock(\"${PWD}\")" || fail "Lock()"
git add --all
lost="$(git diff --cached --name-only --diff-filter=D -- .github/workflows)"
[[ -z "${lost}" ]] || fail "the push would delete workflows: $(echo "${lost}" | tr '\n' ' ')"
if [[ "${dry_run}" == "1" ]]; then
  log "DRY_RUN: would commit and push"
  git diff --cached --stat | tail -n 3
  exit 0
fi
git diff --cached --quiet && fail "nothing to commit"
git commit -q -m "Automated build."
git push -q origin main || fail "git push"
sha="$(git rev-parse --short=8 HEAD)"
if ! git rev-parse -q --verify "refs/tags/v${version}" > /dev/null; then
  git tag -a "v${version}" -m "v${version}"
  git push -q origin "v${version}" || fail "git push of the tag"
fi
log "pushed ${sha}, tag v${version}"
cd "${work}"
rm -rf "${dir:?}"
log "done; the PUB checks and the record follow. Log: ${log_file}"

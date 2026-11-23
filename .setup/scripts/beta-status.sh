#!/usr/bin/env bash
# Report the state of the beta chain (spec .setup/ai/specs/2026-11-19-beta-chain.md):
# per project, the local, pushed and (optionally) public version, the last row of
# .setup/logs/index.md, and every copied file (.setup/r-dependencies/<lib>/*, and
# .setup/cpp/<lib>-*.cpp) compared with its source's pushed state (origin/main of
# the source's .verify). Read-only: git fetch in each .verify, no checkout, no push.
# Usage: bash .setup/scripts/beta-status.sh [FETCH=FALSE] [PUBLIC=TRUE] [project ...]
#   FETCH=FALSE  skip git fetch in each .verify (faster, may be stale)
#   PUBLIC=TRUE  also read the public DESCRIPTION with gh (network)
#   project ...  folder names (default: the whole chain, bottom-up)
set -Eeuo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work="$(dirname "${here}")"
fetch="TRUE"
public="FALSE"
projects=()
for arg in "$@"; do
  case "${arg}" in
    FETCH=*) fetch="${arg#FETCH=}" ;;
    PUBLIC=*) public="${arg#PUBLIC=}" ;;
    *) projects+=("${arg}") ;;
  esac
done
if [[ "${#projects[@]}" -eq 0 ]]; then
  projects=(
    linearAlgebra rhoMatrix dataSets randomGaussian wald lavHelper
    nBootstrap miHelper gammaADF gammaN strRegression deltaMethod
    cran-semmcci processLM cran-betaSandwich cran-betaNB cran-betaLB
    cran-betaDelta cran-betaMC
  )
fi

# Folder of a library or project: <name>, devel-<name>, else cran-<name>.
Dir() {
  if [[ -d "${work}/$1" ]]; then
    printf '%s\n' "${work}/$1"
  elif [[ -d "${work}/devel-$1" ]]; then
    printf '%s\n' "${work}/devel-$1"
  elif [[ -d "${work}/cran-$1" ]]; then
    printf '%s\n' "${work}/cran-$1"
  fi
}

# Version field of a DESCRIPTION read from stdin.
Version() {
  grep -m 1 '^Version:' | sed 's/^Version:[[:space:]]*//' || true
}

# Blob of <file> in origin/main of the .verify of <dir>, trying R/ then .setup/cpp/.
SourceBlob() {
  local dir="$1" file="$2" path
  for path in "R/${file}" ".setup/cpp/${file}"; do
    if git -C "${dir}/.verify" rev-parse -q --verify \
      "origin/main:${path}" 2> /dev/null; then
      return 0
    fi
  done
  return 0
}

# Compare one copied file (<lib> <file>) with its source; print a line if it differs.
CheckCopy() {
  local lib="$1" file="$2" src blob
  src="$(Dir "${lib}")"
  if [[ -z "${src}" || ! -d "${src}/.verify" ]]; then
    printf '  %s: %s: no source .verify\n' "${lib}" "${file##*/}"
    return 0
  fi
  blob="$(SourceBlob "${src}" "${file##*/}")"
  if [[ -z "${blob}" ]]; then
    printf '  %s: %s: not in the source\n' "${lib}" "${file##*/}"
  elif [[ "$(git hash-object "${file}")" != "${blob}" ]]; then
    printf '  %s: %s: differs\n' "${lib}" "${file##*/}"
  fi
  return 0
}

for name in "${projects[@]}"; do
  dir="$(Dir "${name}")"
  if [[ -z "${dir}" ]]; then
    printf '== %s: no folder\n' "${name}"
    continue
  fi
  pushed="-"
  if [[ -d "${dir}/.verify" ]]; then
    if [[ "${fetch}" == "TRUE" ]]; then
      # A failed fetch is reported, not fatal: the old refs are still read.
      timeout 30 git -C "${dir}/.verify" fetch -q origin 2> /dev/null \
        || printf '  (fetch failed: %s)\n' "${name}"
    fi
    pushed="$(git -C "${dir}/.verify" show origin/main:DESCRIPTION \
      2> /dev/null | Version)"
  fi
  local_v="$(Version < "${dir}/DESCRIPTION")"
  public_v=""
  if [[ "${public}" == "TRUE" && -f "${dir}/.setup/repo/public-github.md" ]]; then
    repo="$(grep -o -m 1 '[A-Za-z0-9-]*/[A-Za-z0-9.-]*' \
      "${dir}/.setup/repo/public-github.md" || true)"
    public_v=" public ${repo}: $(gh api "repos/${repo}/contents/DESCRIPTION" \
      --jq .content 2> /dev/null | base64 -d 2> /dev/null | Version || true)"
  fi
  printf '== %s: local %s, pushed %s%s\n' \
    "${name}" "${local_v}" "${pushed}" "${public_v}"
  if [[ -f "${dir}/.setup/logs/index.md" ]]; then
    row="$(grep -m 1 '^| 20' "${dir}/.setup/logs/index.md" | cut -c 1-110 || true)"
    printf '  last row: %s\n' "${row}"
  fi
  n=0
  while IFS= read -r file; do
    lib="$(basename "$(dirname "${file}")")"
    CheckCopy "${lib}" "${file}"
    n=$((n + 1))
  done < <(find "${dir}/.setup/r-dependencies" -mindepth 2 -maxdepth 2 \
    -type f -name '*.R' 2> /dev/null | sort)
  while IFS= read -r file; do
    base="${file##*/}"
    lib="${base%%-*}"
    if [[ "${dir}" == *"/${lib}" || "${dir}" == *"/cran-${lib}" ]]; then
      continue
    fi
    CheckCopy "${lib}" "${file}"
    n=$((n + 1))
  done < <(find "${dir}/.setup/cpp" -maxdepth 1 -type f -name '*-*.cpp' \
    ! -name '000-*' 2> /dev/null | sort)
  printf '  copies checked: %s\n' "${n}"
done

#!/usr/bin/env bash

# Publish the lib-* projects ("build lib"), then rebuild the bibliographies
# in rProject's public repository: bib.bib and quarto.bib on main (the Make
# Project workflow) and on the latex branch (Compile LaTeX (rProject Daily)).
# rProject only; run on the host (it needs SSH and gh):
#
#   bash .setup/scripts/build-lib.sh [--bib-only | --only <project>] <image> [first]
#
#   <image>     Apptainer image (e.g., ~/work/sif/docs.sif)
#   [first]     resume the list from this project
#   --bib-only  the bibliographies only ("build lib only"): no lib release
#   --only      one lib project, then the bibliographies
#   BUILD=host  run make all on this host (default: srun on a compute node,
#               account open, partition basic, 1 core, 16 GB, 2 hours)
#   DRY_RUN=1   build and check, no push, no workflow dispatch
#
# Agents start it detached, so it survives an SSH disconnect or the end of
# the session:
#   setsid nohup bash .setup/scripts/build-lib.sh ... > /dev/null 2>&1 < /dev/null &
# The log is <work>/tmp/YYYY-MM-DD-build-lib.log; the status file next to it
# (.status) says "running <pid> <host> <start>", then "done <time>" or
# "STOPPED <time>: <reason>". The script refuses to start while another run
# is running.
#
# The projects and their order: BibLib() (R/rProject-bib-lib.R), the
# repositories that bib.bib is built from. Per project, the steps of make
# all and make auto: the private repository is downloaded, make project,
# make all (on a compute node), clone.sh brings in the public .git,
# Public() checks the export, Lock() writes the lock, then git add, commit
# "Automated build.", push, and the tag v<version> if it is new. It stops
# at the first failure; a project with nothing to commit is skipped.
# Then it waits for each pushed project's Make Project, counts the entries
# in the public lib-* repositories, dispatches rProject's two workflows (they
# clone the newest lib-* commits), waits for them, and checks that bib.bib on
# main and on latex hold every entry.

set -Eeuo pipefail

bib_only=FALSE
only=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --bib-only)
      bib_only=TRUE
      shift
      ;;
    --only)
      only="$2"
      shift 2
      ;;
    *) break ;;
  esac
done
if [[ $# -lt 1 ]]; then
  sed -n '8,16p' "$0" >&2
  exit 2
fi
image="$1"
first="${2:-}"
dry_run="${DRY_RUN:-0}"
build="${BUILD:-srun}"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work="$(dirname "${root}")"
dir="${work}/tmp/$(date +%Y-%m-%d)-build-lib"
log_file="${dir}.log"
status_file="${dir}.status"
gh="$(command -v gh || echo "${HOME}/.local/bin/gh")"

# one run at a time: a status file of any date that says "running", with
# its process alive (or on another host, where it cannot be checked)
for f in "${work}"/tmp/*-build-lib.status; do
  [[ -f "${f}" ]] || continue
  read -r state pid host _ < "${f}" || true
  [[ "${state:-}" == running ]] || continue
  if [[ "${host}" != "$(hostname)" ]] || kill -0 "${pid}" 2>/dev/null; then
    echo "build-lib.sh: another run is running (${f}: $(cat "${f}"))" >&2
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
  log "downloads kept in ${dir}"
  exit 1
}
finish() {
  local code=$?
  if [[ ${code} -eq 0 ]]; then
    echo "done $(date '+%F %T')" > "${status_file}"
  else
    echo "STOPPED $(date '+%F %T'): ${reason:-exit ${code}}" > "${status_file}"
  fi
}
trap finish EXIT
trap 'reason="hangup"; exit 129' HUP
trap 'reason="interrupted"; exit 130' INT
trap 'reason="terminated"; exit 143' TERM
echo "running $$ $(hostname) $(date '+%F %T')" > "${status_file}"

[[ -f "${image}" ]] || fail "no image ${image}"
[[ -x "${gh}" ]] || fail "gh not found"
if [[ "${build}" == srun ]]; then
  command -v srun > /dev/null || fail "no srun here: BUILD=host to build on this host"
fi

# the lib-* repositories, in BibLib()'s order
mapfile -t projects < <(
  sed -n '/libs <- c(/,/)/p' "${root}/R/rProject-bib-lib.R" |
    grep -o '"lib-[^"]*"' | tr -d '"'
)
[[ ${#projects[@]} -gt 0 ]] || fail "no lib-* in R/rProject-bib-lib.R"
all_projects=("${projects[@]}")
if [[ "${bib_only}" == TRUE ]]; then
  [[ -z "${first}" && -z "${only}" ]] || fail "--bib-only takes no project"
  projects=()
elif [[ -n "${only}" ]]; then
  printf '%s\n' "${projects[@]}" | grep -qx "${only}" || fail "${only} is not in BibLib()"
  projects=("${only}")
elif [[ -n "${first}" ]]; then
  start=-1
  for i in "${!projects[@]}"; do
    [[ "${projects[$i]}" == "${first}" ]] && start=$i
  done
  [[ ${start} -ge 0 ]] || fail "${first} is not in BibLib()"
  projects=("${projects[@]:${start}}")
fi
log "projects: ${projects[*]:-(none: bibliographies only)}"
log "downloads: ${dir}; make all: ${build}"

# GitHub over SSH: github.com, else the <owner> alias in ~/.ssh/config
# (Roar has no default key). url.insteadOf is set for this script only.
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
log "SSH: private via ${private_host}, public via ${public_host}"

# run_wait <repo> <workflow> <jq select> <minutes>: wait for the newest
# matching run to complete; prints "<conclusion> <id> <sha>"
run_wait() {
  local repo=$1 workflow=$2 select=$3 minutes=$4 i out
  for ((i = 0; i < minutes * 2; i++)); do
    out="$("${gh}" run list -R "${repo}" --workflow "${workflow}" --limit 20 \
      --json createdAt,headSha,status,conclusion,databaseId \
      --jq "[.[] | select(${select})] | sort_by(.createdAt) | last |
        select(. != null) | \"\(.status) \(.conclusion) \(.databaseId) \(.headSha[0:8])\"" \
      2>/dev/null || true)"
    if [[ "${out}" == completed* ]]; then
      echo "${out#completed }"
      return 0
    fi
    sleep 30
  done
  echo "timeout"
  return 1
}

# make all: on a compute node (srun waits for it), or here
make_all() {
  if [[ "${build}" == srun ]]; then
    srun --account=open --partition=basic --nodes=1 --ntasks=1 \
      --cpus-per-task=1 --mem=16G --time=02:00:00 --job-name=build-lib \
      apptainer exec "${image}" make all
  else
    apptainer exec "${image}" make all
  fi
}

summary=()
pushed=()
for p in "${projects[@]}"; do
  log "== ${p}"
  rm -rf "${dir:?}/${p}"
  git clone -q "git@${private_host}:jeksterslab-psu/${p}.git" "${dir}/${p}" ||
    fail "cannot download jeksterslab-psu/${p}"
  cd "${dir}/${p}"
  repo="$(tr -d '[:space:]' < .setup/repo/public-github.md)"
  if [[ ! -f Makefile || ! -f .setup/scripts/make-project.R ]]; then
    apptainer exec "${image}" Rscript -e "rProject::Template(\"${PWD}\")" ||
      fail "${p}: Template()"
  fi
  apptainer exec "${image}" make project || fail "${p}: make project"
  started=${SECONDS}
  make_all || fail "${p}: make all"
  log "${p}: make all done ($(( (SECONDS - started) / 60 )) min)"
  # make auto's steps
  bash .setup/scripts/clone.sh || fail "${p}: clone.sh"
  apptainer exec "${image}" Rscript -e "rProject::Public(\"${PWD}\")" ||
    fail "${p}: Public()"
  apptainer exec "${image}" Rscript -e "rProject::Lock(\"${PWD}\")" ||
    fail "${p}: Lock()"
  git add --all
  lost="$(git diff --cached --name-only --diff-filter=D -- .github/workflows)"
  if [[ -n "${lost}" ]]; then
    fail "${p}: the push would delete workflows: $(echo "${lost}" | tr '\n' ' ')"
  fi
  if git diff --cached --quiet; then
    log "${p}: nothing to commit"
    summary+=("| ${p} | (nothing to commit) | | skipped |")
    continue
  fi
  if [[ "${dry_run}" == "1" ]]; then
    log "${p}: DRY_RUN, would commit:"
    git diff --cached --stat | tail -3
    summary+=("| ${p} | (dry run) | | |")
    continue
  fi
  git commit -q -m "Automated build."
  sha="$(git rev-parse HEAD)"
  git push -q origin main || fail "${p}: push"
  version="$(sed -n 's/^Version: *//p' DESCRIPTION 2> /dev/null || true)"
  tag=""
  if [[ -n "${version}" ]] && ! git rev-parse -q --verify "refs/tags/v${version}" > /dev/null; then
    git tag -a "v${version}" -m "v${version}" || fail "${p}: tag v${version}"
    git push -q origin "v${version}" || fail "${p}: push tag v${version}"
    tag="v${version}"
  fi
  log "${p}: pushed ${sha:0:8} ${tag}"
  pushed+=("${p} ${repo} ${sha}")
done

# Make Project on each pushed commit
for entry in "${pushed[@]}"; do
  read -r p repo sha <<< "${entry}"
  result="$(run_wait "${repo}" "Make Project" ".headSha == \"${sha}\"" 120)" ||
    fail "${p}: Make Project ${result}"
  log "${p}: Make Project ${result}"
  [[ "${result}" == success* ]] || fail "${p}: Make Project ${result}"
  summary+=("| ${p} | ${sha:0:8} | ${result} | ok |")
done

# the entries in the public lib-* repositories now (their newest commits):
# one entry per .setup/latex/bib/lib-*.bib file
pub="${dir}/public"
rm -rf "${pub:?}"
mkdir -p "${pub}"
expected=0
heads=()
for p in "${all_projects[@]}"; do
  GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0 git clone -q --depth 1 \
    "https://github.com/ijapesigan/${p}.git" "${pub}/${p}" ||
    fail "cannot clone the public ${p}"
  n="$(find "${pub}/${p}/.setup/latex/bib" -maxdepth 1 -name 'lib-*.bib' -exec grep -h '^@' {} + | wc -l)"
  expected=$((expected + n))
  heads+=("${p}@$(git -C "${pub}/${p}" rev-parse --short=8 HEAD):${n}")
done
log "public lib-*: ${expected} entries (${heads[*]})"

# count_bib <repo> <ref> <path>: the entries in a file of a public repository
count_bib() {
  "${gh}" api "repos/$1/contents/$3?ref=$2" -H "Accept: application/vnd.github.raw" 2>/dev/null |
    grep -c '^@' || true
}

if [[ "${dry_run}" == "1" ]]; then
  log "DRY_RUN: rProject's workflows not dispatched"
else
  since="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  "${gh}" workflow run make.yml -R ijapesigan/rProject --ref main ||
    fail "rProject: cannot dispatch Make Project"
  "${gh}" workflow run latex-rproject-daily.yml -R ijapesigan/rProject --ref main ||
    fail "rProject: cannot dispatch Compile LaTeX (rProject Daily)"
  log "rProject: dispatched Make Project and Compile LaTeX (rProject Daily)"
  sleep 60
  main_run="$(run_wait ijapesigan/rProject "Make Project" \
    ".createdAt >= \"${since}\"" 240)" || fail "rProject Make Project ${main_run}"
  log "rProject Make Project: ${main_run}"
  [[ "${main_run}" == success* ]] || fail "rProject Make Project ${main_run}"
  latex_run="$(run_wait ijapesigan/rProject "Compile LaTeX (rProject Daily)" \
    ".createdAt >= \"${since}\"" 240)" || fail "rProject latex ${latex_run}"
  log "rProject Compile LaTeX (rProject Daily): ${latex_run}"
  [[ "${latex_run}" == success* ]] || fail "rProject latex ${latex_run}"
  main_bib="$(count_bib ijapesigan/rProject main .setup/latex/bib/bib.bib)"
  main_quarto="$(count_bib ijapesigan/rProject main .setup/quarto/bib/quarto.bib)"
  latex_bib="$(count_bib ijapesigan/rProject latex bib.bib)"
  log "entries: lib-* ${expected}; main bib.bib ${main_bib}, quarto.bib ${main_quarto}; latex bib.bib ${latex_bib}"
  for n in "${main_bib}" "${main_quarto}" "${latex_bib}"; do
    [[ "${n}" -eq "${expected}" ]] ||
      fail "a bibliography has ${n} entries, the public lib-* have ${expected}"
  done
fi

log "summary"
echo "| Project | Pushed | Make Project | Result |"
echo "|---|---|---|---|"
[[ ${#summary[@]} -gt 0 ]] && printf '%s\n' "${summary[@]}"
cd "${work}"
rm -rf "${dir:?}"
log "done; downloads removed; log: ${log_file}"

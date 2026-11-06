#!/usr/bin/env bash

# Publish the docker images in order ("build docs"), then build docs.sif and
# docs-plus.sif. rProject only; run on the host (it needs SSH and gh):
#
#   bash .setup/scripts/build-docs.sh [--only <project>] [--no-images] <image> [first]
#   bash .setup/scripts/build-docs.sh --images-only <image>
#
#   <image>    Apptainer image for rProject::Public() (e.g., ~/work/sif/docs.sif)
#   [first]    resume the list from this project
#   --only     run one project ("build docs only": --only docker-docs)
#   --no-images  do not build docs.sif and docs-plus.sif after docker-docs
#   --images-only  build docs.sif and docs-plus.sif only ("build sif"): no push
#   DRY_RUN=1  download, clone.sh and Public() only: no push, no images
#
# Agents start it detached, so it survives an SSH disconnect or the end of
# the session:
#   setsid nohup bash .setup/scripts/build-docs.sh ... > /dev/null 2>&1 < /dev/null &
# The log is <work>/tmp/YYYY-MM-DD-build-docs.log; the status file next to it
# (.status) says "running <pid> <host> <start>", then "done <time>" or
# "STOPPED <time>: <reason>". The script refuses to start while another run
# is running.
#
# The projects and their order: .setup/scripts/build-docs.txt.
# Per project, the steps of `make auto`: the private repository is
# downloaded, make project (and make readme) write the generated files
# (Template() first when the Makefile or make-project.R is missing), the
# written clone.sh brings in the public .git, Public() checks the export, then
# git add, commit "Automated build.", and push; a push that would delete a
# workflow stops the run. The script waits
# for Make Project on the pushed commit, then for "Docker Build and Push
# [multi]" (it runs on the commit that Make Project pushes), retries failed
# multi jobs once, and stops at the first failure.
# After docker-docs: docs-plus/run-def.sh builds both images on one core into
# a staging folder; an image replaces the current one only if that one is not
# in use (this node, or a Slurm job script of the user). Where sbatch exists,
# the images build as a Slurm job (account open, 1 core, 16 GB, 12 h), which
# this script waits for; BUILD=host builds them here instead.
#
# The script runs from a copy of itself in <work>/tmp, so an edit to this file
# cannot reach a running build (bash reads a running script from disk).

set -Eeuo pipefail

if [[ -z "${BUILD_DOCS_ROOT:-}" ]]; then
  BUILD_DOCS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  export BUILD_DOCS_ROOT
  build_docs_copy="$(dirname "${BUILD_DOCS_ROOT}")/tmp/build-docs-copy-$$.sh"
  mkdir -p "$(dirname "${build_docs_copy}")"
  cp "${BASH_SOURCE[0]}" "${build_docs_copy}"
  export BUILD_DOCS_COPY="${build_docs_copy}"
  exec bash "${build_docs_copy}" "$@"
fi

images=TRUE
images_only=FALSE
only=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      only="$2"
      shift 2
      ;;
    --no-images)
      images=FALSE
      shift
      ;;
    --images-only)
      images_only=TRUE
      shift
      ;;
    *) break ;;
  esac
done
if [[ $# -lt 1 ]]; then
  sed -n '6,15p' "$0" >&2
  exit 2
fi
image="$1"
first="${2:-}"
# always bind ~/work (a symlink or a folder) and, on Roar, /scratch/ibp5092
binds=(-B "${HOME}/work:$(readlink -f "${HOME}/work")")
if [[ -d /scratch/ibp5092 ]]; then
  binds+=(-B /scratch/ibp5092)
fi
dry_run="${DRY_RUN:-0}"

root="${BUILD_DOCS_ROOT}"
list="${root}/.setup/scripts/build-docs.txt"
work="$(dirname "${root}")"
# the Slurm job of the image step shares the run's folder and log
dir="${BUILD_DOCS_DIR:-${work}/tmp/$(date +%Y-%m-%d)-build-docs}"
log_file="${dir}.log"
gh="$(command -v gh || echo "${HOME}/.local/bin/gh")"
sif_dir="/storage/home/${USER}/work/sif"

status_file="${dir}.status"
if [[ -n "${BUILD_DOCS_CHILD:-}" ]]; then
  status_file="${dir}.images-status"
fi

# one run at a time: a status file of any date that says "running", with
# its process alive (or on another host, where it cannot be checked)
for f in "${work}"/tmp/*-build-docs.status; do
  [[ -z "${BUILD_DOCS_CHILD:-}" ]] || break
  [[ -f "${f}" ]] || continue
  read -r state pid host _ < "${f}" || true
  [[ "${state:-}" == running ]] || continue
  if [[ "${host}" != "$(hostname)" ]] || kill -0 "${pid}" 2>/dev/null; then
    echo "build-docs.sh: another run is running (${f}: $(cat "${f}"))" >&2
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
  if [[ -z "${BUILD_DOCS_CHILD:-}" && -n "${BUILD_DOCS_COPY:-}" ]]; then
    rm -f "${BUILD_DOCS_COPY}"
  fi
}
trap finish EXIT
trap 'reason="hangup"; exit 129' HUP
trap 'reason="interrupted"; exit 130' INT
trap 'reason="terminated"; exit 143' TERM
echo "running $$ $(hostname) $(date '+%F %T')" > "${status_file}"

[[ -f "${image}" ]] || fail "no image ${image}"
[[ -x "${gh}" ]] || fail "gh not found"

# projects to run
mapfile -t projects < <(grep -v -e '^#' -e '^[[:space:]]*$' "${list}")
if [[ "${images_only}" == TRUE ]]; then
  [[ -z "${only}" && -z "${first}" && "${images}" == TRUE ]] ||
    fail "--images-only takes no project, [first], or --no-images"
  projects=()
elif [[ -n "${only}" ]]; then
  printf '%s\n' "${projects[@]}" | grep -qx "${only}" || fail "${only} is not in ${list}"
  projects=("${only}")
elif [[ -n "${first}" ]]; then
  start=-1
  for i in "${!projects[@]}"; do
    [[ "${projects[$i]}" == "${first}" ]] && start=$i
  done
  [[ ${start} -ge 0 ]] || fail "${first} is not in ${list}"
  projects=("${projects[@]:${start}}")
fi
log "projects: ${projects[*]:-(none: images only)}"
log "downloads: ${dir}"

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

# the public rProject must have the version in DESCRIPTION: the docs image
# installs rProject from the public repository
version="$(sed -n 's/^Version: *//p' "${root}/DESCRIPTION")"
public_version="$("${gh}" api repos/ijapesigan/rProject/contents/DESCRIPTION \
  --jq .content | base64 -d | sed -n 's/^Version: *//p')"
[[ "${public_version}" == "${version}" ]] ||
  fail "public rProject is ${public_version}, DESCRIPTION is ${version}: PUB first"
log "public rProject ${public_version}"

# run_wait <repo> <workflow> <jq select>: wait (up to <minutes>) for the
# newest matching run to complete; prints "<conclusion> <id> <sha>"
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

# id_wait <repo> <run id> <minutes>: wait for a rerun; prints its conclusion
id_wait() {
  local repo=$1 id=$2 minutes=$3 i out
  for ((i = 0; i < minutes * 2; i++)); do
    out="$("${gh}" run view "${id}" -R "${repo}" --json status,conclusion \
      --jq '"\(.status) \(.conclusion)"' 2>/dev/null || true)"
    if [[ "${out}" == completed* ]]; then
      echo "${out#completed }"
      return 0
    fi
    sleep 30
  done
  echo "timeout"
  return 1
}

summary=()
for p in "${projects[@]}"; do
  log "== ${p}"
  rm -rf "${dir:?}/${p}"
  git clone -q "git@${private_host}:jeksterslab-psu/${p}.git" "${dir}/${p}" ||
    fail "cannot download jeksterslab-psu/${p}"
  cd "${dir}/${p}"
  repo="$(tr -d '[:space:]' < .setup/repo/public-github.md)"
  # the files make writes (workflows, Makefile, scripts: Template(); the
  # README) are not in the private repository: build them first, as make
  # auto assumes (rProject 0.0.58)
  # a copy without the Makefile or make-project.R (tier 2): write the
  # template files first, with the image's rProject
  if [[ ! -f Makefile || ! -f .setup/scripts/make-project.R ]]; then
    apptainer exec "${binds[@]}" "${image}" Rscript -e "rProject::Template(\"${PWD}\")" ||
      fail "${p}: Template()"
  fi
  apptainer exec "${binds[@]}" "${image}" make project || fail "${p}: make project"
  if [[ -f .setup/readme/README.Rmd ]]; then
    apptainer exec "${binds[@]}" "${image}" make readme || fail "${p}: make readme"
  fi
  log "${p}: make project done"
  # clone.sh is one of the written files: it brings in the public .git
  bash .setup/scripts/clone.sh || fail "${p}: clone.sh"
  log "${p}: public .git from ${repo}"
  apptainer exec "${binds[@]}" "${image}" Rscript -e "rProject::Public(\"${PWD}\")" ||
    fail "${p}: Public()"
  git add --all
  # never publish a project without its workflows
  lost="$(git diff --cached --name-only --diff-filter=D -- .github/workflows)"
  if [[ -n "${lost}" ]]; then
    fail "${p}: the push would delete workflows: $(echo "${lost}" | tr '\n' ' ')"
  fi
  if git diff --cached --quiet; then
    log "${p}: nothing to commit"
    summary+=("| ${p} | (nothing to commit) | | | skipped |")
    continue
  fi
  if [[ "${dry_run}" == "1" ]]; then
    log "${p}: DRY_RUN, would commit:"
    git diff --cached --stat
    summary+=("| ${p} | (dry run) | | | |")
    continue
  fi
  git commit -q -m "Automated build."
  sha="$(git rev-parse HEAD)"
  since="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  git push -q origin main || fail "${p}: push"
  log "${p}: pushed ${sha:0:8}"
  make_project="$(run_wait "${repo}" "Make Project" ".headSha == \"${sha}\"" 240)" ||
    fail "${p}: Make Project ${make_project}"
  log "${p}: Make Project ${make_project}"
  [[ "${make_project}" == success* ]] || fail "${p}: Make Project ${make_project}"
  multi="$(run_wait "${repo}" "Docker Build and Push [multi]" \
    ".createdAt >= \"${since}\"" 360)" || fail "${p}: multi ${multi}"
  if [[ "${multi}" != success* ]]; then
    id="$(echo "${multi}" | cut -d ' ' -f 2)"
    log "${p}: multi ${multi}; rerunning the failed jobs once"
    "${gh}" run rerun "${id}" -R "${repo}" --failed
    sleep 60
    result="$(id_wait "${repo}" "${id}" 360)" || fail "${p}: multi rerun ${result}"
    multi="${result} ${id} (rerun)"
    [[ "${result}" == success* ]] || fail "${p}: multi rerun ${result}"
  fi
  log "${p}: Docker Build and Push [multi] ${multi}"
  summary+=("| ${p} | ${sha:0:8} | ${make_project} | ${multi} | ok |")
done

# docs.sif and docs-plus.sif, after docker-docs (or alone, --images-only:
# the download only brings run-def.sh and docs-plus.def; nothing is pushed)
built=""
# the image step as a Slurm job: the job is this script, --images-only
if [[ "${images}" == TRUE && "${dry_run}" != "1" && "${BUILD:-}" != "host" ]] &&
  [[ -z "${SLURM_JOB_ID:-}" ]] && command -v sbatch > /dev/null 2>&1 &&
  { [[ "${images_only}" == TRUE ]] ||
    printf '%s\n' "${projects[@]}" | grep -qx docker-docs; }; then
  log "images: Slurm job (account open, 1 core, 16 GB, 12 h); waiting"
  BUILD_DOCS_CHILD=1 BUILD_DOCS_DIR="${dir}" sbatch --wait --account=open --cpus-per-task=1 \
    --mem=16G --time=12:00:00 --job-name=build-docs-images \
    --output="${dir}.images-%j.out" --export=ALL \
    --wrap="bash ${BUILD_DOCS_COPY} --images-only ${image}" ||
    fail "images: the Slurm job failed (see ${dir}.images-*.out)"
  images=FALSE
  images_only_done=TRUE
fi
if [[ "${images_only}" == TRUE && "${dry_run}" != "1" ]]; then
  rm -rf "${dir:?}/docker-docs"
  git clone -q "git@${private_host}:jeksterslab-psu/docker-docs.git" "${dir}/docker-docs" ||
    fail "cannot download jeksterslab-psu/docker-docs"
  log "images only: docker-docs $(git -C "${dir}/docker-docs" rev-parse --short=8 HEAD)"
fi
if [[ "${images}" == TRUE && "${dry_run}" != "1" ]] &&
  { [[ "${images_only}" == TRUE ]] ||
    printf '%s\n' "${projects[@]}" | grep -qx docker-docs; }; then
  notes="${dir}/docker-docs/.setup/notes"
  [[ -d "${sif_dir}" ]] || fail "images: no ${sif_dir} on this machine"
  grep -q 'SIF_DIR:-' "${notes}/run-def.sh" ||
    fail "images: docker-docs run-def.sh does not take SIF_DIR"
  stage="${sif_dir}/.staging-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "${stage}"
  log "images: building on one core into ${stage}"
  # In a Slurm job the allocation limits the cores, and core 0 may not be in it
  pin=(taskset -c 0)
  [[ -n "${SLURM_JOB_ID:-}" ]] && pin=()
  # apptainer build applies APPTAINER_BIND in %post, where the mount fails
  (cd "${notes}" && SIF_DIR="${stage}" env -u APPTAINER_BIND nice -n 19 "${pin[@]}" bash run-def.sh) ||
    fail "images: run-def.sh (staging kept: ${stage})"
  # --vanilla from /: a project's .Rprofile (e.g., rProject's .library)
  # must not hide the rProject in the image
  for f in docs.sif docs-plus.sif; do
    in_image="$(cd / && apptainer exec "${binds[@]}" "${stage}/${f}" Rscript --vanilla -e \
      'cat(as.character(packageVersion("rProject")))')"
    log "images: ${f} has rProject ${in_image}"
    [[ "${in_image}" == "${version}" ]] ||
      fail "images: ${f} has rProject ${in_image}, not ${version} (staging kept: ${stage})"
  done
  apptainer exec "${binds[@]}" "${stage}/docs-plus.sif" bash -c \
    'command -v mplus && test ! -e /usr/src/local/src && echo "installer removed"' ||
    fail "images: docs-plus.sif check (staging kept: ${stage})"
  for f in docs.sif docs-plus.sif; do
    why=""
    fuser "${sif_dir}/${f}" 2>/dev/null | grep -q '[0-9]' && why="open on $(hostname)"
    while read -r job; do
      [[ -z "${job}" ]] && continue
      script="$(scontrol show job "${job}" 2>/dev/null | sed -n 's/^ *Command=//p')"
      if [[ -f "${script}" ]] && grep -q "${f}" "${script}"; then
        why="Slurm job ${job}"
      fi
    done < <(squeue -u "${USER}" -h -o '%i' 2>/dev/null || true)
    if [[ -n "${why}" ]]; then
      log "images: ${f} is in use (${why}); the new one stays in ${stage}"
      built+=" ${f}:staged"
    else
      mv -f "${stage}/${f}" "${sif_dir}/${f}"
      log "images: ${f} replaced"
      built+=" ${f}:replaced"
    fi
  done
  rmdir "${stage}" 2>/dev/null || true
fi

if [[ -n "${BUILD_DOCS_CHILD:-}" ]]; then
  [[ -z "${built}" ]] || log "Images:${built}"
  exit 0
fi
log "summary"
echo "| Project | Pushed | Make Project | Docker Build and Push [multi] | Result |"
echo "|---|---|---|---|---|"
[[ ${#summary[@]} -gt 0 ]] && printf '%s\n' "${summary[@]}"
[[ -n "${built}" ]] && echo "Images:${built}"
[[ -z "${images_only_done:-}" ]] || echo "Images: see the Slurm job's lines above"
cd "${work}"
rm -rf "${dir:?}"
log "done; downloads removed; log: ${log_file}"

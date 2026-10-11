#!/usr/bin/env bash

# Verify the latest Overleaf push against the change-set log.
#
# Run on the host (not in the container) from the project folder:
#   bash .setup/scripts/verify.sh
#   RECORD=TRUE bash .setup/scripts/verify.sh   # also fill in the log and index
#   LOG=2026-10-11-topic.md bash .setup/scripts/verify.sh
#
# Git runs on the host because the SSH keys are not available in the container.
# R runs in the container, as always.

set -Eeuo pipefail

path="$(pwd)"
project="$(sed -n 's/^project <- "\(.*\)"$/\1/p' .setup/scripts/project.R | head -n 1)"
if [[ -z "${project}" ]]; then
  echo "Cannot find project in .setup/scripts/project.R" >&2
  exit 1
fi

# local only: gitignored, never uploaded to Overleaf
private="${VERIFY_DIR:-${path}/.verify}"
if [[ -d "${private}/.git" ]]; then
  git -C "${private}" fetch -q origin
  git -C "${private}" reset -q --hard origin/HEAD
else
  mkdir -p "$(dirname "${private}")"
  git clone -q "git@github.com:jeksterslab-psu/${project}.git" "${private}"
fi

sif="${SIF:-${HOME}/work/sif/docs.sif}"
log="${LOG:-}"
if [[ -n "${log}" ]]; then
  log_arg="\"${log}\""
else
  log_arg="NULL"
fi

apptainer exec \
  --bind "${path}" \
  --bind "${private}" \
  --pwd "${path}" \
  "${sif}" \
  Rscript -e "rProject::Verify(path = \"${path}\", private = \"${private}\", log = ${log_arg}, record = ${RECORD:-FALSE})"

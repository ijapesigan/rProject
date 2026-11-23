#! /bin/bash
#SBATCH --job-name=make
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=06:00:00
#SBATCH --output=make.out
#SBATCH --error=make.err

###############################################################################
# Written once by rProject::Template() (inst/template/once/sim-make.sh);
# Conform() flags a copy that differs.
#
# Usage (on the submit node, from .sim/):
#   sbatch --account=open make.sh          # build the project above .sim/
#   CLEAN=1 sbatch make.sh                 # remove generated files first
#   PROJECT=/path/to/clone sbatch make.sh  # build another copy
#
# Description:
#   make project, then make release (make all, the secret scan, make auto),
#   which stops at the first failure. make all is serial, so one CPU and one
#   BLAS thread keep the CPU busy; more CPUs would sit idle. After a run,
#   check with seff <jobid>, and set --mem to the peak plus 10%.
#
# Settings (environment variables):
#   PROJECT      the project folder (default: the folder above .sim/)
#   SIF          the image (default: ~/work/sif/docs.sif)
#   CLEAN=1      remove the generated vignette files and ${CLEAN_FILES}
#   CLEAN_FILES  more files to remove, relative to PROJECT
###############################################################################

set -Eeuo pipefail

PROJECT=${PROJECT:-${SLURM_SUBMIT_DIR:-${PWD}}/..}
PROJECT=$(readlink -f "${PROJECT}")
SIF=${SIF:-${HOME}/work/sif/docs.sif}
# ~/work is a symlink on some machines: bind its target, so that git in the
# container finds the SSH keys (make auto clones and pushes)
WORK=$(readlink -f "${HOME}/work")
BINDS=(-B "${HOME}/work:${WORK}")
if [ -d /scratch/ibp5092 ]; then
  BINDS+=(-B /scratch/ibp5092)
fi

# one thread per library, one make job
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
export OPENBLAS_CORETYPE=${OPENBLAS_CORETYPE:-Haswell}
export MAKEFLAGS=-j1

if [ ! -f "${PROJECT}/Makefile" ]; then
  echo "No Makefile in ${PROJECT}" >&2
  exit 1
fi

cd "${PROJECT}"
echo "Processing: ${PROJECT}"

if [ "${CLEAN:-}" = "1" ]; then
  echo "Removing generated files..."
  # CLEAN_FILES is a list: split on spaces on purpose
  # shellcheck disable=SC2086
  rm -f vignettes/session.Rmd vignettes/vignettes.bib ${CLEAN_FILES:-}
fi

apptainer exec "${BINDS[@]}" "${SIF}" make project
apptainer exec "${BINDS[@]}" "${SIF}" make release

echo "done"

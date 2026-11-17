#! /bin/bash
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --time=0
#SBATCH --output=make.out
#SBATCH --error=make.err

###############################################################################
# Usage:
#   CLEAN=1 sbatch make.sh   # runs clean step before build
#   sbatch make.sh           # skips clean step
#
# Description:
#   - Builds project using `make all`
#   - Pushes results using `make auto`
#   - Optionally removes generated vignette files when CLEAN=1
###############################################################################

set -Eeuo pipefail

# Define project variables
PROJECT=/home/ibp5092/Downloads/rProject
SIF=/home/ibp5092/work/sif/docs.sif

# Run clean only when CLEAN=1
if [ "${CLEAN:-}" = "1" ]; then
  echo "Running clean step..."

  rm -rf ${PROJECT}/vignettes/tags.Rmd
  rm -rf ${PROJECT}/vignettes/session.Rmd
  rm -rf ${PROJECT}/vignettes/vignettes.bib
else
  echo "Skipping clean step..."
fi

# make

cd ${PROJECT} || exit
apptainer exec ${SIF} make all

# push

cd ${PROJECT} || exit
rm -rf .git
apptainer exec ${SIF} make auto

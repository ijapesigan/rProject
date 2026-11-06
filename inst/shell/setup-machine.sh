#!/bin/bash
# Set up a machine, on the host: the tools, the dotfiles, and `make local`.
#
#   bash inst/shell/setup-machine.sh [--force] [--check] [--image <sif>]
#
#   --force   make localforce instead of make local
#   --check   also make all in this copy (heavy: not on a submit node)
#   --image   the image (default: ~/work/sif/docs.sif); without it, the
#             `make` steps are skipped and the script says so
#
# ~/work/scripts/rproject.sh can be: git clone rProject, then this script.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "${dir}/../.." && pwd)"
force=false
check=false
image="${HOME}/work/sif/docs.sif"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force=true
      shift
      ;;
    --check)
      check=true
      shift
      ;;
    --image)
      image="$2"
      shift 2
      ;;
    *)
      sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 1
      ;;
  esac
done

status=0
bash "${dir}/install.sh" machine cli || status=1
if [[ -d "${HOME}/work" ]]; then
  bash "${dir}/install.sh" --move || status=1
fi
bash "${dir}/install-dotfiles.sh" || status=1

# the standards agents read (rProject as pushed), where a clone has .verify
if [[ -d "${root}/.verify" ]] && ! grep -qs '^export RPROJECT=' "${HOME}/.bash-local"; then
  printf 'export RPROJECT="%s"\n' "${root}" >> "${HOME}/.bash-local"
fi

if [[ ! -f "${image}" ]]; then
  printf 'No image at %s: skipped make local. Build or copy it, then run this again.\n' "${image}" >&2
  exit "${status}"
fi
binds=()
if [[ -e "${HOME}/work" ]]; then
  binds+=(-B "${HOME}/work:$(readlink -f "${HOME}/work")")
fi
if [[ -d /scratch/ibp5092 ]]; then
  binds+=(-B /scratch/ibp5092)
fi
target="local"
if [[ "${force}" == true ]]; then
  target="localforce"
fi
(cd "${root}" && apptainer exec "${binds[@]}" "${image}" make "${target}") || status=1
if [[ "${check}" == true ]]; then
  (cd "${root}" && apptainer exec "${binds[@]}" "${image}" make all) || status=1
fi
exit "${status}"

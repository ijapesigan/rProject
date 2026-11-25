#!/usr/bin/env bash

# Compare the RStudio pins of the docker projects with rocker-versioned2.
# rocker's dockerfiles/rstudio_<R version>.Dockerfile sets RSTUDIO_VERSION
# and S6_VERSION; a project in build-docs.txt whose Dockerfile pins them
# (ENV, for /rocker_scripts/install_rstudio.sh) should use the same values.
# Host only (gh or curl; no R, no Apptainer):
#
#   bash .setup/scripts/rocker-pins.sh [--update] [--remote] [--dir <folder>] [R version]
#
#   [R version]  default: the tag of the rocker/r-ver base in the list's
#                Dockerfiles; "latest" (or none) is rocker's newest release
#   --dir        the folder that holds the projects (default: the folder
#                next to rProject); a project not there is skipped
#   --remote     read each Dockerfile from the private repository
#                (jeksterslab-psu/<project>, gh) instead of a local folder
#   --update     rewrite the pins that differ in the local Dockerfiles
#                (not with --remote); the change still goes through Overleaf
#
# Prints one row per pin (project, variable, ours, rocker's). Exit 0 when
# every pin equals rocker's, 1 when one differs (after --update: 0 once
# rewritten), 2 on a usage or download error.

set -Eeuo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
list="${root}/.setup/scripts/build-docs.txt"
dir="$(dirname "${root}")"
update=FALSE
remote=FALSE
r_version=""
vars=(RSTUDIO_VERSION S6_VERSION)
rocker="rocker-org/rocker-versioned2"

usage() {
  sed -n '9,18p' "${BASH_SOURCE[0]}" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --update)
      update=TRUE
      shift
      ;;
    --remote)
      remote=TRUE
      shift
      ;;
    --dir)
      [[ $# -ge 2 ]] || usage
      dir="$2"
      shift 2
      ;;
    -h | --help) usage ;;
    -*) usage ;;
    *)
      r_version="$1"
      shift
      ;;
  esac
done
if [[ "${update}" == TRUE && "${remote}" == TRUE ]]; then
  echo "rocker-pins.sh: --update rewrites local files; not with --remote" >&2
  exit 2
fi

gh="$(command -v gh || echo "${HOME}/.local/bin/gh")"
have_gh=FALSE
if [[ -x "${gh}" ]]; then
  have_gh=TRUE
fi

# fetch <owner/repo> <path>: the file's text (gh, else raw.githubusercontent.com)
fetch() {
  local repo=$1 path=$2
  if [[ "${have_gh}" == TRUE ]]; then
    "${gh}" api "repos/${repo}/contents/${path}" -H "Accept: application/vnd.github.raw"
  else
    curl -fsSL "https://raw.githubusercontent.com/${repo}/HEAD/${path}"
  fi
}

# pin <variable>: the value of ENV <variable>="..." in the text on stdin
pin() {
  sed -n "s/^ENV[[:space:]]\{1,\}$1=\"\{0,1\}\([^\" ]*\)\"\{0,1\}.*$/\1/p" | head -n 1
}

# dockerfile <project>: the project's Dockerfile, or nothing when absent
dockerfile() {
  local p=$1
  if [[ "${remote}" == TRUE ]]; then
    fetch "jeksterslab-psu/${p}" Dockerfile 2> /dev/null || true
  elif [[ -f "${dir}/${p}/Dockerfile" ]]; then
    cat "${dir}/${p}/Dockerfile"
  fi
}

mapfile -t projects < <(grep -v -e '^#' -e '^[[:space:]]*$' "${list}")
declare -A text=()
for p in "${projects[@]}"; do
  text["${p}"]="$(dockerfile "${p}")"
done

# the R version: the rocker/r-ver tag of the list's base image
if [[ -z "${r_version}" ]]; then
  for p in "${projects[@]}"; do
    from="$(sed -n 's/^FROM[[:space:]]\{1,\}rocker\/r-ver:\([^[:space:]]*\).*$/\1/p' <<< "${text[${p}]}" | head -n 1)"
    if [[ -n "${from}" ]]; then
      r_version="${from}"
      break
    fi
  done
fi
if [[ -z "${r_version}" || "${r_version}" == latest ]]; then
  if [[ "${have_gh}" != TRUE ]]; then
    echo "rocker-pins.sh: gh not found; give the R version (e.g. 4.6.2)" >&2
    exit 2
  fi
  r_version="$("${gh}" api "repos/${rocker}/contents/dockerfiles" --jq '.[].name' |
    sed -n 's/^rstudio_\([0-9][0-9.]*\)\.Dockerfile$/\1/p' | sort -V | tail -n 1)"
fi
[[ "${r_version}" =~ ^[0-9]+(\.[0-9]+)+$ ]] || {
  echo "rocker-pins.sh: not an R version: ${r_version:-(none)}" >&2
  exit 2
}

upstream="$(fetch "${rocker}" "dockerfiles/rstudio_${r_version}.Dockerfile")" || {
  echo "rocker-pins.sh: cannot download ${rocker} dockerfiles/rstudio_${r_version}.Dockerfile" >&2
  exit 2
}
declare -A theirs=()
for v in "${vars[@]}"; do
  theirs["${v}"]="$(pin "${v}" <<< "${upstream}")"
  [[ -n "${theirs[${v}]}" ]] || {
    echo "rocker-pins.sh: no ${v} in rstudio_${r_version}.Dockerfile" >&2
    exit 2
  }
done

echo "rocker pins: ${rocker} rstudio_${r_version}.Dockerfile ($(if [[ "${remote}" == TRUE ]]; then echo "private repositories"; else echo "${dir}"; fi))"
printf '%-24s %-16s %-18s %-18s %s\n' project variable ours "rocker's" result
differ=0
checked=0
for p in "${projects[@]}"; do
  if [[ -z "${text[${p}]}" ]]; then
    printf '%-24s %-16s %-18s %-18s %s\n' "${p}" - - - "(no Dockerfile here)"
    continue
  fi
  for v in "${vars[@]}"; do
    ours="$(pin "${v}" <<< "${text[${p}]}")"
    [[ -n "${ours}" ]] || continue
    checked=$((checked + 1))
    result=equal
    if [[ "${ours}" != "${theirs[${v}]}" ]]; then
      result=DIFFERS
      if [[ "${update}" == TRUE ]]; then
        sed -i "s/^ENV\([[:space:]]\{1,\}\)${v}=.*$/ENV\1${v}=\"${theirs[${v}]}\"/" "${dir}/${p}/Dockerfile"
        result="updated"
      else
        differ=$((differ + 1))
      fi
    fi
    printf '%-24s %-16s %-18s %-18s %s\n' "${p}" "${v}" "${ours}" "${theirs[${v}]}" "${result}"
  done
done

if [[ ${differ} -gt 0 ]]; then
  echo "rocker pins: ${differ} of ${checked} differ (--update rewrites them)"
  exit 1
fi
echo "rocker pins: ${checked} checked, all equal to rocker's"

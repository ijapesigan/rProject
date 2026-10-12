#!/bin/bash

# GitHub CLI: the official prebuilt release, checked against its SHA-256
# checksums, installed to ~/.local/bin/gh. No Go needed.

set -euo pipefail

# shellcheck source=install-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_gh() {
  local arch tmp gh_version tarball base
  case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64) arch="arm64" ;;
  esac
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '${tmp}'" RETURN
  gh_version="$(
    fetch "https://api.github.com/repos/cli/cli/releases/latest" - |
      sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' |
      head -n 1
  )"
  [[ -n "${gh_version}" ]] || return 1
  tarball="gh_${gh_version}_linux_${arch}.tar.gz"
  base="https://github.com/cli/cli/releases/download/v${gh_version}"
  fetch "${base}/${tarball}" "${tmp}/${tarball}"
  fetch "${GH_CHECKSUMS_URL:-${base}/gh_${gh_version}_checksums.txt}" "${tmp}/checksums.txt"
  if ! (cd "${tmp}" && grep " ${tarball}\$" checksums.txt | sha256sum -c --status -); then
    printf 'ERROR: gh: checksum mismatch for %s; nothing installed\n' "${tarball}" >&2
    return 1
  fi
  tar -xzf "${tmp}/${tarball}" -C "${tmp}"
  install -m 755 "${tmp}/gh_${gh_version}_linux_${arch}/bin/gh" "${BIN}/gh"
}

safe_install gh install_gh

cat <<'EOF'

Log in once per account (read-only: Actions, Contents, Metadata: read):
  gh auth login    # repeat for ijapesigan, jeksterslab, jeksterslab-psu
  gh auth switch   # choose the active account
Never paste a token into a chat.
EOF

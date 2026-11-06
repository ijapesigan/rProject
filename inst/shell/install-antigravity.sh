#!/bin/bash
# Google Antigravity CLI (agy): the official installer, into ~/.local/bin. The
# installer appends a PATH block to the shell startup files, although the
# dotfiles already set PATH, so they are put back as they were. It updates
# itself in the background, which can replace the link; `install.sh --list`
# shows this and `install.sh --move` links it again.
set -euo pipefail
# shellcheck source=install-common.sh disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/install-common.sh"
check_arch

install_agy() {
  fetch "https://antigravity.google/cli/install.sh" - | bash -s -- --dir "${BIN}"
}

rc_files=(.bashrc .bash_profile .profile)
rc_backup="$(mktemp -d)"
restore_rc() {
  local file
  for file in "${rc_files[@]}"; do
    if [[ -e "${rc_backup}/${file}" ]]; then
      cp -p "${rc_backup}/${file}" "${HOME}/${file}"
    else
      rm -f "${HOME}/${file}"
    fi
  done
  rm -rf "${rc_backup}"
}
trap restore_rc EXIT
for rc_file in "${rc_files[@]}"; do
  if [[ -e "${HOME}/${rc_file}" ]]; then
    cp -p "${HOME}/${rc_file}" "${rc_backup}/${rc_file}"
  fi
done

safe_install agy install_agy

#!/bin/bash
# The shell, tmux, Vim, and xterm files, from rProject's inst/dotfiles, into
# home. No R, no Apptainer. A file it replaces is kept in
# ~/.dotfiles-backup/<time>/. Only the files listed below are written: no token
# file, .gitconfig, or SSH file.
#
#   bash install-dotfiles.sh           # install
#   bash install-dotfiles.sh --check   # show the differences; change nothing
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="${dir}/../dotfiles"
check=false
if [[ "${1:-}" == "--check" ]]; then
  check=true
fi
if [[ ! -d "${src}" ]]; then
  printf 'ERROR: %s not found\n' "${src}" >&2
  exit 1
fi

# source (in inst/dotfiles) and target (in home)
files=(
  "bash/bashrc .bashrc"
  "bash/bash_profile .bash_profile"
  "bash/inputrc .inputrc"
  "bash/bash-aliases .bash-aliases"
  "bash/bash-fastfetch .bash-fastfetch"
  "bash/bash-git-completion .bash-git-completion"
  "bash/bash-git-prompt .bash-git-prompt"
  "bash/bash-misc .bash-misc"
  "bash/bash-path .bash-path"
  "bash/bash-prompt .bash-prompt"
  "bash/bash-settings .bash-settings"
  "bash/bash-variables .bash-variables"
  "tmux/tmux.conf .tmux.conf"
  "vim/vimrc .vimrc"
  "xterm/xterm .Xresources"
)

backup="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
changed=0
for pair in "${files[@]}"; do
  from="${src}/${pair%% *}"
  to="${HOME}/${pair##* }"
  if cmp -s "${from}" "${to}"; then
    continue
  fi
  changed=$((changed + 1))
  if [[ "${check}" == true ]]; then
    printf '==> %s\n' "${to}"
    if [[ -e "${to}" ]]; then
      diff -u "${to}" "${from}" || true
    else
      printf 'new file\n'
    fi
    continue
  fi
  if [[ -e "${to}" ]]; then
    mkdir -p "${backup}"
    cp -p "${to}" "${backup}/"
  fi
  cp "${from}" "${to}"
  printf '==> %s\n' "${to}"
done

if [[ "${check}" == true ]]; then
  printf '%s file(s) differ; nothing changed.\n' "${changed}"
  exit 0
fi
if command -v git >/dev/null 2>&1; then
  bash "${src}/vim/vim-plugins" || printf 'WARNING: the Vim packages were not installed.\n' >&2
fi
if [[ -n "${DISPLAY:-}" ]] && command -v xrdb >/dev/null 2>&1; then
  xrdb "${HOME}/.Xresources" || true
fi
printf '%s file(s) installed%s. Open a new shell to use them.\n' "${changed}" \
  "$([[ -d "${backup}" ]] && printf '; the old ones are in %s' "${backup}")"

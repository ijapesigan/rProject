#!/bin/bash

# Install or update the machine tools (Linux; no sudo). Where ~/work exists, the
# large ones live in ~/work/tools and are linked from ~/.local.
#
#   bash install.sh machine      # apptainer claude codex copilot antigravity herdr gh
#   bash install.sh cli          # fzf zoxide bat fd eza delta
#   bash install.sh claude gh    # some tools
#   bash install.sh --list       # installed tools, versions, and where they live
#   bash install.sh --move       # move what is already installed to ~/work/tools
#
# Each tool keeps its previous version if the new one fails. One failure does
# not stop the others; the exit code is nonzero if any failed.

set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
machine=(apptainer claude codex copilot antigravity herdr gh)
cli=(fzf zoxide bat fd eza delta)
# the command each tool installs, where it differs from the tool's name
command_name() {
  if [[ "$1" == "antigravity" ]]; then
    echo "agy"
  else
    echo "$1"
  fi
}

for cmd in bash tar; do
  command -v "${cmd}" >/dev/null 2>&1 || {
    echo "ERROR: ${cmd} is required" >&2
    exit 1
  }
done
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "ERROR: curl or wget is required" >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 1
fi

if [[ "$1" == "--list" ]]; then
  for tool in "${machine[@]}" "${cli[@]}"; do
    path="${HOME}/.local/bin/$(command_name "${tool}")"
    if [[ -x "${path}" ]]; then
      printf '%-12s %-40s %s\n' "${tool}" "$("${path}" --version 2>/dev/null | head -n 1 | cut -c1-40)" "$(readlink -f "${path}")"
    else
      printf '%-12s %s\n' "${tool}" "not installed"
    fi
  done
  exit 0
fi

if [[ "$1" == "--move" ]]; then
  # shellcheck source=install-common.sh disable=SC1091
  source "${dir}/install-common.sh"
  [[ -d "${HOME}/work" ]] || die "no ~/work here: nothing to move to"
  for item in .codex/packages .local/share/claude ".local/$(uname -m)" .local/julia; do
    if [[ -e "${HOME}/${item}" ]]; then
      link_tool "${item}"
      say "${item}: $(readlink -f "${HOME}/${item}")"
    fi
  done
  for tool in "${machine[@]}" "${cli[@]}" lazygit fastfetch mpdemo; do
    item=".local/bin/$(command_name "${tool}")"
    # apptainer's is a small wrapper that finds its files next to itself
    if [[ "${tool}" != "apptainer" && -f "${HOME}/${item}" ]]; then
      link_tool "${item}"
      say "${item}: $(readlink -f "${HOME}/${item}")"
    fi
  done
  exit 0
fi

tools=()
for arg in "$@"; do
  if [[ "${arg}" == "machine" ]]; then
    tools+=("${machine[@]}")
  elif [[ "${arg}" == "cli" ]]; then
    tools+=("${cli[@]}")
  elif [[ -f "${dir}/install-${arg}.sh" ]]; then
    tools+=("${arg}")
  else
    echo "ERROR: unknown tool: ${arg}" >&2
    exit 1
  fi
done

ok=()
failed=()
for tool in "${tools[@]}"; do
  echo
  echo "==> Installing ${tool}"
  if bash "${dir}/install-${tool}.sh"; then
    ok+=("${tool}")
  else
    failed+=("${tool}")
  fi
done

echo
echo "Installed: ${ok[*]:-(none)}"
if [[ ${#failed[@]} -gt 0 ]]; then
  echo "Failed:    ${failed[*]}" >&2
  exit 1
fi

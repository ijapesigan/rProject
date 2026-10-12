#!/bin/bash

# Install or update the machine tools into ~/.local (Linux; no sudo).
#
#   bash install.sh machine      # apptainer claude codex copilot gemini herdr gh
#   bash install.sh claude gh    # some tools
#   bash install.sh --list       # installed tools and versions
#
# Each tool keeps its previous version if the new one fails. One failure does
# not stop the others; the exit code is nonzero if any failed.

set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
machine=(apptainer claude codex copilot gemini herdr gh)

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
  sed -n '3,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 1
fi

if [[ "$1" == "--list" ]]; then
  for tool in "${machine[@]}"; do
    path="${HOME}/.local/bin/${tool}"
    if [[ -x "${path}" ]]; then
      printf '%-10s %s\n' "${tool}" "$("${path}" --version 2>/dev/null | head -n 1)"
    else
      printf '%-10s %s\n' "${tool}" "not installed"
    fi
  done
  exit 0
fi

tools=()
for arg in "$@"; do
  if [[ "${arg}" == "machine" ]]; then
    tools+=("${machine[@]}")
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

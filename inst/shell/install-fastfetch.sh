#!/usr/bin/env bash

set -euo pipefail

repo="fastfetch-cli/fastfetch"

case "$(uname -m)" in
  x86_64)
    arch="amd64"
    ;;
  aarch64 | arm64)
    arch="aarch64"
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

mkdir -p "${HOME}/.local/bin"

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT

asset="fastfetch-linux-${arch}.tar.gz"
url="https://github.com/${repo}/releases/latest/download/${asset}"

cd "${tmpdir}"

if command -v curl >/dev/null 2>&1; then
  curl -L -o "${asset}" "${url}"
elif command -v wget >/dev/null 2>&1; then
  wget -O "${asset}" "${url}"
else
  echo "Need curl or wget to download fastfetch." >&2
  exit 1
fi

tar -xzf "${asset}"

fastfetch_bin="$(
  find "${tmpdir}" -type f -name fastfetch -perm -u+x | head -n 1
)"

if [[ -z "${fastfetch_bin}" ]]; then
  echo "Could not find fastfetch binary in extracted archive." >&2
  exit 1
fi

install -m 755 "${fastfetch_bin}" "${HOME}/.local/bin/fastfetch"

ls -l "${HOME}/.local/bin/fastfetch"
"${HOME}/.local/bin/fastfetch" --version

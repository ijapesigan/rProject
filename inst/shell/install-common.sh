#!/bin/bash

# Shared helpers for inst/shell/install-*.sh (sourced, not run).
# Linux only; no sudo. Tools go into ~/.local; where ~/work exists (a symlink
# or a folder), the large ones live in ~/work/tools and are linked from home.

BIN="${HOME}/.local/bin"
TOOLS="${HOME}/work/tools"
mkdir -p "${BIN}"
export PATH="${BIN}:${PATH}"

say() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

# x86_64 or aarch64 only
check_arch() {
  case "$(uname -m)" in
    x86_64 | aarch64) ;;
    *) die "unsupported architecture: $(uname -m)" ;;
  esac
}

# fetch URL OUTPUT ("-" for standard output), with curl or wget
fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$2" "$1"
  else
    die "neither curl nor wget is installed"
  fi
}

# version NAME: first line of `NAME --version`, or empty
version() {
  "$1" --version 2>/dev/null | head -n 1
}

# link_tool PATH (relative to home): PATH becomes a link to the same path in
# ~/work/tools, so an installer writes through it. A no-op without ~/work (also
# inside a container that does not bind it) and for a path that is a link.
# The copy it replaces in ~/work/tools is moved aside, then removed if it can
# be: a running container can hold its files open.
link_tool() {
  local src="${HOME}/$1"
  local dst="${TOOLS}/$1"
  local stale="${dst}.old.$$"
  [[ -d "${HOME}/work" ]] || return 0
  [[ -L "${src}" ]] && return 0
  mkdir -p "$(dirname "${dst}")" "$(dirname "${src}")"
  if [[ -e "${src}" ]]; then
    if [[ -e "${dst}" || -L "${dst}" ]]; then
      mv "${dst}" "${stale}"
    fi
    mv "${src}" "${dst}"
    rm -rf "${stale}" 2>/dev/null || say "kept ${stale} (files in use); remove it later"
  else
    mkdir -p "${dst}"
  fi
  ln -s "${dst}" "${src}"
}

# install_release NAME REPO PATTERN [BINARY]: the static build of a GitHub
# release (PATTERN is matched against its asset names, with {arch} replaced by
# x86_64 or aarch64 and {go} by amd64 or arm64); installs BINARY (default NAME)
# from the archive to ~/.local/bin.
install_release() {
  local name="$1"
  local repo="$2"
  local pattern="$3"
  local binary="${4:-$1}"
  local arch go urls url tmp found
  arch="$(uname -m)"
  go="amd64"
  [[ "${arch}" == "aarch64" ]] && go="arm64"
  pattern="${pattern//\{arch\}/${arch}}"
  pattern="${pattern//\{go\}/${go}}"
  urls="$(
    fetch "https://api.github.com/repos/${repo}/releases/latest" - |
      sed -n 's/.*"browser_download_url": *"\([^"]*\)".*/\1/p' |
      grep -E "/${pattern}\$"
  )" || true
  # a static (musl) build runs on an old GLIBC, such as Roar's
  url="$(printf '%s\n' "${urls}" | grep -m 1 musl || printf '%s\n' "${urls}" | head -n 1)"
  [[ -n "${url}" ]] || die "${name}: no release asset matches ${pattern}"
  tmp="$(mktemp -d)"
  fetch "${url}" "${tmp}/archive.tar.gz"
  tar -xzf "${tmp}/archive.tar.gz" -C "${tmp}"
  found="$(find "${tmp}" -type f -name "${binary}" | head -n 1)"
  if [[ -z "${found}" ]]; then
    rm -rf "${tmp}"
    die "${name}: ${binary} is not in ${url}"
  fi
  install -m 755 "${found}" "${BIN}/${name}"
  rm -rf "${tmp}"
}

# safe_install NAME FUNCTION
# Moves ~/.local/bin/NAME aside, runs FUNCTION, and keeps the new version
# only if `NAME --version` works; otherwise the old one is put back. A new
# file then moves to ~/work/tools and is linked (see link_tool).
safe_install() {
  local name="$1"
  local fn="$2"
  local target="${BIN}/${name}"
  local old=""
  if [[ -e "${target}" || -L "${target}" ]]; then
    old="${target}.old.$$"
    mv "${target}" "${old}"
  fi
  if "${fn}" && [[ -n "$(version "${target}")" ]]; then
    [[ -n "${old}" ]] && rm -f "${old}"
    link_tool ".local/bin/${name}"
    say "${name}: $(version "${target}")"
  else
    rm -f "${target}"
    if [[ -n "${old}" ]]; then
      mv "${old}" "${target}"
      die "${name}: install failed; kept the previous version"
    fi
    die "${name}: install failed"
  fi
}

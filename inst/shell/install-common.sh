#!/bin/bash

# Shared helpers for inst/shell/install-*.sh (sourced, not run).
# Linux only; no sudo; everything goes into ~/.local.

BIN="${HOME}/.local/bin"
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

# safe_install NAME FUNCTION
# Moves ~/.local/bin/NAME aside, runs FUNCTION, and keeps the new version
# only if `NAME --version` works; otherwise the old one is put back.
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

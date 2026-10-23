# Install Project Packages from GitHub

A package found in any library is never upgraded. It is installed when
it is missing, or when its `ref` is a commit SHA that differs from the
installed commit (`RemoteSha`). Dependencies are installed only when
missing.

## Usage

``` r
PkgProjectGitHub(path, pkg, ref = "HEAD")
```

## Arguments

- path:

  Character string. Project path.

- pkg:

  Character vector. GitHub packages.

- ref:

  Character vector. Git branch, tag, or commit SHA (only a SHA
  reinstalls).

## Author

Ivan Jacob Agaloos Pesigan

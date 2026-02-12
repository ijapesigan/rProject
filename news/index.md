# Changelog

## rProject 0.0.24

### Patch

- Address
  [`install_github()`](https://remotes.r-lib.org/reference/install_github.html)
  deprecation by using
  [`pak::pak()`](https://pak.r-lib.org/reference/pak.html).

## rProject 0.0.23

### Patch

- Edits to the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.22

### Patch

- Added the
  [`PkgProjectBioconductor()`](https://github.com/ijapesigan/rProject/reference/PkgProjectBioconductor.md)
  function.

## rProject 0.0.21

### Patch

- Specific `rProject` GitHub commit can be installed via the
  `rproject_ver` object in `.setup/scripts/project.R`.

## rProject 0.0.20

### Patch

- Updated MIT license year to 2025.

## rProject 0.0.19

### Patch

- The
  [`PkgProjectGitHub()`](https://github.com/ijapesigan/rProject/reference/PkgProjectGitHub.md)
  function gives priority to installing packages that contain the `@`
  character in their specification.
- The
  [`PkgProjectVersion()`](https://github.com/ijapesigan/rProject/reference/PkgProjectVersion.md)
  function installs the available package first before checking its
  version.

## rProject 0.0.18

### Patch

- Added `.quarto` in the
  [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md)
  function.

## rProject 0.0.17

### Patch

- Revised the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.16

### Patch

- Added `tests` in exclusions in the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.15

### Patch

- Added `nolint.R` in exclusions in the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.14

### Patch

- Added `lib-2000-2009-manual` in
  [`BibLib()`](https://github.com/ijapesigan/rProject/reference/BibLib.md).

## rProject 0.0.13

### Patch

- Added `.sif` to
  [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md).

## rProject 0.0.12

### Patch

- Option to NOT delete `.sim` and `.sif` in
  [`CleanProj()`](https://github.com/ijapesigan/rProject/reference/CleanProj.md).

## rProject 0.0.11

### Patch

- Install `rhub` from CRAN.

## rProject 0.0.10

### Patch

- Added `".*\\.sif$` in
  [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md).

## rProject 0.0.9

### Patch

- Added the
  [`LatexTikzCompile()`](https://github.com/ijapesigan/rProject/reference/LatexTikzCompile.md)
  function and
  [`LatexMake()`](https://github.com/ijapesigan/rProject/reference/LatexMake.md)
  calls it before
  [`LatexCompile()`](https://github.com/ijapesigan/rProject/reference/LatexCompile.md).

## rProject 0.0.8

### Patch

- `knit::knit()` uses `envir = new.env()`.

## rProject 0.0.7

### Patch

- Exclude `R/methods.R` from linting in
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md).

## rProject 0.0.6

### Patch

- Edits to
  [`Clean()`](https://github.com/ijapesigan/rProject/reference/Clean.md)
  to keep `vignettes.bib` when `push = TRUE`.

## rProject 0.0.5

### Patch

- Option to build `bib.bib` from `lib-*` repositories using
  [`Bib()`](https://github.com/ijapesigan/rProject/reference/Bib.md).

## rProject 0.0.4

### Patch

- Added build tools for `Rcpp()` functions.

## rProject 0.0.3

### Patch

- Added the the function
  [`Bib()`](https://github.com/ijapesigan/rProject/reference/Bib.md) to
  generate `bib.bib` files for LateX, quarto, and vignettes.

## rProject 0.0.2

### Patch

- Added the argumnent `push` to
  [`Clean()`](https://github.com/ijapesigan/rProject/reference/Clean.md)
  for cleaning the directory in preparation for git push.

## rProject 0.0.1

### Patch

- Started version numbers.

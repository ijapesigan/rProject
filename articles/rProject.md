# rProject: Setup R Project

[![Make
Project](https://github.com/ijapesigan/rProject/actions/workflows/make.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/make.yml)
[![R-CMD-check](https://github.com/ijapesigan/rProject/actions/workflows/check-full.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/check-full.yml)
[![R Package Test
Coverage](https://github.com/ijapesigan/rProject/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/test-coverage.yml)
[![Lint R
Package](https://github.com/ijapesigan/rProject/actions/workflows/lint.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/lint.yml)
[![Package Website (GitHub
Pages)](https://github.com/ijapesigan/rProject/actions/workflows/pkgdown-gh-pages.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/pkgdown-gh-pages.yml)
[![Quarto Website (GitHub
Pages)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-gh-pages.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-gh-pages.yml)
[![Quarto Website (Quarto
Pub)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-quarto-pub.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-quarto-pub.yml)
[![Compile
LaTeX](https://github.com/ijapesigan/rProject/actions/workflows/latex.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/latex.yml)
[![Compile LaTeX (rProject
Daily)](https://github.com/ijapesigan/rProject/actions/workflows/latex-rproject-daily.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/latex-rproject-daily.yml)
[![Shell
Check](https://github.com/ijapesigan/rProject/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/shellcheck.yml)
[![pages-build-deployment](https://github.com/ijapesigan/rProject/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/pages/pages-build-deployment)
[![codecov](https://codecov.io/gh/ijapesigan/rProject/branch/main/graph/badge.svg?token=KVLUET3DJ6)](https://codecov.io/gh/ijapesigan/rProject)

## Description

A collection of functions to setup R (R Core Team, 2025) projects. This
package is intended for personal use only.

## Installation

You can install the released version of `rProject` from
[GitHub](https://github.com/ijapesigan/rProject) with:

``` r

if (!require("remotes")) install.packages("remotes")
remotes::install_github("ijapesigan/rProject")
```

## Workflow using the template produced by `rProject`

To build applications installed in `$HOME/.local/bin` (e.g., `tmux`) and
config files (e.g., `.tmux.conf`) run:

``` bash
make local
```

To build the project run:

``` bash
make
```

## More Information

See [GitHub Pages](https://ijapesigan.github.io/rProject) for package
documentation.

See [Quarto Pub](https://ijapesigan.quarto.pub/rproject) for package
wiki and other resources.

## References

R Core Team. (2025). *R: A language and environment for statistical
computing*. R Foundation for Statistical Computing.
<https://www.R-project.org/>

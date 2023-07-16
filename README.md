rProject
================
Ivan Jacob Agaloos Pesigan
2023-07-16

<!-- README.md is generated from .setup/readme/README.Rmd. Please edit that file -->
<!-- badges: start -->

[![latex](https://github.com/ijapesigan/rProject/actions/workflows/latex.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/latex.yml)
[![lint](https://github.com/ijapesigan/rProject/actions/workflows/lint.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/lint.yml)
[![make](https://github.com/ijapesigan/rProject/actions/workflows/make.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/make.yml)
[![pages-build-deployment](https://github.com/ijapesigan/rProject/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/pages/pages-build-deployment)
[![pkgdown](https://github.com/ijapesigan/rProject/actions/workflows/pkgdown-gh-pages.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/pkgdown-gh-pages.yml)
[![quarto (GitHub
Pages)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-gh-pages.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-gh-pages.yml)
[![quarto (Quarto
Pub)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-quarto-pub.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-quarto-pub.yml)
[![R-CMD-check](https://github.com/ijapesigan/rProject/actions/workflows/check-full.yaml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/check-full.yaml)
[![Shell
Check](https://github.com/ijapesigan/rProject/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/shellcheck.yml)
[![test-coverage](https://github.com/ijapesigan/rProject/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/test-coverage.yml)
<!-- badges: end -->

## Description

A collection of functions to setup R (R Core Team, 2023) projects. This
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

<div id="refs" class="references csl-bib-body hanging-indent"
line-spacing="2">

<div id="ref-RCoreTeam-2023" class="csl-entry">

R Core Team. (2023). *R: A language and environment for statistical
computing*. R Foundation for Statistical Computing.
<https://www.R-project.org/>

</div>

</div>

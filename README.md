rProject
================
Ivan Jacob Agaloos Pesigan
2023-06-29

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/ijapesigan/rProject/workflows/R-CMD-check/badge.svg)](https://github.com/ijapesigan/rProject/actions)
[![test-coverage](https://github.com/ijapesigan/rProject/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/test-coverage.yaml)
[![lint](https://github.com/ijapesigan/rProject/actions/workflows/lint.yaml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/lint.yaml)
[![pkgdown](https://github.com/ijapesigan/rProject/actions/workflows/pkgdown-gh-pages.yaml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/pkgdown-gh-pages.yaml)
[![quarto (Quarto
Pub)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-quarto-pub.yml/badge.svg)](https://github.com/ijapesigan/rProject/actions/workflows/quarto-quarto-pub.yml)
[![codecov](https://codecov.io/gh/ijapesigan/rProject/branch/main/graph/badge.svg)](https://codecov.io/gh/ijapesigan/rProject)
<!-- badges: end -->

## Description

A collection of functions to setup R projects. This package is intended
for personal use only.

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

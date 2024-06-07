# rProject 0.0.14

## Patch

Account for `.sty` files in `LatexKnit()`.

# rProject 0.0.13

## Patch

Added `.sif` to `BuildIgnore()`.

# rProject 0.0.12

## Patch

Option to NOT delete `.sim` and `.sif` in `CleanProj()`.

# rProject 0.0.11

## Patch

Install `rhub` from CRAN.

# rProject 0.0.10

## Patch

Added `".*\\.sif$` in `BuildIgnore()`.

# rProject 0.0.9

## Patch

Added the `LatexTikzCompile()` function and `LatexMake()` calls it before `LatexCompile()`.

# rProject 0.0.8

## Patch

`knit::knit()` uses `envir = new.env()`.

# rProject 0.0.7

## Patch

Exclude `R/methods.R` from linting in `Lint()`.

# rProject 0.0.6

## Patch

Edits to `Clean()` to keep `vignettes.bib` when `push = TRUE`.

# rProject 0.0.5

## Patch

Option to build `bib.bib` from `lib-*` repositories using `Bib()`.

# rProject 0.0.4

## Patch

Added build tools for `Rcpp()` functions.

# rProject 0.0.3

## Patch

Added the the function `Bib()` to generate `bib.bib` files for LateX, quarto, and vignettes.

# rProject 0.0.2

## Patch

Added the argumnent `push` to `Clean()` for cleaning the directory in preparation for git push.

# rProject 0.0.1

## Patch

Started version numbers.

# Consolidate .bib Files into a Single File

Joins the `.bib` files in `.setup/latex/bib` into `bib.bib`, verbatim
and in file-name order, and copies it to `.setup/quarto/bib/quarto.bib`
and `vignettes/vignettes.bib` when those folders exist. Without sources
(a clone of the repository, which has only `bib.bib`), the existing
`bib.bib` is copied. The source files are never rewritten: in `lib-*`
projects they are the entries themselves (one entry per file, ASCII with
LaTeX accents).
[`LibCheck()`](https://github.com/ijapesigan/rProject/reference/LibCheck.md)
validates them with biber.

## Usage

``` r
Bib(path, bib_lib = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- bib_lib:

  Logical. If `bib_lib = TRUE`, build `bib.bib` from `lib-*` GitHub
  repositories.

## Author

Ivan Jacob Agaloos Pesigan

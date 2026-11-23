# Code Coverage

Runs
[`covr::package_coverage()`](https://covr.r-lib.org/reference/package_coverage.html)
on the package. To leave files out, put covr's `.covrignore` at the
project root (and add it to `.Rbuildignore` with `ignore` in
`.setup/scripts/project.R`). The tests run with `NOT_CRAN=true`, as
under
[`devtools::test()`](https://devtools.r-lib.org/reference/test.html), so
that
[`testthat::skip_on_cran()`](https://testthat.r-lib.org/reference/skip.html)
does not skip them.

## Usage

``` r
Coverage(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
Coverage(path = getwd())
} # }
```

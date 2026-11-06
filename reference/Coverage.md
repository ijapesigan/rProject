# Code Coverage

Runs
[`covr::package_coverage()`](http://covr.r-lib.org/reference/package_coverage.md)
on the package. To leave files out, put covr's `.covrignore` at the
project root (and add it to `.Rbuildignore` with `ignore` in
`.setup/scripts/project.R`).

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

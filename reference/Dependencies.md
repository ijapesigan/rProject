# Copy Dependencies to from `.setup/r-dependencies` to `R`

Replaces the copies in `R`: a helper renamed or deleted in
`.setup/r-dependencies/<set>` does not stay in `R` as `<set>-*.R`. A set
named after the package is left alone (the package's own files).

## Usage

``` r
Dependencies(path)
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
Dependencies(path = getwd())
} # }
```

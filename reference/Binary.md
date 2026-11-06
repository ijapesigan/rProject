# Setup Binaries not Included in the Package

Runs (sources) every R script in `.setup/bin/`, at `make project`; for
example, a script that builds a bespoke binary the project needs.
`.setup/bin/` is optional: `make` does not create it, and without it
`Binary()` does nothing.

## Usage

``` r
Binary(path)
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
Binary(path = getwd())
} # }
```

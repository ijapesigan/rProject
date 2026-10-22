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

## Author

Ivan Jacob Agaloos Pesigan

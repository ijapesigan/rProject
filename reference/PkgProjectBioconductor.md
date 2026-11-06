# Install Project Packages from Bioconductor

Install Project Packages from Bioconductor

## Usage

``` r
PkgProjectBioconductor(path, pkg)
```

## Arguments

- path:

  Character string. Project path.

- pkg:

  Character vector. Bioconductor packages.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
PkgProjectBioconductor(path = getwd(), pkg = "stats")
} # }
```

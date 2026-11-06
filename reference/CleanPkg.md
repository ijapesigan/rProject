# Clean R Packages

Remove the project's R library (`.library`). Packages outside the
project (the image's site library, the user library) are never touched.

## Usage

``` r
CleanPkg(path)
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
CleanPkg(path = getwd())
} # }
```

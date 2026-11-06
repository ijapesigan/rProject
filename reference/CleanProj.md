# Clean Project

Remove all files except `project.Rproj` and, optionally, `.library`.

## Usage

``` r
CleanProj(path, lib = FALSE, sim = FALSE, sif = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- lib:

  Logical. If `lib = TRUE`, delete `.library`. If `lib = FALSE`,
  `.library` is not deleted.

- sim:

  Logical. If `sim = TRUE`, delete `.sim`. If `sim = FALSE`, `.sim` is
  not deleted.

- sif:

  Logical. If `sif = TRUE`, delete `.sif`. If `sif = FALSE`, `.sif` is
  not deleted.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
CleanProj(path = getwd())
} # }
```

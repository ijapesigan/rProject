# Clean Files Generated on Build

Delete all output files that are generated on automated build.

## Usage

``` r
Clean(path, push = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- push:

  Logical. If `push = TRUE` clean in preparation for git push: generated
  files are kept, and files matching `*secrets*` are deleted, except in
  hidden folders such as `.setup`.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
Clean(path = getwd())
} # }
```

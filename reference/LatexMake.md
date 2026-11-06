# Compile Output of `LatexKnit`

Compile Output of `LatexKnit`

## Usage

``` r
LatexMake(path, clean = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- clean:

  Logical. Clean `latexmk` output except `*.pdf`

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
LatexMake(path = getwd())
} # }
```

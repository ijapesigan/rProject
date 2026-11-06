# Compile Tikz

Compile Tikz

## Usage

``` r
LatexTikzCompile(path, clean = FALSE)
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
LatexTikzCompile(path = getwd())
} # }
```

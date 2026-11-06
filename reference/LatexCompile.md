# Compile Output of `LatexKnit`

Runs `latexmk` on every `.tex` file, with 10 million extra words of
pdfTeX main memory (`extra_mem_bot`), so that a long bibliography
compiles. A document whose last run failed (fatal error, TeX capacity
exceeded) stops `make latex` in GitHub Actions and gives a warning
locally: `latexmk -f` would otherwise leave a stub PDF and succeed.

## Usage

``` r
LatexCompile(path, clean = FALSE)
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
LatexCompile(path = getwd())
} # }
```

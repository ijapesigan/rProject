# Compile Output of `LatexKnit`

Runs `latexmk` on every `.tex` file, with 10 million extra words of
pdfTeX main memory (`extra_mem_bot`), so that a long bibliography
compiles.

## Usage

``` r
LatexCompile(path, clean = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- clean:

  Logical. Clean `latexmk` output except `*.pdf`

## Author

Ivan Jacob Agaloos Pesigan

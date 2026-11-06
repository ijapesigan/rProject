# Data Analysis

Execute R scripts in `data-analysis`.

## Usage

``` r
DataAnalysis(path, clean = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- clean:

  Logical. Remove all `.Rds` files in `data-process` and `data-analysis`
  before running.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
DataAnalysis(path = getwd())
} # }
```

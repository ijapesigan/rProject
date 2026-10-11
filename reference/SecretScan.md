# Scan Project for Secrets

Searches text files in the project for strings that look like tokens
(GitHub, Docker Hub, Quarto Pub, Overleaf, Codecov, OpenAI, Anthropic).
Matches are reported with the value masked.

## Usage

``` r
SecretScan(path, max_size = 5e+06, error = TRUE)
```

## Arguments

- path:

  Character string. Project path.

- max_size:

  Numeric. Files larger than `max_size` bytes are skipped.

- error:

  Logical. If `TRUE`, stop with an error when secrets are found.

## Value

Returns a data frame of findings with the columns `file`, `line`,
`type`, and `match` (masked).

## Author

Ivan Jacob Agaloos Pesigan

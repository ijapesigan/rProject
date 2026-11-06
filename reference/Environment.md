# Setup `.Renviron`

Setup `.Renviron`

## Usage

``` r
Environment(path, project, tokens)
```

## Arguments

- path:

  Character string. Project path.

- project:

  Character string. Project name.

- tokens:

  Named vector of tokens.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
Environment(
  path = getwd(),
  project = "myProject",
  tokens = c(GITHUB_PAT = Sys.getenv(x = "GITHUB_PAT"))
)
} # }
```

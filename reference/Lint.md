# Lint Project

Runs `lintr` on the R code, then the house checks of the style guides,
and prints one table of findings: file, line, rule, message, and level.
The R and C++ checks are warnings until a project sets
`lint_error <- TRUE` in `.setup/scripts/project.R`: then they stop
`make lint`. The LaTeX and Markdown checks are always warnings. Talks
(project type `talk`) run the rules kept in talks only.

## Usage

``` r
Lint(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns the `lints` object of `lintr`, invisibly with the house findings
as the data frame in its `house` attribute.

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
Lint(path = getwd())
} # }

if (FALSE) { # \dontrun{
Lint(path = getwd())
} # }
```

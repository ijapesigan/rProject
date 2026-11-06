# README Badges

Returns a Markdown badge for the project's DOI and for each workflow in
`.github/workflows`.
[`ReadMe()`](https://ijapesigan.github.io/rProject/reference/ReadMe.md)
writes them between the `<!-- badges: start -->` and
`<!-- badges: end -->` lines of `README.md`, and keeps any other badge
there, such as CRAN status. The DOI is the first `doi` in
`inst/CITATION`; the placeholder `10.0000/0000000000` has no badge. The
r-hub review tiers (3 and 4) are labeled, because `continue-on-error`
keeps their badges green. Tier 5, run by hand, has no badge.

## Usage

``` r
Badges(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns a character vector of Markdown badges. It is empty when the
project has no DOI, and no workflows or public repository.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
Badges(path = getwd())
} # }
```

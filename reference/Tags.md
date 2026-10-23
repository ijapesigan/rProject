# Library Tags

Lists the key, `annotation`, and `keywords` of every entry in the
project's Quarto bibliography (`.setup/quarto/bib/quarto.bib`, written
by [`Bib()`](https://github.com/ijapesigan/rProject/reference/Bib.md)),
for the "Library Tags" page of the Quarto site.

## Usage

``` r
Tags(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns a data frame with the columns `key`, `annotation`, and
`keywords` (`NA` when an entry has none), sorted by key. Without the
bibliography, an empty data frame, with a message.

## Author

Ivan Jacob Agaloos Pesigan

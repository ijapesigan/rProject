# Report the Articles Missing an Abstract in the lib-\* Library

For each `lib-<decade>-<type>` project in `root`, lists the `@Article`
entries (`.setup/latex/bib/lib-*.bib`) that have no `abstract` field.
Many entries have none on purpose (for example, JSTOR articles); the
report is information, not a check.

## Usage

``` r
LibAbstractReport(root)
```

## Arguments

- root:

  Character string. The folder with local clones of the `lib-*`
  projects.

## Value

Returns a data frame, invisibly, with the columns `repo` and `key`.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
LibAbstractReport(root = dirname(getwd()))
} # }
```

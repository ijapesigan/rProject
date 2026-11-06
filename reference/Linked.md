# Compare the Files Linked from the Functions Repository

The files in `.setup/r-dependencies/` are Overleaf links to the private
functions repository: `<lib>/<file>` there. They are changed only there.
`Linked()` compares each one, by content, with a local clone of
functions.

## Usage

``` r
Linked(path, functions = NULL)
```

## Arguments

- path:

  Character string. Project path.

- functions:

  Character string or `NULL`. The local clone of the functions
  repository. If `NULL`, the path in `.setup/repo/functions.md`, else
  `functions` next to the project.

## Value

Returns a data frame with the columns `file` and `status`, invisibly.

## Details

The status of a file is `same`, `differs`, `name differs` (the source
has only the `-dot` variant of the name), or `no source`.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
Linked(path = getwd())
} # }
```

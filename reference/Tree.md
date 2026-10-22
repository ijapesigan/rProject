# Project Folders and What They Are For

Prints the standard folders of the project's type
(`inst/template/folders.tsv`) with their purpose, and flags the folders
that differ from the standard: a folder that `make` creates for the type
but that is missing, and a folder that is not standard for the type.

## Usage

``` r
Tree(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns a data frame, invisibly, with the columns `folder`, `status`
(`"present"`, `"missing"`, `"absent"` for an optional folder,
`"not standard"` for this type, or `"unknown"`), `private`, and
`purpose`.

## Details

The type comes from the `type` line in `.setup/scripts/project.R` (see
[`Template()`](https://github.com/ijapesigan/rProject/reference/Template.md));
without it, it is guessed as in
[`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md).

## Author

Ivan Jacob Agaloos Pesigan

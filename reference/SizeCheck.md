# Check a Project Against Overleaf's Limits

Measures what goes to Overleaf: every file in the project except
local-only folders (`.git`, `.verify`, `.library`, `.Rproj.user`,
`detritus`) and build output that `make` writes and Overleaf never gets
(`docs`, `pkgdown`, `quarto`, `.setup/build`, `.setup/latex/pdf`,
`.setup/quarto/bib`), and the local-only data tiers
(`.setup/data-external`, `.setup/data-cache`).

## Usage

``` r
SizeCheck(
  path,
  editable = 7,
  text_file = 2,
  file = 50,
  total = 100,
  files = 2000L,
  error = FALSE
)
```

## Arguments

- path:

  Character string. Project path.

- editable:

  Numeric. Limit for all editable text, in MB.

- text_file:

  Numeric. Limit for one editable text file, in MB.

- file:

  Numeric. Limit for one file, in MB.

- total:

  Numeric. Recommended limit for the whole project, in MB.

- files:

  Integer. Limit for the number of files.

- error:

  Logical. If `TRUE`, stop with an error when a check fails.

## Value

Returns a data frame of checks with the columns `check`, `status`, and
`detail`.

## Details

- **Editable text** (fails): non-binary files in total above `editable`
  MB. Overleaf's GitHub sync stops above 7 MB.

- **Text file size** (fails): any non-binary file above `text_file` MB.
  Overleaf caps editable files at 2 MB.

- **File size** (fails): any file above `file` MB. Overleaf caps uploads
  at 50 MB.

- **Number of files** (fails): more than `files` files. Overleaf allows
  2,000.

- **Total size** (warning): above `total` MB. Overleaf recommends under
  100 MB with GitHub sync or git.

- **Duplicates** (warning): files of at least 1 MB with the same
  content.

The report also lists the largest text files and the largest files.

## Author

Ivan Jacob Agaloos Pesigan

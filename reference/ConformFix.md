# Fix What Conform Can Fix

Applies the `fix` rows of
[`Conform()`](https://ijapesigan.github.io/rProject/reference/Conform.md):
it writes the missing tier 1 template files and the files every package
has (from `reference` when it has them, else from rProject), and removes
the strays (`main.tex`, an empty `.tmp-r/`) from the working copy. It
never overwrites a file, and never touches a `decide` or `info` row.
Strays are removed only with `remove = TRUE`, and never a locked copy.
The upload folder is compared with the project (files that differ, that
are missing, and that are not in the manifest) and the drift is
reported. Then it keeps the records in step: it adds a "Structure audit
additions" section to the log `.setup/logs/YYYY-MM-DD-<topic>.md` (made
with [`Log()`](https://ijapesigan.github.io/rProject/reference/Log.md)
when there is none; a fix-up with
[`FixUp()`](https://ijapesigan.github.io/rProject/reference/FixUp.md)
when the log was already pushed, that is, a row of
`.setup/logs/index.md` names it with a commit), and puts the new files
and the log in the upload folder (in place when the log was not pushed,
a `-fixup` folder when it was). It prints the files changed and the
files to delete in Overleaf (which it never does itself), and that the
dot-files must be created by hand in Overleaf. With `lint = TRUE` or
`tests = TRUE` it ends with a final re-check: the real `make lint` and
the unit tests, reported as in
[`Conform()`](https://ijapesigan.github.io/rProject/reference/Conform.md)
(never run otherwise). Nothing is committed or pushed.

## Usage

``` r
ConformFix(
  path = ".",
  reference = NULL,
  topic = "conform",
  dest = NULL,
  remove = FALSE,
  lint = FALSE,
  tests = FALSE,
  log_dir = tempdir()
)
```

## Arguments

- path:

  Character string. The project folder.

- reference:

  Character string or `NULL`. The folder of a finished project to
  compare the file set with. With `NULL`, only the manifest and the
  rules are used.

- topic:

  Character string. The topic of the change-set log
  (`.setup/logs/YYYY-MM-DD-<topic>.md`).

- dest:

  Character string or `NULL`. The folder that holds the upload folders,
  as in
  [`Upload()`](https://ijapesigan.github.io/rProject/reference/Upload.md).

- remove:

  Logical. If `TRUE`, remove the strays (`main.tex`, an empty `.tmp-r/`)
  from the working copy; otherwise they are only reported. A locked copy
  (a file in `.setup/r-dependencies/<lib>/` or `.setup/cpp/`) is never
  removed.

- lint, tests:

  Logical. If `TRUE`, run `make lint` or
  [`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
  after the fixes, as in
  [`Conform()`](https://ijapesigan.github.io/rProject/reference/Conform.md).

- log_dir:

  Character string. The folder for the raw outputs of the final
  re-check.

## Value

Returns a list, invisibly, with the files written (`new`), the files to
delete in Overleaf (`overleaf`), the local-only removals (`local`), the
log, and the upload folder (`NULL` when there was nothing to fix), and
`check`, the findings of the final re-check (`NULL` without `lint` or
`tests`).

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
ConformFix(path = getwd(), reference = "../devel-linearAlgebra")
} # }
```

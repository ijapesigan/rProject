# Build the Upload Folder of a Change Set

Copies the files that the change-set log lists as new or edited to
`<dest>/YYYY-MM-DD-<project>-<topic>[-fixup]/`, at their paths in the
project, so the folder can be uploaded to Overleaf as it is. Generated
files, linked files, and the commit message are not in it. The deletions
are printed, to be done by hand in Overleaf. An existing folder is never
touched: upload folders are final, and a later change is a fix-up
([`FixUp()`](https://ijapesigan.github.io/rProject/reference/FixUp.md)).

## Usage

``` r
Upload(path, topic, fixup = FALSE, dest = NULL)
```

## Arguments

- path:

  Character string. Project path.

- topic:

  Character string. Short topic in kebab case (e.g., `"log-spec"`). The
  change-set log uses the same topic.

- fixup:

  Logical. If `TRUE`, use the lists of the newest fix-up section of the
  log and name the folder `...-fixup`. Otherwise, use the lists of the
  change set itself.

- dest:

  Character string. The folder that holds the upload folders. By default
  `/scratch/ibp5092/Work/upload` when it exists (Roar), else `upload`
  next to the projects.

## Value

Returns the path of the upload folder invisibly.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
Upload(path = getwd(), topic = "my-topic")
} # }
```

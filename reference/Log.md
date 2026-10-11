# Create or Update a Change-Set Log

Creates `.setup/logs/YYYY-MM-DD-<topic>.md`, the log for one change set
(one Overleaf push), and adds a pending row to `.setup/logs/index.md`.
The log has the commit message skeleton, a "Pushes" table, and the list
of files to update in Overleaf.

## Usage

``` r
Log(
  path,
  topic,
  summary = topic,
  private = file.path(path, ".verify"),
  update = FALSE
)
```

## Arguments

- path:

  Character string. Project path.

- topic:

  Character string. Short topic in kebab case (e.g., `"log-spec"`). The
  change-set log uses the same topic.

- summary:

  Character string. First line of the commit message.

- private:

  Character string. Path to a clone of the private repository at the
  pushed commit. By default `.verify` in the project.

- update:

  Logical. If `TRUE`, refresh only the file lists of the newest existing
  log for `topic`.

## Value

Returns the path of the log invisibly.

## Details

The file lists come from comparing the project with a clone of the
private repository (by default `.verify`, kept by
`.setup/scripts/verify.sh`), using the same rules as
[`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md).
Without a clone, the lists hold `TODO`.

## Author

Ivan Jacob Agaloos Pesigan

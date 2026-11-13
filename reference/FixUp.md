# Add a Fix-Up to a Change-Set Log

A fix-up is a small push after a change set was logged (the upload
folder is final, so a later change is a new push). `FixUp()` appends a
`## Fix-up: <summary>` section to the newest log for `topic`: the commit
message skeleton (ending `Log: .setup/logs/<log>`) and the lists of
files to update in Overleaf, compared with the clone of the private
repository (the same rules as
[`Log()`](https://ijapesigan.github.io/rProject/reference/Log.md)). It
also adds a pending row to the log's "Pushes" table (in the order of the
table's header) and a pending row to `.setup/logs/index.md`. After the
push,
[`Verify()`](https://ijapesigan.github.io/rProject/reference/Verify.md)
with `record = TRUE` fills them in.
[`Upload()`](https://ijapesigan.github.io/rProject/reference/Upload.md)
with `fixup = TRUE` builds the upload folder.

## Usage

``` r
FixUp(path, topic, summary, private = file.path(path, ".verify"))
```

## Arguments

- path:

  Character string. Project path.

- topic:

  Character string. Short topic in kebab case (e.g., `"log-spec"`). The
  change-set log uses the same topic.

- summary:

  Character string. First line of the fix-up's commit message.

- private:

  Character string. Path to a clone of the private repository at the
  pushed commit. By default `.verify` in the project.

## Value

Returns the path of the log invisibly.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
FixUp(path = getwd(), topic = "my-topic", summary = "Fix-up: handoff")
} # }
```

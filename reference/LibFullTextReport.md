# Report the Full Texts Missing from the lib-\* Library

For each `lib-<decade>-<type>` project in `root`, lists the entries with
no full text in the private repository
(`.setup/notes/<ext>/<repo>-<key>.<ext>` in the project's `.verify`),
and the files there that match no entry. PDF, EPUB, and DjVu count as a
full text, and so does a part (`-ch01`); a supplement alone does not. A
work with no copy in any format is listed in
`.setup/notes/no-full-text.txt` (one key per line, a reason after `#`).

## Usage

``` r
LibFullTextReport(root)
```

## Arguments

- root:

  Character string. The folder with local clones of the `lib-*`
  projects.

## Value

Returns a list, invisibly: `missing`, a data frame with the columns
`repo`, `key`, and `status`; `orphans`, a data frame with the columns
`repo` and `file`; and `unchecked`, the projects without a `.verify`.

## Details

Pull each `.verify` first (`bash .setup/scripts/verify.sh` on the host).

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
LibFullTextReport(root = dirname(getwd()))
} # }
```

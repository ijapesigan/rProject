# Put the Entries of a lib-\* Library in the House Layout

Rewrites each entry file in `.setup/latex/bib` of a `lib-*` project in
the house layout, without changing what the entry says:

## Usage

``` r
LibFormat(path, write = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- write:

  Logical. If `TRUE`, rewrite the files that change. If `FALSE`, only
  report them.

## Value

Returns the names of the files that change (or changed), invisibly.

## Details

- `@Type{Key,`, then one ` field = {value},` per line, then `}`, and a
  final newline;

- fields in the house order: `author`, `editor`, `bookauthor`,
  `booktitle`, `date`, `journaltitle`, `title`, `subtitle`, the other
  fields alphabetically, then `abstract`, `publisher`, `keywords`,
  `library`, and `annotation`;

- field names in lower case and entry types in the house spelling
  (`Article`, `InBook`, `PhdThesis`, ...);

- `\a'`-style accents as `\'` (`{\a'e}` becomes `{\'e}`);

- page ranges with `--`;

- DOIs without a `https://doi.org/` or `doi:` prefix.

Files that do not parse, or that hold more than one entry, are left as
they are (see
[`LibCheck()`](https://github.com/ijapesigan/rProject/reference/LibCheck.md)).

## Author

Ivan Jacob Agaloos Pesigan

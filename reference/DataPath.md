# Find a Data File in the Data Tiers

Finds a data file by its plain name in the data tiers, in this order:
`.setup/data-raw` (shareable), `.setup/data-private` (restricted; never
public), and `.setup/data-external` (local only). The file can be stored
as is or compressed (`.xz` or `.gz`);
[`utils::read.table()`](https://rdrr.io/r/utils/read.table.html) and
similar functions read compressed files directly.

## Usage

``` r
DataPath(path, file, plain = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- file:

  Character string. Plain file name, e.g., `"data.txt"`, even if it is
  stored as `data.txt.xz`.

- plain:

  Logical. If `TRUE`, return a path to an uncompressed copy.

## Value

Returns the path of the file.

## Details

With `plain = TRUE`, a compressed file is unpacked into
`.setup/data-cache` (local only), for tools that need plain text, such
as Mplus. The copy is refreshed when the compressed file changes.

## Author

Ivan Jacob Agaloos Pesigan

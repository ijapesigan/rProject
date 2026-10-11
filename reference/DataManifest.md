# Write the Data Manifest

Writes `.setup/ai/data.md` (private), with one row for each file in the
data tiers (`.setup/data-raw`, `.setup/data-private`,
`.setup/data-external`): the file, its tier, size, MD5, status, the
source and location (filled in by the user and kept on rewrite), and the
scripts that use it.

## Usage

``` r
DataManifest(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns the manifest as a data frame, invisibly.

## Details

External files are local only. One that is listed but missing on this
machine is kept, marked "not on this machine"; one whose MD5 differs
from the recorded one is marked "changed".

## Author

Ivan Jacob Agaloos Pesigan

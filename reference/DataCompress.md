# Compress Data Files

Compresses data files in place with xz (e.g., `data.txt` becomes
`data.txt.xz`), checks that the compressed copy reads back byte for
byte, and then removes the original. Compressed files are binary, so
they do not count as editable text in Overleaf (see
[`SizeCheck()`](https://github.com/ijapesigan/rProject/reference/SizeCheck.md)).
Scripts that find files with
[`DataPath()`](https://github.com/ijapesigan/rProject/reference/DataPath.md)
keep working unchanged.

## Usage

``` r
DataCompress(path, files)
```

## Arguments

- path:

  Character string. Project path.

- files:

  Character vector. Files to compress, relative to `path`.

## Value

Returns the paths of the compressed files, invisibly.

## Author

Ivan Jacob Agaloos Pesigan

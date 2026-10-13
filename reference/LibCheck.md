# Check the Entries of a lib-\* Library

Checks every entry file in `.setup/latex/bib` of a `lib-<decade>-<type>`
project against the house conventions.

## Usage

``` r
LibCheck(path, root = NULL, error = FALSE)
```

## Arguments

- path:

  Character string. Project path.

- root:

  Character string or `NULL`. A folder with local clones of the other
  `lib-*` projects, to find keys and DOIs used in more than one
  repository. If `NULL`, only this project is checked.

- error:

  Logical. If `TRUE`, stop when there is an ERROR.

## Value

Returns a data frame with the columns `file`, `key`, `severity`,
`check`, and `message`, invisibly.

## Details

- **ERROR:** the file does not parse or holds more than one entry; the
  file name is not `<repo>-<key>.bib`; the key does not follow
  `Family-Family-Family[-etal]-Year[a-z]` (three names, then `etal`, for
  four or more authors); the key year differs from the `date` year or
  lies outside the decade; a required field is missing; a non-ASCII
  character; an unescaped `%` in a text field; a key or DOI used twice;
  biber reports a missing mandatory field.

- **WARNING:** an entry type outside the repository's type; a lone
  suffix (`b` without `a`); other biber datamodel warnings.

- **STYLE:** not in the house layout (see
  [`LibFormat()`](https://github.com/ijapesigan/rProject/reference/LibFormat.md));
  `\a'`-style accents; a page range with one hyphen; a DOI with a
  prefix; no final newline.

biber's warning that `publisher` is not an `@Article` field is the house
convention and is not reported.

## Author

Ivan Jacob Agaloos Pesigan

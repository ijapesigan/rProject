# Add an Entry to the lib-\* Library from a DOI

Drafts a biblatex entry from the DOI's Crossref record, in the house
layout, and names the repository and file it belongs in:

## Usage

``` r
LibAdd(doi, root, key = NULL, title = NULL, fields = NULL, write = FALSE)
```

## Arguments

- doi:

  Character string. The DOI.

- root:

  Character string. The folder with local clones of the `lib-*`
  projects.

- key:

  Character string or `NULL`. A key to use instead of the drafted one
  (e.g., with a suffix).

- title:

  Character string or `NULL`. A title to use instead of the drafted one.

- fields:

  Named character vector or `NULL`. Fields to set or replace (e.g., full
  author names or an abstract from the publisher's page).

- write:

  Logical. If `TRUE`, write the file and run
  [`LibCheck()`](https://github.com/ijapesigan/rProject/reference/LibCheck.md)
  on its repository.

## Value

Returns a list with `file`, `text`, and `questions`, invisibly.

## Details

- the entry type and the repository type from the Crossref type;

- `date` from the print issue (`published-print`), else the journal
  issue, else the first publication; the key year and the decade
  repository follow it;

- names and text with LaTeX accents, and `\%` and `\&` escaped;

- the key as `Family-Family-Family[-etal]-Year`, accents dropped;

- the abstract without its JATS tags;

- the ISSN and publisher reused from the library's other entries for the
  same journal;

- the title in a sentence-case draft.

It never invents a field: what Crossref does not have is left out. It
lists what it cannot decide (initials only, an online-first date, a
missing abstract, the title's proper nouns, a key already in use) as
questions for the user.

## Author

Ivan Jacob Agaloos Pesigan

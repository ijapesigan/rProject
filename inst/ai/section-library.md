
## Bibliography library

This is one of the 22 `lib-<decade>-<type>` repositories (type `article`,
`book`, or `manual`). Together they are the user's citation library; other
projects get the entries from the public copies (`ijapesigan/lib-*`) with
`make bibrproject`.

- One entry per file: `.setup/latex/bib/<repo>-<Key>.bib`. The file is the
  source of truth; `make bib` only joins the files into `bib.bib` and never
  rewrites them. PDFs go in `.setup/notes/pdf/<repo>-<Key>.pdf`, EPUBs in
  `.setup/notes/epub/` (private, never published).
- Key: `Family-Family-Family-Year`; four or more authors: the first three,
  then `etal` (`Hamaker-Asparouhov-Brose-etal-2018`). Accents are dropped and
  particles, spaces, and hyphens joined in keys (`Muthen`, `LeBourdonnec`,
  `KisbuSakarya`). Same stem and year: suffixes `a`, `b`, ... Never rename a
  key without the user's approval: it breaks citations elsewhere.
- Year: the publication (issue) date, not the online-first date, sets `date`
  (`YYYY-MM` when known), the key year, the file name, and the decade
  repository. An online-first article with no issue yet uses the online
  year and is flagged until the issue appears.
- Text: ASCII only. Accents as LaTeX in names and text (`Muth{\'e}n`,
  `Gouri{\'e}roux`), `--` for ranges, `` `` `` and `''` for quotes, `\%` and
  `\&` escaped in text fields (not in `doi` or `url`).
- Names: full given names when the publisher, the work, or ORCID gives them;
  corporate authors in double braces (`{{R Core Team}}`).
- Fields, as complete as authoritative sources allow: `author`, `date`,
  `journaltitle`, `title` (sentence case, proper nouns and acronyms in braces:
  `{R}`, `{Mplus}`, `{Bayesian}`), `doi` (bare), `issn`, `number`, `pages`,
  `volume`, `abstract` (the final published version, from the publisher,
  JSTOR, PubMed, or Crossref), `publisher`. Books: `isbn`, `location`,
  `edition`, `pagetotal` (not `pages`), `library` (`Library of Congress;
  LCCN ...; LCC ...`) and Library of Congress subject headings in `keywords`,
  from a record of the same edition. Chapters: `@InBook` with `booktitle`,
  `editor`, and `pages`.
- `keywords`: from the authors, the publisher, or a catalog. `annotation`:
  the user's own topic tags. Never move one into the other.
- Layout: `make libformat` (`LibFormat()`) writes the house layout and field
  order; never hand-format.
- Add an entry with `rProject::LibAdd(doi, root)`: show the user the draft
  and its questions before `write = TRUE`.
- Never invent an entry or a field. A field no authoritative source gives is
  left out; record the source of every field you add.
- Check before the user pushes: `make libcheck` (`LibCheck()`; pass
  `ROOT=<folder with all lib-* clones>` to find keys and DOIs used twice).

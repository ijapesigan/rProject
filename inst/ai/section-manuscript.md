
## Manuscript

- Sources are `.setup/latex/*.Rtex` (knitr). The manuscript is the
  `*-manuscript*.Rtex` file; supplements and notes sit beside it.
- Build with `make latex` (or `make pdf` for a clean build). Never edit the
  generated `.tex` or anything in `.setup/latex/pdf/`.
- Follow `.setup/ai/style/manuscript.md` for all manuscript prose, abstracts,
  cover letters, and responses to reviewers.
- Track edits with the `changes` package without an `id`; never use an "AI" id.
- Every number in the text comes from `make` output; never type results by hand.
- References come from `bib.bib`, built from the `lib-*` repositories; never
  invent a citation.
- A reference missing from `bib.bib` is never added to this project: note its
  DOI under "Missing references" in `.setup/ai/plan.md` and ask the user. It
  goes into the right `lib-*` repository first (`LibAdd()`), then into this
  project with `make bibrproject` after the user publishes it.
- When the user works on the text, check the citations against the `lib-*`
  library and point out gaps: recent or key works the library lacks (found
  with Undermind, Consensus, or PubMed, never from memory).

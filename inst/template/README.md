# Template files (`rProject::Template()`)

- `manifest.tsv`: one row per file: `set`, `tier` (1: Overleaf link,
  checked only; 2: written by make), and the path in the project.
- `<set>/`: the files of each set at their project paths. A path
  component `.x` is stored as `dot-x` (hidden files in `inst/` give an
  R CMD check note).
- Sets per type: see `.TemplateSets()`.
- Sources. Tier 2: these files (edit them here). Tier 1 that rProject
  uses itself (`common`, `package`, `cran`): rProject's own copy, which
  the projects link to; `make project` in rProject copies it here.
  Tier 1 of the other sets: these files, which the projects link to.
- The apa7 class is not a template: manuscripts use the copy in the TeX
  distribution (CTAN; TinyTeX-2 in `docs.sif`, TeX Live in Overleaf).

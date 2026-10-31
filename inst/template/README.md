# Template files (`rProject::Template()`)

- `manifest.tsv`: one row per file: `set`, `tier` (1: Overleaf link,
  checked only; 2: written by make), and the path in the project.
- `<set>/`: the files of each set at their project paths. A path
  component `.x` is stored as `dot-x` (hidden files in `inst/` give an
  R CMD check note).
- Sets per type: see `.TemplateSets()`. `rproject` holds rProject's own
  files (its extra workflows).
- `workflows/`: the workflow catalog. A project names the ones it runs in
  `project.R` (`workflows <- c(...)`). A workflow with `{{title}}` is the
  daily docker build: written as `<name>-<workflow_daily>.yml`; `{{title}}`
  from `workflow_title`, `{{schedule}}` from `workflow_cron` (none when
  empty), and `{{next}}`, a step that starts the next image's build, from
  `workflow_next` (one or more images; none when empty). A line that holds only an empty
  placeholder is dropped.
- `folders.tsv`: the standard folders (`folder`, `types`, `private`,
  `create`, `writer`, `reader`, `purpose`). `Template()` creates the
  folders marked `create` (an empty `.gitignore`); `AI()` writes the
  AGENTS.md folder map from it; `make tree` and the vignette show it;
  the public export check reads the private ones.
- `removed.tsv`: files that left the template (`path`, `since`; a path
  may be a glob, a folder ends in `/`). `Template()` deletes them.
- Sources. Tier 2: these files (edit them here). Tier 1 that rProject
  uses itself (`common`, `package`, `cran`): rProject's own copy, which
  the projects link to; `make project` in rProject copies it here.
  Tier 1 of the other sets: these files, which the projects link to.
- Overleaf. A project's Overleaf holds, as regular files (uploaded),
  what it needs to compile its documents and to run `make`: the tier 1
  files, `latexmkrc`, the `Makefile` (`make` needs it to run at all), the
  `.gitignore` files (a fresh clone keeps its export rules), and
  `project.Rproj` (`knitr.R` finds the root by it). `make` writes
  everything else, which is not in Overleaf. `Template()` names the kept
  files it writes, for upload; when rProject changes one, the agent names
  the affected projects and gives an upload folder for each. The only
  links: `.setup/r-dependencies/*` (from the functions project) and
  `bib.bib`.
- The apa7 class is not a template: manuscripts use the copy in the TeX
  distribution (CTAN; TinyTeX-2 in `docs.sif`, TeX Live in Overleaf).

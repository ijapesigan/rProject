# Changelog

## rProject 0.0.53

### Minor

- [`Template()`](https://github.com/ijapesigan/rProject/reference/Template.md)
  (new; `make template`, and `make project` runs it) writes the template
  files of the project’s type from rProject’s `inst/template/`, so a
  template change reaches a project with `make` and no Overleaf refresh.
  The type is a new line in `.setup/scripts/project.R`
  (`type <- "cran"`; one of `"rProject"`, `"cran"`, `"man"`, `"lib"`,
  `"talk"`, `"docker"`). Tier 2 files (workflows, scripts, …) are
  written when missing or different, and an overwritten file is named.
  Tier 1 files (`Makefile`, `latexmkrc`, the LaTeX preamble, …) stay
  Overleaf links:
  [`Template()`](https://github.com/ijapesigan/rProject/reference/Template.md)
  lists the ones that differ as links to refresh. `check = TRUE` writes
  nothing. Nothing is written in GitHub Actions.
  `inst/template/manifest.tsv` lists the files;
  `inst/template/README.md` explains the layout and the sources. The
  apa7 class is not a template: manuscripts use the copy in the TeX
  distribution (CTAN), and the man projects drop their
  `.setup/latex/apa7/` during the rollout.
- `make project` writes the template files first when
  `.setup/scripts/make-project.R` is missing (a fresh copy from
  Overleaf), using the image’s rProject.
- [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  skips the tier 2 template files of the project’s type: they are
  written by make and are not uploaded.
- [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md) reads
  the project type from the `type` line in `project.R` when it is
  present.
- [`AIGlobal()`](https://github.com/ijapesigan/rProject/reference/AIGlobal.md)
  merges `claude-settings.json` into an existing
  `~/.claude/settings.json`: its keys win, permission rules are added to
  the existing ones, and other keys (e.g., an MCP allow, `autoMode`) are
  kept. Before, it replaced the file.
- Docker, lib, and manuscript templates now live in rProject
  (`inst/template/docker`, `lib`, `man`).
- rProject’s `make bib` (so `make all`) rebuilds `bib.bib` from the
  public `lib-*` repositories (`Bib(bib_lib = TRUE)`; the Makefile
  checks `type <- "rProject"` in `project.R`); other projects are
  unchanged. If no repository can be cloned (e.g., offline), the
  previous `bib.bib` is kept, with a warning.

### Patch

- [`BibLib()`](https://github.com/ijapesigan/rProject/reference/BibLib.md)
  clones without the user’s git config (`GIT_CONFIG_GLOBAL=/dev/null`; a
  config that rewrites https to ssh made the clones hang in the
  container), never prompts, clones shallow and quietly, and copies only
  the `lib-*.bib` entries (before, a clone’s own `quarto.bib` was left
  in `.setup/latex/bib/`). The `bib` target sets the same git
  environment, so it also works with an older installed rProject.

## rProject 0.0.52

### Patch

- `.github/workflows/check-full.yml`: the R-CMD-check-full matrix drops
  `windows-latest (3.6)` (below the minimum R of the template’s
  packages) and `windows-latest (oldrel-4)` (r-lib/actions dropped it
  too; RcppArmadillo code fails to link there), adds
  `windows-latest (oldrel-1)` (CRAN’s r-oldrel-windows flavor), and
  replaces `ubuntu-22.04-arm` with `ubuntu-26.04-arm` (devel and
  release). The job sets `PKG_INCLUDE_LINKINGTO: true`, so pak builds
  packages such as glmnet from source with their `LinkingTo`
  dependencies. `use-public-rspm: true` is removed; it is the default in
  `r-lib/actions/setup-r@v2`.

## rProject 0.0.51

### Minor

- `.setup/scripts/build-docs.sh` runs detached (`setsid nohup`, so it
  survives an SSH disconnect or the end of the agent’s session) and
  writes a status file next to its log (`running <pid> <host> <start>`,
  then `done` or `STOPPED: <reason>`, also when it is killed). It
  refuses to start while another run is running. `--images-only` builds
  `docs.sif` and `docs-plus.sif` alone, without a push. It checks
  rProject in both images with `Rscript --vanilla` from `/` (a project
  `.Rprofile` could hide it) and stops before the rename on a version
  mismatch.
- Global instructions: “build docs” and “build docs only” start the
  script detached and watch its status file; a new keyword, “build sif”
  (`--images-only`).
- `.setup/scripts/o2g-watch.sh` (rProject only, run on the host): after
  an upload folder, the agent watches the private repository
  (`git ls-remote` every 60 seconds, up to 8 hours) and verifies and
  records the push when a commit with the expected first line lands,
  without the user’s “O2G” (global instructions).

### Patch

- [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  reads only the file list of the pushed commit: the log section with a
  code block that starts with the commit’s first line (the top-level
  lists for the log’s own commit message; the lists inside a later
  push’s `##` section, none for a push of records only). Before, it read
  every list in the log, so a later push in the same log failed “Listed
  files” on files of an earlier list that had changed since. If no block
  matches, every list is used, as before.

## rProject 0.0.50

### Minor

- `.setup/scripts/build-docs.sh` (rProject only, run on the host):
  “build docs” publishes the docker images in the order of
  `.setup/scripts/build-docs.txt` (the steps of `make auto` in a fresh
  download of each private repository; it waits for Make Project and
  “Docker Build and Push \[multi\]” before the next, retries failed
  multi jobs once, and stops at the first failure), then builds
  `docs.sif` and `docs-plus.sif` with docker-docs’ `run-def.sh` on one
  core into a staging folder and replaces an image only if it is not in
  use. `--only docker-docs` is “build docs only”; `DRY_RUN=1` pushes
  nothing. It first checks that the public rProject has the version in
  `DESCRIPTION`.
- Global instructions: the “build docs” and “build docs only” keywords.

## rProject 0.0.49

### Minor

- [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md)
  creates `.setup/todo/` (`todo.txt`, the user’s to-do list, and a
  `.gitignore` that keeps the folder private) if and only if the folder
  does not exist, and the project’s `AGENTS.md` lists it in the folder
  map. Agents read `todo.txt` when planning and never edit it (global
  instructions).
- [`Public()`](https://github.com/ijapesigan/rProject/reference/Public.md)
  and
  [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  treat `.setup/todo/` as private: the public export fails if it is
  published.
  [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  does not count changes under `.setup/todo/` as unlisted (the user
  edits the list on Overleaf at any time).
- Global instructions (`.setup/ai/global/AGENTS.md`): how agents use
  `.setup/todo/todo.txt`; `.setup/todo/` among the private folders. The
  root `.gitignore` lists `.setup/todo/`.

## rProject 0.0.48

### Patch

- [`LibFormat()`](https://github.com/ijapesigan/rProject/reference/LibFormat.md)
  keeps entry types it does not list (a type outside its list became
  `@NA`) and knows `@Collection`.
  [`LibCheck()`](https://github.com/ijapesigan/rProject/reference/LibCheck.md)
  accepts `@Collection` (an edited volume; requires `editor`, `date`,
  `title`, `publisher`) in book libraries.
- [`Bib()`](https://github.com/ijapesigan/rProject/reference/Bib.md):
  without source `.bib` files, the existing `.setup/latex/bib/bib.bib`
  is copied to `vignettes/vignettes.bib` and
  `.setup/quarto/bib/quarto.bib`. A clone of the private repository has
  only `bib.bib` (`vignettes.bib` is gitignored), so
  [`Site()`](https://github.com/ijapesigan/rProject/reference/Site.md)
  could not rebuild `vignettes.bib` and pkgdown failed with “File
  ‘vignettes.bib’ not found”.

## rProject 0.0.47

### Patch

- [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md):
  `.Rbuildignore` ignores the root `latexmkrc` (Overleaf’s copy, kept in
  every Overleaf project). Built from an Overleaf clone, `R CMD check`
  noted “Non-standard file/directory found at top level: ‘latexmkrc’”.
  The package copy, `inst/latexmk/latexmkrc`, is still shipped.

## rProject 0.0.46

### Minor

- [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md): a
  new project type, `"cran"`, for `cran-*` folders (R packages on CRAN
  or headed there; their `project.R` names the package). They get the
  package and the new CRAN section (`R CMD check --as-cran` clean,
  version and NEWS for every change,
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) only, the user
  submits).
- [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md): a
  project is a simulation when `.sim/README.md` (which describes the
  simulation) exists; `.sim/` alone (the template’s `make.sh`) is not
  one. rProject and plain packages were labelled “simulation”.
- [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md):
  `.setup/notes/claude.txt` (the resume commands, which the agent keeps
  current when the user leaves) is not counted as an unlisted change.
- `make-project.R` (linked into every project): installs rProject alone
  into `.library`, with the dependencies from the image; in GitHub
  Actions, with its dependencies.

## rProject 0.0.45

### Patch

- `.LibLatex()` (used by
  [`LibAdd()`](https://github.com/ijapesigan/rProject/reference/LibAdd.md))
  keeps its character map as a two-column matrix instead of a named
  vector. Names become symbols, which R without a UTF-8 locale (R 3.6
  and R 4.1 on Windows) could not translate: `R CMD check` warned, and
  the accents were left unconverted.

## rProject 0.0.44

### Patch

- [`LibCheck()`](https://github.com/ijapesigan/rProject/reference/LibCheck.md)
  no longer reports a layout difference for an entry checked out with
  CRLF line endings (Windows);
  [`LibFormat()`](https://github.com/ijapesigan/rProject/reference/LibFormat.md)
  and
  [`LibAdd()`](https://github.com/ijapesigan/rProject/reference/LibAdd.md)
  write LF line endings on every platform. This fixes the
  `test-rProject-lib.R` failure on the Windows R CMD check jobs.

## rProject 0.0.43

### Minor

- [`Bib()`](https://github.com/ijapesigan/rProject/reference/Bib.md)
  joins the `.bib` files into `bib.bib` verbatim and no longer rewrites
  them with RefManageR (which turned `{\'e}` into `{\a'e}`, reordered
  fields, and silently dropped entries it could not read). RefManageR is
  no longer imported; `jsonlite` is (for Crossref).
- New
  [`LibCheck()`](https://github.com/ijapesigan/rProject/reference/LibCheck.md)
  (and `make libcheck`): checks a `lib-*` library’s entries (one per
  file, file name, key and `-etal` rule, year and decade, entry type,
  required fields, ASCII, unescaped `%`, keys and DOIs used twice across
  repositories, lone suffixes, biber’s datamodel, house layout).
  `make lint` runs it in `lib-*` projects.
- New
  [`LibFormat()`](https://github.com/ijapesigan/rProject/reference/LibFormat.md)
  (and `make libformat`): puts every entry in the house layout and field
  order, with `{\'e}` accents, `--` page ranges, and bare DOIs, without
  changing what the entries say.
- New
  [`LibAdd()`](https://github.com/ijapesigan/rProject/reference/LibAdd.md):
  drafts an entry from a DOI’s Crossref record (issue date, LaTeX
  accents, key, repository, abstract, the library’s ISSN and publisher
  for the journal) and lists what it cannot decide.
- [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md): the
  library section states the conventions; the manuscript section says to
  check citations against the `lib-*` library and to add missing
  references there first.

## rProject 0.0.42

### Minor

- `.setup/repo/` records where a project lives: `private-github.md`,
  `private-overleaf.md` (the project URL, never a share link), and
  `public-github.md` (`owner/repo`, or `none`).
  [`Project()`](https://github.com/ijapesigan/rProject/reference/Project.md)
  creates it when it is missing, with the two GitHub repositories filled
  in.
- `verify.sh` clones the private repository named in
  `.setup/repo/private-github.md` (needed when `project.R` and the
  repository name differ, as in the docker projects).
- [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  checks `.setup/repo/` (“Repo info”): an Overleaf share link fails; a
  missing file, or a repository that differs from the `.verify` remote
  or from `clone.sh`, warns.
- `Verify(record = TRUE)` records a fix-up push without a pending row:
  it finds the log from the commit message (`Log: .setup/logs/<log>`)
  and adds rows to the log and to `index.md`.
- [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md)
  writes the three locations into `AGENTS.md`, and has a `"container"`
  type for `docker-*` projects (`inst/ai/section-container.md`).
- [`Public()`](https://github.com/ijapesigan/rProject/reference/Public.md)
  and
  [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  treat `.setup/repo/` as private, and
  [`Public()`](https://github.com/ijapesigan/rProject/reference/Public.md)
  applies `.gitignore` outside a git repository (for example, a folder
  downloaded from Overleaf).
- [`Log()`](https://github.com/ijapesigan/rProject/reference/Log.md)
  lists the files to delete in Overleaf (in the private repository but
  not in the project), and names the
  [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md) files
  as generated.

### Patch

- [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  and
  [`Style()`](https://github.com/ijapesigan/rProject/reference/Style.md)
  skip `.verify/`;
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  resolves its exclusions relative to the project and no longer hides
  errors with [`try()`](https://rdrr.io/r/base/try.html).
- `.DataManifestUsedBy()` keeps the `.setup/data-analysis/` and
  `.setup/data-process/` scripts.
- `make-project.R` upgrades rProject in the rProject project too (it
  only installed it when missing, so `.library` kept an old version).

## rProject 0.0.41

### Patch

- [`CFF()`](https://github.com/ijapesigan/rProject/reference/CFF.md)
  works from any working directory: it passes cffr the project’s
  `DESCRIPTION` file and writes `CITATION.cff` into the project folder.

## rProject 0.0.40

### Patch

- Paths and shell calls work across platforms, and with spaces in paths:
  - [`Profile()`](https://github.com/ijapesigan/rProject/reference/Profile.md)
    writes the library path with
    [`deparse()`](https://rdrr.io/r/base/deparse.html), and
    [`Environment()`](https://github.com/ijapesigan/rProject/reference/Environment.md)
    writes paths with forward slashes.
  - [`DataManifest()`](https://github.com/ijapesigan/rProject/reference/DataManifest.md)
    makes paths relative by prefix, not by a regular expression built
    from the path.
  - Shell commands go through
    [`system2()`](https://rdrr.io/r/base/system2.html), with each path
    quoted for the platform’s shell:
    [`LatexCompile()`](https://github.com/ijapesigan/rProject/reference/LatexCompile.md)
    and
    [`LatexTikzCompile()`](https://github.com/ijapesigan/rProject/reference/LatexTikzCompile.md)
    pass the `.tex` files to latexmk explicitly (no shell glob);
    [`Style()`](https://github.com/ijapesigan/rProject/reference/Style.md)
    finds the C++ files in R (no `find`);
    [`BibLib()`](https://github.com/ijapesigan/rProject/reference/BibLib.md)
    clones into the bib folder without changing the working directory;
    plus
    [`Manual()`](https://github.com/ijapesigan/rProject/reference/Manual.md),
    [`InstallLocal()`](https://github.com/ijapesigan/rProject/reference/InstallLocal.md),
    [`ConfigFiles()`](https://github.com/ijapesigan/rProject/reference/ConfigFiles.md)
    (`make -C`),
    [`Public()`](https://github.com/ijapesigan/rProject/reference/Public.md),
    and
    [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md).
  - New internal helpers: `.PathSlash()` and `.ShellQuote()`.
- Tests pass on the plain GitHub runners (ubuntu, macOS, Windows) and
  under covr. Tests of functions that need the container layout
  ([`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md),
  [`Style()`](https://github.com/ijapesigan/rProject/reference/Style.md),
  [`PkgProjectVersion()`](https://github.com/ijapesigan/rProject/reference/PkgProjectVersion.md))
  skip when their packages are not in the site library. Tests of
  Unix-only behavior (file modes, `clang-format`,
  [`CleanPkg()`](https://github.com/ijapesigan/rProject/reference/CleanPkg.md))
  skip on Windows, as do
  [`Public()`](https://github.com/ijapesigan/rProject/reference/Public.md)
  and
  [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  until a Windows run confirms them. Tests now use paths with spaces.
- `inst/shell/install-*.sh`: a ShellCheck directive for the sourced
  `install-common.sh` (SC1091).

## rProject 0.0.39

### Patch

- Unit tests for every exported function. Slow tests (installers,
  network, full LaTeX and Quarto builds) run only with
  `RPROJECT_SLOW_TESTS=true`. Functions that change the machine
  ([`TinyTex()`](https://github.com/ijapesigan/rProject/reference/TinyTex.md),
  [`CleanTinyTex()`](https://github.com/ijapesigan/rProject/reference/CleanTinyTex.md),
  [`PkgDevel()`](https://github.com/ijapesigan/rProject/reference/PkgDevel.md),
  [`PkgDevelGitHub()`](https://github.com/ijapesigan/rProject/reference/PkgDevelGitHub.md))
  are checked for their interface only.
  [`CleanPkg()`](https://github.com/ijapesigan/rProject/reference/CleanPkg.md)
  is tested in a separate R process whose library paths are temporary.
- [`CleanProj()`](https://github.com/ijapesigan/rProject/reference/CleanProj.md)
  keeps `.sim` and `.sif` unless `sim = TRUE` or `sif = TRUE`, as
  documented. It used to delete them.
- The package ships `inst/latexmk/latexmkrc` again (Overleaf’s latexmk
  configuration), so
  [`LatexCompile()`](https://github.com/ijapesigan/rProject/reference/LatexCompile.md)
  and
  [`LatexTikzCompile()`](https://github.com/ijapesigan/rProject/reference/LatexTikzCompile.md)
  use the same latexmk rules on GitHub Actions and locally as on
  Overleaf. `.gitignore` now ignores only the root `latexmkrc`, and
  [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  compares `inst/latexmk/latexmkrc`.
- The
  [`Clean()`](https://github.com/ijapesigan/rProject/reference/Clean.md)
  documentation says that `push = TRUE` does not delete `*secrets*`
  files in hidden folders such as `.setup`.

## rProject 0.0.38

### Patch

- The user chooses the Apptainer image and runs
  `apptainer exec <image>`.
  [`Log()`](https://github.com/ijapesigan/rProject/reference/Log.md)
  records the image that actually ran (its name, build date, and base
  digest, from the container’s labels) under “Make commands run”.
- The project instructions
  ([`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md))
  tell agents not to pick an image; `.setup/ai/project.md` has a line
  for the image a project usually uses.
- [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md) no
  longer takes `sif`.
- [`SizeCheck()`](https://github.com/ijapesigan/rProject/reference/SizeCheck.md)
  and
  [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  skip `.sif/`.

## rProject 0.0.37

### Patch

- Added `inst/shell/install.sh` to install or update the machine tools
  into `~/.local` on Linux (Apptainer, Claude Code, Codex, Copilot,
  Gemini, herdr, gh): `bash install.sh machine`, or name the tools;
  `--list` shows versions. Each tool keeps its previous version if the
  new one fails.
- Added
  `inst/shell/install-{apptainer,claude,codex,copilot,gemini,herdr}.sh`
  and `install-common.sh`. `install-gh.sh` now installs the prebuilt
  release, checked against its SHA-256 checksums. `install-gemini.sh`
  links `node` into `~/.local/bin`, so Gemini works without nvm being
  loaded.

## rProject 0.0.36

### Patch

- `make verify RECORD=TRUE` (run as
  `apptainer exec <sif> make verify RECORD=TRUE`) pulls the private
  repository into `.verify` and checks the push.
  `.setup/scripts/verify.sh` only pulls (git; no R, no Apptainer).
- [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  has a new check, “New commit”, which fails, and records nothing, when
  the commit is already in `.setup/logs/index.md` (a stale `.verify` or
  no new push).
- Makefile targets never call Apptainer; `make auto` and `make public`
  call `Rscript`.

## rProject 0.0.35

### Patch

- Data tiers: `.setup/data-raw` (shareable), `.setup/data-private`
  (restricted; never public), `.setup/data-external` (local only), and
  `.setup/data-cache` (local only).
- Added the
  [`DataPath()`](https://github.com/ijapesigan/rProject/reference/DataPath.md)
  function to find a data file by its plain name in the tiers, stored as
  is or compressed (`.xz`, `.gz`); `plain = TRUE` returns an
  uncompressed copy for tools such as Mplus.
- Added the
  [`DataCompress()`](https://github.com/ijapesigan/rProject/reference/DataCompress.md)
  function to compress data files with xz, so they do not count as
  editable text in Overleaf.
- Added the
  [`DataManifest()`](https://github.com/ijapesigan/rProject/reference/DataManifest.md)
  function and the `make manifest` target to write `.setup/ai/data.md`
  (private): tier, size, MD5, status, source, location, and the scripts
  that use each file.

## rProject 0.0.34

### Patch

- Added the
  [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md)
  function and the `make ai` target.
  [`AI()`](https://github.com/ijapesigan/rProject/reference/AI.md)
  writes the project’s AI instructions (`AGENTS.md`, `CLAUDE.md`,
  `.github/copilot-instructions.md`) from templates in `inst/ai`, and
  creates `.setup/ai/project.md` for project facts once. Project types
  are detected (package, manuscript, simulation, library, talk) or set
  with an `ai` list in `.setup/scripts/project.R`. `make project` runs
  it.
- `make project` upgrades rProject in other projects when GitHub has a
  newer commit (a pinned `rproject_ver` is still honored).
- [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  and [`Log()`](https://github.com/ijapesigan/rProject/reference/Log.md)
  treat the generated AI instruction files as generated.

## rProject 0.0.33

### Patch

- Added the
  [`SizeCheck()`](https://github.com/ijapesigan/rProject/reference/SizeCheck.md)
  function and the `make sizecheck` target to check a project against
  Overleaf’s limits (editable text, file sizes, number of files, total
  size, duplicates). `make lint` reports it.
- Added the
  [`Public()`](https://github.com/ijapesigan/rProject/reference/Public.md)
  function and the `make public` target. `make auto` calls
  [`Public()`](https://github.com/ijapesigan/rProject/reference/Public.md)
  before `git add`, so private files, files over 50 MB, and tokens are
  never published.

## rProject 0.0.32

### Patch

- Added the
  [`Spec()`](https://github.com/ijapesigan/rProject/reference/Spec.md)
  and [`Log()`](https://github.com/ijapesigan/rProject/reference/Log.md)
  functions and the `make spec` and `make log` targets.
  [`Log()`](https://github.com/ijapesigan/rProject/reference/Log.md)
  writes the change-set log, adds a pending row to
  `.setup/logs/index.md`, and lists the files to update in Overleaf by
  comparing the project with the private repository.
- `.setup/scripts/verify.sh` keeps the clone of the private repository
  in `.verify` (local only), so `make verify` and `make log` work inside
  the container.
- [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  ignores the generated `Config/roxygen2/version` line in `DESCRIPTION`.

## rProject 0.0.31

### Patch

- Added the
  [`Verify()`](https://github.com/ijapesigan/rProject/reference/Verify.md)
  function, the `make verify` target, and `.setup/scripts/verify.sh` to
  check an Overleaf push against its change-set log: listed files,
  deletions, unlisted changes, the commit message, secrets, and the
  public export. With `record = TRUE`, the result is written to the log
  and `.setup/logs/index.md`.

## rProject 0.0.30

### Patch

- [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md)
  excludes AI tool files from package builds: `.claude`, `CLAUDE.md`,
  `CLAUDE.local.md`, `.mcp.json`, `AGENTS.md`, `.codex`, `GEMINI.md`,
  and `.gemini`.

## rProject 0.0.29

### Patch

- [`AIGlobal()`](https://github.com/ijapesigan/rProject/reference/AIGlobal.md)
  installs the GitHub Copilot instructions to
  `~/.copilot/copilot-instructions.md`, which Copilot loads in every
  session. `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` is no longer needed.

## rProject 0.0.28

### Patch

- [`ConfigFiles()`](https://github.com/ijapesigan/rProject/reference/ConfigFiles.md)
  no longer takes `git_user`. It clones `repo` (default
  `ijapesigan/dotfiles`) anonymously over HTTPS, ignoring Git URL
  rewrites, so `make dotfiles` works inside containers. It stops with an
  error when the clone or `make` fails.

## rProject 0.0.27

### Patch

- Added the
  [`AIGlobal()`](https://github.com/ijapesigan/rProject/reference/AIGlobal.md)
  function and the `make aiglobal` target to install global AI
  instructions for Claude Code, Codex, and GitHub Copilot.

## rProject 0.0.26

### Patch

- Secrets are read from the local machine (`$RPROJECT_SECRETS`,
  `~/.config/rproject/<project>.R`, or `~/.config/rproject/secrets.R`)
  in `.setup/scripts/make-project.R`. `.setup/scripts/secrets.R` is only
  used as a fallback, with a warning.
- [`Environment()`](https://github.com/ijapesigan/rProject/reference/Environment.md)
  sets the permissions of `.Renviron` to `600`.
- Added the
  [`SecretScan()`](https://github.com/ijapesigan/rProject/reference/SecretScan.md)
  function and the `make secretscan` target.

## rProject 0.0.25

### Patch

- Changed year from 2025 to 2026 in MIT license.

## rProject 0.0.24

### Patch

- Address
  [`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)
  deprecation by using
  [`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html).

## rProject 0.0.23

### Patch

- Edits to the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.22

### Patch

- Added the
  [`PkgProjectBioconductor()`](https://github.com/ijapesigan/rProject/reference/PkgProjectBioconductor.md)
  function.

## rProject 0.0.21

### Patch

- Specific `rProject` GitHub commit can be installed via the
  `rproject_ver` object in `.setup/scripts/project.R`.

## rProject 0.0.20

### Patch

- Updated MIT license year to 2025.

## rProject 0.0.19

### Patch

- The
  [`PkgProjectGitHub()`](https://github.com/ijapesigan/rProject/reference/PkgProjectGitHub.md)
  function gives priority to installing packages that contain the `@`
  character in their specification.
- The
  [`PkgProjectVersion()`](https://github.com/ijapesigan/rProject/reference/PkgProjectVersion.md)
  function installs the available package first before checking its
  version.

## rProject 0.0.18

### Patch

- Added `.quarto` in the
  [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md)
  function.

## rProject 0.0.17

### Patch

- Revised the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.16

### Patch

- Added `tests` in exclusions in the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.15

### Patch

- Added `nolint.R` in exclusions in the
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md)
  function.

## rProject 0.0.14

### Patch

- Added `lib-2000-2009-manual` in
  [`BibLib()`](https://github.com/ijapesigan/rProject/reference/BibLib.md).

## rProject 0.0.13

### Patch

- Added `.sif` to
  [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md).

## rProject 0.0.12

### Patch

- Option to NOT delete `.sim` and `.sif` in
  [`CleanProj()`](https://github.com/ijapesigan/rProject/reference/CleanProj.md).

## rProject 0.0.11

### Patch

- Install `rhub` from CRAN.

## rProject 0.0.10

### Patch

- Added `".*\\.sif$` in
  [`BuildIgnore()`](https://github.com/ijapesigan/rProject/reference/BuildIgnore.md).

## rProject 0.0.9

### Patch

- Added the
  [`LatexTikzCompile()`](https://github.com/ijapesigan/rProject/reference/LatexTikzCompile.md)
  function and
  [`LatexMake()`](https://github.com/ijapesigan/rProject/reference/LatexMake.md)
  calls it before
  [`LatexCompile()`](https://github.com/ijapesigan/rProject/reference/LatexCompile.md).

## rProject 0.0.8

### Patch

- `knit::knit()` uses `envir = new.env()`.

## rProject 0.0.7

### Patch

- Exclude `R/methods.R` from linting in
  [`Lint()`](https://github.com/ijapesigan/rProject/reference/Lint.md).

## rProject 0.0.6

### Patch

- Edits to
  [`Clean()`](https://github.com/ijapesigan/rProject/reference/Clean.md)
  to keep `vignettes.bib` when `push = TRUE`.

## rProject 0.0.5

### Patch

- Option to build `bib.bib` from `lib-*` repositories using
  [`Bib()`](https://github.com/ijapesigan/rProject/reference/Bib.md).

## rProject 0.0.4

### Patch

- Added build tools for `Rcpp()` functions.

## rProject 0.0.3

### Patch

- Added the the function
  [`Bib()`](https://github.com/ijapesigan/rProject/reference/Bib.md) to
  generate `bib.bib` files for LateX, quarto, and vignettes.

## rProject 0.0.2

### Patch

- Added the argumnent `push` to
  [`Clean()`](https://github.com/ijapesigan/rProject/reference/Clean.md)
  for cleaning the directory in preparation for git push.

## rProject 0.0.1

### Patch

- Started version numbers.

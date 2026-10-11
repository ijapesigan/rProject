# Changelog

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

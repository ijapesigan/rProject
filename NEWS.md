# rProject 0.0.46

## Minor

* `AI()`: a new project type, `"cran"`, for `cran-*` folders (R packages on CRAN or headed there; their `project.R` names the package). They get the package and the new CRAN section (`R CMD check --as-cran` clean, version and NEWS for every change, `tempdir()` only, the user submits).
* `AI()`: a project is a simulation when `.sim/README.md` (which describes the simulation) exists; `.sim/` alone (the template's `make.sh`) is not one. rProject and plain packages were labelled "simulation".
* `Verify()`: `.setup/notes/claude.txt` (the resume commands, which the agent keeps current when the user leaves) is not counted as an unlisted change.
* `make-project.R` (linked into every project): installs rProject alone into `.library`, with the dependencies from the image; in GitHub Actions, with its dependencies.

# rProject 0.0.45

## Patch

* `.LibLatex()` (used by `LibAdd()`) keeps its character map as a two-column matrix instead of a named vector. Names become symbols, which R without a UTF-8 locale (R 3.6 and R 4.1 on Windows) could not translate: `R CMD check` warned, and the accents were left unconverted.

# rProject 0.0.44

## Patch

* `LibCheck()` no longer reports a layout difference for an entry checked out with CRLF line endings (Windows); `LibFormat()` and `LibAdd()` write LF line endings on every platform. This fixes the `test-rProject-lib.R` failure on the Windows R CMD check jobs.

# rProject 0.0.43

## Minor

* `Bib()` joins the `.bib` files into `bib.bib` verbatim and no longer rewrites them with RefManageR (which turned `{\'e}` into `{\a'e}`, reordered fields, and silently dropped entries it could not read). RefManageR is no longer imported; `jsonlite` is (for Crossref).
* New `LibCheck()` (and `make libcheck`): checks a `lib-*` library's entries (one per file, file name, key and `-etal` rule, year and decade, entry type, required fields, ASCII, unescaped `%`, keys and DOIs used twice across repositories, lone suffixes, biber's datamodel, house layout). `make lint` runs it in `lib-*` projects.
* New `LibFormat()` (and `make libformat`): puts every entry in the house layout and field order, with `{\'e}` accents, `--` page ranges, and bare DOIs, without changing what the entries say.
* New `LibAdd()`: drafts an entry from a DOI's Crossref record (issue date, LaTeX accents, key, repository, abstract, the library's ISSN and publisher for the journal) and lists what it cannot decide.
* `AI()`: the library section states the conventions; the manuscript section says to check citations against the `lib-*` library and to add missing references there first.

# rProject 0.0.42

## Minor

* `.setup/repo/` records where a project lives: `private-github.md`, `private-overleaf.md` (the project URL, never a share link), and `public-github.md` (`owner/repo`, or `none`). `Project()` creates it when it is missing, with the two GitHub repositories filled in.
* `verify.sh` clones the private repository named in `.setup/repo/private-github.md` (needed when `project.R` and the repository name differ, as in the docker projects).
* `Verify()` checks `.setup/repo/` ("Repo info"): an Overleaf share link fails; a missing file, or a repository that differs from the `.verify` remote or from `clone.sh`, warns.
* `Verify(record = TRUE)` records a fix-up push without a pending row: it finds the log from the commit message (`Log: .setup/logs/<log>`) and adds rows to the log and to `index.md`.
* `AI()` writes the three locations into `AGENTS.md`, and has a `"container"` type for `docker-*` projects (`inst/ai/section-container.md`).
* `Public()` and `Verify()` treat `.setup/repo/` as private, and `Public()` applies `.gitignore` outside a git repository (for example, a folder downloaded from Overleaf).
* `Log()` lists the files to delete in Overleaf (in the private repository but not in the project), and names the `AI()` files as generated.

## Patch

* `Lint()` and `Style()` skip `.verify/`; `Lint()` resolves its exclusions relative to the project and no longer hides errors with `try()`.
* `.DataManifestUsedBy()` keeps the `.setup/data-analysis/` and `.setup/data-process/` scripts.
* `make-project.R` upgrades rProject in the rProject project too (it only installed it when missing, so `.library` kept an old version).

# rProject 0.0.41

## Patch

* `CFF()` works from any working directory: it passes cffr the project's `DESCRIPTION` file and writes `CITATION.cff` into the project folder.

# rProject 0.0.40

## Patch

* Paths and shell calls work across platforms, and with spaces in paths:
  * `Profile()` writes the library path with `deparse()`, and `Environment()` writes paths with forward slashes.
  * `DataManifest()` makes paths relative by prefix, not by a regular expression built from the path.
  * Shell commands go through `system2()`, with each path quoted for the platform's shell: `LatexCompile()` and `LatexTikzCompile()` pass the `.tex` files to latexmk explicitly (no shell glob); `Style()` finds the C++ files in R (no `find`); `BibLib()` clones into the bib folder without changing the working directory; plus `Manual()`, `InstallLocal()`, `ConfigFiles()` (`make -C`), `Public()`, and `Verify()`.
  * New internal helpers: `.PathSlash()` and `.ShellQuote()`.
* Tests pass on the plain GitHub runners (ubuntu, macOS, Windows) and under covr. Tests of functions that need the container layout (`Lint()`, `Style()`, `PkgProjectVersion()`) skip when their packages are not in the site library. Tests of Unix-only behavior (file modes, `clang-format`, `CleanPkg()`) skip on Windows, as do `Public()` and `Verify()` until a Windows run confirms them. Tests now use paths with spaces.
* `inst/shell/install-*.sh`: a ShellCheck directive for the sourced `install-common.sh` (SC1091).

# rProject 0.0.39

## Patch

* Unit tests for every exported function. Slow tests (installers, network, full LaTeX and Quarto builds) run only with `RPROJECT_SLOW_TESTS=true`. Functions that change the machine (`TinyTex()`, `CleanTinyTex()`, `PkgDevel()`, `PkgDevelGitHub()`) are checked for their interface only. `CleanPkg()` is tested in a separate R process whose library paths are temporary.
* `CleanProj()` keeps `.sim` and `.sif` unless `sim = TRUE` or `sif = TRUE`, as documented. It used to delete them.
* The package ships `inst/latexmk/latexmkrc` again (Overleaf's latexmk configuration), so `LatexCompile()` and `LatexTikzCompile()` use the same latexmk rules on GitHub Actions and locally as on Overleaf. `.gitignore` now ignores only the root `latexmkrc`, and `Verify()` compares `inst/latexmk/latexmkrc`.
* The `Clean()` documentation says that `push = TRUE` does not delete `*secrets*` files in hidden folders such as `.setup`.

# rProject 0.0.38

## Patch

* The user chooses the Apptainer image and runs `apptainer exec <image>`. `Log()` records the image that actually ran (its name, build date, and base digest, from the container's labels) under "Make commands run".
* The project instructions (`AI()`) tell agents not to pick an image; `.setup/ai/project.md` has a line for the image a project usually uses.
* `AI()` no longer takes `sif`.
* `SizeCheck()` and `Verify()` skip `.sif/`.

# rProject 0.0.37

## Patch

* Added `inst/shell/install.sh` to install or update the machine tools into `~/.local` on Linux (Apptainer, Claude Code, Codex, Copilot, Gemini, herdr, gh): `bash install.sh machine`, or name the tools; `--list` shows versions. Each tool keeps its previous version if the new one fails.
* Added `inst/shell/install-{apptainer,claude,codex,copilot,gemini,herdr}.sh` and `install-common.sh`. `install-gh.sh` now installs the prebuilt release, checked against its SHA-256 checksums. `install-gemini.sh` links `node` into `~/.local/bin`, so Gemini works without nvm being loaded.

# rProject 0.0.36

## Patch

* `make verify RECORD=TRUE` (run as `apptainer exec <sif> make verify RECORD=TRUE`) pulls the private repository into `.verify` and checks the push. `.setup/scripts/verify.sh` only pulls (git; no R, no Apptainer).
* `Verify()` has a new check, "New commit", which fails, and records nothing, when the commit is already in `.setup/logs/index.md` (a stale `.verify` or no new push).
* Makefile targets never call Apptainer; `make auto` and `make public` call `Rscript`.

# rProject 0.0.35

## Patch

* Data tiers: `.setup/data-raw` (shareable), `.setup/data-private` (restricted; never public), `.setup/data-external` (local only), and `.setup/data-cache` (local only).
* Added the `DataPath()` function to find a data file by its plain name in the tiers, stored as is or compressed (`.xz`, `.gz`); `plain = TRUE` returns an uncompressed copy for tools such as Mplus.
* Added the `DataCompress()` function to compress data files with xz, so they do not count as editable text in Overleaf.
* Added the `DataManifest()` function and the `make manifest` target to write `.setup/ai/data.md` (private): tier, size, MD5, status, source, location, and the scripts that use each file.

# rProject 0.0.34

## Patch

* Added the `AI()` function and the `make ai` target. `AI()` writes the project's AI instructions (`AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`) from templates in `inst/ai`, and creates `.setup/ai/project.md` for project facts once. Project types are detected (package, manuscript, simulation, library, talk) or set with an `ai` list in `.setup/scripts/project.R`. `make project` runs it.
* `make project` upgrades rProject in other projects when GitHub has a newer commit (a pinned `rproject_ver` is still honored).
* `Verify()` and `Log()` treat the generated AI instruction files as generated.

# rProject 0.0.33

## Patch

* Added the `SizeCheck()` function and the `make sizecheck` target to check a project against Overleaf's limits (editable text, file sizes, number of files, total size, duplicates). `make lint` reports it.
* Added the `Public()` function and the `make public` target. `make auto` calls `Public()` before `git add`, so private files, files over 50 MB, and tokens are never published.

# rProject 0.0.32

## Patch

* Added the `Spec()` and `Log()` functions and the `make spec` and `make log` targets. `Log()` writes the change-set log, adds a pending row to `.setup/logs/index.md`, and lists the files to update in Overleaf by comparing the project with the private repository.
* `.setup/scripts/verify.sh` keeps the clone of the private repository in `.verify` (local only), so `make verify` and `make log` work inside the container.
* `Verify()` ignores the generated `Config/roxygen2/version` line in `DESCRIPTION`.

# rProject 0.0.31

## Patch

* Added the `Verify()` function, the `make verify` target, and `.setup/scripts/verify.sh` to check an Overleaf push against its change-set log: listed files, deletions, unlisted changes, the commit message, secrets, and the public export. With `record = TRUE`, the result is written to the log and `.setup/logs/index.md`.

# rProject 0.0.30

## Patch

* `BuildIgnore()` excludes AI tool files from package builds: `.claude`, `CLAUDE.md`, `CLAUDE.local.md`, `.mcp.json`, `AGENTS.md`, `.codex`, `GEMINI.md`, and `.gemini`.

# rProject 0.0.29

## Patch

* `AIGlobal()` installs the GitHub Copilot instructions to `~/.copilot/copilot-instructions.md`, which Copilot loads in every session. `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` is no longer needed.

# rProject 0.0.28

## Patch

* `ConfigFiles()` no longer takes `git_user`. It clones `repo` (default `ijapesigan/dotfiles`) anonymously over HTTPS, ignoring Git URL rewrites, so `make dotfiles` works inside containers. It stops with an error when the clone or `make` fails.

# rProject 0.0.27

## Patch

* Added the `AIGlobal()` function and the `make aiglobal` target to install global AI instructions for Claude Code, Codex, and GitHub Copilot.

# rProject 0.0.26

## Patch

* Secrets are read from the local machine (`$RPROJECT_SECRETS`, `~/.config/rproject/<project>.R`, or `~/.config/rproject/secrets.R`) in `.setup/scripts/make-project.R`. `.setup/scripts/secrets.R` is only used as a fallback, with a warning.
* `Environment()` sets the permissions of `.Renviron` to `600`.
* Added the `SecretScan()` function and the `make secretscan` target.

# rProject 0.0.25

## Patch

* Changed year from 2025 to 2026 in MIT license.

# rProject 0.0.24

## Patch

* Address `remotes::install_github()` deprecation by using `pak::pkg_install()`.

# rProject 0.0.23

## Patch

* Edits to the `Lint()` function.

# rProject 0.0.22

## Patch

* Added the `PkgProjectBioconductor()` function.

# rProject 0.0.21

## Patch

* Specific `rProject` GitHub commit can be installed via the `rproject_ver` object in `.setup/scripts/project.R`.

# rProject 0.0.20

## Patch

* Updated MIT license year to 2025.

# rProject 0.0.19

## Patch

* The `PkgProjectGitHub()` function gives priority to installing packages that contain the `@` character in their specification.
* The `PkgProjectVersion()` function installs the available package first before checking its version.

# rProject 0.0.18

## Patch

* Added `.quarto` in the `BuildIgnore()` function.

# rProject 0.0.17

## Patch

* Revised the `Lint()` function.

# rProject 0.0.16

## Patch

* Added `tests` in exclusions in the `Lint()` function.

# rProject 0.0.15

## Patch

* Added `nolint.R` in exclusions in the `Lint()` function.

# rProject 0.0.14

## Patch

* Added `lib-2000-2009-manual` in `BibLib()`.

# rProject 0.0.13

## Patch

* Added `.sif` to `BuildIgnore()`.

# rProject 0.0.12

## Patch

* Option to NOT delete `.sim` and `.sif` in `CleanProj()`.

# rProject 0.0.11

## Patch

* Install `rhub` from CRAN.

# rProject 0.0.10

## Patch

* Added `".*\\.sif$` in `BuildIgnore()`.

# rProject 0.0.9

## Patch

* Added the `LatexTikzCompile()` function and `LatexMake()` calls it before `LatexCompile()`.

# rProject 0.0.8

## Patch

* `knit::knit()` uses `envir = new.env()`.

# rProject 0.0.7

## Patch

* Exclude `R/methods.R` from linting in `Lint()`.

# rProject 0.0.6

## Patch

* Edits to `Clean()` to keep `vignettes.bib` when `push = TRUE`.

# rProject 0.0.5

## Patch

* Option to build `bib.bib` from `lib-*` repositories using `Bib()`.

# rProject 0.0.4

## Patch

* Added build tools for `Rcpp()` functions.

# rProject 0.0.3

## Patch

* Added the the function `Bib()` to generate `bib.bib` files for LateX, quarto, and vignettes.

# rProject 0.0.2

## Patch

* Added the argumnent `push` to `Clean()` for cleaning the directory in preparation for git push.

# rProject 0.0.1

## Patch

* Started version numbers.
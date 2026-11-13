# rProject 0.0.69

## Library

- `LibAdd()` takes the abstract from PubMed when Crossref has none (`.LibPubMed()`, `.LibPubMedAbstract()`); the questions name the source (PubMed ID) or say that neither has one.
- New `LibAbstractReport()`: lists the `@Article` entries without an abstract in each `lib-*` project.
- `inst/ai/section-library.md`: every new entry gets an abstract (Crossref, PubMed, publisher page, then ask).

# rProject 0.0.68

## Verify

- `Verify(record = TRUE)` writes the "Pushes" row in the order of the log's own header (`Commit | Date | Result` or `Date | Commit | Result`), fills a pending row wherever `(pending)` sits in it, and replaces the last cell of the index row whatever it holds (it used to fill only an empty cell, so `not pushed` stayed).

## Fix-ups

- New `FixUp()` (`make fixup TOPIC= SUMMARY=`): adds a fix-up section (commit message and file lists), a pending Pushes row, and a pending index row to the topic's log.
- New `Upload()` (`make upload TOPIC= [FIXUP=TRUE]`): builds the upload folder from the log's lists; never overwrites an existing folder.

# rProject 0.0.67

## Templates

- `rhub-1-essential.yml`: the `nosuggests` job no longer rebuilds the vignettes, because that image has no Suggests packages (no rmarkdown).

## Scripts

- `build-docs.sh`, `build-lib.sh`, and `build-rproject.sh` write their details to `<work>/tmp/*.log` and print one summary line; `verify.sh` logs to `<work>/tmp/*-verify.log`.

## AI instructions

- The keyword procedures (`build docs`, `build lib`, `build rProject`, `CI`, `rollout`, `sim status`, `EX`) and the Token tips table moved from `.setup/ai/global/AGENTS.md` to `.setup/ai/global/keywords.md` (16 KB to 12 KB). The handoff is capped at 3 KB.

# rProject 0.0.66

## LaTeX

- `lib-apa` compiles again, with all its entries. A long bibliography fills pdfTeX's high memory, so `LatexCompile()` now sets `extra_mem_top`; `extra_mem_bot`, set since 0.0.57, could not help.
- A failed PDF now fails `make latex` in CI: `LatexMake()` no longer hides the error in `try()`, so a stub PDF is not published.

## Websites

- One GitHub Pages site: pkgdown at the root, Quarto under `/quarto/`. The Quarto Pub workflow is removed (`inst/template/removed.tsv`).
- The `talk` set gains `latex`, `make`, `pkgdown-gh-pages`, and `quarto-gh-pages`.

## Logs and checks

- `Log()` and `Verify()` date a push in the user's time zone (`RPROJECT_TZ`, by default `America/New_York`), not UTC.
- `Log()` lists new files under `.setup/latex/figures/psu/`, leaves out `.setup/todo/`, and no longer proposes deleting `.setup/repo/` files that are only missing locally.
- `o2g-watch.sh`: one failed connection no longer ends the watcher.
- Non-ASCII, shellcheck, and lint findings on the public checks are fixed.

## Style

- The R and Rcpp guides: every function has complete roxygen, unexported functions use `@noRd`, and the rules for helper libraries and their copies. `make lint` does not check this yet.

# rProject 0.0.65

## Tools in `~/work`

- Where `~/work` exists, a symlink or a folder, the tools rProject installs live in `~/work/tools` and are linked from home, so a small home quota holds only the links. `install.sh --move` moves what is installed; `--list` shows where each tool lives. Quarto, tmux, and pfetch stay in `~/.local`.
- New `install.sh cli`: fzf, zoxide, bat, fd, eza, and delta, as static builds, which also run on an old GLIBC.
- New `inst/shell/setup-machine.sh` sets up a machine on the host: the tools, the dotfiles, and `make local`.
- Antigravity (`agy`, the command line tool only) joins the machine tools, with the shell startup files kept as they were. The Gemini CLI leaves: `install-gemini.sh` is gone. To remove it from a machine: `npm uninstall -g --prefix ~/.local @google/gemini-cli`.

## Dotfiles

- rProject builds the dotfiles, from `inst/dotfiles`. `ConfigFiles()` no longer clones `ijapesigan/dotfiles`; its `repo` argument is replaced by `check`. It runs `inst/shell/install-dotfiles.sh`, which needs no R and keeps each file it replaces in `~/.dotfiles-backup`.
- **`make build`, so `make all`, no longer installs the dotfiles**: a package build should not rewrite a shell setup. `make dotfiles` does.
- Fixes: `shell` pointed to a missing image; `exec`, which shadowed the builtin, is now `ax`; the vi cursor settings move to `~/.inputrc`, where they work; fastfetch runs only where it can; Vim's aliases file has its right name; Vim's packages are pinned.
- A short bash prompt with the host, folder, git status, last error, and a marker inside a container. fzf and zoxide are used if present. Longer history. `~/.bash-local` is for one machine's settings.

## Apptainer binds

- Written Apptainer commands and scripts bind `~/work` and, on Roar, `/scratch/ibp5092`. A bare `-B ~/work` fails where `~/work` is a symlink, so the form is `-B ~/work:$(readlink -f ~/work)`. `APPTAINER_BIND` in `~/.bash-variables` covers interactive shells; `apptainer build` must run without it, and `build-docs.sh` removes it.

## Publishing

- New `make release`: `make all`, the secret scan, then `make auto`, stopping at the first failure.
- New `.setup/scripts/build-rproject.sh` and the "build rProject" keyword: publish from a verified private push, with `make all` on a compute node. It refuses a version that is not above the public one, and stops on any error, warning, or note from `R CMD check`.
- `build-docs.sh` builds the images as a Slurm job (`BUILD=host` to override) and runs from a copy of itself.

## README and site

- New `Badges()`: `make readme` writes the badges in every project type: the workflows, from `.github/workflows`, and the DOI, from `inst/CITATION` (not the `10.0000/0000000000` placeholder). Other badges in the block, such as CRAN status, stay. Review-only tiers are labeled, and tier 5 has none.
- `Site()` sets pkgdown's `url` from the public repository.

## Agents

- Agent files in `inst/ai/agents/`, installed by `make aiglobal`: `build-docs`, `verify`, `o2g-watch`, `pub-check`, `ci-watch`, `rollout`, and `sim-status`, on cheaper models. New keywords: "CI", "rollout", "sim status", and "build rProject".
- New `vignette("agents")`, "Working with AI Agents".
- Global instructions gain the session habits: one release per session, long jobs detached, upload folders final once given, and never editing a running script. Each project's `AGENTS.md` points to rProject as pushed.

## Overleaf

- `.PreambleBiblatexCombined()`, which every `.Rtex` uses on Overleaf (no rProject there), is in a kept file: `make` wrote it, so it never reached Overleaf, and deleting its old copy stopped the compile.
- New `inst/shell/overleaf-check.sh` compiles a project's `.Rtex` files as Overleaf does: from a copy of the private repository, without rProject.

## CI

- Least-privilege `permissions:` on every template workflow that lacked them.
- r-hub tier 5, after its first run: `c23`, `clang16` to `clang20`, `gcc15`, `noremap`, `rhel7`, and `centos7` leave, because they stop before the package is checked (`vctrs` or `pak` does not load). `rhel8` and `rhel9` install `cmake`, which `fs` needs.
- `ggplot2` joins `Suggests`, which clears the `R CMD check` warning from `test-rProject-figures.R`.

# rProject 0.0.64

## Style guides

- New guides: shell, Make, and CI (007) and simulation (008), with the agents' copies in `.setup/ai/style/`. Seeds come from `taskid`, `repid`, and a numbered attempt; each project lists the failures that allow a new seed. The default run is a SLURM job array of blocks, with replications in series inside each and sizes taken from measurements; GNU Parallel on a whole node is the exception.
- `Lint()` warns on a shell script without a shebang or strict mode, a Makefile recipe that calls `apptainer`, and a workflow action at a moving branch.
- Workflow templates use release tags, with one version of each action.

## r-hub checks

- The r-hub workflows of `cran-*` projects and rProject, the testbed, are grouped in five tiers. Essential (CRAN's flavors, `donttest`, `nosuggests`) and Memory (sanitizers, including `m1-san` on macOS, `valgrind`, `rchk`; for `src/`, and always in rProject) run at every PUB. Numerics and Compilers also run at every PUB, for review only. Other platforms (deprecated containers, `rhel`, `centos7`, `s390x`) run by hand.
- Containers r-hub lists as deprecated move out of the regular runs, in favor of current ones (`ubuntu-gcc16`, `gcc16`, `clang23`).

## Notation

- Guide 005 gains a form rule: a symbol's meaning can change per paper, its form cannot (scalars plain italic, vectors bold lowercase, matrices bold uppercase; `\boldsymbol{W}` is a named exception). The default transition matrix is now `\boldsymbol{B}`. The differential is upright with a thin space: `\, \mathrm{d} t`. Existing packages and papers keep their symbols until next reused.

## Tests

- `testthat::test_that()` names its arguments (`desc`, `code`), in rProject, the template, and the R guide; `Lint()` no longer exempts it, so each project's tests change at its cleanup push.

## Safer publishing

- `Public()` stops, before anything is published, when `origin` is not the repository in `.setup/repo/public-github.md`. The template's `clone.sh` stops at the first error: a failed `git clone` no longer goes on to remove `.git`.
- `SecretScan()` stops on a folder that does not exist, instead of reporting no findings.

## Verify

- A push with no file list of its own (a fix-up) compares the files of its commit instead of passing with "0 files match". A difference is a warning, and an empty commit warns that nothing was checked.
- Files named `secretscan` are compared; secret files are still never compared.
- New check "Linked files": a note when `.setup/r-dependencies/` differs from the functions clone. New check "Full text" in `lib-*` projects: a warning for an added entry with no full text, and for a file that matches no entry.

## Library

- `LibFullTextReport()` lists the entries without a full text across all `lib-*`, and the files that match no entry. A work with no copy in any format goes in `.setup/notes/no-full-text.txt`. `LibAdd(write = TRUE)` reminds you to upload the full text.

## Linked files

- `Linked()` and `make linked` compare `.setup/r-dependencies/` with the functions clone. `Log()` lists these files under "Linked from functions" (refresh the link; do not upload), and the agent instructions say how to change them.
- `Dependencies()` and `make-install.R` delete a helper set's old copies in `R/` before copying, so a helper renamed or deleted in functions is not built. A set named after the package is left alone.

## Fixes

- `PkgRepo()` falls back to the source repository when `distro` is out of reach (`LibPaths()` may leave only a project's `.library`), so `PkgProject()` no longer stops there. On Windows it returns the repository's root: `install.packages()` adds `bin/windows/contrib` itself, so the old URL could not be read. Slow tests running on CI since 0.0.63 found both.
- The `Template()` atomic-write tests skip on Windows (they test POSIX rename and file modes), and the slow `BibLib()` test skips there too (it finds no `.bib` files; cause not looked at).
- `Lint()` and the lint workflow stop reporting two false positives: `object_usage_linter` on the `texTools` helpers, and `commented_code_linter` on the template's smoke test. Long lines in the templates are wrapped. The lint workflow fails on any lintr finding, so these kept it red.

## Sites and workflows

- Every pkgdown site and the `lib-*` and rProject Quarto books show the author's affiliation in the footer.
- Docker workflow templates: `softprops/action-gh-release@v2`; `repo-token` removed (not an input of `docker/build-push-action`).
- rProject sets `lint_error <- TRUE`.

# rProject 0.0.63

## Style guides and lint

- New guides: Rcpp (003), LaTeX (004), LaTeX math with the shared notation (005), Markdown (006), figures and tables (009), and talks (010), with the agents' copies in `.setup/ai/style/` and a test page, `.setup/quarto/math/math.qmd`. The global instructions point to them.
- `Lint()` adds the house checks of the guides for R, C++, LaTeX, and Markdown, and prints one table of findings. R and C++ checks warn until a project sets `lint_error <- TRUE` in `.setup/scripts/project.R`; LaTeX and Markdown checks always warn. Talks (type `talk`) run the rules kept in talks only. `make all` runs `make lint` first; the lint workflow runs the checks.
- `make style` inserts braces in C++ (`InsertBraces`).
- rProject's own R code follows the guide: `pkg::`, named arguments, braces, no `return()`, and `@return` and `@examples` on every export.

## Tests

- Tests skip by capability: `.SkipSlow()` now runs on CI as well as on request, and `.SkipIfMissing()` is new. `Template()` writes `tests/testthat/helper-<pkg>.R` and `test-<pkg>-smoke.R` once, when missing.
- The `check-*`, `make`, `make-all`, and `test-coverage` workflows set `NOT_CRAN`; the r-hub CRAN-like checks do not.

## Figures

- `.setup/r-miscellaneous/texTools/` in the template holds `.Tabular()`, `.Round()`, `.Array()`, the Okabe-Ito palette, the size presets (`.FigSize()`), the ggplot2 theme, `.FigSave()`, `GifWrite()`, and `GifFrames()`.
- `LatexTikzCompile()` makes a PNG at 300 dpi next to each diagram (`pdftoppm`).

## Tools

- `make agents` installs the agents' command line tools into `~/.local/bin` on the host (`UPDATE=TRUE` updates them).

## Fixes

- `Template()` writes files atomically. Written in place, a `make-project.R` that replaced itself while running went on reading the new file from the old file's size, which could stop `make project` with a parse error, or run the wrong code.
- The template's `texTools-preamble-biblatex-combined-dot.R` is now `texTools-preamble-combined-dot.R`: its path in the tarball was 106 bytes, over the portable limit of 100, which gave a note in `R CMD check`. The function is now `.PreambleCombined()`; `.PreambleBiblatexCombined()` stays as an alias for documents that still call it. `make project` deletes the old file; delete it in Overleaf too.

# rProject 0.0.62

## Patch

- The pkgdown template (`inst/pkgdown/_pkgdown.yml`) renders math with KaTeX (`math-rendering: katex`) instead of MathJax. pkgdown 2.2.1 writes its MathJax configuration after the MathJax script, which replaces the running MathJax object, so macros MathJax autoloads, such as `\boldsymbol`, failed on every site using the template (simStateSpace, the cran-beta* packages).

# rProject 0.0.61

## Patch

- The Posit Package Manager snapshot is the day before the image's date (`.SnapshotDate()`), in the lock (`snapshot`) and in `PkgRepo()`. The lock took the image's own date (UTC), and a day's snapshot is published only after that day ends: docs.sif built on 2026-11-01 (EDT) was dated 2026-11-02, the cran-beta* locks said `snapshot <- "2026-11-02"`, and every CI job that installs from the snapshot failed. At build time the image installs the newest packages, which is the previous day's snapshot.
- `image-lock.sh` (CI) checks that the lock's snapshot is published and otherwise uses the newest earlier one (up to a week back), with a warning, so locks from before 0.0.61 work too.

# rProject 0.0.60

## Minor

- rProject is a pkgdown template package: `inst/pkgdown/_pkgdown.yml` holds the shared site look (Bootstrap 5, `math-rendering: mathjax`, Roboto, Roboto Slab, and Roboto Mono, and the Penn State colors Nittany Navy, Beaver Blue, Pugh Blue, and Coaly). A project's `.setup/pkgdown/_pkgdown.yml` sets `template: package: rProject` in place of its own `template:` block; its own settings still win. rProject's site uses it, and its `url` is the GitHub Pages site.
- The Quarto `custom.scss` (the `lib`, `man`, and `talk` sets, and rProject's own) uses the same fonts and colors, including the book sidebar. The Fira Sans and Fira Code imports are gone (Fira Code came from cdn.rawgit.com, which is shut down). Projects get it at their next `make project`.

## Patch

- `PkgRepo()` and the template `make-project.R` use Posit Package Manager's `cran` repository (`https://packagemanager.posit.co/cran/`). The `all` repository (CRAN and Bioconductor) no longer serves date snapshots: `/all/2026-10-31/` returned 404, so `R CMD check` could not read `PACKAGES` and packages the image lacks could not be installed from the snapshot. Bioconductor packages still come through `BiocManager`.

# rProject 0.0.59

## Patch

- `Dependencies()` and the template `make-install.R` copy `.setup/r-dependencies/` into `R/` with `overwrite = TRUE`, and `make-install.R` copies `.setup/cpp/Makevars` and `Makevars.win` into `src/` the same way. Before, `file.copy()` kept the copy already in `R/` (or `src/`), so an updated helper never reached the build: metaDyn ran stale `mxHelper-run-dot.R` and `mxHelper-ensure-good-hessian-dot.R`.

# rProject 0.0.58

## Minor

- docker set: the README's "Use" part starts with RStudio Server when the `Dockerfile` publishes port 8787 or installs RStudio (`install_rstudio.sh`): `docker run --rm -ti -e PASSWORD=yourpassword -p 127.0.0.1:8787:8787 <image>`, the address `http://localhost:8787`, the username (`DEFAULT_USER`, else `rstudio`), and the password, as docker-docs' and docker-rocker's READMEs had before the template.
- `SecretScan()`: the OpenAI and Anthropic key patterns need a left boundary (no letter, digit, `_`, or `-` before `sk-`), so `sk-` inside a longer name is not a key. Simulation run folders such as `task-1-rep-1-alternative-200-...` matched from `ta[sk-1-...]`: manMetaVARMed's push 09bbf46 failed `Verify()` on 14 such false positives.
- Makefiles (package, lib, talk, docker): a project without `.setup/scripts/make-project.R` downloads the current one from rProject on GitHub before anything else (it installs the newest rProject), and falls back to the image's `Template()` only when offline. Before, the image's rProject wrote the template files, so an image older than a workflow stopped `make project` ("Unknown workflows": docker-torch and docker-rarch with docs built before the amd64-only workflows).
- docker set: the README names the image from `.setup/repo/public-github.md` locally and from `GITHUB_REPOSITORY` in GitHub Actions, and stops when it has neither. Make Project renders the README in the public repository, where `.setup/repo/` (private) is absent, so docker-r2u's README read `NA/NA` and its badges pointed to `github.com/NA`. `rproject_sys.sh` installs `libfreetype-dev` (Ubuntu 24.04 and 26.04; 26.04 has no `libfreetype6-dev`).
- cran set: `check-oldrel.yml`, `check-standard.yml`, `non-ascii-check.yml`, `rhub-cran-add-03.yml`, and `rhub-cran-add-04.yml` move from the rproject set to the cran set, so every cran project gets the 19 workflows the cran-* repositories run (rProject keeps them through the cran set). With `type <- "cran"` in `project.R`, a cran project can delete its workflows in Overleaf: `make project` writes them.
- docker set: system dependencies are installed with an `apt_install()` function (skips packages already installed; updates the apt lists only when they are empty), and R packages with `install2.r --error --skipinstalled -n -1`. `install-cran.sh` and `install-github.sh` look up the system dependencies of the listed packages and of their R dependencies with `pak::pkg_sysreqs()` (the r-hub system requirements database) before installing, so a rocker-based image (PPM binaries without system libraries) gets them without hand-written `*_sys.sh` lists; `install-github.sh` installs the CRAN dependencies from each DESCRIPTION (`pak::pkg_deps()`) with `install2.r`, then the packages without dependencies. `install-apt.sh` uses `apt_install()`.
- `build-docs.sh` ("build docs") runs `make project` (and `make readme`) in each project before it publishes, so the files make writes (workflows, `Makefile`, scripts, `README.md`) are in the push; a push that would delete a workflow stops the run, and a dry run prints the whole change. Before, it would have published docker-docs without its workflows.
- `clone.sh` (`make auto`) clones through the SSH alias `github-<owner>` when `~/.ssh/config` defines it (as on Roar), else `github.com`.
- The template files pass lint in rProject: `lint_dir()` skips hidden folders, so they were first linted when 0.0.54 moved them to `inst/template/` (Lint R Package had failed since 2026-10-21). `detritus.R` and the knitr option scripts drop `return()`; `KnitrOptionsDefault()` takes `Detritus()` from `source()`'s value; `load.R`'s comments are prose. `make lint` and the lint workflow skip only `indentation_linter` on `.Rtex` files: lintr counts the `%` of a chunk-option line (`% #| label = ...`) as indentation (the manuscripts had the same false positive).
- Template sets: docker gains `make-install.R`, `make-packages.R`, and `.setup/scripts/.gitignore` (its Makefile uses them); talk gains `make-config.R` and `verify.sh` (`make verify`). So in every type, `.setup/scripts/` holds `project.R` plus generated files. In Overleaf, a project keeps only the files it needs to compile and to run `make`: the compile files (tier 1), `latexmkrc`, the `Makefile` (the entry point), the `.gitignore` files (a fresh clone keeps its export rules), and `project.Rproj` (knitr finds the root by it), all as regular files, uploaded when the template changes (the agent names the affected projects); everything else `make` writes is removed from Overleaf. The only links are `.setup/r-dependencies/*` (the functions project) and `bib.bib` (`inst/template/README.md`, "Overleaf"). `Template()` writes the tier 1 files too and names the kept files it writes for upload (no more "Links to refresh"); `Verify()` compares the `Makefile` and the `.gitignore` files with the private repository.
- `build-docs.sh` writes the template files first (`Template()`) when a download has no `Makefile` or `make-project.R`.
- docker set: the install scripts are generic and read the project's lists. `scripts/install-apt.sh` (`apt.txt`), `install-cran.sh` (`cran.txt`, one `install2.r` call), `install-github.sh` (`github.txt`, one `install_github()` call after CRAN; stops without `GITHUB_PAT`, as the anonymous GitHub limit of 60 calls an hour had broken docker-r2u's daily build since 2026-10-20), and `check.sh` (loads every listed package and fails naming each one that does not load). The lists name only the packages wanted, never their dependencies: those change upstream, and `install2.r` (bspm binaries on r2u, PPM elsewhere) and each DESCRIPTION resolve them at every build. Each script does nothing without its list.
- docker set: `.setup/readme/README.Rmd` is a template file. The README shows the image, a badge for each workflow the project runs, the project's own paragraph (`.setup/readme/description.md`), how to run the image with Docker and Apptainer (`apptainer pull docker://`), the packages in `cran.txt` and `github.txt`, and each workflow with its trigger, all read when `make readme` runs.
- `workflow_next` may name several images (`c("owner/a", "owner/b")`): the daily build starts each one (docker-dev starts docker-docs and docker-rocker).
- Workflow catalog: `docker-build-push-amd64-only` and `docker-build-push-daily-amd64-only`, for images with x86-only parts (docker-torch: CUDA).
- "build lib" (`.setup/scripts/build-lib.sh`): publishes every lib-* in `BibLib()` (`make all` on a compute node, then `make auto`'s steps and the tag), waits for their CI, then dispatches rProject's Make Project (`bib.bib`, `quarto.bib` on `main`) and Compile LaTeX (rProject Daily) (the `latex` branch) and checks that each bibliography has every entry of the public lib-*. `--bib-only` ("build lib only") rebuilds the bibliographies alone.
- Keyword "start" (global instructions): a fresh session reads the handoff and `todo.txt`, checks what is pending (a push it waits for is verified and recorded as for "O2G"), reports, and waits. Not `/init`, Claude Code's own command.
- `BibLib()` stops when some lib-* cannot be cloned (a `bib.bib` without them would look complete); when none can (offline), `Bib()` still keeps the previous `bib.bib`.
- `LatexCompile()` (`make latex`) checks each log: a document whose last run failed (fatal error, TeX capacity exceeded) stops the build in GitHub Actions and gives a warning locally. `latexmk -f` had left lib-apa as a one-page stub for two days while CI reported success.

# rProject 0.0.57

## Minor

- Our own lock, not renv. `Lock()` (`make auto`) also records the image (`image`, a registry digest read from the running sif's labels, and `image_name`), the Posit Package Manager snapshot (`snapshot`, the image's date), `r_version`, and the packages the project adds (`extra_cran`, `extra_github`). For a proprietary add-on sif it records the sif's name, source, checksum (`sif_sha256`), and date; CI runs the public image. docker-* projects get no lock.
- `make project` restores the lock by default, locally and in GitHub Actions (was: CI only, or `LOCK=TRUE`); `make upgrade` (new; or `make project LOCK=FALSE`) follows the newest rProject, and the next `make auto` updates the lock. `make project` says when a newer rProject exists or when the running sif is not the locked image, checks that the image provides rProject's imports before installing it, and names packages in `.library` that hide the image's. docker-* always follow the newest rProject.
- No upgrades anywhere: a package found in any library is never upgraded. `PkgProjectGitHub()` reinstalls only for a commit SHA that differs from the installed one (a branch or tag never does) and uses `remotes::install_github(upgrade = "never")`; `PkgDevelGitHub()` installs only missing packages; `Build()`, `make install`, and every `pak::pkg_install()` pass `upgrade = FALSE`.
- `PkgRepo()` uses the snapshot of the image's date (`RPROJECT_SNAPSHOT`, the running sif, the lock, or `latest`) and knows Ubuntu noble.
- GitHub Actions: each workflow that runs the image starts with a job, `image` (`.setup/scripts/image-lock.sh`), that reads the lock; the main job runs that image. A scheduled run, a manual run with the new input `latest`, no lock, or a digest gone from the registry runs the latest image. The setup-r workflows (check-full, check-standard, check-oldrel, test-coverage, lint) and the r-hub workflows install packages from the snapshot (not on R-devel); check-full's `release` rows run the lock's R version.
- `CleanPkg()` (`make cleanpkg`) removes the project's `.library` only; it no longer uninstalls the image's packages. `make-all.yml` no longer runs it, and `make-project.R` installs rProject without its dependencies in GitHub Actions too.
- Convention for images with proprietary software: the public image `ijapesigan/<name>` never holds it; an add-on is built locally from `<name>.sif` with `Bootstrap: localimage` into `<name>-plus.sif` and never pushed (template `inst/plus/plus.def`).
- In rProject itself, `make project` documents and installs the working copy into `.library` (rProject builds itself from source; its GitHub HEAD is the last release).
- `make-project.R` is one file for every type (the `common` set; the docker set keeps an identical copy); talk gets the template `Makefile` (the same as the package one). `Template()` says to delete an Overleaf link when it overwrites a linked file.
- Nine unused docker workflows leave the catalog (`removed.tsv`).
- `Verify()` compares hand-written vignettes; only those knitted from `.setup/vignettes/` are skipped. `Verify()` takes the log named in the commit message (`Log:`) first, then the newest pending log (two logs may be pending, e.g. a deletions-only push first).
- `LatexCompile()` gives pdfTeX 10 million more words of main memory (`extra_mem_bot`): `lib-apa` (biblatex-apa over the whole library) ran out of memory with biblatex 3.22 and compiled to a one-page stub.
- Vignette "How an rProject Project Works": section "Reproducible builds".

# rProject 0.0.56

## Minor

- `Tags()` (new) lists the key, annotation, and keywords of `quarto.bib` with rProject's own parser; the "Library Tags" page (`tags.qmd`, lib, man, talk) uses it. `RefManageR` is dropped from `PkgDevel()` and the docker image.
- Overleaf keeps only the files its PDF compile needs (LaTeX preamble, `r-scripts`, `load.R` (now a link), style files, lib documents, `latexmkrc`). `Makefile` and `.setup/latex/.gitignore` are now written by make; so are the lib `.gitignore` and `_quarto.yml`, and every `clone.sh`. A fresh copy from Overleaf runs `Rscript -e 'rProject::Template(getwd())'` once.
- Placeholders `{{project}}`, `{{public}}`, `{{owner}}`, `{{repo}}` in any tier 2 template file; a file that needs the public repository is skipped without one.
- `Lock()` (new): `make auto` writes `.setup/scripts/rproject.lock` (the rProject commit and version); `make project` installs that rProject in GitHub Actions and locally with `make project LOCK=TRUE`. `rproject_ver` is removed. `make auto` also tags `v<Version>` once per version.

# rProject 0.0.55

## Minor

- The daily docker builds run as a chain instead of on staggered crons. The template `docker-build-push-daily-multi.yml` always listens for a `base-image-built` event (`repository_dispatch`) and `workflow_dispatch`; it has a schedule only when `workflow_cron` is set in `project.R`, and, when `workflow_next` (`"owner/repository"`) is set, a last step that sends the event to the next image after a successful build (with the `PAT` secret). So each image builds right after its base, and a failure stops the chain. `workflow_cron` is now optional; an invalid `workflow_next` stops `Template()`.
- `.TemplateFill()`: a value may span several lines, and a line that holds only an empty placeholder is dropped.

# rProject 0.0.54

## Minor

- One template source: every workflow now lives in `inst/template/`. rProject's own workflows come from a new set, `rproject` (`.TemplateSets()$rProject` is `common package cran rproject`), so `make` writes rProject's `.github/workflows/` too. `.setup/docker/` (with `archive/`) and `.setup/lib/` are gone.
- Workflow catalog (`inst/template/workflows/`): workflows that only some projects run (docker builds, `make-topics`). A project names them in `project.R` (`workflows <- c(...)`). The daily docker build is one template, `docker-build-push-daily-multi.yml`, written as `docker-build-push-daily-multi-<workflow_daily>.yml` with `{{title}}` and `{{cron}}` filled from `workflow_title` and `workflow_cron`. Only these keys are filled; other braces (e.g. `{{version}}`) are kept. An unknown workflow name stops with the list of valid ones. `docker-build-push-multi` moves from the `docker` set to the catalog. `docker-build-push-daily-docs.yml` (unused) is dropped.
- Shared workflows are the same for every type: `lint`, `pkgdown-gh-pages`, and `source` move from `cran` to `package` (cran, man, rProject); man and talk get the current versions (man's `make.yml` without `make bibrproject`).
- Standard folders (`inst/template/folders.tsv`): each folder, its types, whether it is private, who writes and reads it, and its purpose. `Template()` creates the folder skeleton of the type (an empty `.gitignore` in each folder marked `create`; an existing `.gitignore` is kept).
- Removed files (`inst/template/removed.tsv`): `Template()` deletes files that left the template and names them (to delete in Overleaf too); a folder is deleted only when nothing but `.gitignore` files is left in it, and nothing in a private folder is touched. 0.0.54 removes `.devcontainer/`, `.setup/cran/`, `.setup/coverage/`, `.setup/latex/apa7/`, `.setup/scripts/secrets.R`, and an empty `.setup/bin/`. `Template()` returns the deleted files in the attribute `removed`.
- `Tree()` (new; `make tree`): the project's folders and what each is for; flags missing standard folders, and folders that are not standard for the type.
- `AI()`: the AGENTS.md folder map comes from `folders.tsv` for the project's type; `make tree` is in the make targets; the container section says `Template()` writes the workflows.
- New vignette, "How an rProject Project Works": types, folders, template tiers, the Overleaf protocol, make targets, and keywords.
- `.VerifyPublic()` (so `make auto` and `Verify()`) reads the private folders from `folders.tsv`; `.setup/notes/` and `.setup/repo/` are added to the template `.gitignore`.
- `.setup/latex/pdf/` is left out of the public export (cran `.gitignore`); the CI builds it.
- `Coverage()` no longer copies `.setup/coverage/.covrignore`, and `test-coverage.yml` drops its `.covignore` step (a typo; it never ran). Put covr's `.covrignore` at the project root.
- `Binary()` stays: `.setup/bin/` is an optional folder for R scripts run at `make project` (for example, to build a bespoke binary); `make` no longer creates it.

# rProject 0.0.53

## Minor

- `Template()` (new; `make template`, and `make project` runs it) writes the template files of the project's type from rProject's `inst/template/`, so a template change reaches a project with `make` and no Overleaf refresh. The type is a new line in `.setup/scripts/project.R` (`type <- "cran"`; one of `"rProject"`, `"cran"`, `"man"`, `"lib"`, `"talk"`, `"docker"`). Tier 2 files (workflows, scripts, ...) are written when missing or different, and an overwritten file is named. Tier 1 files (`Makefile`, `latexmkrc`, the LaTeX preamble, ...) stay Overleaf links: `Template()` lists the ones that differ as links to refresh. `check = TRUE` writes nothing. Nothing is written in GitHub Actions. `inst/template/manifest.tsv` lists the files; `inst/template/README.md` explains the layout and the sources. The apa7 class is not a template: manuscripts use the copy in the TeX distribution (CTAN), and the man projects drop their `.setup/latex/apa7/` during the rollout.
- `make project` writes the template files first when `.setup/scripts/make-project.R` is missing (a fresh copy from Overleaf), using the image's rProject.
- `Verify()` skips the tier 2 template files of the project's type: they are written by make and are not uploaded.
- `AI()` reads the project type from the `type` line in `project.R` when it is present.
- `AIGlobal()` merges `claude-settings.json` into an existing `~/.claude/settings.json`: its keys win, permission rules are added to the existing ones, and other keys (e.g., an MCP allow, `autoMode`) are kept. Before, it replaced the file.
- Docker, lib, and manuscript templates now live in rProject (`inst/template/docker`, `lib`, `man`).
- rProject's `make bib` (so `make all`) rebuilds `bib.bib` from the public `lib-*` repositories (`Bib(bib_lib = TRUE)`; the Makefile checks `type <- "rProject"` in `project.R`); other projects are unchanged. If no repository can be cloned (e.g., offline), the previous `bib.bib` is kept, with a warning.

## Patch

- `BibLib()` clones without the user's git config (`GIT_CONFIG_GLOBAL=/dev/null`; a config that rewrites https to ssh made the clones hang in the container), never prompts, clones shallow and quietly, and copies only the `lib-*.bib` entries (before, a clone's own `quarto.bib` was left in `.setup/latex/bib/`). The `bib` target sets the same git environment, so it also works with an older installed rProject.

# rProject 0.0.52

## Patch

- `.github/workflows/check-full.yml`: the R-CMD-check-full matrix drops `windows-latest (3.6)` (below the minimum R of the template's packages) and `windows-latest (oldrel-4)` (r-lib/actions dropped it too; RcppArmadillo code fails to link there), adds `windows-latest (oldrel-1)` (CRAN's r-oldrel-windows flavor), and replaces `ubuntu-22.04-arm` with `ubuntu-26.04-arm` (devel and release). The job sets `PKG_INCLUDE_LINKINGTO: true`, so pak builds packages such as glmnet from source with their `LinkingTo` dependencies. `use-public-rspm: true` is removed; it is the default in `r-lib/actions/setup-r@v2`.

# rProject 0.0.51

## Minor

- `.setup/scripts/build-docs.sh` runs detached (`setsid nohup`, so it survives an SSH disconnect or the end of the agent's session) and writes a status file next to its log (`running <pid> <host> <start>`, then `done` or `STOPPED: <reason>`, also when it is killed). It refuses to start while another run is running. `--images-only` builds `docs.sif` and `docs-plus.sif` alone, without a push. It checks rProject in both images with `Rscript --vanilla` from `/` (a project `.Rprofile` could hide it) and stops before the rename on a version mismatch.
- Global instructions: "build docs" and "build docs only" start the script detached and watch its status file; a new keyword, "build sif" (`--images-only`).
- `.setup/scripts/o2g-watch.sh` (rProject only, run on the host): after an upload folder, the agent watches the private repository (`git ls-remote` every 60 seconds, up to 8 hours) and verifies and records the push when a commit with the expected first line lands, without the user's "O2G" (global instructions).

## Patch

- `Verify()` reads only the file list of the pushed commit: the log section with a code block that starts with the commit's first line (the top-level lists for the log's own commit message; the lists inside a later push's `##` section, none for a push of records only). Before, it read every list in the log, so a later push in the same log failed "Listed files" on files of an earlier list that had changed since. If no block matches, every list is used, as before.

# rProject 0.0.50

## Minor

- `.setup/scripts/build-docs.sh` (rProject only, run on the host): "build docs" publishes the docker images in the order of `.setup/scripts/build-docs.txt` (the steps of `make auto` in a fresh download of each private repository; it waits for Make Project and "Docker Build and Push [multi]" before the next, retries failed multi jobs once, and stops at the first failure), then builds `docs.sif` and `docs-plus.sif` with docker-docs' `run-def.sh` on one core into a staging folder and replaces an image only if it is not in use. `--only docker-docs` is "build docs only"; `DRY_RUN=1` pushes nothing. It first checks that the public rProject has the version in `DESCRIPTION`.
- Global instructions: the "build docs" and "build docs only" keywords.

# rProject 0.0.49

## Minor

- `AI()` creates `.setup/todo/` (`todo.txt`, the user's to-do list, and a `.gitignore` that keeps the folder private) if and only if the folder does not exist, and the project's `AGENTS.md` lists it in the folder map. Agents read `todo.txt` when planning and never edit it (global instructions).
- `Public()` and `Verify()` treat `.setup/todo/` as private: the public export fails if it is published. `Verify()` does not count changes under `.setup/todo/` as unlisted (the user edits the list on Overleaf at any time).
- Global instructions (`.setup/ai/global/AGENTS.md`): how agents use `.setup/todo/todo.txt`; `.setup/todo/` among the private folders. The root `.gitignore` lists `.setup/todo/`.

# rProject 0.0.48

## Patch

- `LibFormat()` keeps entry types it does not list (a type outside its list became `@NA`) and knows `@Collection`. `LibCheck()` accepts `@Collection` (an edited volume; requires `editor`, `date`, `title`, `publisher`) in book libraries.
- `Bib()`: without source `.bib` files, the existing `.setup/latex/bib/bib.bib` is copied to `vignettes/vignettes.bib` and `.setup/quarto/bib/quarto.bib`. A clone of the private repository has only `bib.bib` (`vignettes.bib` is gitignored), so `Site()` could not rebuild `vignettes.bib` and pkgdown failed with "File 'vignettes.bib' not found".

# rProject 0.0.47

## Patch

- `BuildIgnore()`: `.Rbuildignore` ignores the root `latexmkrc` (Overleaf's copy, kept in every Overleaf project). Built from an Overleaf clone, `R CMD check` noted "Non-standard file/directory found at top level: 'latexmkrc'". The package copy, `inst/latexmk/latexmkrc`, is still shipped.

# rProject 0.0.46

## Minor

- `AI()`: a new project type, `"cran"`, for `cran-*` folders (R packages on CRAN or headed there; their `project.R` names the package). They get the package and the new CRAN section (`R CMD check --as-cran` clean, version and NEWS for every change, `tempdir()` only, the user submits).
- `AI()`: a project is a simulation when `.sim/README.md` (which describes the simulation) exists; `.sim/` alone (the template's `make.sh`) is not one. rProject and plain packages were labelled "simulation".
- `Verify()`: `.setup/notes/claude.txt` (the resume commands, which the agent keeps current when the user leaves) is not counted as an unlisted change.
- `make-project.R` (linked into every project): installs rProject alone into `.library`, with the dependencies from the image; in GitHub Actions, with its dependencies.

# rProject 0.0.45

## Patch

- `.LibLatex()` (used by `LibAdd()`) keeps its character map as a two-column matrix instead of a named vector. Names become symbols, which R without a UTF-8 locale (R 3.6 and R 4.1 on Windows) could not translate: `R CMD check` warned, and the accents were left unconverted.

# rProject 0.0.44

## Patch

- `LibCheck()` no longer reports a layout difference for an entry checked out with CRLF line endings (Windows); `LibFormat()` and `LibAdd()` write LF line endings on every platform. This fixes the `test-rProject-lib.R` failure on the Windows R CMD check jobs.

# rProject 0.0.43

## Minor

- `Bib()` joins the `.bib` files into `bib.bib` verbatim and no longer rewrites them with RefManageR (which turned `{\'e}` into `{\a'e}`, reordered fields, and silently dropped entries it could not read). RefManageR is no longer imported; `jsonlite` is (for Crossref).
- New `LibCheck()` (and `make libcheck`): checks a `lib-*` library's entries (one per file, file name, key and `-etal` rule, year and decade, entry type, required fields, ASCII, unescaped `%`, keys and DOIs used twice across repositories, lone suffixes, biber's datamodel, house layout). `make lint` runs it in `lib-*` projects.
- New `LibFormat()` (and `make libformat`): puts every entry in the house layout and field order, with `{\'e}` accents, `--` page ranges, and bare DOIs, without changing what the entries say.
- New `LibAdd()`: drafts an entry from a DOI's Crossref record (issue date, LaTeX accents, key, repository, abstract, the library's ISSN and publisher for the journal) and lists what it cannot decide.
- `AI()`: the library section states the conventions; the manuscript section says to check citations against the `lib-*` library and to add missing references there first.

# rProject 0.0.42

## Minor

- `.setup/repo/` records where a project lives: `private-github.md`, `private-overleaf.md` (the project URL, never a share link), and `public-github.md` (`owner/repo`, or `none`). `Project()` creates it when it is missing, with the two GitHub repositories filled in.
- `verify.sh` clones the private repository named in `.setup/repo/private-github.md` (needed when `project.R` and the repository name differ, as in the docker projects).
- `Verify()` checks `.setup/repo/` ("Repo info"): an Overleaf share link fails; a missing file, or a repository that differs from the `.verify` remote or from `clone.sh`, warns.
- `Verify(record = TRUE)` records a fix-up push without a pending row: it finds the log from the commit message (`Log: .setup/logs/<log>`) and adds rows to the log and to `index.md`.
- `AI()` writes the three locations into `AGENTS.md`, and has a `"container"` type for `docker-*` projects (`inst/ai/section-container.md`).
- `Public()` and `Verify()` treat `.setup/repo/` as private, and `Public()` applies `.gitignore` outside a git repository (for example, a folder downloaded from Overleaf).
- `Log()` lists the files to delete in Overleaf (in the private repository but not in the project), and names the `AI()` files as generated.

## Patch

- `Lint()` and `Style()` skip `.verify/`; `Lint()` resolves its exclusions relative to the project and no longer hides errors with `try()`.
- `.DataManifestUsedBy()` keeps the `.setup/data-analysis/` and `.setup/data-process/` scripts.
- `make-project.R` upgrades rProject in the rProject project too (it only installed it when missing, so `.library` kept an old version).

# rProject 0.0.41

## Patch

- `CFF()` works from any working directory: it passes cffr the project's `DESCRIPTION` file and writes `CITATION.cff` into the project folder.

# rProject 0.0.40

## Patch

- Paths and shell calls work across platforms, and with spaces in paths:
  - `Profile()` writes the library path with `deparse()`, and `Environment()` writes paths with forward slashes.
  - `DataManifest()` makes paths relative by prefix, not by a regular expression built from the path.
  - Shell commands go through `system2()`, with each path quoted for the platform's shell: `LatexCompile()` and `LatexTikzCompile()` pass the `.tex` files to latexmk explicitly (no shell glob); `Style()` finds the C++ files in R (no `find`); `BibLib()` clones into the bib folder without changing the working directory; plus `Manual()`, `InstallLocal()`, `ConfigFiles()` (`make -C`), `Public()`, and `Verify()`.
  - New internal helpers: `.PathSlash()` and `.ShellQuote()`.
- Tests pass on the plain GitHub runners (ubuntu, macOS, Windows) and under covr. Tests of functions that need the container layout (`Lint()`, `Style()`, `PkgProjectVersion()`) skip when their packages are not in the site library. Tests of Unix-only behavior (file modes, `clang-format`, `CleanPkg()`) skip on Windows, as do `Public()` and `Verify()` until a Windows run confirms them. Tests now use paths with spaces.
- `inst/shell/install-*.sh`: a ShellCheck directive for the sourced `install-common.sh` (SC1091).

# rProject 0.0.39

## Patch

- Unit tests for every exported function. Slow tests (installers, network, full LaTeX and Quarto builds) run only with `RPROJECT_SLOW_TESTS=true`. Functions that change the machine (`TinyTex()`, `CleanTinyTex()`, `PkgDevel()`, `PkgDevelGitHub()`) are checked for their interface only. `CleanPkg()` is tested in a separate R process whose library paths are temporary.
- `CleanProj()` keeps `.sim` and `.sif` unless `sim = TRUE` or `sif = TRUE`, as documented. It used to delete them.
- The package ships `inst/latexmk/latexmkrc` again (Overleaf's latexmk configuration), so `LatexCompile()` and `LatexTikzCompile()` use the same latexmk rules on GitHub Actions and locally as on Overleaf. `.gitignore` now ignores only the root `latexmkrc`, and `Verify()` compares `inst/latexmk/latexmkrc`.
- The `Clean()` documentation says that `push = TRUE` does not delete `*secrets*` files in hidden folders such as `.setup`.

# rProject 0.0.38

## Patch

- The user chooses the Apptainer image and runs `apptainer exec <image>`. `Log()` records the image that actually ran (its name, build date, and base digest, from the container's labels) under "Make commands run".
- The project instructions (`AI()`) tell agents not to pick an image; `.setup/ai/project.md` has a line for the image a project usually uses.
- `AI()` no longer takes `sif`.
- `SizeCheck()` and `Verify()` skip `.sif/`.

# rProject 0.0.37

## Patch

- Added `inst/shell/install.sh` to install or update the machine tools into `~/.local` on Linux (Apptainer, Claude Code, Codex, Copilot, Gemini, herdr, gh): `bash install.sh machine`, or name the tools; `--list` shows versions. Each tool keeps its previous version if the new one fails.
- Added `inst/shell/install-{apptainer,claude,codex,copilot,gemini,herdr}.sh` and `install-common.sh`. `install-gh.sh` now installs the prebuilt release, checked against its SHA-256 checksums. `install-gemini.sh` links `node` into `~/.local/bin`, so Gemini works without nvm being loaded.

# rProject 0.0.36

## Patch

- `make verify RECORD=TRUE` (run as `apptainer exec <sif> make verify RECORD=TRUE`) pulls the private repository into `.verify` and checks the push. `.setup/scripts/verify.sh` only pulls (git; no R, no Apptainer).
- `Verify()` has a new check, "New commit", which fails, and records nothing, when the commit is already in `.setup/logs/index.md` (a stale `.verify` or no new push).
- Makefile targets never call Apptainer; `make auto` and `make public` call `Rscript`.

# rProject 0.0.35

## Patch

- Data tiers: `.setup/data-raw` (shareable), `.setup/data-private` (restricted; never public), `.setup/data-external` (local only), and `.setup/data-cache` (local only).
- Added the `DataPath()` function to find a data file by its plain name in the tiers, stored as is or compressed (`.xz`, `.gz`); `plain = TRUE` returns an uncompressed copy for tools such as Mplus.
- Added the `DataCompress()` function to compress data files with xz, so they do not count as editable text in Overleaf.
- Added the `DataManifest()` function and the `make manifest` target to write `.setup/ai/data.md` (private): tier, size, MD5, status, source, location, and the scripts that use each file.

# rProject 0.0.34

## Patch

- Added the `AI()` function and the `make ai` target. `AI()` writes the project's AI instructions (`AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`) from templates in `inst/ai`, and creates `.setup/ai/project.md` for project facts once. Project types are detected (package, manuscript, simulation, library, talk) or set with an `ai` list in `.setup/scripts/project.R`. `make project` runs it.
- `make project` upgrades rProject in other projects when GitHub has a newer commit (a pinned `rproject_ver` is still honored).
- `Verify()` and `Log()` treat the generated AI instruction files as generated.

# rProject 0.0.33

## Patch

- Added the `SizeCheck()` function and the `make sizecheck` target to check a project against Overleaf's limits (editable text, file sizes, number of files, total size, duplicates). `make lint` reports it.
- Added the `Public()` function and the `make public` target. `make auto` calls `Public()` before `git add`, so private files, files over 50 MB, and tokens are never published.

# rProject 0.0.32

## Patch

- Added the `Spec()` and `Log()` functions and the `make spec` and `make log` targets. `Log()` writes the change-set log, adds a pending row to `.setup/logs/index.md`, and lists the files to update in Overleaf by comparing the project with the private repository.
- `.setup/scripts/verify.sh` keeps the clone of the private repository in `.verify` (local only), so `make verify` and `make log` work inside the container.
- `Verify()` ignores the generated `Config/roxygen2/version` line in `DESCRIPTION`.

# rProject 0.0.31

## Patch

- Added the `Verify()` function, the `make verify` target, and `.setup/scripts/verify.sh` to check an Overleaf push against its change-set log: listed files, deletions, unlisted changes, the commit message, secrets, and the public export. With `record = TRUE`, the result is written to the log and `.setup/logs/index.md`.

# rProject 0.0.30

## Patch

- `BuildIgnore()` excludes AI tool files from package builds: `.claude`, `CLAUDE.md`, `CLAUDE.local.md`, `.mcp.json`, `AGENTS.md`, `.codex`, `GEMINI.md`, and `.gemini`.

# rProject 0.0.29

## Patch

- `AIGlobal()` installs the GitHub Copilot instructions to `~/.copilot/copilot-instructions.md`, which Copilot loads in every session. `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` is no longer needed.

# rProject 0.0.28

## Patch

- `ConfigFiles()` no longer takes `git_user`. It clones `repo` (default `ijapesigan/dotfiles`) anonymously over HTTPS, ignoring Git URL rewrites, so `make dotfiles` works inside containers. It stops with an error when the clone or `make` fails.

# rProject 0.0.27

## Patch

- Added the `AIGlobal()` function and the `make aiglobal` target to install global AI instructions for Claude Code, Codex, and GitHub Copilot.

# rProject 0.0.26

## Patch

- Secrets are read from the local machine (`$RPROJECT_SECRETS`, `~/.config/rproject/<project>.R`, or `~/.config/rproject/secrets.R`) in `.setup/scripts/make-project.R`. `.setup/scripts/secrets.R` is only used as a fallback, with a warning.
- `Environment()` sets the permissions of `.Renviron` to `600`.
- Added the `SecretScan()` function and the `make secretscan` target.

# rProject 0.0.25

## Patch

- Changed year from 2025 to 2026 in MIT license.

# rProject 0.0.24

## Patch

- Address `remotes::install_github()` deprecation by using `pak::pkg_install()`.

# rProject 0.0.23

## Patch

- Edits to the `Lint()` function.

# rProject 0.0.22

## Patch

- Added the `PkgProjectBioconductor()` function.

# rProject 0.0.21

## Patch

- Specific `rProject` GitHub commit can be installed via the `rproject_ver` object in `.setup/scripts/project.R`.

# rProject 0.0.20

## Patch

- Updated MIT license year to 2025.

# rProject 0.0.19

## Patch

- The `PkgProjectGitHub()` function gives priority to installing packages that contain the `@` character in their specification.
- The `PkgProjectVersion()` function installs the available package first before checking its version.

# rProject 0.0.18

## Patch

- Added `.quarto` in the `BuildIgnore()` function.

# rProject 0.0.17

## Patch

- Revised the `Lint()` function.

# rProject 0.0.16

## Patch

- Added `tests` in exclusions in the `Lint()` function.

# rProject 0.0.15

## Patch

- Added `nolint.R` in exclusions in the `Lint()` function.

# rProject 0.0.14

## Patch

- Added `lib-2000-2009-manual` in `BibLib()`.

# rProject 0.0.13

## Patch

- Added `.sif` to `BuildIgnore()`.

# rProject 0.0.12

## Patch

- Option to NOT delete `.sim` and `.sif` in `CleanProj()`.

# rProject 0.0.11

## Patch

- Install `rhub` from CRAN.

# rProject 0.0.10

## Patch

- Added `".*\\.sif$` in `BuildIgnore()`.

# rProject 0.0.9

## Patch

- Added the `LatexTikzCompile()` function and `LatexMake()` calls it before `LatexCompile()`.

# rProject 0.0.8

## Patch

- `knit::knit()` uses `envir = new.env()`.

# rProject 0.0.7

## Patch

- Exclude `R/methods.R` from linting in `Lint()`.

# rProject 0.0.6

## Patch

- Edits to `Clean()` to keep `vignettes.bib` when `push = TRUE`.

# rProject 0.0.5

## Patch

- Option to build `bib.bib` from `lib-*` repositories using `Bib()`.

# rProject 0.0.4

## Patch

- Added build tools for `Rcpp()` functions.

# rProject 0.0.3

## Patch

- Added the the function `Bib()` to generate `bib.bib` files for LateX, quarto, and vignettes.

# rProject 0.0.2

## Patch

- Added the argumnent `push` to `Clean()` for cleaning the directory in preparation for git push.

# rProject 0.0.1

## Patch

- Started version numbers.

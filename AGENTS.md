# rProject

This project follows the house rules in your global instructions
(`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`,
`~/.copilot/copilot-instructions.md`). This file adds only what is
specific to this project.

**Read `.setup/ai/project.md` first.** It holds the project facts that
the user maintains (aims, data, notation, co-authors, open issues).

## Project

- Name: `rProject`
- Type: simulation
- Private repository: `jeksterslab-psu/rProject` (Overleaf pushes here)
- Image: **the user chooses it** and runs
  `apptainer exec <image> make <target>`; R is not installed on the
  host. Do not pick an image. When a command needs one, ask, or give the
  command with `<image>` for the user to fill in. `.setup/ai/project.md`
  may note the image the project usually uses.

## Folder map

| Folder | Contents |
|----|----|
| `R/` | package functions, one per file |
| `tests/testthat/` | tests |
| `.setup/scripts/` | `project.R` (project settings) and the make scripts |
| `.setup/data-raw/` | shareable raw data |
| `.setup/data-private/` | restricted data: never public |
| `.setup/ai/` | specs, the plan, `project.md` (private) |
| `.setup/logs/` | one log per Overleaf push, and `index.md` (private) |
| `.sim/` | simulation scripts (SLURM, GNU Parallel) |
| `.sif/` | images or links to them (local only; never uploaded) |

## Make targets

| Target | Does |
|----|----|
| `make all` | build, docs, LaTeX, pkgdown, quarto, coverage |
| `make lint` | style and lint the R code, and report Overleaf limits |
| `make sizecheck` | check Overleaf limits; run before uploading |
| `make spec TOPIC=<topic>` | start a spec for a change set |
| `make log TOPIC=<topic> SUMMARY="..."` | write the change-set log and its file list (`UPDATE=TRUE` refreshes the list) |
| `make verify RECORD=TRUE` | after the user pushes from Overleaf (O2G): verify and record the push. On Roar, run `bash .setup/scripts/verify.sh` on the host first to pull. |
| `make auto` | publish to the public repository (checks the export first) |

## Generated files: never edit by hand

`NAMESPACE`, `man/`, `README.md`, `CITATION.cff`, `LICENSE*`,
`.Rbuildignore`, `project.Rproj`, `R/RcppExports.R`,
`src/RcppExports.cpp`, `*/bib.bib`, `vignettes/*.Rmd` built from
`.setup/vignettes/`, `.setup/latex/pdf/`, `.setup/latex/figures/`,
`data/*.rda`. Change their sources and run `make`.

## Size

Overleaf’s GitHub sync stops above 7 MB of editable text and caps text
files at 2 MB. Keep large data compressed (binary, e.g. `.Rds` or `.xz`)
and never store the same file twice. `make sizecheck` reports problems.

## Simulation

- Scripts are in `.sim/`; read `.sim/README.md` first.
- Jobs run with SLURM and GNU Parallel inside the image
  (`apptainer exec`). The user submits jobs on the compute nodes or the
  local nodes; you never submit a job.
- Before handing over a job: a smoke test with one or two replications
  on the submit node, inside the image, and `sbatch --test-only` on the
  job script (it checks the script and submits nothing).
- Summaries must be compressed and under 50 MB, and must not repeat raw
  output. Run `make sizecheck` before uploading.
- When a run fails, read the SLURM output and the error files, and list
  the failed tasks and replications with the first error of each.

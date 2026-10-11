# Write the Project's AI Instructions

Writes the instruction files that AI tools read in this project, on top
of the global instructions installed by
[`AIGlobal()`](https://github.com/ijapesigan/rProject/reference/AIGlobal.md).

## Usage

``` r
AI(path, type = NULL, sif = NULL)
```

## Arguments

- path:

  Character string. Project path.

- type:

  Character vector. Project types: any of `"package"`, `"manuscript"`,
  `"simulation"`, `"library"`, and `"talk"`.

- sif:

  Character string. File name of the Apptainer image.

## Value

Returns the paths of the files that were written, invisibly.

## Details

- `.setup/ai/project.md`: project facts that the user maintains. Created
  once and never overwritten.

- `AGENTS.md` (Codex, Copilot CLI, Claude through `CLAUDE.md`),
  `CLAUDE.md` (Claude Code), and `.github/copilot-instructions.md`
  (Copilot in the IDE): generated, and rewritten when they change.

All of them are private (gitignored and excluded from the package
build).

The project type and the image come from `type` and `sif`, else from an
`ai` list in `.setup/scripts/project.R` (e.g.,
`ai <- list(type = c("manuscript", "simulation"), sif = "x.sif")`), else
they are detected: `"simulation"` if `.sim` exists, `"manuscript"` if a
`*-manuscript*.Rtex` exists or the name starts with `man`, `"library"`
for `lib-*`, `"talk"` for `talks*`, otherwise `"package"`; the image
defaults to `docs.sif`.

## Author

Ivan Jacob Agaloos Pesigan

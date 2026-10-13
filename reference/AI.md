# Write the Project's AI Instructions

Writes the instruction files that AI tools read in this project, on top
of the global instructions installed by
[`AIGlobal()`](https://github.com/ijapesigan/rProject/reference/AIGlobal.md).

## Usage

``` r
AI(path, type = NULL)
```

## Arguments

- path:

  Character string. Project path.

- type:

  Character vector. Project types: any of `"package"`, `"manuscript"`,
  `"simulation"`, `"library"`, `"talk"`, and `"container"`.

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

The project type comes from `type`, else from an `ai` list in
`.setup/scripts/project.R` (e.g.,
`ai <- list(type = c("manuscript", "simulation"))`), else it is
detected: `"simulation"` if `.sim` exists, `"manuscript"` if a
`*-manuscript*.Rtex` exists or the name starts with `man`, `"library"`
for `lib-*`, `"talk"` for `talks*`, `"container"` for `docker-*`,
otherwise `"package"`.

Where the project lives (the private GitHub repository, the Overleaf
project, and the public GitHub repository) comes from `.setup/repo/`,
which
[`Project()`](https://github.com/ijapesigan/rProject/reference/Project.md)
creates when it is missing.

The user chooses the Apptainer image and runs `apptainer exec`; the
instructions tell agents not to pick an image.

## Author

Ivan Jacob Agaloos Pesigan

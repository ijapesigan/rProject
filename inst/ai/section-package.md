
## Package

- Every exported function has roxygen documentation and tests.
- `make all` runs the checks; fix every error, warning, and note.
- Keep the R style rules from your global instructions (BigCamelCase, one
  function per file, internal `.Foo` functions in `R/<pkg>-<name>-dot.R`).
- Keep every line of R code and roxygen at 80 characters or fewer: the public
  CI lint fails on one. Read the `make lint` output, not only its exit code.
  `make lint` (via the line-length gate), `make upload`, and `make verify`
  check it; `LINTR_ERROR_ON_LINT=false` switches the check off.

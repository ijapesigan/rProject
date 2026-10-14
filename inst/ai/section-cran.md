
## CRAN

This package is on CRAN or headed there.

- `R CMD check --as-cran` must pass with no errors, warnings, or notes, on R
  release and R devel.
- Every user-visible change: a version bump and a `NEWS.md` entry.
- Examples, tests, and vignettes write only to `tempdir()`, use at most two
  cores, and do not need the internet unless skipped (`skip_on_cran()`,
  `skip_if_offline()`). Long examples go in `\donttest{}`.
- Before a submission: `cran-comments.md` (test environments, check results,
  reverse dependencies) and reverse-dependency checks when the package has
  any.
- The user submits to CRAN. Agents prepare the submission; they never submit.

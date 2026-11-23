.TemplateOnce <- function(path,
                          root,
                          check) {
  # the test helper and the smoke test: written once, when missing, and the
  # project's after that; only in a package with unit tests
  tests <- file.path(path, "tests", "testthat")
  written <- character(length = 0L)
  if (dir.exists(
    paths = tests
  ) && file.exists(file.path(path, "DESCRIPTION"))) {
    pkg <- .LintPkg(path = path)
    sources <- c(helper = "helper-pkg.R", smoke = "test-pkg-smoke.R")
    targets <- c(
      helper = paste0("helper-", pkg, ".R"),
      smoke = paste0("test-", pkg, "-smoke.R")
    )
    for (key in names(x = sources)) {
      target <- file.path(tests, targets[[key]])
      if (!file.exists(target)) {
        written <- c(written, file.path("tests", "testthat", targets[[key]]))
        if (!check) {
          text <- readLines(
            con = file.path(root, "once", sources[[key]]),
            warn = FALSE
          )
          writeLines(
            text = gsub(
              pattern = "{{pkg}}",
              replacement = pkg,
              x = text,
              fixed = TRUE
            ),
            con = target
          )
        }
      }
    }
  }
  # the Slurm script of .sim/ in a package: written once, when missing (a
  # regular file in Overleaf, since it runs before make); Conform() flags a
  # copy that differs
  sim <- file.path(path, ".sim")
  if (
    dir.exists(paths = sim) &&
      file.exists(file.path(path, "DESCRIPTION")) &&
      !file.exists(file.path(sim, "make.sh"))
  ) {
    written <- c(written, file.path(".sim", "make.sh"))
    if (!check) {
      file.copy(
        from = file.path(root, "once", "sim-make.sh"),
        to = file.path(sim, "make.sh")
      )
      Sys.chmod(paths = file.path(sim, "make.sh"), mode = "0755")
    }
  }
  written
}

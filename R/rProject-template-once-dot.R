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
  # the Slurm script of .sim/ (make project, then make release or make all)
  # and its .gitignore, in every project type: each written once, when
  # missing (regular files in Overleaf, since the script runs before make;
  # a simulation keeps its own .gitignore); Conform() flags a make.sh that
  # differs
  sim <- file.path(path, ".sim")
  once <- c("make.sh" = "sim-make.sh", ".gitignore" = "sim-gitignore")
  for (file in names(x = once)) {
    if (!file.exists(file.path(sim, file))) {
      written <- c(written, file.path(".sim", file))
      if (!check) {
        dir.create(path = sim, showWarnings = FALSE)
        file.copy(
          from = file.path(root, "once", once[[file]]),
          to = file.path(sim, file)
        )
        if (file == "make.sh") {
          Sys.chmod(paths = file.path(sim, file), mode = "0755")
        }
      }
    }
  }
  written
}

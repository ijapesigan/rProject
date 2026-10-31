## ---- test-rProject-verify-changes
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "verifychanges")
    path <- file.path(root, "project")
    private <- file.path(root, "private")
    for (dir in c(path, private)) {
      dir.create(file.path(dir, "inst", "latexmk"), recursive = TRUE)
      writeLines("same", file.path(dir, "R.R"))
    }
    writeLines("local", file.path(path, "inst", "latexmk", "latexmkrc"))
    writeLines("overleaf", file.path(private, "inst", "latexmk", "latexmkrc"))
    writeLines("local", file.path(path, "latexmkrc"))
    writeLines("overleaf", file.path(private, "latexmkrc"))
    # a knitted vignette (from .setup/vignettes/) and a hand-written one
    for (dir in c(path, private)) {
      dir.create(file.path(dir, "vignettes"))
      dir.create(file.path(dir, ".setup", "vignettes"), recursive = TRUE)
      writeLines("orig", file.path(dir, ".setup", "vignettes", "a.Rmd.orig"))
    }
    writeLines("knitted", file.path(path, "vignettes", "a.Rmd"))
    writeLines("local", file.path(path, "vignettes", "b.Rmd"))
    writeLines("overleaf", file.path(private, "vignettes", "b.Rmd"))
    # a cran project: the Makefile is kept in Overleaf (compared), a
    # workflow is written by make (skipped)
    for (dir in c(path, private)) {
      dir.create(file.path(dir, ".setup", "scripts"), recursive = TRUE)
      dir.create(file.path(dir, ".github", "workflows"), recursive = TRUE)
    }
    for (dir in c(path, private)) {
      writeLines(
        text = 'type <- "cran"',
        con = file.path(dir, ".setup", "scripts", "project.R")
      )
    }
    writeLines("local", file.path(path, "Makefile"))
    writeLines("overleaf", file.path(private, "Makefile"))
    workflow <- file.path(".github", "workflows", "make.yml")
    writeLines("local", file.path(path, workflow))
    writeLines("overleaf", file.path(private, workflow))
    writeLines("local", file.path(path, ".github", ".gitignore"))
    writeLines("overleaf", file.path(private, ".github", ".gitignore"))
    out <- rProject:::.VerifyChanges(path = path, private = private)
    testthat::test_that(
      paste(text, "compares inst/latexmk/latexmkrc"),
      {
        testthat::expect_true("inst/latexmk/latexmkrc" %in% names(out))
      }
    )
    testthat::test_that(
      paste(text, "skips the root latexmkrc that LatexCompile() writes"),
      {
        testthat::expect_false("latexmkrc" %in% names(out))
        testthat::expect_false("R.R" %in% names(out))
      }
    )
    testthat::test_that(
      paste(text, "compares the Makefile, skips a generated workflow"),
      {
        testthat::expect_true("Makefile" %in% names(out))
        testthat::expect_false(".github/workflows/make.yml" %in% names(out))
        testthat::expect_false(".github/.gitignore" %in% names(out))
      }
    )
    testthat::test_that(
      paste(text, "compares hand-written vignettes, skips knitted ones"),
      {
        testthat::expect_true("vignettes/b.Rmd" %in% names(out))
        testthat::expect_false("vignettes/a.Rmd" %in% names(out))
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-verify-changes"
)

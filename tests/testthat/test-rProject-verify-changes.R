## ---- test-rProject-verify-changes
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "verifychanges")
    path <- file.path(root, "project")
    private <- file.path(root, "private")
    for (dir in c(path, private)) {
      dir.create(path = file.path(dir, "inst", "latexmk"), recursive = TRUE)
      writeLines(text = "same", con = file.path(dir, "R.R"))
    }
    writeLines(
      text = "local",
      con = file.path(path, "inst", "latexmk", "latexmkrc")
    )
    writeLines(
      text = "overleaf",
      con = file.path(private, "inst", "latexmk", "latexmkrc")
    )
    writeLines(text = "local", con = file.path(path, "latexmkrc"))
    writeLines(text = "overleaf", con = file.path(private, "latexmkrc"))
    # a knitted vignette (from .setup/vignettes/) and a hand-written one
    for (dir in c(path, private)) {
      dir.create(path = file.path(dir, "vignettes"))
      dir.create(path = file.path(dir, ".setup", "vignettes"), recursive = TRUE)
      writeLines(
        text = "orig",
        con = file.path(dir, ".setup", "vignettes", "a.Rmd.orig")
      )
    }
    writeLines(text = "knitted", con = file.path(path, "vignettes", "a.Rmd"))
    writeLines(text = "local", con = file.path(path, "vignettes", "b.Rmd"))
    writeLines(
      text = "overleaf",
      con = file.path(private, "vignettes", "b.Rmd")
    )
    # a cran project: the Makefile is kept in Overleaf (compared), a
    # workflow is written by make (skipped)
    for (dir in c(path, private)) {
      dir.create(path = file.path(dir, ".setup", "scripts"), recursive = TRUE)
      dir.create(
        path = file.path(dir, ".github", "workflows"),
        recursive = TRUE
      )
    }
    for (dir in c(path, private)) {
      writeLines(
        text = 'type <- "cran"',
        con = file.path(dir, ".setup", "scripts", "project.R")
      )
    }
    writeLines(text = "local", con = file.path(path, "Makefile"))
    writeLines(text = "overleaf", con = file.path(private, "Makefile"))
    workflow <- file.path(".github", "workflows", "make.yml")
    writeLines(text = "local", con = file.path(path, workflow))
    writeLines(text = "overleaf", con = file.path(private, workflow))
    writeLines(text = "local", con = file.path(path, ".github", ".gitignore"))
    writeLines(
      text = "overleaf",
      con = file.path(private, ".github", ".gitignore")
    )
    out <- rProject:::.VerifyChanges(path = path, private = private)
    testthat::test_that(
      paste(text, "compares inst/latexmk/latexmkrc"),
      {
        testthat::expect_true(
          object = "inst/latexmk/latexmkrc" %in% names(x = out)
        )
      }
    )
    testthat::test_that(
      paste(text, "skips the root latexmkrc that LatexCompile() writes"),
      {
        testthat::expect_false(object = "latexmkrc" %in% names(x = out))
        testthat::expect_false(object = "R.R" %in% names(x = out))
      }
    )
    testthat::test_that(
      paste(text, "compares the Makefile, skips a generated workflow"),
      {
        testthat::expect_true(object = "Makefile" %in% names(x = out))
        testthat::expect_false(
          object = ".github/workflows/make.yml" %in% names(x = out)
        )
        testthat::expect_false(
          object = ".github/.gitignore" %in% names(x = out)
        )
      }
    )
    testthat::test_that(
      paste(text, "compares hand-written vignettes, skips knitted ones"),
      {
        testthat::expect_true(object = "vignettes/b.Rmd" %in% names(x = out))
        testthat::expect_false(object = "vignettes/a.Rmd" %in% names(x = out))
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-verify-changes"
)

## ---- test-rProject-manual
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if(Sys.which("pdflatex") == "", "pdflatex not found")
    state <- .TestState()
    root <- .TestProject(name = "manualPkg")
    lib <- tempfile(pattern = "lib")
    dir.create(lib)
    dir.create(file.path(root, "man"))
    writeLines(
      c("export(Foo)"),
      file.path(root, "NAMESPACE")
    )
    writeLines("Foo <- function() 1", file.path(root, "R", "foo.R"))
    writeLines(
      c(
        "\\name{Foo}", "\\alias{Foo}", "\\title{Foo}", "\\usage{Foo()}",
        "\\description{Returns 1.}"
      ),
      file.path(root, "man", "Foo.Rd")
    )
    system2(
      command = file.path(R.home("bin"), "R"),
      args = c("CMD", "INSTALL", "-l", shQuote(lib), shQuote(root)),
      stdout = FALSE,
      stderr = FALSE
    )
    testthat::test_that(
      paste(text, "writes the PDF manual into .setup/build"),
      {
        testthat::skip_if_not(dir.exists(file.path(lib, "manualPkg")))
        .libPaths(c(lib, .libPaths()))
        dir.create(file.path(root, ".setup", "build"))
        wd <- setwd(root)
        on.exit(setwd(wd), add = TRUE)
        suppressWarnings(Manual(path = root, project = "manualPkg"))
        testthat::expect_true(
          file.exists(file.path(root, ".setup", "build", "manualPkg.pdf"))
        )
        testthat::expect_false(file.exists(file.path(root, "manualPkg.pdf")))
      }
    )
    testthat::test_that(
      paste(text, "skips folders that are not packages"),
      {
        other <- .TestProject(description = FALSE)
        testthat::expect_message(
          Manual(path = other, project = "x"),
          "is not an R package"
        )
        unlink(dirname(other), recursive = TRUE)
      }
    )
    .TestRestore(state)
    unlink(c(dirname(root), lib), recursive = TRUE)
  },
  text = "test-rProject-manual"
)

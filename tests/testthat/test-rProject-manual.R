## ---- test-rProject-manual
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if(
      condition = Sys.which(names = "pdflatex") == "",
      message = "pdflatex not found"
    )
    state <- .TestState()
    root <- .TestProject(name = "manualPkg")
    lib <- tempfile(pattern = "lib")
    dir.create(path = lib)
    dir.create(path = file.path(root, "man"))
    writeLines(
      text = c("export(Foo)"),
      con = file.path(root, "NAMESPACE")
    )
    writeLines(
      text = "Foo <- function() 1",
      con = file.path(root, "R", "foo.R")
    )
    writeLines(
      text = c(
        "\\name{Foo}", "\\alias{Foo}", "\\title{Foo}", "\\usage{Foo()}",
        "\\description{Returns 1.}"
      ),
      con = file.path(root, "man", "Foo.Rd")
    )
    system2(
      command = file.path(R.home(component = "bin"), "R"),
      args = c(
        "CMD",
        "INSTALL",
        "-l",
        shQuote(string = lib),
        shQuote(string = root)
      ),
      stdout = FALSE,
      stderr = FALSE
    )
    testthat::test_that(
      desc = paste(text, "writes the PDF manual into .setup/build"),
      code = {
        testthat::skip_if_not(
          condition = dir.exists(paths = file.path(lib, "manualPkg"))
        )
        .libPaths(new = c(lib, .libPaths()))
        dir.create(path = file.path(root, ".setup", "build"))
        wd <- setwd(dir = root)
        on.exit(expr = setwd(dir = wd), add = TRUE)
        suppressWarnings(expr = Manual(path = root, project = "manualPkg"))
        testthat::expect_true(
          object = file.exists(
            file.path(root, ".setup", "build", "manualPkg.pdf")
          )
        )
        testthat::expect_false(
          object = file.exists(file.path(root, "manualPkg.pdf"))
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "skips folders that are not packages"),
      code = {
        other <- .TestProject(description = FALSE)
        testthat::expect_message(
          object = Manual(path = other, project = "x"),
          regexp = "is not an R package"
        )
        unlink(x = dirname(path = other), recursive = TRUE)
      }
    )
    .TestRestore(state = state)
    unlink(x = c(dirname(path = root), lib), recursive = TRUE)
  },
  text = "test-rProject-manual"
)

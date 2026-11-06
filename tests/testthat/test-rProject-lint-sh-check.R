## ---- test-rProject-lint-sh-check
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_on_os(os = "windows")
    testthat::test_that(
      desc = paste(text, "reads shellcheck's findings"),
      code = {
        root <- .TestLintProject(
          files = list("a.sh" = c("#!/usr/bin/env bash", "echo $x"))
        )
        # a stand-in, so the test does not depend on the image
        bin <- tempfile(pattern = "bin")
        dir.create(path = bin)
        stub <- file.path(bin, "shellcheck")
        writeLines(
          text = c(
            "#!/bin/sh",
            "shift",
            "echo \"$1:2:6: note: Double quote to prevent globbing. [SC2086]\""
          ),
          con = stub
        )
        Sys.chmod(paths = stub, mode = "755")
        old <- Sys.getenv(x = "PATH")
        Sys.setenv(PATH = paste(bin, old, sep = .Platform$path.sep))
        rows <- .LintShCheck(path = root)
        Sys.setenv(PATH = old)
        testthat::expect_identical(object = rows$file, expected = "a.sh")
        testthat::expect_identical(object = rows$line, expected = 2L)
        testthat::expect_identical(object = rows$rule, expected = "sh-check")
        unlink(x = bin, recursive = TRUE)
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "reports nothing without shellcheck"),
      code = {
        root <- .TestLintProject(files = list("a.sh" = "echo $x"))
        old <- Sys.getenv(x = "PATH")
        Sys.setenv(PATH = tempfile(pattern = "none"))
        rows <- .LintShCheck(path = root)
        Sys.setenv(PATH = old)
        testthat::expect_identical(object = nrow(x = rows), expected = 0L)
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-sh-check"
)

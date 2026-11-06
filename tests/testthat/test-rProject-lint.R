## ---- test-rProject-lint
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed(pkg = "lintr")
    .SkipUnlessSiteLibrary(pkgs = c("lintr", "distro"))
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      desc = paste(text, "reports lints with the house rules"),
      code = {
        writeLines(
          text = "bad_Name = function( x ) x",
          con = file.path(root, "R", "a.R")
        )
        lints <- Lint(path = root)
        testthat::expect_s3_class(object = lints, class = "lints")
        testthat::expect_true(object = length(x = lints) > 0L)
      }
    )
    testthat::test_that(
      desc = paste(text, "allows BigCamelCase and snake_case"),
      code = {
        writeLines(
          text = c(
            "Foo <- function(x) {",
            "  my_value <- x",
            "  my_value",
            "}"
          ),
          con = file.path(root, "R", "a.R")
        )
        testthat::expect_length(object = Lint(path = root), n = 0L)
      }
    )
    testthat::test_that(
      desc = paste(text, "skips .verify, from any working directory"),
      code = {
        dir.create(path = file.path(root, ".verify", "R"), recursive = TRUE)
        writeLines(
          text = "bad_Name = function( x ) x",
          con = file.path(root, ".verify", "R", "b.R")
        )
        old <- setwd(dir = tempdir())
        lints <- Lint(path = root)
        setwd(dir = old)
        testthat::expect_length(object = lints, n = 0L)
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-lint"
)

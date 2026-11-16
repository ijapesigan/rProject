## ---- test-rProject-upload-line-length-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    root <- tempfile()
    dir.create(path = file.path(root, "R"), recursive = TRUE)
    writeLines(
      text = c("x <- 1", paste0("# ", strrep(x = "a", times = 83))),
      con = file.path(root, "R", "long.R")
    )
    writeLines(
      text = "x <- 1",
      con = file.path(root, "R", "short.R")
    )
    testthat::test_that(
      desc = paste(text, "refuses a long line in a package upload"),
      code = {
        withr::local_envvar(.new = c(LINTR_ERROR_ON_LINT = NA))
        testthat::expect_error(
          object = .UploadLineLength(
            path = root,
            files = c("R/long.R", "R/short.R"),
            type = "cran"
          ),
          regexp = "R/long.R:2"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "passes short files, other types, and the switch"),
      code = {
        withr::local_envvar(.new = c(LINTR_ERROR_ON_LINT = NA))
        testthat::expect_silent(
          object = .UploadLineLength(
            path = root,
            files = "R/short.R",
            type = "cran"
          )
        )
        testthat::expect_silent(
          object = .UploadLineLength(
            path = root,
            files = "R/long.R",
            type = "man"
          )
        )
        withr::local_envvar(.new = c(LINTR_ERROR_ON_LINT = "false"))
        testthat::expect_silent(
          object = .UploadLineLength(
            path = root,
            files = "R/long.R",
            type = "cran"
          )
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-upload-line-length-dot"
)

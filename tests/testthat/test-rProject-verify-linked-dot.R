## ---- test-rProject-verify-linked-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "compares the copies with the pushed library"),
      code = {
        work <- tempfile(pattern = "linked")
        path <- file.path(work, "proj")
        copy <- file.path(path, ".setup", "r-dependencies", "libA")
        pushed <- file.path(work, "devel-libA", ".verify", "R")
        dir.create(path = copy, recursive = TRUE)
        dir.create(path = pushed, recursive = TRUE)
        writeLines(text = "x <- 1", con = file.path(copy, "libA-foo-dot.R"))
        writeLines(text = "x <- 1", con = file.path(pushed, "libA-foo-dot.R"))
        testthat::expect_equal(
          object = .LinkedSources(path = path),
          expected = list(libA = normalizePath(path = pushed))
        )
        x <- .VerifyLinked(path = path, private = path)
        testthat::expect_equal(
          object = unname(obj = x["status"]),
          expected = "pass"
        )
        writeLines(text = "x <- 2", con = file.path(pushed, "libA-foo-dot.R"))
        x <- .VerifyLinked(path = path, private = path)
        testthat::expect_equal(
          object = unname(obj = x["status"]),
          expected = "warn"
        )
        testthat::expect_match(
          object = x[["detail"]],
          regexp = "libA/libA-foo-dot.R (differs)",
          fixed = TRUE
        )
        unlink(x = work, recursive = TRUE)
      }
    )
  },
  text = "test-rProject-verify-linked-dot"
)

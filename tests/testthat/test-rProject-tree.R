## ---- test-rProject-tree
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    cat(
      "type <- \"lib\"\n",
      file = file.path(root, ".setup", "scripts", "project.R"),
      append = TRUE
    )
    dir.create(path = file.path(root, ".setup", "latex"))
    dir.create(path = file.path(root, ".setup", "cpp"))
    dir.create(path = file.path(root, ".setup", "odd"))
    testthat::test_that(
      paste(text, "flags missing and non-standard folders"),
      {
        out <- suppressMessages(expr = Tree(path = root))
        status <- stats::setNames(object = out$status, nm = out$folder)
        testthat::expect_equal(
          object = status[[".setup/latex/"]],
          expected = "present"
        )
        testthat::expect_equal(
          object = status[[".setup/r-miscellaneous/"]],
          expected = "missing"
        )
        testthat::expect_equal(
          object = status[[".setup/ai/"]],
          expected = "absent"
        )
        testthat::expect_equal(
          object = status[[".setup/cpp/"]],
          expected = "not standard"
        )
        testthat::expect_equal(
          object = status[[".setup/odd/"]],
          expected = "unknown"
        )
        # R/ belongs to packages, not to lib
        testthat::expect_equal(
          object = status[["R/"]],
          expected = "not standard"
        )
        testthat::expect_message(
          object = Tree(path = root),
          regexp = "lib project"
        )
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-tree"
)

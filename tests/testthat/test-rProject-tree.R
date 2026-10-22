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
    dir.create(file.path(root, ".setup", "latex"))
    dir.create(file.path(root, ".setup", "cpp"))
    dir.create(file.path(root, ".setup", "odd"))
    testthat::test_that(
      paste(text, "flags missing and non-standard folders"),
      {
        out <- suppressMessages(Tree(path = root))
        status <- stats::setNames(out$status, out$folder)
        testthat::expect_equal(status[[".setup/latex/"]], "present")
        testthat::expect_equal(status[[".setup/r-miscellaneous/"]], "missing")
        testthat::expect_equal(status[[".setup/ai/"]], "absent")
        testthat::expect_equal(status[[".setup/cpp/"]], "not standard")
        testthat::expect_equal(status[[".setup/odd/"]], "unknown")
        # R/ belongs to packages, not to lib
        testthat::expect_equal(status[["R/"]], "not standard")
        testthat::expect_message(Tree(path = root), regexp = "lib project")
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-tree"
)

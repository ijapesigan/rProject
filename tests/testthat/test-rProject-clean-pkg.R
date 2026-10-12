## ---- test-rProject-clean-pkg
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # CleanPkg() removes every non-base package in every library path. To be
    # safe it runs in a separate base-R process (no site or user library),
    # with only a temporary library and base R on the path, and stops unless
    # that holds.
    testthat::skip_on_cran()
    testthat::skip_on_os("windows")
    # covr instruments CleanPkg(), so its copy cannot run in a clean process
    testthat::skip_if(identical(Sys.getenv("R_COVR"), "true"), "under covr")
    r_bin <- R.home("bin")
    root <- .TestProject()
    other <- tempfile(pattern = "otherlib")
    dir.create(other)
    pkg <- file.path(tempfile(pattern = "pkg"), "dummyPkg")
    dir.create(file.path(pkg, "R"), recursive = TRUE)
    writeLines(
      text = c(
        "Package: dummyPkg", "Version: 0.0.1", "Title: Dummy",
        "Description: Dummy.", "License: MIT", "Encoding: UTF-8"
      ),
      con = file.path(pkg, "DESCRIPTION")
    )
    writeLines("", file.path(pkg, "NAMESPACE"))
    system2(
      command = file.path(r_bin, "R"),
      args = c("CMD", "INSTALL", "-l", shQuote(other), shQuote(pkg)),
      stdout = FALSE,
      stderr = FALSE
    )
    script <- tempfile(fileext = ".R")
    writeLines(
      text = c(
        paste("LibPaths <-", paste(deparse(LibPaths), collapse = "\n")),
        paste("CleanPkg <-", paste(deparse(CleanPkg), collapse = "\n")),
        paste0(".libPaths(\"", other, "\")"),
        "# refuse to run unless every library path is temporary or base R",
        paste0("safe <- normalizePath(c(\"", other, "\", .Library))"),
        "if (!all(normalizePath(.libPaths()) %in% safe)) {",
        "  stop(",
        "    \"unsafe library paths: \",",
        "    paste(.libPaths(), collapse = \", \")",
        "  )",
        "}",
        "invisible(CleanPkg(path = commandArgs(TRUE)[1]))",
        "cat(\"done\\n\")"
      ),
      con = script
    )
    testthat::test_that(
      paste(text, "empties .library and removes packages in other libraries"),
      {
        testthat::skip_if_not(
          dir.exists(file.path(other, "dummyPkg")),
          "could not install the dummy package"
        )
        dir.create(file.path(root, ".library"))
        writeLines("x", file.path(root, ".library", "old.txt"))
        out <- suppressWarnings(
          system2(
            command = file.path(r_bin, "Rscript"),
            args = c("--vanilla", shQuote(script), shQuote(root)),
            env = c(paste0("R_LIBS_SITE=", other), "R_LIBS_USER=", "R_LIBS="),
            stdout = TRUE,
            stderr = TRUE
          )
        )
        testthat::expect_false(any(grepl("unsafe library paths", out)))
        testthat::expect_true("done" %in% out)
        testthat::expect_false(dir.exists(file.path(other, "dummyPkg")))
        testthat::expect_false(
          file.exists(file.path(root, ".library", "old.txt"))
        )
        testthat::expect_true(dir.exists(file.path(root, ".library")))
      }
    )
    unlink(c(dirname(root), other, dirname(pkg), script), recursive = TRUE)
  },
  text = "test-rProject-clean-pkg"
)

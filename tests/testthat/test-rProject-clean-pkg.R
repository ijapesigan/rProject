## ---- test-rProject-clean-pkg
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # CleanPkg() removes .library only; a package in another library path
    # stays. It runs in a separate base-R process (no site or user library),
    # with only a temporary library and base R on the path, and stops unless
    # that holds.
    testthat::skip_on_cran()
    testthat::skip_on_os(os = "windows")
    # covr instruments CleanPkg(), so its copy cannot run in a clean process
    testthat::skip_if(
      condition = identical(x = Sys.getenv(x = "R_COVR"), y = "true"),
      message = "under covr"
    )
    r_bin <- R.home(component = "bin")
    root <- .TestProject()
    other <- tempfile(pattern = "otherlib")
    dir.create(path = other)
    pkg <- file.path(tempfile(pattern = "pkg"), "dummyPkg")
    dir.create(path = file.path(pkg, "R"), recursive = TRUE)
    writeLines(
      text = c(
        "Package: dummyPkg", "Version: 0.0.1", "Title: Dummy",
        "Description: Dummy.", "License: MIT", "Encoding: UTF-8"
      ),
      con = file.path(pkg, "DESCRIPTION")
    )
    writeLines(text = "", con = file.path(pkg, "NAMESPACE"))
    system2(
      command = file.path(r_bin, "R"),
      args = c(
        "CMD",
        "INSTALL",
        "-l",
        shQuote(string = other),
        shQuote(string = pkg)
      ),
      stdout = FALSE,
      stderr = FALSE
    )
    script <- tempfile(fileext = ".R")
    writeLines(
      text = c(
        paste("LibPaths <-", paste(deparse(expr = LibPaths), collapse = "\n")),
        paste("CleanPkg <-", paste(deparse(expr = CleanPkg), collapse = "\n")),
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
      paste(text, "empties .library and keeps packages in other libraries"),
      {
        testthat::skip_if_not(
          condition = dir.exists(paths = file.path(other, "dummyPkg")),
          message = "could not install the dummy package"
        )
        dir.create(path = file.path(root, ".library"))
        writeLines(text = "x", con = file.path(root, ".library", "old.txt"))
        out <- suppressWarnings(
          expr = system2(
            command = file.path(r_bin, "Rscript"),
            args = c(
              "--vanilla",
              shQuote(string = script),
              shQuote(string = root)
            ),
            env = c(paste0("R_LIBS_SITE=", other), "R_LIBS_USER=", "R_LIBS="),
            stdout = TRUE,
            stderr = TRUE
          )
        )
        testthat::expect_false(
          object = any(grepl(pattern = "unsafe library paths", x = out))
        )
        testthat::expect_true(object = "done" %in% out)
        testthat::expect_true(
          object = dir.exists(paths = file.path(other, "dummyPkg"))
        )
        testthat::expect_false(
          object = file.exists(file.path(root, ".library", "old.txt"))
        )
        testthat::expect_true(
          object = dir.exists(paths = file.path(root, ".library"))
        )
      }
    )
    unlink(
      x = c(dirname(path = root), other, dirname(path = pkg), script),
      recursive = TRUE
    )
  },
  text = "test-rProject-clean-pkg"
)

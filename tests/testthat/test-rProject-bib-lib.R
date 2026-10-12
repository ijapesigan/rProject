## ---- test-rProject-bib-lib
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "clones the lib-* libraries, keeps their .bib files (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(Sys.which("git") == "")
        root <- .TestProject()
        wd <- getwd()
        suppressWarnings(BibLib(path = root))
        bib_dir <- file.path(root, ".setup", "latex", "bib")
        testthat::expect_true(
          length(list.files(bib_dir, pattern = "^lib-.*\\.bib$")) > 0L
        )
        # the clones are removed, and the working directory is restored
        testthat::expect_length(
          list.dirs(bib_dir, recursive = FALSE),
          0L
        )
        testthat::expect_equal(getwd(), wd)
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-bib-lib"
)

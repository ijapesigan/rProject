## ---- test-rProject-bib-lib
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "clones the lib-* libraries, keeps their .bib files (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(condition = Sys.which(names = "git") == "")
        root <- .TestProject()
        wd <- getwd()
        suppressWarnings(expr = BibLib(path = root))
        bib_dir <- file.path(root, ".setup", "latex", "bib")
        testthat::expect_true(
          object = length(
            x = list.files(path = bib_dir, pattern = "^lib-.*\\.bib$")
          ) > 0L
        )
        # the clones are removed, and the working directory is restored
        testthat::expect_length(
          object = list.dirs(path = bib_dir, recursive = FALSE),
          n = 0L
        )
        testthat::expect_equal(object = getwd(), expected = wd)
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-bib-lib"
)

## ---- test-rProject-bib-keep
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "bibkeep")
    bib_dir <- file.path(root, ".setup", "latex", "bib")
    dir.create(
      path = bib_dir,
      recursive = TRUE
    )
    entry <- c("@Article{Key-2000,", "  title = {Title},", "}")
    writeLines(
      text = entry,
      con = file.path(bib_dir, "bib.bib")
    )
    testthat::test_that(
      desc = paste(text, "keeps bib.bib when no lib-* repository is cloned"),
      code = {
        testthat::local_mocked_bindings(
          BibLib = function(path) {
            NULL
          }
        )
        testthat::expect_warning(
          object = Bib(path = root, bib_lib = TRUE),
          regexp = "keeping the previous bib.bib"
        )
        testthat::expect_equal(
          object = readLines(con = file.path(bib_dir, "bib.bib")),
          expected = entry
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-bib-keep"
)

## ---- test-rProject-latex-log-check
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    dir <- tempfile(pattern = "latexlog")
    dir.create(dir)
    good <- file.path(dir, "good.log")
    stub <- file.path(dir, "stub.log")
    full <- file.path(dir, "full.log")
    writeLines(
      text = "Output written on good.pdf (78 pages, 334979 bytes).",
      con = good
    )
    writeLines(
      text = c(
        "!  ==> Fatal error occurred, no output PDF file produced!",
        "Transcript written on stub.log."
      ),
      con = stub
    )
    writeLines(
      text = "! TeX capacity exceeded, sorry [main memory size=5000000].",
      con = full
    )
    testthat::test_that(
      paste(text, "names the documents whose last run failed"),
      {
        out <- .LatexLogCheck(
          logs = c(good, stub, full, file.path(dir, "missing.log"))
        )
        testthat::expect_equal(unname(out), c(stub, full))
      }
    )
    testthat::test_that(
      paste(text, "is empty when every document compiled"),
      {
        testthat::expect_length(.LatexLogCheck(logs = good), 0)
      }
    )
    unlink(dir, recursive = TRUE)
  },
  text = "test-rProject-latex-log-check"
)

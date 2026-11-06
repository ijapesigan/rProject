## ---- test-rProject-latex-tikz-png
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "an empty folder writes nothing"),
      {
        pdf_folder <- file.path(tempfile(), "pdf")
        dir.create(path = pdf_folder, recursive = TRUE)
        testthat::expect_false(
          object = dir.exists(paths = .LatexTikzPng(pdf_folder = pdf_folder))
        )
        unlink(x = dirname(path = pdf_folder), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "a PDF gets a PNG, rebuilt only when newer"),
      {
        testthat::skip_if(condition = Sys.which(names = "pdftoppm") == "")
        pdf_folder <- file.path(tempfile(), "pdf")
        dir.create(path = pdf_folder, recursive = TRUE)
        grDevices::pdf(file = file.path(pdf_folder, "a.pdf"))
        graphics::plot.new()
        grDevices::dev.off()
        png_folder <- .LatexTikzPng(pdf_folder = pdf_folder)
        png_file <- file.path(png_folder, "a.png")
        testthat::expect_true(object = file.exists(png_file))
        Sys.setFileTime(path = png_file, time = Sys.time() + 60)
        first <- file.mtime(png_file)
        .LatexTikzPng(pdf_folder = pdf_folder)
        testthat::expect_identical(
          object = file.mtime(png_file),
          expected = first
        )
        unlink(x = dirname(path = pdf_folder), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-latex-tikz-png"
)

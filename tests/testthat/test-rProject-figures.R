## ---- test-rProject-figures
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    tools_folder <- system.file(
      "template",
      "common",
      "dot-setup",
      "r-miscellaneous",
      "texTools",
      package = "rProject"
    )
    testthat::skip_if(condition = !nzchar(x = tools_folder))
    env <- new.env()
    for (file in list.files(path = tools_folder, full.names = TRUE)) {
      sys.source(file = file, envir = env)
    }
    testthat::test_that(
      paste(text, "the presets and palette"),
      {
        testthat::expect_equal(
          object = env$.FigSize(size = "column")$width,
          expected = 3.3
        )
        testthat::expect_equal(
          object = env$.FigSize(size = "page")$height,
          expected = 4
        )
        testthat::expect_equal(
          object = env$.FigSize(size = "slide", height = 2)$height,
          expected = 2
        )
        testthat::expect_error(object = env$.FigSize(size = "poster"))
        testthat::expect_length(object = env$.OkabeIto(), n = 8L)
      }
    )
    testthat::test_that(
      paste(text, "tables"),
      {
        testthat::expect_equal(
          object = env$.Round(x = 1.234, digits = 2),
          expected = "1.23"
        )
        testthat::expect_match(
          object = env$.Tabular(x = data.frame(a = 1.234), digits = 1),
          regexp = "\\$1.2\\$"
        )
      }
    )
    testthat::test_that(
      paste(text, "GifWrite gives the GIF, frames, and multi-page PDF"),
      {
        testthat::skip_if_not_installed(pkg = "ggplot2")
        testthat::skip_if_not_installed(pkg = "magick")
        root <- tempfile()
        dir.create(path = root)
        fig <- function(frame, size) {
          ggplot2::ggplot(
            data = data.frame(x = frame, y = frame),
            mapping = ggplot2::aes(x = x, y = y)
          ) +
            ggplot2::geom_point()
        }
        gif <- env$GifWrite(
          fig = fig,
          frames = 1:2,
          name = "a",
          fps = 5,
          path = root
        )
        figures <- file.path(root, ".setup", "latex", "figures")
        testthat::expect_true(object = file.exists(gif))
        testthat::expect_true(
          object = file.exists(file.path(figures, "gif", "a.pdf"))
        )
        testthat::expect_length(
          object = list.files(path = file.path(figures, "gif-frames", "a")),
          n = 2L
        )
        testthat::expect_error(
          object = env$GifWrite(
            fig = fig,
            frames = 1,
            name = "b",
            fps = 3,
            path = root
          )
        )
        unlink(x = root, recursive = TRUE)
      }
    )
  },
  text = "test-rProject-figures"
)

## ---- test-rProject-conform-sim-make-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "flags a .sim/make.sh that differs"),
      code = {
        root <- .TestProject()
        template <- list(
          root = system.file("template", package = "rProject")
        )
        source <- file.path(template$root, "once", "sim-make.sh")
        testthat::skip_if_not(condition = file.exists(source))
        dir.create(path = file.path(root, ".sim"))
        # no copy: nothing to flag (make project writes it)
        testthat::expect_equal(
          object = nrow(x = .ConformSimMake(path = root, template = template)),
          expected = 0L
        )
        file.copy(from = source, to = file.path(root, ".sim", "make.sh"))
        testthat::expect_equal(
          object = nrow(x = .ConformSimMake(path = root, template = template)),
          expected = 0L
        )
        writeLines(text = "# own", con = file.path(root, ".sim", "make.sh"))
        rows <- .ConformSimMake(path = root, template = template)
        testthat::expect_equal(object = rows$file, expected = ".sim/make.sh")
        testthat::expect_equal(object = rows$class, expected = "decide")
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-conform-sim-make-dot"
)

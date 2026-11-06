## ---- test-rProject-data-process
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    dir <- file.path(root, ".setup", "data-process")
    dir.create(path = dir, recursive = TRUE)
    out <- file.path(dir, "out.Rds")
    writeLines(
      text = paste0("saveRDS(1, ", deparse(expr = out), ")"),
      con = file.path(dir, "data-process-001.R")
    )
    testthat::test_that(
      paste(text, "sources the data-process scripts"),
      {
        DataProcess(path = root)
        testthat::expect_equal(object = readRDS(file = out), expected = 1)
      }
    )
    testthat::test_that(
      paste(text, "with clean = TRUE removes old .Rds before running"),
      {
        stale <- file.path(dir, "stale.Rds")
        saveRDS(object = 0, file = stale)
        DataProcess(path = root, clean = TRUE)
        testthat::expect_false(object = file.exists(stale))
        testthat::expect_true(object = file.exists(out))
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-data-process"
)

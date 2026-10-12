## ---- test-rProject-data-process
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    dir <- file.path(root, ".setup", "data-process")
    dir.create(dir, recursive = TRUE)
    out <- file.path(dir, "out.Rds")
    writeLines(
      text = paste0("saveRDS(1, ", deparse(out), ")"),
      con = file.path(dir, "data-process-001.R")
    )
    testthat::test_that(
      paste(text, "sources the data-process scripts"),
      {
        DataProcess(path = root)
        testthat::expect_equal(readRDS(out), 1)
      }
    )
    testthat::test_that(
      paste(text, "with clean = TRUE removes old .Rds before running"),
      {
        stale <- file.path(dir, "stale.Rds")
        saveRDS(0, stale)
        DataProcess(path = root, clean = TRUE)
        testthat::expect_false(file.exists(stale))
        testthat::expect_true(file.exists(out))
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-data-process"
)

## ---- test-rProject-data-analysis
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    process <- file.path(root, ".setup", "data-process")
    analysis <- file.path(root, ".setup", "data-analysis")
    dir.create(process, recursive = TRUE)
    dir.create(analysis, recursive = TRUE)
    processed <- file.path(process, "processed.Rds")
    result <- file.path(analysis, "result.Rds")
    writeLines(
      text = paste0("saveRDS(2, \"", processed, "\")"),
      con = file.path(process, "data-process-001.R")
    )
    writeLines(
      text = paste0(
        "saveRDS(readRDS(\"", processed, "\") * 3, \"", result, "\")"
      ),
      con = file.path(analysis, "data-analysis-001.R")
    )
    testthat::test_that(
      paste(text, "runs data-process first, then data-analysis"),
      {
        DataAnalysis(path = root)
        testthat::expect_equal(readRDS(result), 6)
      }
    )
    testthat::test_that(
      paste(text, "with clean = TRUE removes old .Rds in both folders"),
      {
        stale <- file.path(analysis, "stale.Rds")
        saveRDS(0, stale)
        DataAnalysis(path = root, clean = TRUE)
        testthat::expect_false(file.exists(stale))
        testthat::expect_equal(readRDS(result), 6)
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-data-analysis"
)

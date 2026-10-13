## ---- test-rProject-data-manifest-used-by
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    write <- function(root, file, text) {
      dir.create(
        dirname(file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    root <- tempfile(pattern = "used-by")
    use <- "x <- readRDS(DataPath(\"ema.Rds\"))"
    write(root, ".setup/data-analysis/data-analysis-ema.R", use)
    write(root, ".setup/data-process/data-process-ema.R", use)
    write(root, ".setup/notes/note.R", use)
    # data stores, AI files, and logs are not scripts that use the data
    write(root, ".setup/data-private/README.R", use)
    write(root, ".setup/ai/plan.R", use)
    write(root, ".setup/logs/log.R", use)
    testthat::test_that(
      paste(text, "keeps the data-analysis and data-process scripts"),
      {
        used <- strsplit(
          .DataManifestUsedBy(
            path = root,
            files = file.path(root, ".setup", "data-private", "ema.Rds.xz")
          ),
          split = ", "
        )[[1]]
        testthat::expect_setequal(
          used,
          c(
            ".setup/data-analysis/data-analysis-ema.R",
            ".setup/data-process/data-process-ema.R",
            ".setup/notes/note.R"
          )
        )
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-data-manifest-used-by"
)

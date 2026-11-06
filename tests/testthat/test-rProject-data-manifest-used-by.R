## ---- test-rProject-data-manifest-used-by
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    write <- function(root, file, text) {
      dir.create(
        path = dirname(path = file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    root <- tempfile(pattern = "used-by")
    use <- "x <- readRDS(DataPath(\"ema.Rds\"))"
    write(
      root = root,
      file = ".setup/data-analysis/data-analysis-ema.R",
      text = use
    )
    write(
      root = root,
      file = ".setup/data-process/data-process-ema.R",
      text = use
    )
    write(root = root, file = ".setup/notes/note.R", text = use)
    # data stores, AI files, and logs are not scripts that use the data
    write(root = root, file = ".setup/data-private/README.R", text = use)
    write(root = root, file = ".setup/ai/plan.R", text = use)
    write(root = root, file = ".setup/logs/log.R", text = use)
    testthat::test_that(
      paste(text, "keeps the data-analysis and data-process scripts"),
      {
        used <- strsplit(
          x = .DataManifestUsedBy(
            path = root,
            files = file.path(root, ".setup", "data-private", "ema.Rds.xz")
          ),
          split = ", "
        )[[1]]
        testthat::expect_setequal(
          object = used,
          expected = c(
            ".setup/data-analysis/data-analysis-ema.R",
            ".setup/data-process/data-process-ema.R",
            ".setup/notes/note.R"
          )
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-data-manifest-used-by"
)

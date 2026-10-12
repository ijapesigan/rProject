## ---- test-rProject-data
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "data with space ")
    dirs <- file.path(
      root,
      ".setup",
      c("data-raw", "data-private", "data-external", "scripts")
    )
    for (dir in dirs) {
      dir.create(dir, recursive = TRUE)
    }
    data <- data.frame(x = 1:500, y = stats::rnorm(500))
    raw <- file.path(root, ".setup", "data-raw", "ema.txt")
    utils::write.table(data, file = raw, row.names = FALSE)
    writeLines(
      text = "x <- 1",
      con = file.path(root, ".setup", "data-private", "restricted.txt")
    )
    writeLines(
      text = "big",
      con = file.path(root, ".setup", "data-external", "posterior.txt")
    )
    writeLines(
      text = "d <- DataPath(path = root, file = \"ema.txt\")",
      con = file.path(root, ".setup", "scripts", "analysis.R")
    )
    original <- utils::read.table(raw, header = TRUE)
    testthat::test_that(
      paste(text, "finds files in the tiers"),
      {
        testthat::expect_equal(
          normalizePath(DataPath(path = root, file = "ema.txt")),
          normalizePath(raw)
        )
        testthat::expect_match(
          DataPath(path = root, file = "restricted.txt"),
          "data-private"
        )
        testthat::expect_error(
          DataPath(path = root, file = "missing.txt"),
          "data-external"
        )
      }
    )
    compressed <- suppressMessages(
      DataCompress(path = root, files = ".setup/data-raw/ema.txt")
    )
    testthat::test_that(
      paste(text, "compresses, checks, and still finds the file"),
      {
        testthat::expect_false(file.exists(raw))
        testthat::expect_true(file.exists(paste0(raw, ".xz")))
        found <- DataPath(path = root, file = "ema.txt")
        testthat::expect_match(found, "ema\\.txt\\.xz$")
        testthat::expect_equal(
          utils::read.table(found, header = TRUE),
          original
        )
        testthat::expect_false(.SizeCheckIsText(file = found))
      }
    )
    testthat::test_that(
      paste(text, "unpacks a plain copy into the cache and refreshes it"),
      {
        plain <- DataPath(path = root, file = "ema.txt", plain = TRUE)
        testthat::expect_match(plain, "data-cache/ema\\.txt$")
        testthat::expect_equal(
          utils::read.table(plain, header = TRUE),
          original
        )
        # a new compressed version replaces the cached copy
        changed <- data.frame(x = 1:3, y = 3:1)
        utils::write.table(changed, file = raw, row.names = FALSE)
        unlink(paste0(raw, ".xz"))
        suppressMessages(
          DataCompress(path = root, files = ".setup/data-raw/ema.txt")
        )
        plain <- DataPath(path = root, file = "ema.txt", plain = TRUE)
        testthat::expect_equal(
          utils::read.table(plain, header = TRUE),
          changed
        )
      }
    )
    manifest_file <- file.path(root, ".setup", "ai", "data.md")
    manifest <- suppressMessages(DataManifest(path = root))
    testthat::test_that(
      paste(text, "writes the manifest with tiers and users"),
      {
        testthat::expect_true(file.exists(manifest_file))
        testthat::expect_setequal(
          manifest$tier,
          c("raw", "private", "external")
        )
        testthat::expect_match(
          manifest$used_by[manifest$file == ".setup/data-raw/ema.txt.xz"],
          ".setup/scripts/analysis.R",
          fixed = TRUE
        )
        testthat::expect_true(all(manifest$status == "ok"))
      }
    )
    testthat::test_that(
      paste(text, "keeps user columns and flags external files"),
      {
        lines <- readLines(manifest_file)
        row <- grep("restricted.txt", lines, fixed = TRUE)
        cells <- strsplit(lines[row], "|", fixed = TRUE)[[1]]
        cells[7] <- " ADID study "
        cells[8] <- " Roar work "
        lines[row] <- paste0(paste(cells, collapse = "|"), "|")
        writeLines(lines, manifest_file)
        writeLines(
          text = "bigger",
          con = file.path(root, ".setup", "data-external", "posterior.txt")
        )
        manifest <- suppressMessages(DataManifest(path = root))
        private <- manifest[
          manifest$file == ".setup/data-private/restricted.txt", ,
          drop = FALSE
        ]
        testthat::expect_equal(private$source, "ADID study")
        testthat::expect_equal(private$location, "Roar work")
        external <- ".setup/data-external/posterior.txt"
        testthat::expect_equal(
          manifest$status[manifest$file == external],
          "changed"
        )
        unlink(file.path(root, external))
        manifest <- suppressMessages(DataManifest(path = root))
        testthat::expect_equal(
          manifest$status[manifest$file == external],
          "not on this machine"
        )
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-data"
)

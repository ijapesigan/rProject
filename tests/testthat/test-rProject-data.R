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
      dir.create(path = dir, recursive = TRUE)
    }
    data <- data.frame(x = 1:500, y = stats::rnorm(n = 500))
    raw <- file.path(root, ".setup", "data-raw", "ema.txt")
    utils::write.table(x = data, file = raw, row.names = FALSE)
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
    original <- utils::read.table(file = raw, header = TRUE)
    testthat::test_that(
      desc = paste(text, "finds files in the tiers"),
      code = {
        testthat::expect_equal(
          object = normalizePath(
            path = DataPath(path = root, file = "ema.txt")
          ),
          expected = normalizePath(path = raw)
        )
        testthat::expect_match(
          object = DataPath(path = root, file = "restricted.txt"),
          regexp = "data-private"
        )
        testthat::expect_error(
          object = DataPath(path = root, file = "missing.txt"),
          regexp = "data-external"
        )
      }
    )
    compressed <- suppressMessages(
      expr = DataCompress(path = root, files = ".setup/data-raw/ema.txt")
    )
    testthat::test_that(
      desc = paste(text, "compresses, checks, and still finds the file"),
      code = {
        testthat::expect_false(object = file.exists(raw))
        testthat::expect_true(object = file.exists(paste0(raw, ".xz")))
        found <- DataPath(path = root, file = "ema.txt")
        testthat::expect_match(object = found, regexp = "ema\\.txt\\.xz$")
        testthat::expect_equal(
          object = utils::read.table(file = found, header = TRUE),
          expected = original
        )
        testthat::expect_false(object = .SizeCheckIsText(file = found))
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "unpacks a plain copy into the cache and refreshes it"
      ),
      code = {
        plain <- DataPath(path = root, file = "ema.txt", plain = TRUE)
        testthat::expect_match(object = plain, regexp = "data-cache/ema\\.txt$")
        testthat::expect_equal(
          object = utils::read.table(file = plain, header = TRUE),
          expected = original
        )
        # a new compressed version replaces the cached copy
        changed <- data.frame(x = 1:3, y = 3:1)
        utils::write.table(x = changed, file = raw, row.names = FALSE)
        unlink(x = paste0(raw, ".xz"))
        suppressMessages(
          expr = DataCompress(path = root, files = ".setup/data-raw/ema.txt")
        )
        plain <- DataPath(path = root, file = "ema.txt", plain = TRUE)
        testthat::expect_equal(
          object = utils::read.table(file = plain, header = TRUE),
          expected = changed
        )
      }
    )
    manifest_file <- file.path(root, ".setup", "ai", "data.md")
    manifest <- suppressMessages(expr = DataManifest(path = root))
    testthat::test_that(
      desc = paste(text, "writes the manifest with tiers and users"),
      code = {
        testthat::expect_true(object = file.exists(manifest_file))
        testthat::expect_setequal(
          object = manifest$tier,
          expected = c("raw", "private", "external")
        )
        testthat::expect_match(
          object = manifest$used_by[
            manifest$file == ".setup/data-raw/ema.txt.xz"
          ],
          regexp = ".setup/scripts/analysis.R",
          fixed = TRUE
        )
        testthat::expect_true(object = all(manifest$status == "ok"))
      }
    )
    testthat::test_that(
      desc = paste(text, "keeps user columns and flags external files"),
      code = {
        lines <- readLines(con = manifest_file)
        row <- grep(pattern = "restricted.txt", x = lines, fixed = TRUE)
        cells <- strsplit(x = lines[row], split = "|", fixed = TRUE)[[1]]
        cells[7] <- " ADID study "
        cells[8] <- " Roar work "
        lines[row] <- paste0(paste(cells, collapse = "|"), "|")
        writeLines(text = lines, con = manifest_file)
        writeLines(
          text = "bigger",
          con = file.path(root, ".setup", "data-external", "posterior.txt")
        )
        manifest <- suppressMessages(expr = DataManifest(path = root))
        private <- manifest[
          manifest$file == ".setup/data-private/restricted.txt", ,
          drop = FALSE
        ]
        testthat::expect_equal(object = private$source, expected = "ADID study")
        testthat::expect_equal(
          object = private$location,
          expected = "Roar work"
        )
        external <- ".setup/data-external/posterior.txt"
        testthat::expect_equal(
          object = manifest$status[manifest$file == external],
          expected = "changed"
        )
        unlink(x = file.path(root, external))
        manifest <- suppressMessages(expr = DataManifest(path = root))
        testthat::expect_equal(
          object = manifest$status[manifest$file == external],
          expected = "not on this machine"
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-data"
)

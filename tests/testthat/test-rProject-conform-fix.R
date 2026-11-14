## ---- test-rProject-conform-fix
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestConform()
    dest <- tempfile(pattern = "upload")
    tier_one <- ".setup/latex/preamble/preamble.tex"
    edited <- ".setup/latex/preamble/001-preamble-encoding.tex"
    unlink(
      x = file.path(
        root,
        c("vignettes/.gitignore", "inst/CITATION", "tests/testthat.R", tier_one)
      )
    )
    writeLines(text = "x", con = file.path(root, "main.tex"))
    dir.create(path = file.path(root, ".tmp-r"))
    cat("\n% mine\n", file = file.path(root, edited), append = TRUE)
    before <- readLines(con = file.path(root, edited))
    out <- suppressMessages(
      expr = ConformFix(
        path = root,
        topic = "conform",
        dest = dest,
        remove = TRUE
      )
    )
    log <- list.files(
      path = file.path(root, ".setup", "logs"),
      pattern = "-conform\\.md$"
    )
    lines <- readLines(con = out$log)
    testthat::test_that(
      desc = paste(text, "restores the files and removes the strays"),
      code = {
        testthat::expect_setequal(
          object = out$new,
          expected = c(
            "vignettes/.gitignore", "inst/CITATION", "tests/testthat.R",
            tier_one
          )
        )
        testthat::expect_true(
          object = all(file.exists(file.path(root, out$new)))
        )
        testthat::expect_equal(
          object = readLines(con = file.path(root, "tests/testthat.R")),
          expected = c(
            "library(testthat)",
            "library(conformPkg)",
            "",
            "test_check(\"conformPkg\")"
          )
        )
        testthat::expect_equal(object = out$overleaf, expected = "main.tex")
        testthat::expect_equal(object = out$local, expected = ".tmp-r/")
        testthat::expect_false(
          object = file.exists(file.path(root, "main.tex"))
        )
        testthat::expect_false(
          object = dir.exists(paths = file.path(root, ".tmp-r"))
        )
        # never overwrites an edited file
        testthat::expect_equal(
          object = readLines(con = file.path(root, edited)),
          expected = before
        )
        after <- suppressMessages(expr = Conform(path = root))
        testthat::expect_false(object = any(after$class == "fix"))
      }
    )
    testthat::test_that(
      desc = paste(text, "leaves no TODO placeholder in the log"),
      code = {
        testthat::expect_false(object = any(grepl(pattern = "TODO", x = lines)))
        testthat::expect_true(
          object = any(grepl(pattern = "^Spec: rProject", x = lines))
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "writes the log section and the upload folder"),
      code = {
        testthat::expect_length(object = log, n = 1L)
        testthat::expect_true(
          object = any(
            grepl(pattern = "^## Structure audit additions", x = lines)
          )
        )
        testthat::expect_true(object = "- new: inst/CITATION" %in% lines)
        testthat::expect_true(
          object = "- delete in Overleaf: main.tex" %in% lines
        )
        testthat::expect_true(
          object = any(
            grepl(
              pattern = "create `vignettes/.gitignore` by hand",
              x = lines
            )
          )
        )
        testthat::expect_false(
          object = grepl(pattern = "-fixup$", x = out$folder)
        )
        testthat::expect_true(
          object = all(
            file.exists(
              file.path(
                out$folder,
                c(
                  out$new,
                  file.path(".setup", "logs", log),
                  ".setup/logs/index.md"
                )
              )
            )
          )
        )
        testthat::expect_false(
          object = file.exists(file.path(out$folder, "main.tex"))
        )
        # nothing left to fix
        testthat::expect_message(
          object = again <- ConformFix(path = root, dest = dest),
          regexp = "nothing to fix"
        )
        testthat::expect_null(object = again$folder)
        testthat::expect_length(object = again$new, n = 0L)
      }
    )
  },
  text = "test-rProject-conform-fix"
)

lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestConform()
    dest <- tempfile(pattern = "upload")
    suppressMessages(
      expr = Log(path = root, topic = "template", summary = "Template")
    )
    log <- list.files(
      path = file.path(root, ".setup", "logs"),
      pattern = "-template\\.md$"
    )
    unlink(x = file.path(root, "inst/CITATION"))
    first <- suppressMessages(
      expr = ConformFix(path = root, topic = "template", dest = dest)
    )
    testthat::test_that(
      desc = paste(text, "a log that was not pushed gets the folder in place"),
      code = {
        testthat::expect_equal(
          object = basename(path = first$folder),
          expected = paste0(
            substr(x = log, start = 1, stop = 11),
            "conformPkg-template"
          )
        )
        testthat::expect_true(
          object = file.exists(file.path(first$folder, "inst/CITATION"))
        )
      }
    )
    index <- file.path(root, ".setup", "logs", "index.md")
    lines <- readLines(con = index)
    writeLines(
      text = sub(
        pattern = "(pending)",
        replacement = "abc1234",
        x = lines,
        fixed = TRUE
      ),
      con = index
    )
    unlink(x = file.path(root, "vignettes/.gitignore"))
    second <- suppressMessages(
      expr = ConformFix(path = root, topic = "template", dest = dest)
    )
    testthat::test_that(
      desc = paste(text, "a pushed log gets a fix-up and a -fixup folder"),
      code = {
        testthat::expect_true(
          object = grepl(pattern = "template-fixup$", x = second$folder)
        )
        testthat::expect_true(
          object = file.exists(file.path(second$folder, "vignettes/.gitignore"))
        )
        text_log <- readLines(con = second$log)
        testthat::expect_true(
          object = any(
            grepl(pattern = "^## Fix-up: Fix-up: structure audit", x = text_log)
          )
        )
        testthat::expect_equal(
          object = sum(
            grepl(pattern = "^## Structure audit additions", x = text_log)
          ),
          expected = 2L
        )
      }
    )
  },
  text = "test-rProject-conform-fix"
)

lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestConform()
    reference <- .TestConform(name = "refPkg", public = "ijapesigan/refPkg")
    writeLines(
      text = c("refPkg citation", "line"),
      con = file.path(reference, "inst", "CITATION")
    )
    unlink(x = file.path(root, c("inst/CITATION", "vignettes/.gitignore")))
    writeLines(text = "x", con = file.path(root, "inst", "CITATION"))
    unlink(x = file.path(root, "inst", "CITATION"))
    dest <- tempfile(pattern = "upload")
    out <- suppressMessages(
      expr = ConformFix(path = root, reference = reference, dest = dest)
    )
    testthat::test_that(
      desc = paste(text, "writes from the reference with the project's name"),
      code = {
        testthat::expect_equal(
          object = readLines(con = file.path(root, "inst", "CITATION")),
          expected = c("conformPkg citation", "line")
        )
        testthat::expect_true(object = "inst/CITATION" %in% out$new)
      }
    )
    testthat::test_that(
      desc = paste(text, ".ConformWrite() never overwrites"),
      code = {
        rows <- .ConformRow(
          rule = "required-file",
          class = "fix",
          file = c("inst/CITATION", "main.tex", "gone.tex", "gone/"),
          message = "x",
          fix = c(
            "default",
            "remove-overleaf",
            "remove-overleaf",
            "remove-local"
          )
        )
        writeLines(text = "mine", con = file.path(root, "inst", "CITATION"))
        done <- .ConformWrite(
          path = root,
          rows = rows,
          reference = NULL,
          template = .ConformTemplate(path = root)
        )
        testthat::expect_length(
          object = unlist(x = done[c("new", "overleaf", "local")]),
          n = 0L
        )
        testthat::expect_length(object = done$kept, n = 3L)
        testthat::expect_equal(
          object = readLines(con = file.path(root, "inst", "CITATION")),
          expected = "mine"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "defaults: pkgdown from the public repository"),
      code = {
        yml <- .ConformDefault(
          path = root,
          file = ".setup/pkgdown/_pkgdown.yml"
        )
        testthat::expect_true(
          object = "url: https://ijapesigan.github.io/conformPkg/" %in% yml
        )
        testthat::expect_true(object = "  - conformPkg" %in% yml)
        unlink(x = file.path(root, ".setup", "repo", "public-github.md"))
        yml <- .ConformDefault(
          path = root,
          file = ".setup/pkgdown/_pkgdown.yml"
        )
        testthat::expect_false(object = any(grepl(pattern = "^url:", x = yml)))
        testthat::expect_null(object = .ConformDefault(path = root, file = "x"))
        testthat::expect_equal(
          object = .ConformDefault(path = root, file = "vignettes/.gitignore"),
          expected = "*.Rds"
        )
        testthat::expect_true(
          object = length(
            x = .ConformDefault(path = root, file = "inst/CITATION")
          ) > 5L
        )
      }
    )
  },
  text = "test-rProject-conform-fix"
)

lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestConform()
    dest <- tempfile(pattern = "upload")
    writeLines(text = "x", con = file.path(root, "main.tex"))
    dir.create(
      path = file.path(root, ".setup", "r-dependencies", "wald"),
      recursive = TRUE
    )
    dir.create(path = file.path(root, ".setup", "cpp"), showWarnings = FALSE)
    cpp <- file.path(root, ".setup", "cpp", "wald-x-dot.cpp")
    writeLines(text = "", con = cpp)
    unlink(x = file.path(root, "inst/CITATION"))
    first <- suppressMessages(
      expr = ConformFix(path = root, dest = dest)
    )
    testthat::test_that(
      desc = paste(text, "strays are kept without remove = TRUE"),
      code = {
        testthat::expect_true(object = file.exists(file.path(root, "main.tex")))
        testthat::expect_equal(object = first$kept, expected = "main.tex")
        testthat::expect_equal(object = first$new, expected = "inst/CITATION")
      }
    )
    testthat::test_that(
      desc = paste(text, "a locked copy is never removed"),
      code = {
        rows <- .ConformRow(
          rule = "stray",
          class = "fix",
          file = "R/wald-ci-dot.R",
          message = "x",
          fix = "remove-overleaf"
        )
        writeLines(text = "x", con = file.path(root, "R", "wald-ci-dot.R"))
        writeLines(
          text = "x",
          con = file.path(
            root,
            ".setup",
            "r-dependencies",
            "wald",
            "wald-ci-dot.R"
          )
        )
        done <- .ConformWrite(
          path = root,
          rows = rows,
          reference = NULL,
          template = .ConformTemplate(path = root),
          remove = TRUE
        )
        testthat::expect_equal(object = done$kept, expected = "R/wald-ci-dot.R")
        testthat::expect_true(
          object = file.exists(file.path(root, "R", "wald-ci-dot.R"))
        )
        testthat::expect_true(object = file.exists(cpp))
      }
    )
    testthat::test_that(
      desc = paste(text, "decide rows are never applied"),
      code = {
        rows <- .ConformRow(
          rule = "required-file",
          class = "decide",
          file = c("inst/CITATION", "main.tex"),
          message = "x",
          fix = c("default", "remove-overleaf")
        )
        unlink(x = file.path(root, "inst/CITATION"))
        done <- .ConformWrite(
          path = root,
          rows = rows,
          reference = NULL,
          template = .ConformTemplate(path = root),
          remove = TRUE
        )
        testthat::expect_length(object = unlist(x = done), n = 0L)
        testthat::expect_false(
          object = file.exists(file.path(root, "inst/CITATION"))
        )
        testthat::expect_true(object = file.exists(file.path(root, "main.tex")))
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "the upload folder drift is reported and the log lists the folder"
      ),
      code = {
        folder <- first$folder
        writeLines(text = "x", con = file.path(folder, ".Rprofile"))
        writeLines(text = "x", con = file.path(folder, "NAMESPACE"))
        dir.create(path = file.path(folder, "R"), showWarnings = FALSE)
        writeLines(text = "gone", con = file.path(folder, "R", "gone.R"))
        dir.create(path = file.path(folder, "tests"), showWarnings = FALSE)
        writeLines(text = "old", con = file.path(folder, "tests", "testthat.R"))
        drift <- .ConformDrift(
          path = root,
          folder = folder,
          template = .ConformTemplate(path = root)
        )
        kind <- stats::setNames(object = drift$message, nm = drift$file)
        testthat::expect_equal(
          object = kind[[".Rprofile"]],
          expected = "not in the manifest (generated; not for upload)"
        )
        testthat::expect_equal(
          object = kind[["NAMESPACE"]],
          expected = kind[[".Rprofile"]]
        )
        testthat::expect_equal(
          object = kind[["R/gone.R"]],
          expected = "missing in the project"
        )
        testthat::expect_equal(
          object = kind[["tests/testthat.R"]],
          expected = "differs from the project"
        )
        # the log lists the upload folder
        log <- readLines(con = first$log)
        testthat::expect_true(object = "- inst/CITATION" %in% log)
        testthat::expect_true(
          object = paste(
            "### Files to update in Overleaf",
            "(from the upload folder)"
          ) %in% log
        )
        testthat::expect_true(
          object = .ConformLinked(
            file = c(".setup/r-dependencies/w/x.R", "R/a.R")
          )[1]
        )
      }
    )
  },
  text = "test-rProject-conform-fix"
)

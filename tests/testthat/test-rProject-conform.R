## ---- test-rProject-conform
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestConform()
    rows <- suppressMessages(expr = Conform(path = root))
    testthat::test_that(
      desc = paste(
        text,
        "a project built from the template has nothing to fix"
      ),
      code = {
        testthat::expect_equal(
          object = names(x = rows),
          expected = c("rule", "class", "file", "message", "fix")
        )
        testthat::expect_false(object = any(rows$class == "fix"))
        testthat::expect_false(
          object = any(rows$rule %in% c("manifest-differs", "stray"))
        )
        # no release yet: the lock is info
        testthat::expect_equal(
          object = rows$class[rows$rule == "lock"],
          expected = "info"
        )
        testthat::expect_message(
          object = Conform(path = root),
          regexp = "Conform: "
        )
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "a missing tier 1 file is a fix, an edited one is not"
      ),
      code = {
        tier_one <- ".setup/latex/preamble/preamble.tex"
        edited <- ".setup/latex/preamble/001-preamble-encoding.tex"
        unlink(x = file.path(root, tier_one))
        cat("\n% edited\n", file = file.path(root, edited), append = TRUE)
        missing <- .TestConformRows(path = root, rule = "manifest-missing")
        differs <- .TestConformRows(path = root, rule = "manifest-differs")
        hit <- missing[missing$file == tier_one, ]
        testthat::expect_equal(object = hit$class, expected = "fix")
        testthat::expect_equal(object = hit$fix, expected = "template")
        testthat::expect_equal(object = differs$file, expected = edited)
        testthat::expect_equal(object = differs$class, expected = "decide")
      }
    )
    testthat::test_that(
      desc = paste(text, "strays are fixes"),
      code = {
        writeLines(text = "x", con = file.path(root, "main.tex"))
        dir.create(path = file.path(root, ".tmp-r"))
        dir.create(path = file.path(root, "odd"))
        writeLines(text = "x", con = file.path(root, "odd.txt"))
        stray <- .TestConformRows(path = root, rule = "stray")
        testthat::expect_setequal(
          object = stray$file,
          expected = c("main.tex", ".tmp-r/")
        )
        testthat::expect_true(object = all(stray$class == "fix"))
        top <- .TestConformRows(path = root, rule = "top-level")
        testthat::expect_equal(object = top$file, expected = "odd.txt")
        folder <- .TestConformRows(path = root, rule = "folder-not-standard")
        testthat::expect_true(object = "odd/" %in% folder$file)
        # a full scratch folder is not removed
        writeLines(text = "x", con = file.path(root, ".tmp-r", "keep"))
        top <- .TestConformRows(path = root, rule = "top-level")
        testthat::expect_true(object = ".tmp-r/" %in% top$file)
      }
    )
  },
  text = "test-rProject-conform"
)

lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestConform()
    testthat::test_that(
      desc = paste(
        text,
        "required files are fixes; the dotless twin is accepted"
      ),
      code = {
        unlink(x = file.path(root, c("vignettes/.gitignore", "inst/CITATION")))
        rows <- .TestConformRows(path = root, rule = "required-file")
        testthat::expect_setequal(
          object = rows$file,
          expected = c("vignettes/.gitignore", "inst/CITATION")
        )
        testthat::expect_true(object = all(rows$fix == "default"))
        writeLines(text = "*.Rds", con = file.path(root, "vignettes/gitignore"))
        rows <- .TestConformRows(path = root, rule = "required-file")
        testthat::expect_equal(object = rows$file, expected = "inst/CITATION")
        twin <- .TestConformRows(path = root, rule = "dotless-twin")
        testthat::expect_equal(
          object = twin$file,
          expected = "vignettes/.gitignore"
        )
        # a nested .gitignore of the manifest, renamed by Overleaf
        file.rename(
          from = file.path(root, ".setup/notes/.gitignore"),
          to = file.path(root, ".setup/notes/gitignore")
        )
        missing <- .TestConformRows(path = root, rule = "manifest-missing")
        testthat::expect_false(
          object = ".setup/notes/.gitignore" %in% missing$file
        )
        twin <- .TestConformRows(path = root, rule = "dotless-twin")
        testthat::expect_true(object = ".setup/notes/.gitignore" %in% twin$file)
      }
    )
    testthat::test_that(
      desc = paste(text, "test names follow .LintKebab() and skip operators"),
      code = {
        writeLines(
          text = c(
            "export(Foo)",
            "export(Lav2RAM)",
            "export(HC0)",
            "export(PInvDmat)",
            "export(\"%||%\")"
          ),
          con = file.path(root, "NAMESPACE")
        )
        tests <- file.path(
          root,
          "tests",
          "testthat",
          c(
            "test-conformPkg-lav2-ram.R",
            "test-conformPkg-hc0.R"
          )
        )
        writeLines(text = "", con = tests[1])
        writeLines(text = "", con = tests[2])
        rows <- .TestConformRows(path = root, rule = "test-name")
        testthat::expect_equal(
          object = rows$file,
          expected = "tests/testthat/test-conformPkg-p-inv-dmat.R"
        )
        writeLines(
          text = "S3method(print, foo)",
          con = file.path(root, "NAMESPACE")
        )
        testthat::expect_equal(
          object = nrow(x = .TestConformRows(path = root, rule = "test-name")),
          expected = 0L
        )
        unlink(x = file.path(root, "NAMESPACE"))
        testthat::expect_equal(
          object = nrow(x = .TestConformRows(path = root, rule = "test-name")),
          expected = 0L
        )
        testthat::expect_equal(object = rows$class, expected = "decide")
      }
    )
    testthat::test_that(
      desc = paste(text, "locked copies are exempt from the file names"),
      code = {
        writeLines(
          text = "WaldCiWaldDot <- function() {\n  1\n}",
          con = file.path(root, "R", "wald-ci-wald-dot.R")
        )
        writeLines(
          text = "x <- 1",
          con = file.path(root, "R", "badName.R")
        )
        dir.create(
          path = file.path(root, ".setup", "cpp"),
          showWarnings = FALSE
        )
        writeLines(
          text = "",
          con = file.path(root, ".setup", "cpp", "linearAlgebra-vech-dot.cpp")
        )
        rows <- .TestConformRows(path = root, rule = "file-name")
        testthat::expect_equal(
          object = rows$class[rows$file == "R/wald-ci-wald-dot.R"],
          expected = "info"
        )
        testthat::expect_equal(
          object = rows$class[rows$file == "R/badName.R"],
          expected = "decide"
        )
        cpp <- .TestConformRows(path = root, rule = "cpp-file-name")
        testthat::expect_equal(object = cpp$class, expected = "info")
        dir.create(
          path = file.path(root, ".setup", "r-dependencies", "wald"),
          recursive = TRUE
        )
        writeLines(
          text = "WaldCiWaldDot <- function() {\n  1\n}",
          con = file.path(
            root, ".setup", "r-dependencies", "wald", "wald-ci-wald-dot.R"
          )
        )
        rows <- .TestConformRows(path = root, rule = "file-name")
        testthat::expect_false(object = "R/wald-ci-wald-dot.R" %in% rows$file)
        testthat::expect_true(object = "R/badName.R" %in% rows$file)
      }
    )
    testthat::test_that(
      desc = paste(text, "one function per file, lint_error, the lock"),
      code = {
        writeLines(
          text = c(
            "Delta <- function(x) {",
            "  UseMethod(\"Delta\")",
            "}",
            "Delta.default <- function(x) {",
            "  x",
            "}"
          ),
          con = file.path(root, "R", "conformPkg-delta.R")
        )
        writeLines(
          text = "Other <- function() {\n  1\n}",
          con = file.path(root, "R", "conformPkg-misnamed.R")
        )
        writeLines(
          text = ".CheckFoo <- function() {\n  1\n}",
          con = file.path(root, "R", "conformPkg-foo-check.R")
        )
        writeLines(
          text = ".Bar <- function() {\n  1\n}",
          con = file.path(root, "R", "conformPkg-bar-dot.R")
        )
        writeLines(
          text = "x <- (",
          con = file.path(root, "R", "conformPkg-broken.R")
        )
        cat(
          "lint_error <- FALSE\n",
          file = file.path(root, ".setup", "scripts", "project.R"),
          append = TRUE
        )
        one <- .TestConformRows(path = root, rule = "one-function-per-file")
        testthat::expect_equal(
          object = one$file,
          expected = "R/conformPkg-delta.R"
        )
        testthat::expect_true(
          object = grepl(pattern = "S3 generic", x = one$message)
        )
        # a function in a file that .LintKebab() would name differently is
        # not a finding: make lint does not check it
        testthat::expect_equal(
          object = nrow(
            x = .TestConformRows(path = root, rule = "function-file-name")
          ),
          expected = 0L
        )
        testthat::expect_false(
          object = "R/conformPkg-misnamed.R" %in% one$file
        )
        testthat::expect_equal(
          object = .TestConformRows(path = root, rule = "lint-error")$class,
          expected = "decide"
        )
        writeLines(
          text = "",
          con = file.path(root, ".setup/scripts/rproject.lock")
        )
        testthat::expect_equal(
          object = nrow(x = .TestConformRows(path = root, rule = "lock")),
          expected = 0L
        )
      }
    )
  },
  text = "test-rProject-conform"
)

lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestConform()
    testthat::test_that(
      desc = paste(text, "placeholder text and bad repository files"),
      code = {
        repo <- file.path(root, ".setup", "repo")
        writeLines(
          text = "PLACEHOLDER",
          con = file.path(repo, "private-overleaf.md")
        )
        writeLines(
          text = "UNKNOWN/conformPkg",
          con = file.path(repo, "private-github.md")
        )
        rows <- .TestConformRows(path = root, rule = "placeholder")
        testthat::expect_setequal(
          object = rows$file,
          expected = c(
            ".setup/repo/private-github.md",
            ".setup/repo/private-overleaf.md"
          )
        )
        repos <- .TestConformRows(path = root, rule = "repo")
        testthat::expect_equal(object = nrow(x = repos), expected = 2L)
        unlink(
          x = file.path(repo, c("private-github.md", "private-overleaf.md"))
        )
        repos <- .TestConformRows(path = root, rule = "repo")
        testthat::expect_equal(object = nrow(x = repos), expected = 2L)
      }
    )
    testthat::test_that(
      desc = paste(text, "the remote check is read-only and quiet without ssh"),
      code = {
        testthat::skip_on_os(os = "windows")
        root <- .TestConform()
        bin <- tempfile(pattern = "bin")
        dir.create(path = bin)
        writeLines(
          text = c(
            "#!/bin/sh",
            "case \"$1\" in",
            "  ls-remote) echo 'ERROR: Repository not found.'; exit 128;;",
            "  -C) echo 'git@github.com:someone/else.git';;",
            "esac"
          ),
          con = file.path(bin, "git")
        )
        writeLines(text = "#!/bin/sh", con = file.path(bin, "ssh"))
        Sys.chmod(paths = file.path(bin, c("git", "ssh")), mode = "0755")
        dir.create(path = file.path(root, ".git"))
        old <- Sys.getenv(x = "PATH")
        Sys.setenv(PATH = paste(bin, old, sep = ":"))
        on.exit(expr = Sys.setenv(PATH = old))
        rows <- suppressMessages(expr = Conform(path = root, remote = TRUE))
        rows <- rows[rows$rule == "remote", ]
        testthat::expect_equal(object = nrow(x = rows), expected = 2L)
        testthat::expect_true(
          object = any(grepl(pattern = "does not exist", x = rows$message))
        )
        testthat::expect_true(
          object = any(grepl(pattern = "someone/else", x = rows$message))
        )
        # without remote = TRUE nothing is asked
        rows <- suppressMessages(expr = Conform(path = root))
        testthat::expect_false(object = "remote" %in% rows$rule)
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "findings that the reference has too are not reported"
      ),
      code = {
        root <- .TestConform()
        reference <- .TestConform(name = "refPkg", public = "ijapesigan/refPkg")
        for (project in c(root, reference)) {
          dir.create(
            path = file.path(project, ".setup", "readme"),
            showWarnings = FALSE
          )
        }
        for (project in c(root, reference)) {
          writeLines(text = "x", con = file.path(project, "main.tex"))
        }
        writeLines(
          text = "x",
          con = file.path(reference, ".setup", "readme", "README.Rmd")
        )
        writeLines(
          text = "x",
          con = file.path(reference, ".setup", "readme", "other.Rmd")
        )
        writeLines(
          text = "x",
          con = file.path(root, ".setup", "readme", "other.Rmd")
        )
        writeLines(
          text = "x",
          con = file.path(root, ".setup", "readme", "mine.Rmd")
        )
        rows <- suppressMessages(
          expr = Conform(path = root, reference = reference)
        )
        testthat::expect_false(object = "main.tex" %in% rows$file)
        missing <- rows[rows$rule == "file-set-missing", ]
        testthat::expect_equal(
          object = missing$file,
          expected = ".setup/readme/README.Rmd"
        )
        extra <- rows[rows$rule == "file-set-extra", ]
        testthat::expect_equal(
          object = extra$file,
          expected = ".setup/readme/mine.Rmd"
        )
        # without the reference the stray is reported
        rows <- suppressMessages(expr = Conform(path = root))
        testthat::expect_true(object = "main.tex" %in% rows$file)
      }
    )
  },
  text = "test-rProject-conform"
)

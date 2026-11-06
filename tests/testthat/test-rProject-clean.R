## ---- test-rProject-clean
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    fill <- function(root) {
      for (dir in c("docs", "pkgdown", ".setup/latex/pdf", "man", "src")) {
        dir.create(
          path = file.path(root, dir),
          recursive = TRUE,
          showWarnings = FALSE
        )
      }
      for (file in c(
        "_pkgdown.yml", "latexmkrc", "README.html", "fig-vignettes-a.png",
        "src/a.o", "src/a.so", "NAMESPACE", "README.md", "CITATION.cff",
        "R/keep.R", ".setup/scripts/secrets.R", "R/secrets.R"
      )) {
        writeLines(text = "x", con = file.path(root, file))
      }
    }
    exists <- function(root, files) {
      file.exists(file.path(root, files))
    }
    testthat::test_that(
      paste(text, "removes build output and generated files"),
      {
        root <- .TestProject()
        fill(root)
        Clean(path = root)
        testthat::expect_false(
          object = any(
            exists(
              root = root,
              files = c(
                "docs", "pkgdown", ".setup/latex/pdf", "_pkgdown.yml",
                "latexmkrc", "README.html", "fig-vignettes-a.png",
                "src/a.o", "src/a.so", "man", "NAMESPACE", "README.md",
                "CITATION.cff"
              )
            )
          )
        )
        testthat::expect_true(
          object = all(
            exists(root = root, files = c("R/keep.R", "DESCRIPTION"))
          )
        )
        testthat::expect_true(
          object = exists(root = root, files = ".setup/scripts/secrets.R")
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "with push = TRUE keeps generated files, removes secrets"),
      {
        root <- .TestProject()
        fill(root)
        Clean(path = root, push = TRUE)
        testthat::expect_true(
          object = all(
            exists(
              root = root,
              files = c("man", "NAMESPACE", "README.md", "CITATION.cff")
            )
          )
        )
        testthat::expect_false(
          object = exists(root = root, files = "R/secrets.R")
        )
        # list.files() skips hidden folders such as .setup (kept by design)
        testthat::expect_true(
          object = exists(root = root, files = ".setup/scripts/secrets.R")
        )
        testthat::expect_false(object = exists(root = root, files = "docs"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-clean"
)

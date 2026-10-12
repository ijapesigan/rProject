## ---- test-rProject-clean
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    fill <- function(root) {
      for (dir in c("docs", "pkgdown", ".setup/latex/pdf", "man", "src")) {
        dir.create(file.path(root, dir), recursive = TRUE, showWarnings = FALSE)
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
          any(
            exists(
              root,
              c(
                "docs", "pkgdown", ".setup/latex/pdf", "_pkgdown.yml",
                "latexmkrc", "README.html", "fig-vignettes-a.png",
                "src/a.o", "src/a.so", "man", "NAMESPACE", "README.md",
                "CITATION.cff"
              )
            )
          )
        )
        testthat::expect_true(all(exists(root, c("R/keep.R", "DESCRIPTION"))))
        testthat::expect_true(exists(root, ".setup/scripts/secrets.R"))
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "with push = TRUE keeps generated files, removes secrets"),
      {
        root <- .TestProject()
        fill(root)
        Clean(path = root, push = TRUE)
        testthat::expect_true(
          all(exists(root, c("man", "NAMESPACE", "README.md", "CITATION.cff")))
        )
        testthat::expect_false(exists(root, "R/secrets.R"))
        # list.files() skips hidden folders such as .setup (kept by design)
        testthat::expect_true(exists(root, ".setup/scripts/secrets.R"))
        testthat::expect_false(exists(root, "docs"))
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-clean"
)

## ---- test-rProject-site
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "skips folders that are not packages"),
      code = {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          object = Site(path = root),
          regexp = "is not an R package"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "builds no pages from the private .md files"),
      code = {
        testthat::skip_if_not_installed(pkg = "pkgdown")
        testthat::skip_if_not_installed(pkg = "devtools")
        root <- .TestProject()
        dir.create(path = file.path(root, ".setup", "pkgdown"))
        dir.create(path = file.path(root, "vignettes"))
        dir.create(path = file.path(root, "pkgdown"))
        writeLines(
          text = "destination: pkgdown",
          con = file.path(root, ".setup", "pkgdown", "_pkgdown.yml")
        )
        writeLines(
          text = "",
          con = file.path(root, "vignettes", "vignettes.bib")
        )
        writeLines(text = "# private", con = file.path(root, "AGENTS.md"))
        writeLines(text = "# private", con = file.path(root, "CLAUDE.md"))
        writeLines(text = "x", con = file.path(root, "pkgdown", "AGENTS.html"))
        seen <- NULL
        testthat::local_mocked_bindings(
          LibPaths = function(path) {
            .libPaths()[1]
          }
        )
        testthat::local_mocked_bindings(
          build_site = function(pkg, ...) {
            # what pkgdown would render: the top-level .md files
            seen <<- list.files(path = pkg, pattern = "\\.md$")
            invisible(x = NULL)
          },
          .package = "pkgdown"
        )
        Site(path = root)
        testthat::expect_false(object = "AGENTS.md" %in% seen)
        testthat::expect_false(object = "CLAUDE.md" %in% seen)
        testthat::expect_true(
          object = all(
            file.exists(file.path(root, c("AGENTS.md", "CLAUDE.md")))
          )
        )
        testthat::expect_false(
          object = file.exists(file.path(root, "pkgdown", "AGENTS.html"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-site"
)

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
        dir.create(path = file.path(root, ".github"))
        writeLines(
          text = "# private",
          con = file.path(root, ".github", "copilot-instructions.md")
        )
        stale <- c("AGENTS.html", "AGENTS.md", "copilot-instructions.html")
        for (file in stale) {
          writeLines(text = "x", con = file.path(root, "pkgdown", file))
        }
        seen <- NULL
        testthat::local_mocked_bindings(
          LibPaths = function(path) {
            .libPaths()[1]
          }
        )
        testthat::local_mocked_bindings(
          build_site = function(pkg, ...) {
            # what pkgdown would render: the .md files at the top and in
            # .github/
            seen <<- c(
              list.files(path = pkg, pattern = "\\.md$"),
              list.files(path = file.path(pkg, ".github"), pattern = "\\.md$")
            )
            invisible(x = NULL)
          },
          .package = "pkgdown"
        )
        Site(path = root)
        testthat::expect_false(object = "AGENTS.md" %in% seen)
        testthat::expect_false(object = "CLAUDE.md" %in% seen)
        testthat::expect_false(object = "copilot-instructions.md" %in% seen)
        private <- c(
          "AGENTS.md",
          "CLAUDE.md",
          file.path(".github", "copilot-instructions.md")
        )
        testthat::expect_true(
          object = all(file.exists(file.path(root, private)))
        )
        testthat::expect_false(
          object = any(file.exists(file.path(root, "pkgdown", stale)))
        )
        # the folder aside is gone
        testthat::expect_length(
          object = list.files(
            path = root,
            pattern = "^\\.site-private-",
            all.files = TRUE
          ),
          n = 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-site"
)

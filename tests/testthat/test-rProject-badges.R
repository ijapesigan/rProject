## ---- test-rProject-badges
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    project <- function() {
      path <- tempfile(pattern = "project")
      workflows <- file.path(path, ".github", "workflows")
      repo <- file.path(path, ".setup", "repo")
      dir.create(path = workflows, recursive = TRUE)
      dir.create(path = repo, recursive = TRUE)
      writeLines(text = "owner/pkg", con = file.path(repo, "public-github.md"))
      workflow_files <- c(
        "lint.yml",
        "make.yml",
        "rhub-1-essential.yml",
        "rhub-3-numerics.yml",
        "rhub-5-other.yml"
      )
      for (file in workflow_files) {
        writeLines(
          text = c(
            paste0(
              "name: ",
              sub(pattern = "\\.yml$", replacement = "", x = file)
            ),
            "jobs:"
          ),
          con = file.path(workflows, file)
        )
      }
      path
    }
    testthat::test_that(
      desc = paste(text, "names workflows that exist, make first"),
      code = {
        path <- project()
        on.exit(expr = unlink(x = path, recursive = TRUE), add = TRUE)
        badges <- Badges(path = path)
        testthat::expect_length(object = badges, n = 4)
        testthat::expect_match(
          object = badges[1],
          regexp = "workflows/make\\.yml/badge\\.svg"
        )
        files <- unique(
          x = sub(
            pattern = ".*/actions/workflows/([^/)]+)/badge.*",
            replacement = "\\1",
            x = badges
          )
        )
        testthat::expect_true(
          object = all(
            file.exists(file.path(path, ".github", "workflows", files))
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "labels review tiers and leaves out tier 5"),
      code = {
        path <- project()
        on.exit(expr = unlink(x = path, recursive = TRUE), add = TRUE)
        badges <- Badges(path = path)
        testthat::expect_false(
          object = any(grepl(pattern = "rhub-5", x = badges))
        )
        testthat::expect_true(
          object = any(
            grepl(
              pattern = "rhub-3-numerics, review only",
              x = badges,
              fixed = TRUE
            )
          )
        )
        testthat::expect_false(
          object = any(
            grepl(
              pattern = "rhub-1-essential, review only",
              x = badges,
              fixed = TRUE
            )
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "is empty without a public repository"),
      code = {
        path <- project()
        on.exit(expr = unlink(x = path, recursive = TRUE), add = TRUE)
        writeLines(
          text = "none",
          con = file.path(path, ".setup", "repo", "public-github.md")
        )
        testthat::expect_length(object = Badges(path = path), n = 0)
      }
    )
    testthat::test_that(
      desc = paste(text, "replaces only the marked block of README.md"),
      code = {
        path <- project()
        on.exit(expr = unlink(x = path, recursive = TRUE), add = TRUE)
        readme <- file.path(path, "README.md")
        writeLines(
          text = c(
            "# pkg",
            "<!-- badges: start -->",
            paste0(
              "[![old](https://github.com/owner/pkg",
              "/actions/workflows/old.yml/badge.svg)](",
              "x)"
            ),
            "<!-- badges: end -->",
            "text"
          ),
          con = readme
        )
        testthat::expect_true(object = .BadgesWrite(path = path))
        lines <- readLines(con = readme)
        testthat::expect_false(
          object = any(grepl(pattern = "old\\.yml", x = lines))
        )
        testthat::expect_identical(object = lines[1], expected = "# pkg")
        testthat::expect_identical(
          object = lines[length(x = lines)],
          expected = "text"
        )
        writeLines(text = "no markers", con = readme)
        testthat::expect_false(object = .BadgesWrite(path = path))
        testthat::expect_identical(
          object = readLines(con = readme),
          expected = "no markers"
        )
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "takes the DOI from inst/CITATION, not the placeholder"
      ),
      code = {
        path <- project()
        on.exit(expr = unlink(x = path, recursive = TRUE), add = TRUE)
        dir.create(path = file.path(path, "inst"))
        citation <- file.path(path, "inst", "CITATION")
        writeLines(
          text = c("bibentry(", "  doi = \"10.0000/0000000000\",", ")"),
          con = citation
        )
        testthat::expect_false(
          object = any(grepl(pattern = "^\\[!\\[DOI", x = Badges(path = path)))
        )
        writeLines(
          text = c(
            "  doi = \"10.1037/met0000779\",",
            "  doi = \"10.1000/other\","
          ),
          con = citation
        )
        badges <- Badges(path = path)
        testthat::expect_identical(
          object = badges[1],
          expected = paste0(
            "[![DOI](https://zenodo.org/badge/DOI/10.1037/met0000779.svg)]",
            "(https://doi.org/10.1037/met0000779)"
          )
        )
        testthat::expect_length(
          object = grep(pattern = "doi\\.org", x = badges),
          n = 1
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "keeps a hand-written badge and replaces the old DOI"),
      code = {
        path <- project()
        on.exit(expr = unlink(x = path, recursive = TRUE), add = TRUE)
        dir.create(path = file.path(path, "inst"))
        writeLines(
          text = "  doi = \"10.1037/met0000779\",",
          con = file.path(path, "inst", "CITATION")
        )
        cran <- paste0(
          "[![CRAN Status](https://www.r-pkg.org/badges/version/pkg)](",
          "https://cran.r-project.org/package=pkg)"
        )
        readme <- file.path(path, "README.md")
        writeLines(
          text = c(
            "<!-- badges: start -->",
            paste0(
              "[![DOI](https://zenodo.org/badge/DOI/10.1/old.svg)](",
              "https://doi.org/10.1/old)"
            ),
            cran,
            paste0(
              "[![old](https://github.com/owner/pkg",
              "/actions/workflows/gone.yml/badge.svg)](",
              "x)"
            ),
            paste0(
              "[![pages](https://github.com/owner/pkg",
              "/actions/workflows/pages/pages-build-deployment/badge.svg)](",
              "x)"
            ),
            "<!-- badges: end -->"
          ),
          con = readme
        )
        testthat::expect_true(object = .BadgesWrite(path = path))
        lines <- readLines(con = readme)
        testthat::expect_true(object = cran %in% lines)
        testthat::expect_false(
          object = any(grepl(pattern = "10\\.1/old|gone\\.yml", x = lines))
        )
        testthat::expect_match(object = lines[2], regexp = "met0000779")
        testthat::expect_identical(object = lines[3], expected = cran)
        testthat::expect_true(
          object = any(grepl(pattern = "pages-build-deployment", x = lines))
        )
        # pandoc wraps a long badge over lines
        writeLines(
          text = c(
            "<!-- badges: start -->",
            "[![CRAN",
            paste0(
              "Status](https://www.r-pkg.org/badges/version/pkg)](",
              "https://cran.r-project.org/package=pkg)"
            ),
            "[![Make",
            paste0(
              "Project](https://github.com/owner/pkg",
              "/actions/workflows/make.yml/badge.svg)](",
              "x)"
            ),
            "<!-- badges: end -->"
          ),
          con = readme
        )
        testthat::expect_true(object = .BadgesWrite(path = path))
        lines <- readLines(con = readme)
        testthat::expect_true(
          object = all(grepl(pattern = "^(\\[!\\[|<!--)", x = lines))
        )
        testthat::expect_true(
          object = any(grepl(pattern = "r-pkg\\.org", x = lines))
        )
        testthat::expect_length(
          object = grep(pattern = "workflows/make\\.yml", x = lines),
          n = 1
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "gives the Pages address for Site()"),
      code = {
        path <- project()
        on.exit(expr = unlink(x = path, recursive = TRUE), add = TRUE)
        testthat::expect_identical(
          object = .SiteUrl(path = path),
          expected = "https://owner.github.io/pkg/"
        )
        writeLines(
          text = "none",
          con = file.path(path, ".setup", "repo", "public-github.md")
        )
        testthat::expect_null(object = .SiteUrl(path = path))
      }
    )
  },
  text = "test-rProject-badges"
)

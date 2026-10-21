## ---- test-rProject-template
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    project <- function(type) {
      root <- tempfile(pattern = "template")
      dir.create(
        file.path(root, ".setup", "scripts"),
        recursive = TRUE
      )
      writeLines(
        text = c(
          "project <- \"test\"",
          paste0("type <- \"", type, "\"")
        ),
        con = file.path(root, ".setup", "scripts", "project.R")
      )
      root
    }
    # CI sets GITHUB_ACTIONS, where Template() writes nothing
    github_actions <- Sys.getenv("GITHUB_ACTIONS")
    Sys.setenv(GITHUB_ACTIONS = "false")
    testthat::test_that(
      paste(text, "manifest paths are not dot-encoded"),
      {
        manifest <- .TemplateFiles(type = "cran")
        all_paths <- unlist(
          lapply(
            X = names(.TemplateSets()),
            FUN = function(type) {
              .TemplateFiles(type = type)$path
            }
          )
        )
        testthat::expect_false(
          any(grepl(pattern = "(^|/)dot-", x = all_paths))
        )
        testthat::expect_true(
          all(file.exists(manifest$source))
        )
      }
    )
    for (type in setdiff(names(.TemplateSets()), "rProject")) {
      root <- project(type = type)
      files <- .TemplateFiles(type = type)
      tier2 <- files$path[files$tier == "2"]
      pending <- suppressMessages(
        Template(path = root, check = TRUE)
      )
      testthat::test_that(
        paste(text, type, "check writes nothing"),
        {
          testthat::expect_equal(sort(pending), sort(tier2))
          testthat::expect_false(
            any(file.exists(file.path(root, tier2)))
          )
        }
      )
      written <- suppressMessages(
        Template(path = root)
      )
      testthat::test_that(
        paste(text, type, "writes tier 2 only"),
        {
          testthat::expect_equal(sort(written), sort(tier2))
          testthat::expect_true(
            all(file.exists(file.path(root, tier2)))
          )
          testthat::expect_false(
            any(file.exists(file.path(root, files$path[files$tier == "1"])))
          )
          testthat::expect_length(
            suppressMessages(Template(path = root, check = TRUE)),
            0L
          )
        }
      )
      unlink(root, recursive = TRUE)
    }
    root <- project(type = "cran")
    suppressMessages(Template(path = root))
    edited <- file.path(root, ".github", "workflows", "make.yml")
    writeLines(text = "edited", con = edited)
    linked <- file.path(root, "Makefile")
    writeLines(text = "old", con = linked)
    testthat::test_that(
      paste(text, "names and overwrites an edited file"),
      {
        testthat::expect_message(
          Template(path = root),
          regexp = "Overwritten"
        )
        testthat::expect_false(
          identical(readLines(edited, warn = FALSE), "edited")
        )
      }
    )
    testthat::test_that(
      paste(text, "reports a differing link and leaves it"),
      {
        testthat::expect_message(
          Template(path = root),
          regexp = "Links to refresh"
        )
        testthat::expect_equal(readLines(linked), "old")
      }
    )
    testthat::test_that(
      paste(text, "does nothing in GitHub Actions"),
      {
        writeLines(text = "edited", con = edited)
        Sys.setenv(GITHUB_ACTIONS = "true")
        suppressMessages(Template(path = root))
        Sys.setenv(GITHUB_ACTIONS = "false")
        testthat::expect_equal(readLines(edited), "edited")
      }
    )
    testthat::test_that(
      paste(text, "writes nothing without a type"),
      {
        bare <- tempfile(pattern = "template")
        dir.create(bare)
        testthat::expect_length(
          suppressMessages(Template(path = bare)),
          0L
        )
        testthat::expect_length(list.files(bare), 0L)
        unlink(bare, recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "stops on an unknown type"),
      {
        testthat::expect_error(
          Template(path = project(type = "other"))
        )
      }
    )
    testthat::test_that(
      paste(text, "maps the type for AI()"),
      {
        testthat::expect_equal(
          .AIType(path = root, project = "test"),
          c("package", "cran")
        )
      }
    )
    unlink(root, recursive = TRUE)
    Sys.setenv(GITHUB_ACTIONS = github_actions)
  },
  text = "test-rProject-template"
)

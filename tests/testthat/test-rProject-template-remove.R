## ---- test-rProject-template-remove
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    template <- system.file("template", package = "rProject", mustWork = TRUE)
    root <- .TestProject()
    put <- function(file, content = "x") {
      dir.create(
        path = dirname(file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = content, con = file.path(root, file))
    }
    put(".devcontainer/devcontainer.json")
    put(".devcontainer/scripts/setup.sh")
    put(".setup/cran/validate.R")
    put(".setup/cran/.gitignore", content = character(0))
    put(".setup/bin/.gitignore", content = character(0))
    put(".setup/latex/apa7/apa7.cls")
    put(".setup/latex/apa7/config/APA7english.txt")
    put(".setup/coverage/.covrignore")
    put(".setup/scripts/secrets.R")
    testthat::test_that(
      paste(text, "check deletes nothing"),
      {
        planned <- suppressMessages(
          .TemplateRemove(path = root, root = template, check = TRUE)
        )
        testthat::expect_true(".devcontainer/devcontainer.json" %in% planned)
        testthat::expect_true(dir.exists(file.path(root, ".devcontainer")))
        testthat::expect_true(
          file.exists(file.path(root, ".setup", "scripts", "secrets.R"))
        )
      }
    )
    testthat::test_that(
      paste(text, "deletes the listed files and emptied folders"),
      {
        testthat::expect_message(
          .TemplateRemove(path = root, root = template, check = FALSE),
          regexp = "Not deleted"
        )
        for (x in c(
          ".devcontainer",
          ".setup/cran",
          ".setup/bin",
          ".setup/latex/apa7",
          ".setup/scripts/secrets.R"
        )) {
          testthat::expect_false(file.exists(file.path(root, x)))
        }
        # a folder with a file the template does not know stays
        testthat::expect_true(
          file.exists(file.path(root, ".setup", "coverage", ".covrignore"))
        )
        testthat::expect_true(
          file.exists(file.path(root, ".setup", "scripts", "project.R"))
        )
      }
    )
    testthat::test_that(
      paste(text, "keeps .setup/bin with a script"),
      {
        put(".setup/bin/.gitignore", content = character(0))
        put(".setup/bin/make-bin.R")
        suppressMessages(
          .TemplateRemove(path = root, root = template, check = FALSE)
        )
        testthat::expect_true(
          file.exists(file.path(root, ".setup", "bin", "make-bin.R"))
        )
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-template-remove"
)

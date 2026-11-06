## ---- test-rProject-ai
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    write <- function(root, file, text) {
      dir.create(
        path = dirname(path = file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    # a manuscript with a simulation, and an image in project.R
    root <- file.path(tempfile(pattern = "ai"), "manTest")
    write(root = root, file = ".setup/scripts/project.R", text = c(
      "project <- \"manTest\"",
      "ai <- list()"
    ))
    write(
      root = root,
      file = ".setup/latex/manTest-manuscript-EDIT-THIS.Rtex",
      text = "x"
    )
    write(root = root, file = ".sim/sim.R", text = "x <- 1")
    write(root = root, file = ".sim/README.md", text = "# Simulation")
    written <- suppressMessages(expr = AI(path = root))
    agents <- readLines(con = file.path(root, "AGENTS.md"))
    testthat::test_that(
      paste(text, "detects types and fills the templates"),
      {
        testthat::expect_true(
          object = all(
            file.exists(
              file.path(
                root,
                c(
                  "AGENTS.md",
                  "CLAUDE.md",
                  ".github/copilot-instructions.md",
                  ".setup/ai/project.md",
                  ".setup/todo/todo.txt",
                  ".setup/todo/.gitignore"
                )
              )
            )
          )
        )
        testthat::expect_true(object = "# manTest" %in% agents)
        testthat::expect_true(
          object = any(
            grepl(
              pattern = "Type: manuscript, simulation",
              x = agents,
              fixed = TRUE
            )
          )
        )
        testthat::expect_true(
          object = any(
            grepl(pattern = "the user chooses it", x = agents, fixed = TRUE)
          )
        )
        testthat::expect_true(object = "## Manuscript" %in% agents)
        testthat::expect_true(object = "## Simulation" %in% agents)
        testthat::expect_false(object = "## Talk" %in% agents)
        testthat::expect_false(
          object = any(grepl(pattern = "{{", x = agents, fixed = TRUE))
        )
        testthat::expect_equal(
          object = readLines(con = file.path(root, "CLAUDE.md"))[3:4],
          expected = c("@AGENTS.md", "@.setup/ai/project.md")
        )
      }
    )
    testthat::test_that(
      paste(text, "never overwrites project.md and skips unchanged files"),
      {
        project_md <- file.path(root, ".setup", "ai", "project.md")
        writeLines(text = "my notes", con = project_md)
        again <- suppressMessages(expr = AI(path = root))
        testthat::expect_equal(
          object = readLines(con = project_md),
          expected = "my notes"
        )
        testthat::expect_length(object = again, n = 0L)
      }
    )
    testthat::test_that(
      paste(text, "creates .setup/todo/ only if the folder does not exist"),
      {
        todo <- file.path(root, ".setup", "todo")
        testthat::expect_equal(
          object = readLines(con = file.path(todo, "todo.txt")),
          expected = "TODO"
        )
        testthat::expect_equal(
          object = readLines(con = file.path(todo, ".gitignore")),
          expected = "*"
        )
        testthat::expect_true(
          object = any(
            grepl(pattern = "`.setup/todo/`", x = agents, fixed = TRUE)
          )
        )
        # the user's list is kept
        writeLines(text = "1. my item", con = file.path(todo, "todo.txt"))
        suppressMessages(expr = AI(path = root))
        testthat::expect_equal(
          object = readLines(con = file.path(todo, "todo.txt")),
          expected = "1. my item"
        )
        # an existing folder is left alone, even without todo.txt
        unlink(x = file.path(todo, c("todo.txt", ".gitignore")))
        suppressMessages(expr = AI(path = root))
        testthat::expect_false(
          object = file.exists(file.path(todo, "todo.txt"))
        )
        testthat::expect_false(
          object = file.exists(file.path(todo, ".gitignore"))
        )
      }
    )
    testthat::test_that(
      paste(text, "follows the type argument and guesses other projects"),
      {
        suppressMessages(expr = AI(path = root, type = "talk"))
        agents <- readLines(con = file.path(root, "AGENTS.md"))
        testthat::expect_true(object = "## Talk" %in% agents)
        testthat::expect_false(object = "## Manuscript" %in% agents)
        testthat::expect_equal(
          object = .AIType(path = tempdir(), project = "lib-2010-2019-article"),
          expected = "library"
        )
        testthat::expect_equal(
          object = .AIType(path = tempdir(), project = "fitVARMxID"),
          expected = "package"
        )
        # cran-* folder; .sim/ with only the template's files
        cran <- file.path(tempfile(pattern = "ai"), "cran-fitVARMxID")
        dir.create(path = file.path(cran, ".sim"), recursive = TRUE)
        writeLines(text = "#!/bin/bash", con = file.path(cran, ".sim/make.sh"))
        writeLines(text = "*", con = file.path(cran, ".sim/.gitignore"))
        testthat::expect_equal(
          object = .AIType(path = cran, project = "fitVARMxID"),
          expected = c("package", "cran")
        )
        # a script alone is not a simulation; .sim/README.md is
        writeLines(text = "x <- 1", con = file.path(cran, ".sim/sim.R"))
        testthat::expect_equal(
          object = .AIType(path = cran, project = "fitVARMxID"),
          expected = c("package", "cran")
        )
        writeLines(
          text = "# Simulation",
          con = file.path(cran, ".sim/README.md")
        )
        testthat::expect_equal(
          object = .AIType(path = cran, project = "fitVARMxID"),
          expected = c("simulation", "package", "cran")
        )
        write(
          root = cran,
          file = ".setup/scripts/project.R",
          text = "project <- \"fitVARMxID\""
        )
        suppressMessages(expr = AI(path = cran, type = c("package", "cran")))
        agents <- readLines(con = file.path(cran, "AGENTS.md"))
        testthat::expect_true(
          object = all(c("## Package", "## CRAN") %in% agents)
        )
      }
    )
    testthat::test_that(
      paste(text, "writes a container section and where the project lives"),
      {
        docker <- file.path(dirname(path = root), "docker-001-tidyverse")
        private <- "jeksterslab-psu/docker-001-tidyverse"
        write(
          root = docker,
          file = ".setup/scripts/project.R",
          text = "project <- \"docker-tidyverse\""
        )
        write(
          root = docker,
          file = ".setup/repo/private-github.md",
          text = private
        )
        write(
          root = docker,
          file = ".setup/repo/public-github.md",
          text = "ijapesigan/docker-tidyverse"
        )
        suppressMessages(expr = AI(path = docker))
        agents <- readLines(con = file.path(docker, "AGENTS.md"))
        testthat::expect_true(
          object = any(
            grepl(pattern = "Type: container", x = agents, fixed = TRUE)
          )
        )
        testthat::expect_true(object = "## Container image" %in% agents)
        testthat::expect_true(
          object = any(
            grepl(pattern = paste0("`", private, "`"), x = agents, fixed = TRUE)
          )
        )
        testthat::expect_true(
          object = any(
            grepl(
              pattern = "`ijapesigan/docker-tidyverse`",
              x = agents,
              fixed = TRUE
            )
          )
        )
        testthat::expect_true(
          object = any(
            grepl(
              pattern = "Overleaf project: not recorded",
              x = agents,
              fixed = TRUE
            )
          )
        )
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-ai"
)

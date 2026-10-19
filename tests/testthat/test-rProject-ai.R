## ---- test-rProject-ai
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    write <- function(root, file, text) {
      dir.create(
        dirname(file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    # a manuscript with a simulation, and an image in project.R
    root <- file.path(tempfile(pattern = "ai"), "manTest")
    write(root, ".setup/scripts/project.R", c(
      "project <- \"manTest\"",
      "ai <- list()"
    ))
    write(root, ".setup/latex/manTest-manuscript-EDIT-THIS.Rtex", "x")
    write(root, ".sim/sim.R", "x <- 1")
    write(root, ".sim/README.md", "# Simulation")
    written <- suppressMessages(AI(path = root))
    agents <- readLines(file.path(root, "AGENTS.md"))
    testthat::test_that(
      paste(text, "detects types and fills the templates"),
      {
        testthat::expect_true(
          all(
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
        testthat::expect_true("# manTest" %in% agents)
        testthat::expect_true(
          any(grepl("Type: manuscript, simulation", agents, fixed = TRUE))
        )
        testthat::expect_true(
          any(grepl("the user chooses it", agents, fixed = TRUE))
        )
        testthat::expect_true("## Manuscript" %in% agents)
        testthat::expect_true("## Simulation" %in% agents)
        testthat::expect_false("## Talk" %in% agents)
        testthat::expect_false(any(grepl("{{", agents, fixed = TRUE)))
        testthat::expect_equal(
          readLines(file.path(root, "CLAUDE.md"))[3:4],
          c("@AGENTS.md", "@.setup/ai/project.md")
        )
      }
    )
    testthat::test_that(
      paste(text, "never overwrites project.md and skips unchanged files"),
      {
        project_md <- file.path(root, ".setup", "ai", "project.md")
        writeLines(text = "my notes", con = project_md)
        again <- suppressMessages(AI(path = root))
        testthat::expect_equal(readLines(project_md), "my notes")
        testthat::expect_length(again, 0L)
      }
    )
    testthat::test_that(
      paste(text, "creates .setup/todo/ only if the folder does not exist"),
      {
        todo <- file.path(root, ".setup", "todo")
        testthat::expect_equal(readLines(file.path(todo, "todo.txt")), "TODO")
        testthat::expect_equal(readLines(file.path(todo, ".gitignore")), "*")
        testthat::expect_true(
          any(grepl("`.setup/todo/`", agents, fixed = TRUE))
        )
        # the user's list is kept
        writeLines(text = "1. my item", con = file.path(todo, "todo.txt"))
        suppressMessages(AI(path = root))
        testthat::expect_equal(
          readLines(file.path(todo, "todo.txt")),
          "1. my item"
        )
        # an existing folder is left alone, even without todo.txt
        unlink(file.path(todo, c("todo.txt", ".gitignore")))
        suppressMessages(AI(path = root))
        testthat::expect_false(file.exists(file.path(todo, "todo.txt")))
        testthat::expect_false(file.exists(file.path(todo, ".gitignore")))
      }
    )
    testthat::test_that(
      paste(text, "follows the type argument and guesses other projects"),
      {
        suppressMessages(AI(path = root, type = "talk"))
        agents <- readLines(file.path(root, "AGENTS.md"))
        testthat::expect_true("## Talk" %in% agents)
        testthat::expect_false("## Manuscript" %in% agents)
        testthat::expect_equal(
          .AIType(path = tempdir(), project = "lib-2010-2019-article"),
          "library"
        )
        testthat::expect_equal(
          .AIType(path = tempdir(), project = "fitVARMxID"),
          "package"
        )
        # cran-* folder; .sim/ with only the template's files
        cran <- file.path(tempfile(pattern = "ai"), "cran-fitVARMxID")
        dir.create(file.path(cran, ".sim"), recursive = TRUE)
        writeLines(text = "#!/bin/bash", con = file.path(cran, ".sim/make.sh"))
        writeLines(text = "*", con = file.path(cran, ".sim/.gitignore"))
        testthat::expect_equal(
          .AIType(path = cran, project = "fitVARMxID"),
          c("package", "cran")
        )
        # a script alone is not a simulation; .sim/README.md is
        writeLines(text = "x <- 1", con = file.path(cran, ".sim/sim.R"))
        testthat::expect_equal(
          .AIType(path = cran, project = "fitVARMxID"),
          c("package", "cran")
        )
        writeLines(
          text = "# Simulation",
          con = file.path(cran, ".sim/README.md")
        )
        testthat::expect_equal(
          .AIType(path = cran, project = "fitVARMxID"),
          c("simulation", "package", "cran")
        )
        write(cran, ".setup/scripts/project.R", "project <- \"fitVARMxID\"")
        suppressMessages(AI(path = cran, type = c("package", "cran")))
        agents <- readLines(file.path(cran, "AGENTS.md"))
        testthat::expect_true(all(c("## Package", "## CRAN") %in% agents))
      }
    )
    testthat::test_that(
      paste(text, "writes a container section and where the project lives"),
      {
        docker <- file.path(dirname(root), "docker-001-tidyverse")
        private <- "jeksterslab-psu/docker-001-tidyverse"
        write(
          docker,
          ".setup/scripts/project.R",
          "project <- \"docker-tidyverse\""
        )
        write(docker, ".setup/repo/private-github.md", private)
        write(
          docker,
          ".setup/repo/public-github.md",
          "ijapesigan/docker-tidyverse"
        )
        suppressMessages(AI(path = docker))
        agents <- readLines(file.path(docker, "AGENTS.md"))
        testthat::expect_true(
          any(grepl("Type: container", agents, fixed = TRUE))
        )
        testthat::expect_true("## Container image" %in% agents)
        testthat::expect_true(
          any(grepl(paste0("`", private, "`"), agents, fixed = TRUE))
        )
        testthat::expect_true(
          any(grepl("`ijapesigan/docker-tidyverse`", agents, fixed = TRUE))
        )
        testthat::expect_true(
          any(grepl("Overleaf project: not recorded", agents, fixed = TRUE))
        )
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-ai"
)

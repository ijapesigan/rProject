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
                  ".setup/ai/project.md"
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

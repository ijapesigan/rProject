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
      dir.create(file.path(root, ".setup", "repo"))
      writeLines(
        text = "ijapesigan/test",
        con = file.path(root, ".setup", "repo", "public-github.md")
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
          all(file.exists(manifest$source[manifest$kind == "file"]))
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
    linked <- file.path(root, ".setup", "latex", "preamble", "preamble.tex")
    dir.create(dirname(linked), recursive = TRUE, showWarnings = FALSE)
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
    testthat::test_that(
      paste(text, "fills the project and its public repository"),
      {
        clone <- readLines(file.path(root, ".setup", "scripts", "clone.sh"))
        testthat::expect_true(
          "git clone \"git@github.com:ijapesigan/test.git\"" %in% clone
        )
        testthat::expect_true("rm -rf \"test\"" %in% clone)
        lib <- project(type = "lib")
        suppressMessages(Template(path = lib))
        quarto <- readLines(file.path(lib, ".setup", "quarto", "_quarto.yml"))
        testthat::expect_true("  title: \"test\"" %in% quarto)
        testthat::expect_true(
          "  site-url: https://ijapesigan.github.io/test/index.html" %in% quarto
        )
        # without a public repository, clone.sh is not written
        unlink(file.path(lib, ".setup", "repo"), recursive = TRUE)
        unlink(file.path(lib, ".setup", "scripts", "clone.sh"))
        testthat::expect_message(
          Template(path = lib),
          regexp = "No public repository"
        )
        testthat::expect_false(
          file.exists(file.path(lib, ".setup", "scripts", "clone.sh"))
        )
        unlink(lib, recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "keeps a folder's own .gitignore"),
      {
        own <- file.path(root, ".setup", "cpp", ".gitignore")
        writeLines(text = "*.o", con = own)
        suppressMessages(Template(path = root))
        testthat::expect_equal(readLines(own), "*.o")
      }
    )
    unlink(root, recursive = TRUE)
    docker <- project(type = "docker")
    cat(
      c(
        "workflows <- c(\"docker-build-push-daily-multi\")",
        "workflow_daily <- \"docs\"",
        "workflow_title <- \"Docker Build and Push Docs [multi] (Daily)\"",
        "workflow_cron <- \"30 3 * * *\""
      ),
      file = file.path(docker, ".setup", "scripts", "project.R"),
      sep = "\n",
      append = TRUE
    )
    testthat::test_that(
      paste(text, "fills the daily workflow"),
      {
        suppressMessages(Template(path = docker))
        daily <- readLines(
          file.path(
            docker,
            ".github",
            "workflows",
            "docker-build-push-daily-multi-docs.yml"
          )
        )
        testthat::expect_true(
          "name: Docker Build and Push Docs [multi] (Daily)" %in% daily
        )
        testthat::expect_true("    - cron: \"30 3 * * *\"" %in% daily)
        testthat::expect_false(any(grepl("{{title}}", daily, fixed = TRUE)))
        testthat::expect_length(
          suppressMessages(Template(path = docker, check = TRUE)),
          0L
        )
      }
    )
    chain <- function(lines) {
      writeLines(
        text = c(
          "type <- \"docker\"",
          "workflows <- \"docker-build-push-daily-multi\"",
          "workflow_daily <- \"x\"",
          "workflow_title <- \"Daily\"",
          lines
        ),
        con = file.path(docker, ".setup", "scripts", "project.R")
      )
      suppressMessages(Template(path = docker))
      readLines(
        file.path(
          docker,
          ".github",
          "workflows",
          "docker-build-push-daily-multi-x.yml"
        )
      )
    }
    testthat::test_that(
      paste(text, "chains the daily builds"),
      {
        # the head: a schedule and the next image
        head <- chain(
          c(
            "workflow_cron <- \"0 0 * * *\"",
            "workflow_next <- \"ijapesigan/docker-dplyr\""
          )
        )
        testthat::expect_true("  schedule:" %in% head)
        testthat::expect_true("  repository_dispatch:" %in% head)
        testthat::expect_true(
          any(
            grepl(
              "repos/ijapesigan/docker-dplyr/dispatches",
              head,
              fixed = TRUE
            )
          )
        )
        step <- which(head == "      - name: Trigger the next image")
        testthat::expect_equal(head[step + 1], "        run: |")
        testthat::expect_true(any(grepl("{{version}}", head, fixed = TRUE)))
        # a middle image: no schedule
        middle <- chain("workflow_next <- \"ijapesigan/docker-sem\"")
        testthat::expect_false("  schedule:" %in% middle)
        testthat::expect_true("  repository_dispatch:" %in% middle)
        # the last image: neither, and no stray placeholder lines
        last <- chain(character(0))
        testthat::expect_false(any(grepl("dispatches", last, fixed = TRUE)))
        testthat::expect_false(
          any(grepl(pattern = "\\{\\{(title|schedule|next)\\}\\}", x = last))
        )
        testthat::expect_true(
          grepl(pattern = "imagetools inspect", x = last[length(last)])
        )
        testthat::expect_length(
          suppressMessages(Template(path = docker, check = TRUE)),
          0L
        )
      }
    )
    testthat::test_that(
      paste(text, "stops on an invalid workflow_next"),
      {
        testthat::expect_error(
          chain("workflow_next <- \"docker-dplyr\""),
          regexp = "owner/repository"
        )
      }
    )
    testthat::test_that(
      paste(text, "stops when the daily workflow has no title"),
      {
        writeLines(
          text = c(
            "type <- \"docker\"",
            "workflows <- \"docker-build-push-daily-multi\""
          ),
          con = file.path(docker, ".setup", "scripts", "project.R")
        )
        testthat::expect_error(
          Template(path = docker),
          regexp = "workflow_title"
        )
      }
    )
    unlink(docker, recursive = TRUE)
    Sys.setenv(GITHUB_ACTIONS = github_actions)
  },
  text = "test-rProject-template"
)

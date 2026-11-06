## ---- test-rProject-template
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    project <- function(type) {
      root <- tempfile(pattern = "template")
      dir.create(
        path = file.path(root, ".setup", "scripts"),
        recursive = TRUE
      )
      writeLines(
        text = c(
          "project <- \"test\"",
          paste0("type <- \"", type, "\"")
        ),
        con = file.path(root, ".setup", "scripts", "project.R")
      )
      dir.create(path = file.path(root, ".setup", "repo"))
      writeLines(
        text = "ijapesigan/test",
        con = file.path(root, ".setup", "repo", "public-github.md")
      )
      root
    }
    # CI sets GITHUB_ACTIONS, where Template() writes nothing
    github_actions <- Sys.getenv(x = "GITHUB_ACTIONS")
    Sys.setenv(GITHUB_ACTIONS = "false")
    testthat::test_that(
      paste(text, "manifest paths are not dot-encoded"),
      {
        manifest <- .TemplateFiles(type = "cran")
        all_paths <- unlist(
          x = lapply(
            X = names(x = .TemplateSets()),
            FUN = function(type) {
              .TemplateFiles(type = type)$path
            }
          )
        )
        testthat::expect_false(
          object = any(grepl(pattern = "(^|/)dot-", x = all_paths))
        )
        testthat::expect_true(
          object = all(file.exists(manifest$source[manifest$kind == "file"]))
        )
      }
    )
    for (type in setdiff(x = names(x = .TemplateSets()), y = "rProject")) {
      root <- project(type = type)
      files <- .TemplateFiles(type = type)
      all_files <- files$path
      pending <- suppressMessages(
        expr = Template(path = root, check = TRUE)
      )
      testthat::test_that(
        paste(text, type, "check writes nothing"),
        {
          testthat::expect_equal(
            object = sort(x = pending),
            expected = sort(x = all_files)
          )
          testthat::expect_false(
            object = any(file.exists(file.path(root, all_files)))
          )
        }
      )
      written <- suppressMessages(
        expr = Template(path = root)
      )
      testthat::test_that(
        paste(text, type, "writes every template file"),
        {
          testthat::expect_equal(
            object = sort(x = written),
            expected = sort(x = all_files)
          )
          testthat::expect_true(
            object = all(file.exists(file.path(root, all_files)))
          )
          testthat::expect_length(
            object = suppressMessages(
              expr = Template(path = root, check = TRUE)
            ),
            n = 0L
          )
        }
      )
      unlink(x = root, recursive = TRUE)
    }
    root <- project(type = "cran")
    suppressMessages(expr = Template(path = root))
    edited <- file.path(root, ".github", "workflows", "make.yml")
    writeLines(text = "edited", con = edited)
    linked <- file.path(root, ".setup", "latex", "preamble", "preamble.tex")
    dir.create(
      path = dirname(path = linked),
      recursive = TRUE,
      showWarnings = FALSE
    )
    writeLines(text = "old", con = linked)
    testthat::test_that(
      paste(text, "names and overwrites an edited file"),
      {
        testthat::expect_message(
          object = Template(path = root),
          regexp = "Overwritten"
        )
        testthat::expect_false(
          object = identical(
            x = readLines(con = edited, warn = FALSE),
            y = "edited"
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "names a differing kept file for upload and writes it"),
      {
        writeLines(text = "old", con = linked)
        testthat::expect_message(
          object = Template(path = root),
          regexp = "To upload to Overleaf"
        )
        testthat::expect_false(
          object = identical(x = readLines(con = linked), y = "old")
        )
      }
    )
    testthat::test_that(
      paste(text, "does nothing in GitHub Actions"),
      {
        writeLines(text = "edited", con = edited)
        Sys.setenv(GITHUB_ACTIONS = "true")
        suppressMessages(expr = Template(path = root))
        Sys.setenv(GITHUB_ACTIONS = "false")
        testthat::expect_equal(
          object = readLines(con = edited),
          expected = "edited"
        )
      }
    )
    testthat::test_that(
      paste(text, "writes nothing without a type"),
      {
        bare <- tempfile(pattern = "template")
        dir.create(path = bare)
        testthat::expect_length(
          object = suppressMessages(expr = Template(path = bare)),
          n = 0L
        )
        testthat::expect_length(object = list.files(path = bare), n = 0L)
        unlink(x = bare, recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "stops on an unknown type"),
      {
        testthat::expect_error(
          object = Template(path = project(type = "other"))
        )
      }
    )
    testthat::test_that(
      paste(text, "maps the type for AI()"),
      {
        testthat::expect_equal(
          object = .AIType(path = root, project = "test"),
          expected = c("package", "cran")
        )
      }
    )
    testthat::test_that(
      paste(text, "fills the project and its public repository"),
      {
        clone <- readLines(
          con = file.path(root, ".setup", "scripts", "clone.sh")
        )
        testthat::expect_true(
          object = "git clone \"git@${host}:ijapesigan/test.git\"" %in% clone
        )
        testthat::expect_true(
          object = "  host=\"github-ijapesigan\"" %in% clone
        )
        testthat::expect_true(object = "rm -rf \"test\"" %in% clone)
        lib <- project(type = "lib")
        suppressMessages(expr = Template(path = lib))
        quarto <- readLines(
          con = file.path(lib, ".setup", "quarto", "_quarto.yml")
        )
        testthat::expect_true(object = "  title: \"test\"" %in% quarto)
        testthat::expect_true(
          object = paste0(
            "  site-url: https://ijapesigan.github.io/test/",
            "index.html"
          ) %in% quarto
        )
        # without a public repository, clone.sh is not written
        unlink(x = file.path(lib, ".setup", "repo"), recursive = TRUE)
        unlink(x = file.path(lib, ".setup", "scripts", "clone.sh"))
        testthat::expect_message(
          object = Template(path = lib),
          regexp = "No public repository"
        )
        testthat::expect_false(
          object = file.exists(file.path(lib, ".setup", "scripts", "clone.sh"))
        )
        unlink(x = lib, recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "keeps a folder's own .gitignore"),
      {
        own <- file.path(root, ".setup", "cpp", ".gitignore")
        writeLines(text = "*.o", con = own)
        suppressMessages(expr = Template(path = root))
        testthat::expect_equal(object = readLines(con = own), expected = "*.o")
      }
    )
    unlink(x = root, recursive = TRUE)
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
        suppressMessages(expr = Template(path = docker))
        daily <- readLines(
          con = file.path(
            docker,
            ".github",
            "workflows",
            "docker-build-push-daily-multi-docs.yml"
          )
        )
        testthat::expect_true(
          object = "name: Docker Build and Push Docs [multi] (Daily)" %in% daily
        )
        testthat::expect_true(object = "    - cron: \"30 3 * * *\"" %in% daily)
        testthat::expect_false(
          object = any(grepl(pattern = "{{title}}", x = daily, fixed = TRUE))
        )
        testthat::expect_length(
          object = suppressMessages(
            expr = Template(path = docker, check = TRUE)
          ),
          n = 0L
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
      suppressMessages(expr = Template(path = docker))
      readLines(
        con = file.path(
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
        testthat::expect_true(object = "  schedule:" %in% head)
        testthat::expect_true(object = "  repository_dispatch:" %in% head)
        testthat::expect_true(
          object = any(
            grepl(
              pattern = "repos/ijapesigan/docker-dplyr/dispatches",
              x = head,
              fixed = TRUE
            )
          )
        )
        step <- which(x = head == "      - name: Trigger the next image")
        testthat::expect_equal(
          object = head[step + 1],
          expected = "        run: |"
        )
        testthat::expect_true(
          object = any(grepl(pattern = "{{version}}", x = head, fixed = TRUE))
        )
        # a middle image: no schedule
        middle <- chain("workflow_next <- \"ijapesigan/docker-sem\"")
        testthat::expect_false(object = "  schedule:" %in% middle)
        testthat::expect_true(object = "  repository_dispatch:" %in% middle)
        # the last image: neither, and no stray placeholder lines
        last <- chain(character(length = 0))
        testthat::expect_false(
          object = any(grepl(pattern = "dispatches", x = last, fixed = TRUE))
        )
        testthat::expect_false(
          object = any(
            grepl(pattern = "\\{\\{(title|schedule|next)\\}\\}", x = last)
          )
        )
        testthat::expect_true(
          object = grepl(
            pattern = "imagetools inspect",
            x = last[length(x = last)]
          )
        )
        testthat::expect_length(
          object = suppressMessages(
            expr = Template(path = docker, check = TRUE)
          ),
          n = 0L
        )
      }
    )
    testthat::test_that(
      paste(text, "stops on an invalid workflow_next"),
      {
        testthat::expect_error(
          object = chain("workflow_next <- \"docker-dplyr\""),
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
          object = Template(path = docker),
          regexp = "workflow_title"
        )
      }
    )
    unlink(x = docker, recursive = TRUE)
    Sys.setenv(GITHUB_ACTIONS = github_actions)
  },
  text = "test-rProject-template"
)

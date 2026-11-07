## ---- test-rProject-config-files
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "installs, backs up, and checks"),
      code = {
        testthat::skip_on_os(os = "windows")
        script <- system.file(
          "shell",
          "install-dotfiles.sh",
          package = "rProject"
        )
        testthat::skip_if(condition = !nzchar(x = script))
        home <- tempfile(pattern = "home")
        dir.create(path = home)
        on.exit(
          expr = unlink(x = home, recursive = TRUE),
          add = TRUE
        )
        writeLines(text = "old", con = file.path(home, ".bashrc"))
        run <- function(...) {
          system2(
            command = "bash",
            args = c(.ShellQuote(x = script), ...),
            env = c(paste0("HOME=", home), "PATH=/usr/bin:/bin:/nogit"),
            stdout = TRUE,
            stderr = TRUE
          )
        }
        check <- run("--check")
        testthat::expect_true(
          object = any(grepl(pattern = "nothing changed", x = check))
        )
        testthat::expect_identical(
          object = readLines(con = file.path(home, ".bashrc")),
          expected = "old"
        )
        testthat::expect_false(object = file.exists(file.path(home, ".vimrc")))
      }
    )
    testthat::test_that(
      desc = paste(text, "lists only its own files"),
      code = {
        script <- system.file(
          "shell",
          "install-dotfiles.sh",
          package = "rProject"
        )
        testthat::skip_if(condition = !nzchar(x = script))
        lines <- readLines(con = script, warn = FALSE)
        pairs <- trimws(
          x = grep(pattern = "^  \"[a-z]+/", x = lines, value = TRUE)
        )
        testthat::expect_gt(object = length(x = pairs), expected = 10)
        testthat::expect_false(
          object = any(
            grepl(
              pattern = "secret|gitconfig|ssh",
              x = pairs,
              ignore.case = TRUE
            )
          )
        )
        sources <- sub(
          pattern = "^\"([^ ]+) .*$",
          replacement = "\\1",
          x = pairs
        )
        testthat::expect_true(
          object = all(
            file.exists(
              file.path(
                dirname(path = dirname(path = script)),
                "dotfiles",
                sources
              )
            )
          )
        )
      }
    )
  },
  text = "test-rProject-config-files"
)

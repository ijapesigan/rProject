## ---- test-rProject-install-tools
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    shell <- function() {
      system.file("shell", package = "rProject")
    }
    run <- function(home, code) {
      system2(
        command = "bash",
        args = c(
          "-c",
          shQuote(string = paste0("source install-common.sh; ", code))
        ),
        env = paste0("HOME=", home),
        stdout = TRUE,
        stderr = TRUE
      )
    }
    in_shell <- function(code) {
      old <- setwd(dir = shell())
      on.exit(expr = setwd(dir = old), add = TRUE)
      force(x = code)
    }
    testthat::test_that(
      desc = paste(text, "links a tool into ~/work/tools"),
      code = {
        testthat::skip_on_os(os = "windows")
        testthat::skip_if(condition = !nzchar(x = shell()))
        home <- tempfile(pattern = "home")
        dir.create(path = file.path(home, "work"), recursive = TRUE)
        dir.create(path = file.path(home, ".local", "bin"), recursive = TRUE)
        on.exit(expr = unlink(x = home, recursive = TRUE), add = TRUE)
        tool <- file.path(home, ".local", "bin", "tool")
        writeLines(text = "new", con = tool)
        in_shell(code = run(home = home, code = "link_tool .local/bin/tool"))
        testthat::expect_true(object = nzchar(x = Sys.readlink(paths = tool)))
        testthat::expect_identical(
          object = readLines(
            con = file.path(home, "work", "tools", ".local", "bin", "tool")
          ),
          expected = "new"
        )
        # a new file replaces the old copy
        unlink(x = tool)
        writeLines(text = "newer", con = tool)
        in_shell(code = run(home = home, code = "link_tool .local/bin/tool"))
        testthat::expect_identical(
          object = readLines(con = tool),
          expected = "newer"
        )
        # an empty folder for an installer to write through
        in_shell(code = run(home = home, code = "link_tool .codex/packages"))
        testthat::expect_true(
          object = nzchar(
            x = Sys.readlink(paths = file.path(home, ".codex", "packages"))
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "stays in ~/.local without ~/work"),
      code = {
        testthat::skip_on_os(os = "windows")
        testthat::skip_if(condition = !nzchar(x = shell()))
        home <- tempfile(pattern = "home")
        dir.create(path = file.path(home, ".local", "bin"), recursive = TRUE)
        on.exit(expr = unlink(x = home, recursive = TRUE), add = TRUE)
        tool <- file.path(home, ".local", "bin", "tool")
        writeLines(text = "new", con = tool)
        in_shell(code = run(home = home, code = "link_tool .local/bin/tool"))
        testthat::expect_false(object = nzchar(x = Sys.readlink(paths = tool)))
      }
    )
    testthat::test_that(
      desc = paste(text, "has a script for each tool in install.sh"),
      code = {
        testthat::skip_if(condition = !nzchar(x = shell()))
        lines <- readLines(con = file.path(shell(), "install.sh"), warn = FALSE)
        sets <- grep(pattern = "^(machine|cli)=\\(", x = lines, value = TRUE)
        tools <- unlist(
          x = strsplit(
            x = gsub(pattern = "^[a-z]+=\\(|\\)$", replacement = "", x = sets),
            split = " ",
            fixed = TRUE
          )
        )
        testthat::expect_true(object = "antigravity" %in% tools)
        testthat::expect_false(object = "gemini" %in% tools)
        testthat::expect_true(
          object = all(
            file.exists(file.path(shell(), paste0("install-", tools, ".sh")))
          )
        )
      }
    )
  },
  text = "test-rProject-install-tools"
)

## ---- test-rProject-repo-info
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject(name = "lib-2010-2019-article")
    writeLines(
      text = c(
        "#!/bin/bash",
        "",
        "git clone git@github.com:ijapesigan/lib-2010-2019-article.git"
      ),
      con = file.path(root, ".setup", "scripts", "clone.sh")
    )
    testthat::test_that(
      desc = paste(text, "reads NA when .setup/repo is missing"),
      code = {
        info <- .RepoInfo(path = root)
        testthat::expect_true(object = is.na(x = info$private_github))
        testthat::expect_true(object = is.na(x = info$public_github))
        testthat::expect_false(object = attr(x = info, which = "public_none"))
      }
    )
    testthat::test_that(
      desc = paste(text, "finds the public repository in clone.sh"),
      code = {
        testthat::expect_equal(
          object = .RepoInfoClone(path = root),
          expected = "ijapesigan/lib-2010-2019-article"
        )
      }
    )
    written <- suppressMessages(expr = .RepoInfoWrite(path = root))
    testthat::test_that(
      desc = paste(text, "creates .setup/repo with the GitHub repositories"),
      code = {
        testthat::expect_length(object = written, n = 3L)
        testthat::expect_equal(
          object = readLines(
            con = file.path(root, ".setup", "repo", ".gitignore")
          ),
          expected = c("*", "*/")
        )
        info <- .RepoInfo(path = root)
        testthat::expect_equal(
          object = info$private_github,
          expected = "jeksterslab-psu/lib-2010-2019-article"
        )
        testthat::expect_equal(
          object = info$public_github,
          expected = "ijapesigan/lib-2010-2019-article"
        )
        testthat::expect_true(object = is.na(x = info$private_overleaf))
      }
    )
    testthat::test_that(
      desc = paste(text, "never overwrites .setup/repo"),
      code = {
        writeLines(
          text = "owner/other",
          con = file.path(root, ".setup", "repo", "private-github.md")
        )
        testthat::expect_length(object = .RepoInfoWrite(path = root), n = 0L)
        testthat::expect_equal(
          object = .RepoInfo(path = root)$private_github,
          expected = "owner/other"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "reads none as no public copy, and trims lines"),
      code = {
        cat(
          "none",
          file = file.path(root, ".setup", "repo", "public-github.md")
        )
        writeLines(
          text = c(
            "  https://www.overleaf.com/project/0123456789abcdef01234567  ",
            ""
          ),
          con = file.path(root, ".setup", "repo", "private-overleaf.md")
        )
        info <- .RepoInfo(path = root)
        testthat::expect_true(object = is.na(x = info$public_github))
        testthat::expect_true(object = attr(x = info, which = "public_none"))
        testthat::expect_equal(
          object = info$private_overleaf,
          expected = "https://www.overleaf.com/project/0123456789abcdef01234567"
        )
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-repo-info"
)

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
      paste(text, "reads NA when .setup/repo is missing"),
      {
        info <- .RepoInfo(path = root)
        testthat::expect_true(is.na(info$private_github))
        testthat::expect_true(is.na(info$public_github))
        testthat::expect_false(attr(info, "public_none"))
      }
    )
    testthat::test_that(
      paste(text, "finds the public repository in clone.sh"),
      {
        testthat::expect_equal(
          .RepoInfoClone(path = root),
          "ijapesigan/lib-2010-2019-article"
        )
      }
    )
    written <- suppressMessages(.RepoInfoWrite(path = root))
    testthat::test_that(
      paste(text, "creates .setup/repo with the GitHub repositories"),
      {
        testthat::expect_length(written, 3L)
        testthat::expect_equal(
          readLines(file.path(root, ".setup", "repo", ".gitignore")),
          c("*", "*/")
        )
        info <- .RepoInfo(path = root)
        testthat::expect_equal(
          info$private_github,
          "jeksterslab-psu/lib-2010-2019-article"
        )
        testthat::expect_equal(
          info$public_github,
          "ijapesigan/lib-2010-2019-article"
        )
        testthat::expect_true(is.na(info$private_overleaf))
      }
    )
    testthat::test_that(
      paste(text, "never overwrites .setup/repo"),
      {
        writeLines(
          text = "owner/other",
          con = file.path(root, ".setup", "repo", "private-github.md")
        )
        testthat::expect_length(.RepoInfoWrite(path = root), 0L)
        testthat::expect_equal(
          .RepoInfo(path = root)$private_github,
          "owner/other"
        )
      }
    )
    testthat::test_that(
      paste(text, "reads none as no public copy, and trims lines"),
      {
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
        testthat::expect_true(is.na(info$public_github))
        testthat::expect_true(attr(info, "public_none"))
        testthat::expect_equal(
          info$private_overleaf,
          "https://www.overleaf.com/project/0123456789abcdef01234567"
        )
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-repo-info"
)

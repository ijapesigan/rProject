## ---- test-rProject-lock
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    testthat::test_that(
      paste(text, "writes the commit and version"),
      {
        out <- suppressMessages(
          .LockWrite(path = root, sha = "abc1234def", version = "0.0.56")
        )
        lock <- new.env()
        sys.source(file = out, envir = lock)
        testthat::expect_equal(lock$rproject_sha, "abc1234def")
        testthat::expect_equal(lock$rproject_version, "0.0.56")
      }
    )
    testthat::test_that(
      paste(text, "writes the image, snapshot, and extras"),
      {
        digest <- paste0("sha256:", strrep("b", 64))
        out <- suppressMessages(
          .LockWrite(
            path = root,
            sha = "abc1234def",
            version = "0.0.57",
            sif = list(
              kind = "public",
              image = "docker.io/ijapesigan/docs",
              digest = digest,
              created = "2026-10-22"
            ),
            r_version = "4.5.1",
            extra_cran = c(betaDelta = "1.0.6"),
            extra_github = c("jeksterslab/betaMC" = "deadbeef")
          )
        )
        lock <- new.env()
        sys.source(file = out, envir = lock)
        testthat::expect_equal(
          lock$image,
          paste0("docker.io/ijapesigan/docs@", digest)
        )
        testthat::expect_equal(lock$image_name, "docker.io/ijapesigan/docs")
        testthat::expect_equal(lock$snapshot, "2026-10-22")
        testthat::expect_equal(lock$r_version, "4.5.1")
        testthat::expect_equal(lock$extra_cran, c(betaDelta = "1.0.6"))
        testthat::expect_equal(
          lock$extra_github,
          c("jeksterslab/betaMC" = "deadbeef")
        )
        testthat::expect_false(exists("sif_sha256", envir = lock))
        testthat::expect_equal(.LockRead(path = root)$snapshot, "2026-10-22")
      }
    )
    testthat::test_that(
      paste(text, "records an add-on sif and an image without a digest"),
      {
        out <- suppressMessages(
          .LockWrite(
            path = root,
            sha = "abc1234def",
            version = "0.0.57",
            sif = list(
              kind = "addon",
              image = "docker.io/ijapesigan/manmetavar",
              digest = NA_character_,
              created = NA_character_,
              source = "https://github.com/ijapesigan/docker-manmetavar-mplus",
              proprietary = "mplus",
              sif = "/sif/manmetavar-plus.sif",
              built = "2026-10-07"
            ),
            sif_sha256 = "cafe"
          )
        )
        lock <- new.env()
        sys.source(file = out, envir = lock)
        testthat::expect_equal(lock$image, "docker.io/ijapesigan/manmetavar")
        testthat::expect_true(is.na(lock$snapshot))
        testthat::expect_equal(lock$image_local, "manmetavar-plus.sif")
        testthat::expect_equal(lock$image_local_proprietary, "mplus")
        testthat::expect_equal(lock$sif_sha256, "cafe")
        testthat::expect_equal(lock$sif_built, "2026-10-07")
        testthat::expect_length(lock$extra_cran, 0)
      }
    )
    testthat::test_that(
      paste(text, "reads the extras from project.R"),
      {
        project_r <- file.path(root, ".setup", "scripts", "project.R")
        writeLines(
          text = c(
            "pkg_cran <- c(\"utils\", \"notInstalledPkg\")",
            "pkg_github <- c(\"owner/notInstalledPkg@main\")"
          ),
          con = project_r
        )
        extra <- .LockExtra(path = root)
        testthat::expect_equal(
          extra$cran[["utils"]],
          as.character(utils::packageVersion("utils"))
        )
        testthat::expect_true(is.na(extra$cran[["notInstalledPkg"]]))
        testthat::expect_equal(names(extra$github), "owner/notInstalledPkg")
        unlink(project_r)
      }
    )
    testthat::test_that(
      paste(text, "writes nothing without a commit"),
      {
        unlink(file.path(root, ".setup", "scripts", "rproject.lock"))
        testthat::expect_message(
          .LockWrite(path = root, sha = NA_character_, version = "0.0.56"),
          regexp = "no lock"
        )
        testthat::expect_false(
          file.exists(file.path(root, ".setup", "scripts", "rproject.lock"))
        )
      }
    )
    testthat::test_that(
      paste(text, "writes no lock in rProject itself"),
      {
        cat(
          "type <- \"rProject\"\n",
          file = file.path(root, ".setup", "scripts", "project.R"),
          append = TRUE
        )
        testthat::expect_null(suppressMessages(Lock(path = root)))
      }
    )
    testthat::test_that(
      paste(text, "writes no lock in a docker project"),
      {
        writeLines(
          text = "type <- \"docker\"",
          con = file.path(root, ".setup", "scripts", "project.R")
        )
        testthat::expect_null(suppressMessages(Lock(path = root)))
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-lock"
)

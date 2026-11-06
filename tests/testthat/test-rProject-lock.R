## ---- test-rProject-lock
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    testthat::test_that(
      desc = paste(text, "writes the commit and version"),
      code = {
        out <- suppressMessages(
          expr = .LockWrite(path = root, sha = "abc1234def", version = "0.0.56")
        )
        lock <- new.env()
        sys.source(file = out, envir = lock)
        testthat::expect_equal(
          object = lock$rproject_sha,
          expected = "abc1234def"
        )
        testthat::expect_equal(
          object = lock$rproject_version,
          expected = "0.0.56"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "writes the image, snapshot, and extras"),
      code = {
        digest <- paste0("sha256:", strrep(x = "b", times = 64))
        out <- suppressMessages(
          expr = .LockWrite(
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
          object = lock$image,
          expected = paste0("docker.io/ijapesigan/docs@", digest)
        )
        testthat::expect_equal(
          object = lock$image_name,
          expected = "docker.io/ijapesigan/docs"
        )
        testthat::expect_equal(object = lock$snapshot, expected = "2026-10-21")
        testthat::expect_equal(object = lock$r_version, expected = "4.5.1")
        testthat::expect_equal(
          object = lock$extra_cran,
          expected = c(betaDelta = "1.0.6")
        )
        testthat::expect_equal(
          object = lock$extra_github,
          expected = c("jeksterslab/betaMC" = "deadbeef")
        )
        testthat::expect_false(object = exists(x = "sif_sha256", envir = lock))
        testthat::expect_equal(
          object = .LockRead(path = root)$snapshot,
          expected = "2026-10-21"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "records an add-on sif and an image without a digest"),
      code = {
        out <- suppressMessages(
          expr = .LockWrite(
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
        testthat::expect_equal(
          object = lock$image,
          expected = "docker.io/ijapesigan/manmetavar"
        )
        testthat::expect_true(object = is.na(x = lock$snapshot))
        testthat::expect_equal(
          object = lock$image_local,
          expected = "manmetavar-plus.sif"
        )
        testthat::expect_equal(
          object = lock$image_local_proprietary,
          expected = "mplus"
        )
        testthat::expect_equal(object = lock$sif_sha256, expected = "cafe")
        testthat::expect_equal(object = lock$sif_built, expected = "2026-10-07")
        testthat::expect_length(object = lock$extra_cran, n = 0)
      }
    )
    testthat::test_that(
      desc = paste(text, "reads the extras from project.R"),
      code = {
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
          object = extra$cran[["utils"]],
          expected = as.character(x = utils::packageVersion(pkg = "utils"))
        )
        testthat::expect_true(
          object = is.na(x = extra$cran[["notInstalledPkg"]])
        )
        testthat::expect_equal(
          object = names(x = extra$github),
          expected = "owner/notInstalledPkg"
        )
        unlink(x = project_r)
      }
    )
    testthat::test_that(
      desc = paste(text, "writes nothing without a commit"),
      code = {
        unlink(x = file.path(root, ".setup", "scripts", "rproject.lock"))
        testthat::expect_message(
          object = .LockWrite(
            path = root,
            sha = NA_character_,
            version = "0.0.56"
          ),
          regexp = "no lock"
        )
        testthat::expect_false(
          object = file.exists(
            file.path(root, ".setup", "scripts", "rproject.lock")
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "writes no lock in rProject itself"),
      code = {
        cat(
          "type <- \"rProject\"\n",
          file = file.path(root, ".setup", "scripts", "project.R"),
          append = TRUE
        )
        testthat::expect_null(
          object = suppressMessages(expr = Lock(path = root))
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "writes no lock in a docker project"),
      code = {
        writeLines(
          text = "type <- \"docker\"",
          con = file.path(root, ".setup", "scripts", "project.R")
        )
        testthat::expect_null(
          object = suppressMessages(expr = Lock(path = root))
        )
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-lock"
)

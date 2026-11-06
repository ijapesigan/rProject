## ---- test-rProject-sif-info
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    dir <- tempfile(pattern = "sif")
    dir.create(path = dir)
    fake <- function(name, labels, def) {
      json <- file.path(dir, paste0(name, ".json"))
      writeLines(
        text = c(
          "{",
          paste0(
            "  \"", names(x = labels), "\": \"", labels, "\"",
            c(rep(x = ",", length(x = labels) - 1), "")
          ),
          "}"
        ),
        con = json
      )
      deffile <- file.path(dir, paste0(name, ".def"))
      writeLines(text = def, con = deffile)
      .SifInfo(labels = json, deffile = deffile, sif = "")
    }
    base <- "org.opencontainers.image."
    digest <- paste0("sha256:", strrep(x = "a", times = 64))
    testthat::test_that(
      desc = paste(text, "reads a public image pulled by tag"),
      code = {
        out <- fake(
          name = "docs",
          labels = stats::setNames(
            object = c(
              "docker.io/ijapesigan/docs:latest", digest,
              "2026-10-22T16:33:24.104Z",
              "https://github.com/ijapesigan/docker-docs",
              "https://github.com/ijapesigan/docker-docs"
            ),
            nm = paste0(
              base,
              c("base.name", "base.digest", "created", "source", "url")
            )
          ),
          def = c("bootstrap: docker", "from: ijapesigan/docs:latest")
        )
        testthat::expect_equal(object = out$kind, expected = "public")
        testthat::expect_equal(
          object = out$image,
          expected = "docker.io/ijapesigan/docs"
        )
        testthat::expect_equal(object = out$digest, expected = digest)
        testthat::expect_equal(object = out$created, expected = "2026-10-22")
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "reads an add-on built from the public sif (localimage)"
      ),
      code = {
        out <- fake(
          name = "docs-plus",
          labels = stats::setNames(
            object = c(
              "docker.io/ijapesigan/docs:latest", digest,
              "https://github.com/ijapesigan/docker-docs-mplus",
              "https://github.com/ijapesigan/docker-docs"
            ),
            nm = paste0(base, c("base.name", "base.digest", "source", "url"))
          ),
          def = c("Bootstrap: localimage", "From: /sif/docs.sif")
        )
        testthat::expect_equal(object = out$kind, expected = "addon")
        testthat::expect_equal(
          object = out$image,
          expected = "docker.io/ijapesigan/docs"
        )
        testthat::expect_equal(object = out$digest, expected = digest)
        testthat::expect_equal(object = out$proprietary, expected = "unknown")
      }
    )
    testthat::test_that(
      desc = paste(text, "finds the public image of a docker-daemon add-on"),
      code = {
        out <- fake(
          name = "manmetavar",
          labels = stats::setNames(
            object = c(
              "docker.io/library/ubuntu:noble",
              "https://github.com/ijapesigan/docker-manmetavar-mplus",
              "https://github.com/ijapesigan/docker-manmetavar"
            ),
            nm = paste0(base, c("base.name", "source", "url"))
          ),
          def = c("bootstrap: docker-daemon", "from: manmetavar:latest")
        )
        testthat::expect_equal(object = out$kind, expected = "addon")
        testthat::expect_equal(
          object = out$image,
          expected = "docker.io/ijapesigan/manmetavar"
        )
        testthat::expect_true(object = is.na(x = out$digest))
        out <- fake(
          name = "manculta",
          labels = stats::setNames(
            object = c(
              "docker.io/library/ubuntu:noble",
              "https://github.com/ijapesigan/docker-manculta-mplus"
            ),
            nm = paste0(base, c("base.name", "source"))
          ),
          def = c("bootstrap: docker-daemon", "from: manculta:latest")
        )
        testthat::expect_equal(
          object = out$image,
          expected = "docker.io/ijapesigan/manculta"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "reads the proprietary label and a digest in From"),
      code = {
        out <- fake(
          name = "pinned",
          labels = stats::setNames(
            object = "mplus",
            nm = "io.github.ijapesigan.proprietary"
          ),
          def = c("Bootstrap: docker", paste0("From: ijapesigan/x@", digest))
        )
        testthat::expect_equal(object = out$kind, expected = "addon")
        testthat::expect_equal(
          object = out$image,
          expected = "docker.io/ijapesigan/x"
        )
        testthat::expect_equal(object = out$digest, expected = digest)
        testthat::expect_equal(object = out$proprietary, expected = "mplus")
      }
    )
    testthat::test_that(
      desc = paste(text, "outside a container"),
      code = {
        out <- .SifInfo(
          labels = file.path(dir, "none.json"),
          deffile = file.path(dir, "none.def"),
          sif = ""
        )
        testthat::expect_equal(object = out$kind, expected = "none")
        testthat::expect_true(object = is.na(x = out$image))
      }
    )
    unlink(x = dir, recursive = TRUE)
  },
  text = "test-rProject-sif-info"
)

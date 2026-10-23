## ---- test-rProject-sif-info
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    dir <- tempfile(pattern = "sif")
    dir.create(dir)
    fake <- function(name, labels, def) {
      json <- file.path(dir, paste0(name, ".json"))
      writeLines(
        text = c(
          "{",
          paste0(
            "  \"", names(labels), "\": \"", labels, "\"",
            c(rep(",", length(labels) - 1), "")
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
    digest <- paste0("sha256:", strrep("a", 64))
    testthat::test_that(
      paste(text, "reads a public image pulled by tag"),
      {
        out <- fake(
          name = "docs",
          labels = stats::setNames(
            c(
              "docker.io/ijapesigan/docs:latest", digest,
              "2026-10-22T16:33:24.104Z",
              "https://github.com/ijapesigan/docker-docs",
              "https://github.com/ijapesigan/docker-docs"
            ),
            paste0(
              base,
              c("base.name", "base.digest", "created", "source", "url")
            )
          ),
          def = c("bootstrap: docker", "from: ijapesigan/docs:latest")
        )
        testthat::expect_equal(out$kind, "public")
        testthat::expect_equal(out$image, "docker.io/ijapesigan/docs")
        testthat::expect_equal(out$digest, digest)
        testthat::expect_equal(out$created, "2026-10-22")
      }
    )
    testthat::test_that(
      paste(text, "reads an add-on built from the public sif (localimage)"),
      {
        out <- fake(
          name = "docs-plus",
          labels = stats::setNames(
            c(
              "docker.io/ijapesigan/docs:latest", digest,
              "https://github.com/ijapesigan/docker-docs-mplus",
              "https://github.com/ijapesigan/docker-docs"
            ),
            paste0(base, c("base.name", "base.digest", "source", "url"))
          ),
          def = c("Bootstrap: localimage", "From: /sif/docs.sif")
        )
        testthat::expect_equal(out$kind, "addon")
        testthat::expect_equal(out$image, "docker.io/ijapesigan/docs")
        testthat::expect_equal(out$digest, digest)
        testthat::expect_equal(out$proprietary, "unknown")
      }
    )
    testthat::test_that(
      paste(text, "finds the public image of a docker-daemon add-on"),
      {
        out <- fake(
          name = "manmetavar",
          labels = stats::setNames(
            c(
              "docker.io/library/ubuntu:noble",
              "https://github.com/ijapesigan/docker-manmetavar-mplus",
              "https://github.com/ijapesigan/docker-manmetavar"
            ),
            paste0(base, c("base.name", "source", "url"))
          ),
          def = c("bootstrap: docker-daemon", "from: manmetavar:latest")
        )
        testthat::expect_equal(out$kind, "addon")
        testthat::expect_equal(out$image, "docker.io/ijapesigan/manmetavar")
        testthat::expect_true(is.na(out$digest))
        out <- fake(
          name = "manculta",
          labels = stats::setNames(
            c(
              "docker.io/library/ubuntu:noble",
              "https://github.com/ijapesigan/docker-manculta-mplus"
            ),
            paste0(base, c("base.name", "source"))
          ),
          def = c("bootstrap: docker-daemon", "from: manculta:latest")
        )
        testthat::expect_equal(out$image, "docker.io/ijapesigan/manculta")
      }
    )
    testthat::test_that(
      paste(text, "reads the proprietary label and a digest in From"),
      {
        out <- fake(
          name = "pinned",
          labels = stats::setNames(
            "mplus",
            "io.github.ijapesigan.proprietary"
          ),
          def = c("Bootstrap: docker", paste0("From: ijapesigan/x@", digest))
        )
        testthat::expect_equal(out$kind, "addon")
        testthat::expect_equal(out$image, "docker.io/ijapesigan/x")
        testthat::expect_equal(out$digest, digest)
        testthat::expect_equal(out$proprietary, "mplus")
      }
    )
    testthat::test_that(
      paste(text, "outside a container"),
      {
        out <- .SifInfo(
          labels = file.path(dir, "none.json"),
          deffile = file.path(dir, "none.def"),
          sif = ""
        )
        testthat::expect_equal(out$kind, "none")
        testthat::expect_true(is.na(out$image))
      }
    )
    unlink(dir, recursive = TRUE)
  },
  text = "test-rProject-sif-info"
)

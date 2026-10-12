## ---- test-rProject-log-image
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    labels <- tempfile(fileext = ".json")
    writeLines(
      text = c(
        "{",
        "  \"org.label-schema.build-date\": \"Sunday_11_October_2026\",",
        "  \"org.opencontainers.image.base.digest\": \"sha256:64b60b5393308d35e1\"",
        "}"
      ),
      con = labels
    )
    saved <- Sys.getenv(c("APPTAINER_NAME", "SINGULARITY_NAME"))
    testthat::test_that(
      paste(text, "records the image that ran"),
      {
        Sys.setenv(APPTAINER_NAME = "manmetavar.sif")
        testthat::expect_equal(
          .LogImage(labels = labels),
          paste0(
            "- Image: `manmetavar.sif` (built Sunday_11_October_2026; ",
            "base sha256:64b60b539330)"
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "says when it did not run in a container"),
      {
        Sys.unsetenv(c("APPTAINER_NAME", "SINGULARITY_NAME"))
        testthat::expect_equal(
          .LogImage(labels = labels),
          "- Image: not run inside a container"
        )
      }
    )
    testthat::test_that(
      paste(text, "reports unknown labels"),
      {
        Sys.setenv(APPTAINER_NAME = "docs.sif")
        testthat::expect_match(
          .LogImage(labels = tempfile()),
          "built unknown; base unknown"
        )
      }
    )
    Sys.unsetenv(c("APPTAINER_NAME", "SINGULARITY_NAME"))
    do.call(what = Sys.setenv, args = as.list(saved[nzchar(saved)]))
    unlink(labels)
  },
  text = "test-rProject-log-image"
)

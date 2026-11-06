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
        paste0(
          "  \"org.opencontainers.image.base.digest\": ",
          "\"sha256:64b60b5393308d35e1\""
        ),
        "}"
      ),
      con = labels
    )
    saved <- Sys.getenv(x = c("APPTAINER_NAME", "SINGULARITY_NAME"))
    testthat::test_that(
      desc = paste(text, "records the image that ran"),
      code = {
        Sys.setenv(APPTAINER_NAME = "manmetavar.sif")
        testthat::expect_equal(
          object = .LogImage(labels = labels),
          expected = paste0(
            "- Image: `manmetavar.sif` (built Sunday_11_October_2026; ",
            "base sha256:64b60b539330)"
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "says when it did not run in a container"),
      code = {
        Sys.unsetenv(x = c("APPTAINER_NAME", "SINGULARITY_NAME"))
        testthat::expect_equal(
          object = .LogImage(labels = labels),
          expected = "- Image: not run inside a container"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "reports unknown labels"),
      code = {
        Sys.setenv(APPTAINER_NAME = "docs.sif")
        testthat::expect_match(
          object = .LogImage(labels = tempfile()),
          regexp = "built unknown; base unknown"
        )
      }
    )
    Sys.unsetenv(x = c("APPTAINER_NAME", "SINGULARITY_NAME"))
    # restore only what was set (Sys.setenv() with no arguments is an error)
    if (any(nzchar(x = saved))) {
      do.call(what = Sys.setenv, args = as.list(x = saved[nzchar(x = saved)]))
    }
    unlink(x = labels)
  },
  text = "test-rProject-log-image"
)

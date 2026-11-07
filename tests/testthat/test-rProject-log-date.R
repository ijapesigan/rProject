## ---- test-rProject-log-date
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "gives the local date of an evening push"),
      code = {
        evening <- as.POSIXct(x = "2026-11-08 02:30:00", tz = "UTC")
        testthat::expect_identical(
          object = .LogDate(time = evening, tz = "America/New_York"),
          expected = "2026-11-07"
        )
        testthat::expect_identical(
          object = .LogDate(time = evening, tz = "UTC"),
          expected = "2026-11-08"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "takes the time zone from RPROJECT_TZ"),
      code = {
        evening <- as.POSIXct(x = "2026-11-08 02:30:00", tz = "UTC")
        old <- Sys.getenv(x = "RPROJECT_TZ", unset = NA)
        on.exit(
          expr = if (is.na(x = old)) {
            Sys.unsetenv(x = "RPROJECT_TZ")
          } else {
            Sys.setenv(RPROJECT_TZ = old)
          },
          add = TRUE
        )
        Sys.setenv(RPROJECT_TZ = "UTC")
        testthat::expect_identical(
          object = .LogDate(time = evening),
          expected = "2026-11-08"
        )
      }
    )
  },
  text = "test-rProject-log-date"
)

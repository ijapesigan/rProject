## ---- test-rProject-snapshot-date
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "is the day before the image's date"),
      {
        testthat::expect_equal(
          .SnapshotDate(created = "2026-11-02"),
          "2026-11-01"
        )
        testthat::expect_equal(
          .SnapshotDate(created = c("2026-03-01", "2024-03-01", "2026-01-01")),
          c("2026-02-28", "2024-02-29", "2025-12-31")
        )
      }
    )
    testthat::test_that(
      paste(text, "is NA without a date"),
      {
        testthat::expect_equal(
          .SnapshotDate(created = c(NA_character_, "latest", "")),
          rep(x = NA_character_, times = 3)
        )
      }
    )
  },
  text = "test-rProject-snapshot-date"
)

## ---- test-rProject-install-local
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "has an install script for every app"),
      {
        apps <- eval(expr = formals(fun = InstallLocal)$what)
        scripts <- vapply(
          X = apps,
          FUN = function(app) {
            system.file(
              "shell",
              paste0("install-", app, ".sh"),
              package = "rProject"
            )
          },
          FUN.VALUE = character(length = 1)
        )
        testthat::expect_true(object = all(nzchar(x = scripts)))
      }
    )
    testthat::test_that(
      paste(text, "ignores unknown apps"),
      {
        testthat::expect_null(object = InstallLocal(what = "not-an-app"))
      }
    )
  },
  text = "test-rProject-install-local"
)

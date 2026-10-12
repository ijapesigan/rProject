## ---- test-rProject-project
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if_not_installed("rprojroot")
    state <- .TestState()
    root <- .TestProject()
    # Project() finds project.Rproj from the working directory, as in
    # make project, which runs in the project folder
    wd <- setwd(root)
    utils::capture.output(Project(path = root))
    setwd(wd)
    rproj <- readLines(file.path(root, "project.Rproj"))
    testthat::test_that(
      paste(text, "writes project.Rproj for a package"),
      {
        testthat::expect_true("BuildType: Package" %in% rproj)
        testthat::expect_true("NumSpacesForTab: 2" %in% rproj)
        testthat::expect_true(
          "PackageRoxygenize: rd,collate,namespace" %in% rproj
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-project"
)

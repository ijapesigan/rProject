## ---- test-rProject-project
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if_not_installed(pkg = "rprojroot")
    state <- .TestState()
    root <- .TestProject()
    # Project() finds project.Rproj from the working directory, as in
    # make project, which runs in the project folder
    wd <- setwd(dir = root)
    utils::capture.output(Project(path = root))
    setwd(dir = wd)
    rproj <- readLines(con = file.path(root, "project.Rproj"))
    testthat::test_that(
      paste(text, "writes project.Rproj for a package"),
      {
        testthat::expect_true(object = "BuildType: Package" %in% rproj)
        testthat::expect_true(object = "NumSpacesForTab: 2" %in% rproj)
        testthat::expect_true(
          object = "PackageRoxygenize: rd,collate,namespace" %in% rproj
        )
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-project"
)
